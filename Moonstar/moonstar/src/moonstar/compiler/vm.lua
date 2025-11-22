local Ast = require("moonstar.ast");
local Scope = require("moonstar.scope");
local AstKind = Ast.AstKind;
local util = require("moonstar.util");
local randomStrings = require("moonstar.randomStrings")

local lookupify = util.lookupify;

local VmGen = {}

function VmGen.emitContainerFuncBody(compiler)
    -- OPTIMIZATION: Block Merging (Super Blocks)
    -- Merge linear sequences of blocks to reduce dispatch overhead
    do
        local blockMap = {}
        local inDegree = {}
        local outEdge = {} -- block -> targetId (if unconditional)

        -- Map blocks and initialize in-degrees
        for _, block in ipairs(compiler.blocks) do
            blockMap[block.id] = block
            inDegree[block.id] = 0
        end

        -- Helper to scan for jump targets
        local function scanTargets(expr)
            if not expr then return end
            if expr.kind == AstKind.NumberExpression then
                local tid = expr.value
                inDegree[tid] = (inDegree[tid] or 0) + 1
            elseif expr.kind == AstKind.BinaryExpression or
                   expr.kind == AstKind.OrExpression or
                   expr.kind == AstKind.AndExpression then
                scanTargets(expr.lhs)
                scanTargets(expr.rhs)
            end
        end

        -- Analyze Control Flow
        for _, block in ipairs(compiler.blocks) do
            if #block.statements > 0 then
                local lastStatWrapper = block.statements[#block.statements]
                if lastStatWrapper.writes[compiler.POS_REGISTER] then
                    local assignStat = lastStatWrapper.statement
                    local val = assignStat.rhs[1]

                    if val.kind == AstKind.NumberExpression then
                        -- Unconditional Jump
                        local targetId = val.value
                        outEdge[block] = targetId
                        inDegree[targetId] = (inDegree[targetId] or 0) + 1
                    else
                        -- Conditional Jump
                        scanTargets(val)
                    end
                end
            end
        end

        -- Perform Merging
        local changed = true
        local mergedBlocks = {} -- Set of IDs that have been merged (and thus removed)

        while changed do
            changed = false
            for _, block in ipairs(compiler.blocks) do
                if not mergedBlocks[block.id] then
                    local targetId = outEdge[block]
                    if targetId then
                        local targetBlock = blockMap[targetId]

                        -- Check valid merge candidate:
                        -- 1. Target exists and hasn't been merged
                        -- 2. Target is not the start block
                        -- 3. Target has exactly one incoming edge (which must be from 'block')
                        -- 4. Target is not 'block' itself (infinite loop)
                        if targetBlock and not mergedBlocks[targetId] and
                           targetId ~= compiler.startBlockId and
                           inDegree[targetId] == 1 and
                           targetId ~= block.id then

                            -- Merge targetBlock into block

                            -- 1. Remove the jump from block (last statement)
                            table.remove(block.statements)

                            -- 2. Append all statements from targetBlock
                            for _, stat in ipairs(targetBlock.statements) do
                                table.insert(block.statements, stat)
                            end

                            -- 3. Update outEdge for block
                            outEdge[block] = outEdge[targetBlock]

                            -- 4. Mark targetId as merged
                            mergedBlocks[targetId] = true

                            changed = true
                        end
                    end
                end
            end
        end

        -- Rebuild block list
        local newBlocks = {}
        for _, block in ipairs(compiler.blocks) do
            if not mergedBlocks[block.id] then
                table.insert(newBlocks, block)
            end
        end
        compiler.blocks = newBlocks
    end

    local blocks = {};

    -- SECURITY: Inject Junk Blocks (Dead Code)
    -- Add 30-50% junk blocks to dilute real code
    if not (compiler.vmProfile == "array") then -- Junk blocks only work well with BST dispatch
        local realBlockCount = #compiler.blocks;
        local junkCount = math.floor(realBlockCount * 0.4);
        for i = 1, junkCount do
            compiler:createJunkBlock();
        end
    end

    util.shuffle(compiler.blocks);

    for _, block in ipairs(compiler.blocks) do
        local id = block.id;
        local blockstats = block.statements;

        -- Shuffle Blockstats
        for i = 2, #blockstats do
            local stat = blockstats[i];
            local reads = stat.reads;
            local writes = stat.writes;
            local maxShift = 0;
            local usesUpvals = stat.usesUpvals;
            for shift = 1, i - 1 do
                local stat2 = blockstats[i - shift];

                if stat2.usesUpvals and usesUpvals then
                    break;
                end

                local reads2 = stat2.reads;
                local writes2 = stat2.writes;
                local f = true;

                for r, b in pairs(reads2) do
                    if(writes[r]) then
                        f = false;
                        break;
                    end
                end

                if f then
                    for r, b in pairs(writes2) do
                        if(writes[r]) then
                            f = false;
                            break;
                        end
                        if(reads[r]) then
                            f = false;
                            break;
                        end
                    end
                end

                if not f then
                    break
                end

                maxShift = shift;
            end

            local shift = math.random(0, maxShift);
            for j = 1, shift do
                    blockstats[i - j], blockstats[i - j + 1] = blockstats[i - j + 1], blockstats[i - j];
            end
        end

        blockstats = {};
        for i, stat in ipairs(block.statements) do
            table.insert(blockstats, stat.statement);
        end

        table.insert(blocks, { id = id, block = Ast.Block(blockstats, block.scope) });
    end

    table.sort(blocks, function(a, b)
        return a.id < b.id;
    end);

    local function buildIfBlock(scope, id, lBlock, rBlock)
        return Ast.Block({
            Ast.IfStatement(Ast.LessThanExpression(compiler:pos(scope), Ast.NumberExpression(id)), lBlock, {}, rBlock);
        }, scope);
    end

    local function buildWhileBody(tb, l, r, pScope, scope)
        local len = r - l + 1;
        if len == 1 then
            tb[r].block.scope:setParent(pScope);
            return tb[r].block;
        elseif len == 0 then
            return nil;
        end

        -- VUL-2025-001 & VUL-2025-004 FIX: Randomized BST split point
        -- Instead of deterministic midpoint, use randomized split within a range
        local mid;
        if compiler.enableInstructionRandomization and len > 2 then
            -- Calculate a range around the midpoint (±25% variance)
            local center = l + math.ceil(len / 2);
            local variance = math.max(1, math.floor(len * 0.25));
            local min_mid = math.max(l + 1, center - variance);
            local max_mid = math.min(r, center + variance);

            -- Ensure min_mid <= max_mid
            if min_mid <= max_mid then
                mid = math.random(min_mid, max_mid);
            else
                mid = center;  -- Fallback to center if range is invalid
            end
        else
            -- Fallback to standard midpoint for small ranges or when randomization disabled
            mid = l + math.ceil(len / 2);
        end

        -- Ensure valid random range for bound
        local min_bound = tb[mid - 1].id + 1;
        local max_bound = tb[mid].id;
        local bound;
        if min_bound <= max_bound then
            bound = math.random(min_bound, max_bound);
        else
            -- If IDs are too close, use the mid ID directly
            bound = tb[mid].id;
        end

        local ifScope = scope or Scope:new(pScope);

        local lBlock = buildWhileBody(tb, l, mid - 1, ifScope);
        local rBlock = buildWhileBody(tb, mid, r, ifScope);

        return buildIfBlock(ifScope, bound, lBlock, rBlock);
    end

    local whileBody;
    local useArrayDispatch = (compiler.vmProfile == "array");
    local handlerTableDecl; -- Declaration for array dispatch

    if useArrayDispatch then
        -- Array-based dispatch: create a dense handler table (list) with sequential indices
        local handlerVar = compiler.containerFuncScope:addVariable();
        local handlerEntries = {};

        for _, block in ipairs(blocks) do
            local id = block.id;

            -- Ensure block has a valid scope
            if not block.block.scope then
                -- Create a new scope if missing
                block.block.scope = Scope:new(compiler.containerFuncScope);
            else
                -- Set parent scope for the block
                block.block.scope:setParent(compiler.containerFuncScope);
            end

            -- Handler function that executes the block code
            local handlerFunc = Ast.FunctionLiteralExpression({}, block.block);

            -- Add to handler table using sequential indices (dense list)
            -- Since blocks are sorted by ID and IDs are sequential (1..N),
            -- we can use TableEntry instead of KeyedTableEntry
            table.insert(handlerEntries, Ast.TableEntry(handlerFunc));
        end

        -- Create the handler table declaration
        handlerTableDecl = Ast.LocalVariableDeclaration(
            compiler.containerFuncScope,
            {handlerVar},
            {Ast.TableConstructorExpression(handlerEntries)}
        );

        -- Create the dispatch loop: while pos do handlers[pos]() end
        compiler.whileScope:addReferenceToHigherScope(compiler.containerFuncScope, handlerVar);

        local dispatchCall = Ast.FunctionCallStatement(
            Ast.IndexExpression(
                Ast.VariableExpression(compiler.containerFuncScope, handlerVar),
                Ast.VariableExpression(compiler.containerFuncScope, compiler.posVar)
            ),
            {}
        );

        whileBody = Ast.Block({dispatchCall}, compiler.whileScope);
    else
        -- Standard binary search tree dispatch (if-chain)
        whileBody = buildWhileBody(blocks, 1, #blocks, compiler.containerFuncScope, compiler.whileScope);
    end

    compiler.whileScope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.returnVar, 1);
    compiler.whileScope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.posVar);

    compiler.containerFuncScope:addReferenceToHigherScope(compiler.scope, compiler.unpackVar);

    local declarations = {
        compiler.returnVar,
    }

    for i, var in pairs(compiler.registerVars) do
        if(i ~= compiler.MAX_REGS) then
            if not useArrayDispatch then
                table.insert(declarations, var);
            end
        end
    end

    local stats = {
        Ast.LocalVariableDeclaration(compiler.containerFuncScope, util.shuffle(declarations), {});
        Ast.WhileStatement(whileBody, Ast.VariableExpression(compiler.containerFuncScope, compiler.posVar));
        Ast.AssignmentStatement({
            Ast.AssignmentVariable(compiler.containerFuncScope, compiler.posVar)
        }, {
            Ast.LenExpression(Ast.VariableExpression(compiler.containerFuncScope, compiler.detectGcCollectVar))
        }),
        Ast.ReturnStatement{
            Ast.FunctionCallExpression(Ast.VariableExpression(compiler.scope, compiler.unpackVar), {
                Ast.VariableExpression(compiler.containerFuncScope, compiler.returnVar)
            });
        }
    }

    if not useArrayDispatch and compiler.maxUsedRegister >= compiler.MAX_REGS then
        -- Ensure registerVars[MAX_REGS] exists before using it
        if not compiler.registerVars[compiler.MAX_REGS] then
            compiler.registerVars[compiler.MAX_REGS] = compiler.containerFuncScope:addVariable();
        end
        table.insert(stats, 1, Ast.LocalVariableDeclaration(compiler.containerFuncScope, {compiler.registerVars[compiler.MAX_REGS]}, {Ast.TableConstructorExpression({})}));
    end

    -- Insert handler table declaration if using array dispatch
    if useArrayDispatch then
        -- Declare registers table
        table.insert(stats, 1, Ast.LocalVariableDeclaration(compiler.containerFuncScope, {compiler.registersTableVar}, {Ast.TableConstructorExpression({})}));

        if handlerTableDecl then
            -- Must be inserted AFTER registers (index 1) and returnVar (index 2) declarations
            table.insert(stats, 3, handlerTableDecl);
        end
    end

    return Ast.Block(stats, compiler.containerFuncScope);
end

function VmGen.createJunkBlock(compiler)
    -- Generates a dead code block for security (fake control flow)
    -- Uses random valid instructions but is never jumped to
    local block = compiler:createBlock();
    local scope = block.scope;

    -- Generate 3-8 random instructions
    local numInstr = math.random(3, 8);
    for i = 1, numInstr do
        local op = math.random(1, 5);
        -- Use temp registers to avoid corrupting real state (though this block runs nowhere)
        local reg1 = math.random(1, compiler.MAX_REGS-1);
        local reg2 = math.random(1, compiler.MAX_REGS-1);
        local reg3 = math.random(1, compiler.MAX_REGS-1);

        -- We manually construct simple AST nodes to avoid complexity
        -- These references are safe because 'blocks' are processed later
        if op == 1 then -- Add
             table.insert(block.statements, {
                statement = Ast.AssignmentStatement({
                    compiler:registerAssignment(scope, reg1)
                }, {
                    Ast.AddExpression(compiler:register(scope, reg2), compiler:register(scope, reg3))
                }),
                writes = lookupify({reg1}), reads = lookupify({reg2, reg3}), usesUpvals = false
            });
        elseif op == 2 then -- Mul
             table.insert(block.statements, {
                statement = Ast.AssignmentStatement({
                    compiler:registerAssignment(scope, reg1)
                }, {
                    Ast.MulExpression(compiler:register(scope, reg2), Ast.NumberExpression(math.random(1, 100)))
                }),
                writes = lookupify({reg1}), reads = lookupify({reg2}), usesUpvals = false
            });
        elseif op == 3 then -- Set Global (Fake)
             -- We can't easily fake globals safely without risk of crashing if env is strict
             -- So just do local assign
             table.insert(block.statements, {
                statement = Ast.AssignmentStatement({
                    compiler:registerAssignment(scope, reg1)
                }, {
                    Ast.StringExpression(randomStrings.randomString(5))
                }),
                writes = lookupify({reg1}), reads = lookupify({}), usesUpvals = false
            });
        elseif op == 4 then -- Table Create
             table.insert(block.statements, {
                statement = Ast.AssignmentStatement({
                    compiler:registerAssignment(scope, reg1)
                }, {
                    Ast.TableConstructorExpression({})
                }),
                writes = lookupify({reg1}), reads = lookupify({}), usesUpvals = false
            });
        else -- JUMP (Fake)
             -- Jump to itself or random number (harmless since unreachable)
             table.insert(block.statements, {
                statement = compiler:setPos(scope, math.random(0, 100000)),
                writes = lookupify({compiler.POS_REGISTER}), reads = lookupify({}), usesUpvals = false
            });
        end
    end

    -- End with a jump or return to be syntactically valid flow
    table.insert(block.statements, {
        statement = compiler:setPos(scope, nil), -- Random jump
        writes = lookupify({compiler.POS_REGISTER}), reads = lookupify({}), usesUpvals = false
    });

    -- Mark as not advancing so we don't append more to it accidentally
    block.advanceToNextBlock = false;

    return block;
end

return VmGen;
