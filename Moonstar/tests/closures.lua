function make_counter()
    local count = 0
    return function()
        count = count + 1
        return count
    end
end

local c1 = make_counter()
print(c1())
print(c1())

local c2 = make_counter()
print(c2())
print(c1())
