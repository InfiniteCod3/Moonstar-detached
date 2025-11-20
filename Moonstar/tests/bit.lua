package.path = "moonstar/src/?.lua;" .. package.path
local bit = require('moonstar.bit')

print(bit.bxor(1, 2))
print(bit.band(6, 3))
print(bit.bor(1, 2))
print(bit.bnot(0))
print(bit.tobit(4294967295))
