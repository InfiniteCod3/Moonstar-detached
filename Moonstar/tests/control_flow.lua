-- Complex control flow tests
-- Tests obfuscator handling of various control flow patterns

-- Nested conditionals with multiple paths
local function classify(value)
    if type(value) == "number" then
        if value < 0 then
            return "negative"
        elseif value == 0 then
            return "zero"
        elseif value < 10 then
            return "small positive"
        elseif value < 100 then
            return "medium positive"
        else
            return "large positive"
        end
    elseif type(value) == "string" then
        if #value == 0 then
            return "empty string"
        elseif #value < 5 then
            return "short string"
        else
            return "long string"
        end
    elseif type(value) == "boolean" then
        if value then
            return "true"
        else
            return "false"
        end
    elseif type(value) == "table" then
        return "table"
    else
        return "other"
    end
end

print("Classify -5:", classify(-5))
print("Classify 0:", classify(0))
print("Classify 5:", classify(5))
print("Classify 50:", classify(50))
print("Classify 500:", classify(500))
print("Classify '':", classify(""))
print("Classify 'hi':", classify("hi"))
print("Classify 'hello world':", classify("hello world"))
print("Classify true:", classify(true))
print("Classify {}:", classify({}))

-- Break from nested loops
local function findPair(matrix, target)
    for i = 1, #matrix do
        for j = 1, #matrix[i] do
            if matrix[i][j] == target then
                return i, j
            end
        end
    end
    return nil, nil
end

local grid = {
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9}
}

local row, col = findPair(grid, 5)
print("Find 5:", row, col)
row, col = findPair(grid, 10)
print("Find 10:", row, col)

-- Early return patterns
local function processData(data)
    if not data then
        return nil, "no data"
    end
    
    if type(data) ~= "table" then
        return nil, "invalid type"
    end
    
    if #data == 0 then
        return nil, "empty data"
    end
    
    local sum = 0
    for _, v in ipairs(data) do
        if type(v) ~= "number" then
            return nil, "non-numeric value"
        end
        sum = sum + v
    end
    
    return sum, nil
end

local result, err = processData({1, 2, 3})
print("Process valid:", result, err)

result, err = processData(nil)
print("Process nil:", result, err)

result, err = processData({})
print("Process empty:", result, err)

result, err = processData({1, "bad", 3})
print("Process mixed:", result, err)

-- Short-circuit evaluation
local function safeGet(t, k1, k2, k3)
    return t and t[k1] and t[k1][k2] and t[k1][k2][k3]
end

local nested = {
    level1 = {
        level2 = {
            level3 = "found!"
        }
    }
}

print("Deep access:", safeGet(nested, "level1", "level2", "level3"))
print("Missing access:", safeGet(nested, "level1", "missing", "level3"))

-- Ternary-style expressions
local function sign(n)
    return n > 0 and 1 or (n < 0 and -1 or 0)
end

print("Sign 10:", sign(10))
print("Sign -5:", sign(-5))
print("Sign 0:", sign(0))

-- Complex loop control
local function primes(limit)
    local result = {}
    for num = 2, limit do
        local isPrime = true
        for i = 2, math.floor(math.sqrt(num)) do
            if num % i == 0 then
                isPrime = false
                break
            end
        end
        if isPrime then
            table.insert(result, num)
        end
    end
    return result
end

print("Primes up to 30:", table.concat(primes(30), ", "))

-- State machine pattern
local function stateMachine(input)
    local state = "start"
    local output = {}
    
    for i = 1, #input do
        local char = input:sub(i, i)
        
        if state == "start" then
            if char:match("%d") then
                state = "number"
                table.insert(output, char)
            elseif char:match("%a") then
                state = "word"
                table.insert(output, char)
            end
        elseif state == "number" then
            if char:match("%d") then
                output[#output] = output[#output] .. char
            else
                state = "start"
                if char:match("%a") then
                    state = "word"
                    table.insert(output, char)
                end
            end
        elseif state == "word" then
            if char:match("%a") then
                output[#output] = output[#output] .. char
            else
                state = "start"
                if char:match("%d") then
                    state = "number"
                    table.insert(output, char)
                end
            end
        end
    end
    
    return output
end

local tokens = stateMachine("abc123def456")
print("Tokens:")
for i, token in ipairs(tokens) do
    print(" ", i, token)
end
