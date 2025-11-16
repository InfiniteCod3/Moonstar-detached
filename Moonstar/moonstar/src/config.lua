-- Minimal config for Prometheus
-- This is required for the logger and other modules

return {
    NameUpper = "MOONSTAR",
    Name = "Moonstar",
    
    -- Formatting options
    SPACE = " ",
    TAB = "\t",
    NEWLINE = "\n",
    
    -- Identifier prefix (for variable naming)
    IdentPrefix = "__MOONSTAR_",
    VarNamePrefix = "",
    
    -- Obfuscation settings (defaults)
    PrettyPrint = false,
    Seed = 0,
    LuaVersion = "Lua51",
}
