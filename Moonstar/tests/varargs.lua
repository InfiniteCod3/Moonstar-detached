function sum(...)
    local s = 0
    for i, v in ipairs({...}) do
        s = s + v
    end
    return s
end

print(sum(1, 2, 3))
print(sum(10, 20))
print(sum())

function print_args(...)
    local args = {...}
    print("Count:", #args)
    for i = 1, #args do
        print(i, args[i])
    end
end

print_args("a", "b", "c")
