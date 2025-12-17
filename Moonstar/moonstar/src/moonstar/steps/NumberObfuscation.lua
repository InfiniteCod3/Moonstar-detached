-- This Script is Part of the Moonstar Obfuscator
--
-- NumberObfuscation.lua
--
-- Transforms numeric literals into complex arithmetic expressions
-- that evaluate to the same value. Compatible with Lua 5.1 and LuaU.

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local visitast = require("moonstar.visitast")
local logger = require("logger")
local AstKind = Ast.AstKind

local NumberObfuscation = Step:extend()
NumberObfuscation.Description = "Transforms numbers into arithmetic expressions."
NumberObfuscation.Name = "Number Obfuscation"

NumberObfuscation.SettingsDescriptor = {
	Enabled = {
		type = "boolean",
		default = true,
	},
	-- Probability of obfuscating each number
	Intensity = {
		type = "number",
		default = 0.5,
		min = 0.0,
		max = 1.0,
	},
	-- Maximum depth of nested expressions
	MaxDepth = {
		type = "number",
		default = 3,
		min = 1,
		max = 5,
	},
	-- Minimum absolute value to obfuscate (skip small numbers for performance)
	MinValue = {
		type = "number",
		default = 0,
	},
	-- Use addition/subtraction transforms
	UseAddSub = {
		type = "boolean",
		default = true,
	},
	-- Use multiplication/division transforms
	UseMulDiv = {
		type = "boolean",
		default = true,
	},
	-- Use modulo transforms
	UseMod = {
		type = "boolean",
		default = true,
	},
	-- Use bitwise-like transforms (using arithmetic, Lua 5.1 compatible)
	UseBitArith = {
		type = "boolean",
		default = true,
	},
}

function NumberObfuscation:init(settings)
	self.transformCount = 0
end

-- Generate addition/subtraction expression: n = a + b or n = a - b
function NumberObfuscation:genAddSub(n)
	if math.random() < 0.5 then
		-- n = a + b
		local a = math.random(-10000, 10000)
		local b = n - a
		return Ast.AddExpression(
			Ast.NumberExpression(a),
			Ast.NumberExpression(b)
		)
	else
		-- n = a - b
		local b = math.random(-10000, 10000)
		local a = n + b
		return Ast.SubExpression(
			Ast.NumberExpression(a),
			Ast.NumberExpression(b)
		)
	end
end

-- Generate multiplication/division expression: n = a * b or n = a / b
function NumberObfuscation:genMulDiv(n)
	-- For multiplication, find factors
	if n ~= 0 and math.random() < 0.6 then
		-- Try to find integer factors
		local factors = {}
		for i = 2, math.min(math.abs(n), 100) do
			if n % i == 0 then
				table.insert(factors, i)
			end
		end
		
		if #factors > 0 then
			local a = factors[math.random(#factors)]
			local b = n / a
			if math.floor(b) == b then
				return Ast.MulExpression(
					Ast.NumberExpression(a),
					Ast.NumberExpression(b)
				)
			end
		end
	end
	
	-- Division: n = a / b where a = n * b
	if n ~= 0 then
		local b = math.random(2, 50)
		local a = n * b
		return Ast.DivExpression(
			Ast.NumberExpression(a),
			Ast.NumberExpression(b)
		)
	end
	
	-- Fallback to addition
	return self:genAddSub(n)
end

-- Generate modulo-based expression
function NumberObfuscation:genMod(n)
	-- n = (n + k*m) % m where result is n (if n < m)
	if n >= 0 and n < 1000 then
		local m = n + math.random(100, 1000)
		local k = math.random(1, 10)
		local base = n + k * m
		return Ast.ModExpression(
			Ast.NumberExpression(base),
			Ast.NumberExpression(m)
		)
	end
	
	-- Fallback
	return self:genAddSub(n)
end

-- Generate arithmetic bitwise-like operations (Lua 5.1 compatible)
-- Uses the identity: floor(x / 2^n) * 2^n extracts high bits
function NumberObfuscation:genBitArith(n)
	if n >= 0 and n < 65536 and math.floor(n) == n then
		-- Split into high and low parts
		local shift = math.random(4, 8)
		local divisor = 2 ^ shift
		local high = math.floor(n / divisor)
		local low = n % divisor
		
		-- n = high * 2^shift + low
		return Ast.AddExpression(
			Ast.MulExpression(
				Ast.NumberExpression(high),
				Ast.NumberExpression(divisor)
			),
			Ast.NumberExpression(low)
		)
	end
	
	return self:genAddSub(n)
end

-- Generate a complex nested expression
function NumberObfuscation:genComplex(n, depth)
	if depth <= 0 then
		return Ast.NumberExpression(n)
	end
	
	local methods = {}
	
	if self.UseAddSub then
		table.insert(methods, function()
			-- n = a + b, then recursively obfuscate a or b
			local a = math.random(-1000, 1000)
			local b = n - a
			if math.random() < 0.5 then
				return Ast.AddExpression(
					self:genComplex(a, depth - 1),
					Ast.NumberExpression(b)
				)
			else
				return Ast.AddExpression(
					Ast.NumberExpression(a),
					self:genComplex(b, depth - 1)
				)
			end
		end)
	end
	
	if self.UseMulDiv and n ~= 0 then
		table.insert(methods, function()
			-- n = (a * b) / b = a, but expressed complexly
			local b = math.random(2, 20)
			local product = n * b
			return Ast.DivExpression(
				self:genComplex(product, depth - 1),
				Ast.NumberExpression(b)
			)
		end)
	end
	
	if self.UseMod and n >= 0 and n < 500 then
		table.insert(methods, function()
			local m = n + math.random(500, 2000)
			local base = n + m * math.random(1, 5)
			return Ast.ModExpression(
				self:genComplex(base, depth - 1),
				Ast.NumberExpression(m)
			)
		end)
	end
	
	if #methods > 0 then
		return methods[math.random(#methods)]()
	end
	
	return Ast.NumberExpression(n)
end

-- Main obfuscation function for a number
function NumberObfuscation:obfuscateNumber(n)
	-- Skip non-integer or very large numbers for safety
	if math.floor(n) ~= n then
		-- For floats, use simple add/sub
		local offset = math.random(1, 1000)
		return Ast.SubExpression(
			Ast.NumberExpression(n + offset),
			Ast.NumberExpression(offset)
		)
	end
	
	-- Skip if below minimum value threshold
	if math.abs(n) < self.MinValue then
		return nil
	end
	
	local depth = math.random(1, self.MaxDepth)
	
	-- Choose a random method based on enabled options
	local methods = {}
	
	if self.UseAddSub then
		table.insert(methods, function() return self:genAddSub(n) end)
	end
	
	if self.UseMulDiv and n ~= 0 then
		table.insert(methods, function() return self:genMulDiv(n) end)
	end
	
	if self.UseMod and n >= 0 then
		table.insert(methods, function() return self:genMod(n) end)
	end
	
	if self.UseBitArith and n >= 0 and n < 65536 then
		table.insert(methods, function() return self:genBitArith(n) end)
	end
	
	-- For deeper obfuscation, use complex nested expressions
	if depth > 1 then
		table.insert(methods, function() return self:genComplex(n, depth) end)
	end
	
	if #methods > 0 then
		return methods[math.random(#methods)]()
	end
	
	return nil
end

function NumberObfuscation:apply(ast)
	if not self.Enabled then
		return ast
	end
	
	local intensity = self.Intensity
	local numbersObfuscated = 0
	
	visitast(ast, nil, function(node, data)
		if node.kind == AstKind.NumberExpression then
			-- Skip if already processed or probability check fails
			if node.__number_obfuscated then
				return nil
			end
			
			if math.random() > intensity then
				return nil
			end
			
			local value = node.value
			
			-- Skip special values
			if value ~= value then -- NaN check
				return nil
			end
			if value == math.huge or value == -math.huge then
				return nil
			end
			
			local obfuscated = self:obfuscateNumber(value)
			if obfuscated then
				obfuscated.__number_obfuscated = true
				numbersObfuscated = numbersObfuscated + 1
				return obfuscated
			end
		end
		
		return nil
	end)
	
	logger:info(string.format("Number Obfuscation: Transformed %d numbers", numbersObfuscated))
	
	return ast
end

return NumberObfuscation
