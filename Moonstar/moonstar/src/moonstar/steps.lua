return {
	WrapInFunction           = require("moonstar.steps.WrapInFunction");
	SplitStrings             = require("moonstar.steps.SplitStrings");
	Vmify                    = require("moonstar.steps.Vmify");
	Vmify2                   = require("moonstar.steps.Vmify");
	ConstantArray            = require("moonstar.steps.ConstantArray");
	ProxifyLocals            = require("moonstar.steps.ProxifyLocals");
	EncryptStrings           = require("moonstar.steps.EncryptStrings");
	NumbersToExpressions     = require("moonstar.steps.NumbersToExpressions");
	AddVararg                = require("moonstar.steps.AddVararg");
	VmProfileRandomizer      = require("moonstar.steps.VmProfileRandomizer");
	ConstantFolding          = require("moonstar.steps.ConstantFolding");
	AntiTamper               = require("moonstar.steps.AntiTamper");
}