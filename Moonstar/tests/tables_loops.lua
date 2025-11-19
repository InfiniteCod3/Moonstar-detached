local t = {
    a = 1,
    b = 2,
    c = 3,
    nested = {
        d = 4,
        e = 5
    }
}

local keys = {}
for k, v in pairs(t) do
    if type(v) ~= "table" then
        table.insert(keys, k)
    end
end
table.sort(keys)
for _, k in ipairs(keys) do
    print(k, t[k])
end

local list = {10, 20, 30, 40}
for i, v in ipairs(list) do
    print(i, v)
end

local i = 0
while i < 5 do
    print("while", i)
    i = i + 1
end

local j = 0
repeat
    print("repeat", j)
    j = j + 1
until j >= 5
