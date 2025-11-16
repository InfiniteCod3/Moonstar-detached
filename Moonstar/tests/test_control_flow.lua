-- Control flow test (loops, conditionals, etc.)
print("=== Control Flow Test ===")

-- Nested loops
print("\nMultiplication table (1-5):")
for i = 1, 5 do
    local line = ""
    for j = 1, 5 do
        line = line .. string.format("%3d", i * j) .. " "
    end
    print(line)
end

-- While loops
print("\nCounting down from 10:")
local count = 10
while count > 0 do
    if count % 2 == 0 then
        print(count .. " (even)")
    else
        print(count .. " (odd)")
    end
    count = count - 1
end

-- Repeat-until
print("\nRepeat-until loop:")
local value = 1
repeat
    print("Value: " .. value)
    value = value * 2
until value > 50

-- Break and continue simulation
print("\nFinding first multiple of 7 greater than 20:")
for i = 1, 100 do
    if i <= 20 then
        -- Skip (continue equivalent)
    elseif i % 7 == 0 then
        print("Found: " .. i)
        break
    end
end

-- Multiple conditions
print("\nClassifying numbers 1-20:")
for i = 1, 20 do
    local classification = ""
    
    if i % 15 == 0 then
        classification = "FizzBuzz"
    elseif i % 3 == 0 then
        classification = "Fizz"
    elseif i % 5 == 0 then
        classification = "Buzz"
    else
        classification = tostring(i)
    end
    
    print(classification)
end

-- Switch-like structure
local function processCommand(cmd)
    if cmd == "start" then
        return "Starting..."
    elseif cmd == "stop" then
        return "Stopping..."
    elseif cmd == "restart" then
        return "Restarting..."
    elseif cmd == "status" then
        return "Status: Running"
    else
        return "Unknown command: " .. cmd
    end
end

print("\nCommand processing:")
local commands = {"start", "status", "stop", "invalid"}
for _, cmd in ipairs(commands) do
    print(processCommand(cmd))
end

-- Nested conditionals
print("\nGrade calculation:")
local function getGrade(score)
    if score >= 90 then
        return "A"
    elseif score >= 80 then
        return "B"
    elseif score >= 70 then
        return "C"
    elseif score >= 60 then
        return "D"
    else
        return "F"
    end
end

local scores = {95, 87, 72, 65, 45}
for _, score in ipairs(scores) do
    print("Score " .. score .. ": Grade " .. getGrade(score))
end

print("\n=== Control flow test complete ===")
