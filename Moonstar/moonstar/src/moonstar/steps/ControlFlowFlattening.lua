-- This Script is Part of the Moonstar Obfuscator
--
-- ControlFlowFlattening.lua
--
-- This Step flattens control flow by converting linear blocks into a state-machine
-- driven while loop with opaque transitions.

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local Scope = require("moonstar.scope")
local visitast = require("moonstar.visitast")
local util = require("moonstar.util")
local AstKind = Ast.AstKind

local ControlFlowFlattening = Step:extend()
ControlFlowFlattening.Description = "Flattens control flow into a state machine."
ControlFlowFlattening.Name = "Control Flow Flattening"

ControlFlowFlattening.SettingsDescriptor = {
    Enabled = {
        type = "boolean",
        default = true,
    },
    ChunkSize = {
        type = "number",
        default = 3,
        min = 1,
        max = 10,
    },
}

function ControlFlowFlattening:init(settings)
end

function ControlFlowFlattening:apply(ast, pipeline)
    if not self.Enabled then return ast end

    -- We only target Function bodies to avoid flattening the top-level too aggressively
    visitast(ast, function(node, data)
        if node.kind == AstKind.FunctionLiteralExpression or 
           node.kind == AstKind.FunctionDeclaration or 
           node.kind == AstKind.LocalFunctionDeclaration then
            
            local block = node.body
            if #block.statements > self.ChunkSize * 2 then -- Only flatten large enough blocks
                 self:flattenBlock(block)
            end
        end
    end)

    return ast
end

function ControlFlowFlattening:flattenBlock(block)
    local statements = block.statements
    local scope = block.scope
    
    -- 1. Break statements into chunks
    local chunks = {}
    local currentChunk = {}
    
    for i, stat in ipairs(statements) do
        table.insert(currentChunk, stat)
        if #currentChunk >= self.ChunkSize then
            table.insert(chunks, currentChunk)
            currentChunk = {}
        end
    end
    if #currentChunk > 0 then
        table.insert(chunks, currentChunk)
    end

    -- If too few chunks, don't bother
    if #chunks < 2 then return end

    -- 2. Create State Variable
    local stateVar = scope:addVariable()
    local startState = math.random(1, 1000)
    
    -- Assign random IDs to chunks
    local chunkIds = {}
    local sequence = {} -- Logical order of IDs
    for i = 1, #chunks do
        local id = math.random(1, 10000)
        -- Ensure uniqueness
        while util.contains(sequence, id) do id = math.random(1, 10000) end
        chunkIds[i] = id
        table.insert(sequence, id)
    end
    
    -- 3. Create State Machine Body
    -- Structure:
    -- local state = startState
    -- while state != endState do
    --    if state == id1 then ... state = id2
    --    elseif state == id2 then ... state = id3
    --    ...
    -- end

    local loopBodyStats = {}
    local endState = -1

    -- We build an if-elseif chain (or nested ifs for performance/obfuscation)
    -- For simplicity, we'll use a list of IfStatements checking the state
    -- Since we want Opaque Predicates later, simpler is better for now.
    -- Actually, let's build a shuffled if-elseif chain using a helper.
    
    local branches = {}
    
    for i, chunk in ipairs(chunks) do
        local myId = chunkIds[i]
        local nextId = (i < #chunks) and chunkIds[i+1] or endState
        
        -- Append state update to the chunk
        -- We need to clone the chunk's statements into a new block
        local chunkStats = {}
        for _, s in ipairs(chunk) do table.insert(chunkStats, s) end
        
        table.insert(chunkStats, Ast.AssignmentStatement(
            { Ast.AssignmentVariable(scope, stateVar) },
            { Ast.NumberExpression(nextId) }
        ))
        
        table.insert(branches, {
            condition = Ast.EqualsExpression(Ast.VariableExpression(scope, stateVar), Ast.NumberExpression(myId)),
            body = Ast.Block(chunkStats, scope)
        })
    end
    
    -- Start state transition
    -- We need to bridge startState -> chunkIds[1]
    -- Actually, let's just set stateVar = chunkIds[1] initially.
    local initialState = chunkIds[1]

    -- Shuffle branches
    util.shuffle(branches)
    
    -- Build the if-chain
    local function buildIfChain(index)
        if index > #branches then return Ast.Block({}, scope) end
        
        local branch = branches[index]
        return Ast.Block({
            Ast.IfStatement(
                branch.condition,
                branch.body,
                {}, -- elseifs (unused here)
                buildIfChain(index + 1) -- else block (recursive)
            )
        }, scope)
    end
    
    -- Or better, flat list of if statements if we want to avoid deep nesting,
    -- but else-if is more efficient.
    -- Let's use the nested structure.
    local loopBody = buildIfChain(1)
    
    -- 4. Replace Block Content
    block.statements = {
        Ast.LocalVariableDeclaration(scope, {stateVar}, {Ast.NumberExpression(initialState)}),
        Ast.WhileStatement(
            loopBody,
            Ast.NotEqualsExpression(Ast.VariableExpression(scope, stateVar), Ast.NumberExpression(endState)),
            scope
        )
    }
end

return ControlFlowFlattening
