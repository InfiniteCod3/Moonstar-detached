return {
	WrapInFunction           = require("moonstar.steps.WrapInFunction");
	SplitStrings             = require("moonstar.steps.SplitStrings");
	Vmify                    = require("moonstar.steps.Vmify");
	ConstantArray            = require("moonstar.steps.ConstantArray");
	ProxifyLocals            = require("moonstar.steps.ProxifyLocals");
	EncryptStrings           = require("moonstar.steps.EncryptStrings");
	NumbersToExpressions     = require("moonstar.steps.NumbersToExpressions");
	ConstantFolding          = require("moonstar.steps.ConstantFolding");
	AntiTamper               = require("moonstar.steps.AntiTamper");
	ControlFlowFlattening    = require("moonstar.steps.ControlFlowFlattening");
	DebugInfoRemover         = require("moonstar.steps.DebugInfoRemover");
	Compression              = require("moonstar.steps.Compression");
}