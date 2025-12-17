return {
	WrapInFunction           = require("moonstar.steps.WrapInFunction");
	Vmify                    = require("moonstar.steps.Vmify");
	Vmify2                   = require("moonstar.steps.Vmify");
	ConstantArray            = require("moonstar.steps.ConstantArray");
	EncryptStrings           = require("moonstar.steps.EncryptStrings");
	VmProfileRandomizer      = require("moonstar.steps.VmProfileRandomizer");
	ConstantFolding          = require("moonstar.steps.ConstantFolding");
	AntiTamper               = require("moonstar.steps.AntiTamper");
	AntiDebug                = require("moonstar.steps.AntiDebug");
	GlobalVirtualization     = require("moonstar.steps.GlobalVirtualization");
	ControlFlowFlattening    = require("moonstar.steps.ControlFlowFlattening");
	Compression              = require("moonstar.steps.Compression");
	OpaquePredicates         = require("moonstar.steps.OpaquePredicates");
	NumberObfuscation        = require("moonstar.steps.NumberObfuscation");
	StringSplitting          = require("moonstar.steps.StringSplitting");
	BytecodePoisoning        = require("moonstar.steps.BytecodePoisoning");
}
