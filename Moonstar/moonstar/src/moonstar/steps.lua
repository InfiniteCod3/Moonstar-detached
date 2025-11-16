return {
	WrapInFunction           = require("moonstar.steps.WrapInFunction");
	SplitStrings             = require("moonstar.steps.SplitStrings");
	Vmify                    = require("moonstar.steps.Vmify");
	ConstantArray            = require("moonstar.steps.ConstantArray");
	ProxifyLocals            = require("moonstar.steps.ProxifyLocals");
	AntiTamper               = require("moonstar.steps.AntiTamper");
	EncryptStrings           = require("moonstar.steps.EncryptStrings");
	NumbersToExpressions     = require("moonstar.steps.NumbersToExpressions");
	AddVararg                = require("moonstar.steps.AddVararg");
	WatermarkCheck           = require("moonstar.steps.WatermarkCheck");

	-- New optional/lightweight steps:
	LocalLifetimeSplitting   = require("moonstar.steps.LocalLifetimeSplitting");
	ControlFlowRestructuring = require("moonstar.steps.ControlFlowRestructuring");
	StructuredJunk           = require("moonstar.steps.StructuredJunk");
	
	-- Plan.md new steps (high priority):
	LayeredStringDecrypt     = require("moonstar.steps.LayeredStringDecrypt");
	OpaquePredicates         = require("moonstar.steps.OpaquePredicates");
	VmProfileRandomizer      = require("moonstar.steps.VmProfileRandomizer");
	
	-- Plan.md new steps (medium priority):
	AntiDebug                = require("moonstar.steps.AntiDebug");
	PolymorphicLayout        = require("moonstar.steps.PolymorphicLayout");
	StagedConstantDecode     = require("moonstar.steps.StagedConstantDecode");
}