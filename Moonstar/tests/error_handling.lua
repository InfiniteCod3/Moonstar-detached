local function risky(val)
    if val < 0 then
        error("Negative value")
    end
    return val * 2
end

local status, result = pcall(risky, 10)
print(status, result)

status, result = pcall(risky, -5)
print(status, string.find(result, "Negative value") ~= nil)
