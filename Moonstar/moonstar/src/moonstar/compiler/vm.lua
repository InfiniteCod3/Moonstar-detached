local Ast = require("moonstar.ast");
local Scope = require("moonstar.scope");
local AstKind = Ast.AstKind;
local util = require("moonstar.util");
local randomStrings = require("moonstar.randomStrings")

local lookupify = util.lookupify;

local VmGen = {}

function VmGen.emitContainerFuncBody(compiler)
    -- OPTIMIZATION: Block Merging (Super Blocks) with Aggressive Inlining (P2)
    -- Merge linear sequences of blocks to reduce dispatch overhead
    -- P2 enhancements: Loop detection, aggressive single-predecessor inlining, depth limiting
    do
        local blockMap = {}
        local inDegree = {}
        local outEdge = {} -- block -> targetId (if unconditional)
        local allEdges = {} -- block -> list of targetIds (for loop detection)

        -- Map blocks and initialize in-degrees
        for _, block in ipairs(compiler.blocks) do
            blockMap[block.id] = block
            inDegree[block.id] = 0
            allEdges[block.id] = {}
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

        -- Helper to collect all jump targets from an expression
        local function collectTargets(expr, targets)
            if not expr then return end
            if expr.kind == AstKind.NumberExpression then
                table.insert(targets, expr.value)
            elseif expr.kind == AstKind.BinaryExpression or
                   expr.kind == AstKind.OrExpression or
                   expr.kind == AstKind.AndExpression then
                collectTargets(expr.lhs, targets)
                collectTargets(expr.rhs, targets)
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
                        table.insert(allEdges[block.id], targetId)
                    else
                        -- Conditional Jump
                        scanTargets(val)
                        collectTargets(val, allEdges[block.id])
                    end
                end
            end
        end

        -- P2: Loop Detection using DFS to find back-edges
        -- A back-edge is an edge from a block to an ancestor in DFS tree
        local loopBlocks = {} -- Set of block IDs that are part of loops (hot blocks)
        do
            local visited = {}
            local inStack = {}
            local loopHeaders = {} -- Blocks that are targets of back-edges

            local function dfs(blockId)
                if visited[blockId] then return end
                visited[blockId] = true
                inStack[blockId] = true

                local edges = allEdges[blockId]
                if edges then
                    for _, targetId in ipairs(edges) do
                        if inStack[targetId] then
                            -- Back-edge found: targetId is a loop header
                            loopHeaders[targetId] = true
                        elseif not visited[targetId] then
                            dfs(targetId)
                        end
                    end
                end

                inStack[blockId] = false
            end

            -- Start DFS from start block
            dfs(compiler.startBlockId)

            -- Mark all blocks reachable from loop headers as hot
            -- Simple approach: mark the loop header and all blocks that can reach it
            local function markLoopBlocks(headerId)
                local reachable = {}
                local queue = {headerId}
                local processed = {}

                while #queue > 0 do
                    local current = table.remove(queue, 1)
                    if not processed[current] then
                        processed[current] = true
                        reachable[current] = true
                        loopBlocks[current] = true

                        -- Add predecessors (blocks that jump to current)
                        for bid, edges in pairs(allEdges) do
                            for _, tid in ipairs(edges) do
                                if tid == current and not processed[bid] and bid ~= headerId then
                                    table.insert(queue, bid)
                                end
                            end
                        end
                    end
                end
            end

            for headerId, _ in pairs(loopHeaders) do
                markLoopBlocks(headerId)
            end
        end

        -- Perform Merging with P2 aggressive inlining
        local changed = true
        local mergedBlocks = {} -- Set of IDs that have been merged (and thus removed)
        local inlineDepth = {} -- Track inline depth per block to prevent exponential growth
        
        -- P2 Configuration (from compiler config)
        local MAX_INLINE_DEPTH = compiler.maxInlineDepth or 10
        local NORMAL_INLINE_THRESHOLD = compiler.inlineThresholdNormal or 12
        local HOT_INLINE_THRESHOLD = compiler.inlineThresholdHot or 25
        local aggressiveInliningEnabled = compiler.enableAggressiveInlining ~= false

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
                        if targetBlock and not mergedBlocks[targetId] and
                           targetId ~= compiler.startBlockId and
                           targetId ~= block.id then

                            -- P2: Check inline depth limit
                            local currentDepth = (inlineDepth[block.id] or 0) + (inlineDepth[targetId] or 0)
                            if currentDepth < MAX_INLINE_DEPTH then

                                -- P2: Single-predecessor blocks are ALWAYS inlined regardless of size
                                local isSinglePredecessor = inDegree[targetId] == 1

                                -- P2: Determine inline threshold based on whether block is hot (if aggressive inlining enabled)
                                local inlineThreshold
                                if aggressiveInliningEnabled and loopBlocks[targetId] then
                                    inlineThreshold = HOT_INLINE_THRESHOLD
                                else
                                    inlineThreshold = NORMAL_INLINE_THRESHOLD
                                end
                                local isSmallBlock = #targetBlock.statements <= inlineThreshold

                                -- P2: Inline if single predecessor (always) OR small block
                                if isSinglePredecessor or isSmallBlock then
                                    -- 1. Remove the jump from block (last statement)
                                    table.remove(block.statements)

                                    -- 2. Append all statements from targetBlock
                                    for _, stat in ipairs(targetBlock.statements) do
                                        table.insert(block.statements, stat)
                                    end

                                    -- 3. Update outEdge for block to point to target's successor
                                    outEdge[block] = outEdge[targetBlock]

                                    -- 4. Track inline depth
                                    inlineDepth[block.id] = currentDepth + 1

                                    -- 5. If it was a single-predecessor merge, mark target as merged
                                    if isSinglePredecessor then
                                        mergedBlocks[targetId] = true
                                    end

                                    changed = true
                                end
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
    
    -- P8: Dead Code Elimination
    -- Optimize by removing unreachable blocks, dead stores, and redundant jumps
    if compiler.enableDeadCodeElimination ~= false then
        local dceChanged = true
        local dceIterations = 0
        local MAX_DCE_ITERATIONS = 5 -- Limit iterations to prevent infinite loops
        
        while dceChanged and dceIterations < MAX_DCE_ITERATIONS do
            dceChanged = false
            dceIterations = dceIterations + 1
            
            -- P8.1: Unreachable Block Detection
            -- Remove blocks with no predecessors (except start block)
            do
                local blockMap = {}
                local hasIncomingEdge = {}
                
                -- Build block map
                for _, block in ipairs(compiler.blocks) do
                    blockMap[block.id] = block
                    hasIncomingEdge[block.id] = false
                end
                
                -- Mark start block as reachable
                hasIncomingEdge[compiler.startBlockId] = true
                
                -- Scan for all jump targets
                local function markReachableTargets(expr)
                    if not expr then return end
                    if expr.kind == AstKind.NumberExpression then
                        local tid = expr.value
                        if blockMap[tid] then
                            hasIncomingEdge[tid] = true
                        end
                    elseif expr.kind == AstKind.BinaryExpression or
                           expr.kind == AstKind.OrExpression or
                           expr.kind == AstKind.AndExpression then
                        markReachableTargets(expr.lhs)
                        markReachableTargets(expr.rhs)
                    end
                end
                
                -- Find all reachable blocks
                for _, block in ipairs(compiler.blocks) do
                    if #block.statements > 0 then
                        local lastStatWrapper = block.statements[#block.statements]
                        if lastStatWrapper.writes[compiler.POS_REGISTER] then
                            local assignStat = lastStatWrapper.statement
                            local val = assignStat.rhs[1]
                            markReachableTargets(val)
                        end
                    end
                end
                
                -- Remove unreachable blocks
                local reachableBlocks = {}
                for _, block in ipairs(compiler.blocks) do
                    if hasIncomingEdge[block.id] then
                        table.insert(reachableBlocks, block)
                    else
                        dceChanged = true
                    end
                end
                compiler.blocks = reachableBlocks
            end
            
            -- P8.2: Dead Store Elimination
            -- Remove register assignments where the value is never read
            do
                for _, block in ipairs(compiler.blocks) do
                    local newStatements = {}
                    for statIndex, statWrapper in ipairs(block.statements) do
                        local isDead = false
                        
                        -- Check if this statement writes to a register (not POS or RETURN)
                        local writtenReg = nil
                        for reg, _ in pairs(statWrapper.writes) do
                            if type(reg) == "number" then
                                writtenReg = reg
                                break
                            end
                        end
                        
                        -- If it writes to a register, check if it's read before next write
                        if writtenReg and not statWrapper.usesUpvals then
                            local isRead = false
                            local isOverwritten = false
                            
                            -- Check remaining statements in this block
                            for i = statIndex + 1, #block.statements do
                                local futureStatWrapper = block.statements[i]
                                if futureStatWrapper.reads[writtenReg] then
                                    isRead = true
                                    break
                                end
                                if futureStatWrapper.writes[writtenReg] then
                                    isOverwritten = true
                                    break
                                end
                            end
                            
                            -- If the register is overwritten without being read, it's a dead store
                            -- Note: We only eliminate if overwritten in same block (conservative)
                            -- Cross-block analysis would require full dataflow analysis
                            if isOverwritten and not isRead then
                                isDead = true
                                dceChanged = true
                            end
                        end
                        
                        if not isDead then
                            table.insert(newStatements, statWrapper)
                        end
                    end
                    block.statements = newStatements
                end
            end
            
            -- P8.3: Redundant Jump Elimination
            -- Remove jumps to the immediately following block
            do
                -- First, sort blocks by ID to determine natural ordering
                local sortedBlocks = {}
                for _, block in ipairs(compiler.blocks) do
                    table.insert(sortedBlocks, block)
                end
                table.sort(sortedBlocks, function(a, b) return a.id < b.id end)
                
                -- Build next-block mapping
                local nextBlockId = {}
                for i = 1, #sortedBlocks - 1 do
                    nextBlockId[sortedBlocks[i].id] = sortedBlocks[i + 1].id
                end
                
                -- Check each block's final jump
                for _, block in ipairs(compiler.blocks) do
                    if #block.statements > 0 then
                        local lastStatWrapper = block.statements[#block.statements]
                        if lastStatWrapper.writes[compiler.POS_REGISTER] then
                            local assignStat = lastStatWrapper.statement
                            local val = assignStat.rhs[1]
                            
                            -- Only eliminate unconditional jumps (NumberExpression)
                            if val.kind == AstKind.NumberExpression then
                                local targetId = val.value
                                -- If jumping to the next sequential block, remove the jump
                                if nextBlockId[block.id] == targetId then
                                    table.remove(block.statements)
                                    dceChanged = true
                                end
                            end
                        end
                    end
                end
            end
        end
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

        -- SECURITY: Dispatch Tree Noise
        -- Add controlled deviation to BST split to prevent pattern matching
        local idealMid = l + math.ceil(len / 2)
        local mid = idealMid
        if compiler.enableInstructionRandomization and len > 4 then
            local maxDeviation = math.floor(len * 0.15)
            if maxDeviation > 0 then
                local deviation = math.random(-maxDeviation, maxDeviation)
                mid = math.max(l + 1, math.min(r, idealMid + deviation))
            end
        end

        -- Use the ID of the block at the split point as the pivot
        -- Blocks < mid go left, Blocks >= mid go right
        local bound = tb[mid].id;

        local ifScope = scope or Scope:new(pScope);

        local lBlock = buildWhileBody(tb, l, mid - 1, ifScope);
        local rBlock = buildWhileBody(tb, mid, r, ifScope);

        return buildIfBlock(ifScope, bound, lBlock, rBlock);
    end

    -- P1: Dispatch Table Mode
    -- Choose dispatch mode based on config and block count
    local useTableDispatch = false
    local blockCount = #blocks
    
    if compiler.vmDispatchMode == "table" then
        useTableDispatch = true
    elseif compiler.vmDispatchMode == "auto" then
        -- Use table dispatch for smaller scripts (< threshold blocks)
        -- Table dispatch has function call overhead per block but O(1) lookup
        -- BST dispatch has O(log N) comparisons but no function call overhead
        useTableDispatch = blockCount < compiler.vmDispatchTableThreshold
    end
    -- vmDispatchMode == "bst" uses the existing BST implementation (useTableDispatch = false)

    local whileBody;
    local dispatchTableVar;
    local dispatchTable;
    
    if useTableDispatch then
        -- P1: Table-based dispatch (O(1) lookup)
        -- Generate: local blocks = { [id1] = function() ... end, [id2] = function() ... end, ... }
        -- while pos do blocks[pos]() end
        
        dispatchTableVar = compiler.containerFuncScope:addVariable();
        
        -- Create table entries for each block
        local tableEntries = {}
        for _, blockData in ipairs(blocks) do
            local blockId = blockData.id
            local blockBody = blockData.block
            
            -- Create a function scope for this block
            local blockFuncScope = Scope:new(compiler.containerFuncScope)
            blockBody.scope:setParent(blockFuncScope)
            
            -- Add references to required variables from containerFuncScope
            blockFuncScope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.returnVar, 1);
            blockFuncScope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.posVar);
            
            -- Create function literal for this block
            local blockFunc = Ast.FunctionLiteralExpression({}, blockBody, false);
            
            -- Create table entry: [blockId] = function() ... end
            table.insert(tableEntries, Ast.KeyedTableEntry(
                Ast.NumberExpression(blockId),
                blockFunc
            ))
        end
        
        -- Store dispatch table for later use in stats
        dispatchTable = Ast.TableConstructorExpression(tableEntries)
        
        -- The while body simply calls the function from the dispatch table
        -- while pos do dispatchTable[pos]() end
        local dispatchScope = Scope:new(compiler.containerFuncScope)
        dispatchScope:addReferenceToHigherScope(compiler.containerFuncScope, dispatchTableVar)
        dispatchScope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.posVar)
        
        whileBody = Ast.Block({
            Ast.FunctionCallStatement(
                Ast.IndexExpression(
                    Ast.VariableExpression(compiler.containerFuncScope, dispatchTableVar),
                    Ast.VariableExpression(compiler.containerFuncScope, compiler.posVar)
                ),
                {}
            )
        }, dispatchScope)
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
            table.insert(declarations, var);
        end
    end

    -- P4: Add spill register variables to declarations
    -- Spill registers are used for registers MAX_REGS to MAX_REGS + SPILL_REGS - 1
    -- They provide faster access than table indexing for these overflow registers
    for spillIndex = 0, compiler.SPILL_REGS - 1 do
        local spillVar = compiler.spillVars[spillIndex]
        if spillVar then
            table.insert(declarations, spillVar)
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
    
    -- P1: Add dispatch table declaration for table dispatch mode
    if useTableDispatch and dispatchTableVar and dispatchTable then
        table.insert(stats, 1, Ast.LocalVariableDeclaration(compiler.containerFuncScope, {dispatchTableVar}, {dispatchTable}));
    end

    -- P4: Only create overflow table for registers beyond spill range (MAX_REGS + SPILL_REGS and above)
    -- Registers 0-149: normal local variables
    -- Registers 150-159: spill local variables (P4 optimization)
    -- Registers 160+: table indexing (overflow)
    if compiler.maxUsedRegister >= compiler.MAX_REGS + compiler.SPILL_REGS then
        -- Ensure registerVars[MAX_REGS] exists before using it (this is the overflow table)
        if not compiler.registerVars[compiler.MAX_REGS] then
            compiler.registerVars[compiler.MAX_REGS] = compiler.containerFuncScope:addVariable();
        end
        table.insert(stats, 1, Ast.LocalVariableDeclaration(compiler.containerFuncScope, {compiler.registerVars[compiler.MAX_REGS]}, {Ast.TableConstructorExpression({})}));
    end

    -- P3: Add hoisted global declarations before the dispatch loop
    local hoistedStats = compiler:emitHoistedGlobals()
    for i = #hoistedStats, 1, -1 do
        table.insert(stats, 1, hoistedStats[i])
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
