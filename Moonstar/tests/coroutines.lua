local co = coroutine.create(function()
    for i = 1, 3 do
        print("co", i)
        coroutine.yield()
    end
end)

print(coroutine.status(co))
coroutine.resume(co)
print(coroutine.status(co))
coroutine.resume(co)
print(coroutine.status(co))
coroutine.resume(co)
print(coroutine.status(co))
coroutine.resume(co)
print(coroutine.status(co))
