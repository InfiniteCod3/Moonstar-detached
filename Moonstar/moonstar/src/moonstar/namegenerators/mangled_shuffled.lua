-- This Script is Part of the Moonstar Obfuscator by Aurologic
--
-- namegenerators/mangled_shuffled.lua
--
-- This Script provides a function for generation of mangled names with shuffled character order


local util = require("moonstar.util");
local chararray = util.chararray;

-- Note on character set:
-- Do NOT include '_' in VarDigits to avoid conflicts with internal/reserved identifiers.
-- Having '_' as a generated name can trigger:
--   "A variable with the name '_' was already defined, you should have no variables starting with '__MOONSTAR_'"
-- Keep VarStartDigits the same (letters only), and VarDigits without plain '_' to avoid collisions.
local VarDigits = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789");
local VarStartDigits = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");

local function generateName(id, scope)
	local name = ''
	local d = id % #VarStartDigits
	id = (id - d) / #VarStartDigits
	name = name..VarStartDigits[d+1]
	while id > 0 do
		local d = id % #VarDigits
		id = (id - d) / #VarDigits
		name = name..VarDigits[d+1]
	end
	return name
end

local function prepare(ast)
	util.shuffle(VarDigits);
	util.shuffle(VarStartDigits);
end

return {
	generateName = generateName, 
	prepare = prepare
};