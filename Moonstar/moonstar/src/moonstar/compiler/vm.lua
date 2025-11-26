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

                        -- Check valid merge/inline candidate:
                        -- 1. Target exists and hasn't been merged
                        -- 2. Target is not the start block
                        -- 3. Target is not 'block' itself (infinite loop)
                        -- 4. EITHER:
                        --    a) Target has only one predecessor (classic merge)
                        --    b) Target is small (<= 12 statements) and can be inlined (tail duplication)
                        if targetBlock and not mergedBlocks[targetId] and
                           targetId ~= compiler.startBlockId and
                           targetId ~= block.id then

                            local isMergeCandidate = inDegree[targetId] == 1
                            -- Tail Duplication: Inline small blocks even if they have multiple predecessors
                            -- OPTIMIZATION: Increased threshold to 12 to reduce dispatch overhead
                            local isInlineCandidate = #targetBlock.statements <= 12

                            if isMergeCandidate or isInlineCandidate then
                                -- 1. Remove the jump from block (last statement)
                                table.remove(block.statements)

                                -- 2. Append all statements from targetBlock
                                for _, stat in ipairs(targetBlock.statements) do
                                    table.insert(block.statements, stat)
                                end

                                -- 3. Update outEdge for block to point to target's successor
                                outEdge[block] = outEdge[targetBlock]

                                -- 4. If it was a merge, mark target as merged. If just an inline, don't.
                                if isMergeCandidate then
                                    mergedBlocks[targetId] = true
                                end

                                changed = true
                            end
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
    
    -- FEATURE: Junk Blocks (Dead Code Insertion)
    -- Insert 3-6 junk blocks to confuse reverse engineers
    -- These blocks are syntactically valid but unreachable
    for i = 1, math.random(3, 6) do
        VmGen.createJunkBlock(compiler)
    end

    -- FEATURE: Block Cloning (Polymorphism)
    -- Duplicate some blocks and rewire random predecessors to point to the clone
    -- This creates multiple "handlers" (block IDs) for the same logic
    if compiler.enableInstructionRandomization then
        local blockMap = {}
        for _, block in ipairs(compiler.blocks) do
            blockMap[block.id] = block
        end

        -- 1. Build Predecessor Map
        local predecessors = {} -- targetId -> list of {block, statIndex}
        for _, block in ipairs(compiler.blocks) do
            if #block.statements > 0 then
                local lastStatWrapper = block.statements[#block.statements]
                if lastStatWrapper.writes[compiler.POS_REGISTER] then
                    local assignStat = lastStatWrapper.statement
                    local val = assignStat.rhs[1]
                    if val.kind == AstKind.NumberExpression then
                         local tid = val.value
                         if not predecessors[tid] then predecessors[tid] = {} end
                         table.insert(predecessors[tid], {block = block, statIndex = #block.statements})
                    end
                end
            end
        end

        -- 2. Clone Candidates
        local candidates = {}
        for _, block in ipairs(compiler.blocks) do
             -- Only clone small blocks that have multiple predecessors
             if predecessors[block.id] and #predecessors[block.id] >= 2 and #block.statements <= 5 then
                  table.insert(candidates, block)
             end
        end

        -- 3. Perform Cloning
        -- Limit to a few clones to avoid code bloat
        local numClones = math.min(#candidates, math.random(2, 5))
        for i = 1, numClones do
             local original = candidates[math.random(1, #candidates)]
             
             -- Create Clone
             local clone = compiler:createBlock() -- Generates new ID
             -- Copy statements (reuse AST nodes as they are immutable-ish)
             for _, stat in ipairs(original.statements) do
                  table.insert(clone.statements, stat)
             end
             -- Clone should not advance automatically since we copied the jump
             clone.advanceToNextBlock = false 

             -- Rewire ~50% of predecessors to the clone
             local preds = predecessors[original.id]
             if preds then
                 for _, pred in ipairs(preds) do
                      if math.random() > 0.5 then
                           -- Update the jump instruction in the predecessor
                           local jumpStat = pred.block.statements[pred.statIndex].statement
                           jumpStat.rhs[1] = Ast.NumberExpression(clone.id)
                      end
                 end
             end
        end
    end

    local blocks = {};

    -- OPTIMIZATION: Junk blocks removed to reduce dispatch tree depth and cache pressure
    
    -- OPTIMIZATION: Sort blocks by ID to ensure the BST is built over a sorted range
    -- This is critical for the binary search logic to work correctly
    for _, block in ipairs(compiler.blocks) do
        local blockstats = {};
        for i, stat in ipairs(block.statements) do
            table.insert(blockstats, stat.statement);
        end
        table.insert(blocks, { id = block.id, block = Ast.Block(blockstats, block.scope) });
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

        -- OPTIMIZATION: Perfectly Balanced BST
        -- Always split at the exact center to minimize tree depth (O(log N))
        local mid = l + math.ceil(len / 2);

        -- Use the ID of the block at the split point as the pivot
        -- Blocks < mid go left, Blocks >= mid go right
        local bound = tb[mid].id;

        local ifScope = scope or Scope:new(pScope);

        local lBlock = buildWhileBody(tb, l, mid - 1, ifScope);
        local rBlock = buildWhileBody(tb, mid, r, ifScope);

        return buildIfBlock(ifScope, bound, lBlock, rBlock);
    end

    local whileBody;
    -- Standard binary search tree dispatch (if-chain)
    whileBody = buildWhileBody(blocks, 1, #blocks, compiler.containerFuncScope, compiler.whileScope);

    compiler.whileScope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.returnVar, 1);
    compiler.whileScope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.posVar);

    compiler.containerFuncScope:addReferenceToHigherScope(compiler.scope, compiler.unpackVar);

    local declarations = {
        compiler.returnVar,
    }

    for i, var in pairs(compiler.registerVars) do
        if(i ~= compiler.MAX_REGS) then
            table.insert(declarations, var);
        end
    end

    -- OPTIMIZATION: Removed register shuffling
    -- Registers are declared in the order they were allocated/indexed.
    -- This avoids overhead and ensures deterministic behavior.
    local finalDeclarations = declarations

    local stats = {
        Ast.LocalVariableDeclaration(compiler.containerFuncScope, finalDeclarations, {});
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

    if compiler.maxUsedRegister >= compiler.MAX_REGS then
        -- Ensure registerVars[MAX_REGS] exists before using it
        if not compiler.registerVars[compiler.MAX_REGS] then
            compiler.registerVars[compiler.MAX_REGS] = compiler.containerFuncScope:addVariable();
        end
        table.insert(stats, 1, Ast.LocalVariableDeclaration(compiler.containerFuncScope, {compiler.registerVars[compiler.MAX_REGS]}, {Ast.TableConstructorExpression({})}));
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
