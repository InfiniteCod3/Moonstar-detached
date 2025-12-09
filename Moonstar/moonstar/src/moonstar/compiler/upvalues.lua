-- upvalues.lua
-- Upvalue handling and garbage collection for the compiler

local Ast = require("moonstar.ast");
local Scope = require("moonstar.scope");
local util = require("moonstar.util");

local Upvalues = {}

-- Check if a variable is an upvalue
function Upvalues.isUpvalue(compiler, scope, id)
    return compiler.upvalVars[scope] and compiler.upvalVars[scope][id];
end

-- Mark a variable as an upvalue
function Upvalues.makeUpvalue(compiler, scope, id)
    if(not compiler.upvalVars[scope]) then
        compiler.upvalVars[scope] = {}
    end
    compiler.upvalVars[scope][id] = true;
end

-- Create the upvalue GC function
function Upvalues.createUpvaluesGcFunc(compiler)
    local scope = Scope:new(compiler.scope);
    local selfVar = scope:addVariable();

    local x9wL4 = scope:addVariable();
    local p5tZ7 = scope:addVariable();

    local whileScope = Scope:new(scope);
    whileScope:addReferenceToHigherScope(compiler.scope, compiler.upvaluesReferenceCountsTable, 3);
    whileScope:addReferenceToHigherScope(scope, p5tZ7, 3);
    whileScope:addReferenceToHigherScope(scope, x9wL4, 3);

    local ifScope = Scope:new(whileScope);
    ifScope:addReferenceToHigherScope(compiler.scope, compiler.upvaluesReferenceCountsTable, 1);
    ifScope:addReferenceToHigherScope(compiler.scope, compiler.upvaluesTable, 1);
    

    return Ast.FunctionLiteralExpression({Ast.VariableExpression(scope, selfVar)}, Ast.Block({
        Ast.LocalVariableDeclaration(scope, {x9wL4, p5tZ7}, {Ast.NumberExpression(1), Ast.IndexExpression(Ast.VariableExpression(scope, selfVar), Ast.NumberExpression(1))}),
        Ast.WhileStatement(Ast.Block({
            Ast.AssignmentStatement({
                Ast.AssignmentIndexing(Ast.VariableExpression(compiler.scope, compiler.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, p5tZ7)),
                Ast.AssignmentVariable(scope, x9wL4),
            }, {
                Ast.SubExpression(Ast.IndexExpression(Ast.VariableExpression(compiler.scope, compiler.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, p5tZ7)), Ast.NumberExpression(1)),
                Ast.AddExpression(unpack(util.shuffle{Ast.VariableExpression(scope, x9wL4), Ast.NumberExpression(1)})),
            }),
            Ast.IfStatement(Ast.EqualsExpression(unpack(util.shuffle{Ast.IndexExpression(Ast.VariableExpression(compiler.scope, compiler.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, p5tZ7)), Ast.NumberExpression(0)})), Ast.Block({
                Ast.AssignmentStatement({
                    Ast.AssignmentIndexing(Ast.VariableExpression(compiler.scope, compiler.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, p5tZ7)),
                    Ast.AssignmentIndexing(Ast.VariableExpression(compiler.scope, compiler.upvaluesTable), Ast.VariableExpression(scope, p5tZ7)),
                }, {
                    Ast.NilExpression(),
                    Ast.NilExpression(),
                })
            }, ifScope), {}, nil),
            Ast.AssignmentStatement({
                Ast.AssignmentVariable(scope, p5tZ7),
            }, {
                Ast.IndexExpression(Ast.VariableExpression(scope, selfVar), Ast.VariableExpression(scope, x9wL4)),
            }),
        }, whileScope), Ast.VariableExpression(scope, p5tZ7), scope);
    }, scope));
end

-- Create the free upvalue function
function Upvalues.createFreeUpvalueFunc(compiler)
    local scope = Scope:new(compiler.scope);
    local argVar = scope:addVariable();
    local ifScope = Scope:new(scope);
    ifScope:addReferenceToHigherScope(scope, argVar, 3);
    scope:addReferenceToHigherScope(compiler.scope, compiler.upvaluesReferenceCountsTable, 2);
    return Ast.FunctionLiteralExpression({Ast.VariableExpression(scope, argVar)}, Ast.Block({
        Ast.AssignmentStatement({
            Ast.AssignmentIndexing(Ast.VariableExpression(compiler.scope, compiler.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, argVar))
        }, {
            Ast.SubExpression(Ast.IndexExpression(Ast.VariableExpression(compiler.scope, compiler.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, argVar)), Ast.NumberExpression(1));
        }),
        Ast.IfStatement(Ast.EqualsExpression(unpack(util.shuffle{Ast.IndexExpression(Ast.VariableExpression(compiler.scope, compiler.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, argVar)), Ast.NumberExpression(0)})), Ast.Block({
            Ast.AssignmentStatement({
                Ast.AssignmentIndexing(Ast.VariableExpression(compiler.scope, compiler.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, argVar)),
                Ast.AssignmentIndexing(Ast.VariableExpression(compiler.scope, compiler.upvaluesTable), Ast.VariableExpression(scope, argVar)),
            }, {
                Ast.NilExpression(),
                Ast.NilExpression(),
            })
        }, ifScope), {}, nil)
    }, scope))
end

-- Create the upvalues proxy function
function Upvalues.createUpvaluesProxyFunc(compiler)
    local scope = Scope:new(compiler.scope);
    scope:addReferenceToHigherScope(compiler.scope, compiler.newproxyVar);

    local entriesVar = scope:addVariable();

    local ifScope = Scope:new(scope);
    local proxyVar = ifScope:addVariable();
    local metatableVar = ifScope:addVariable();
    local elseScope = Scope:new(scope);
    ifScope:addReferenceToHigherScope(compiler.scope, compiler.newproxyVar);
    ifScope:addReferenceToHigherScope(compiler.scope, compiler.getmetatableVar);
    ifScope:addReferenceToHigherScope(compiler.scope, compiler.upvaluesGcFunctionVar);
    ifScope:addReferenceToHigherScope(scope, entriesVar);
    elseScope:addReferenceToHigherScope(compiler.scope, compiler.setmetatableVar);
    elseScope:addReferenceToHigherScope(scope, entriesVar);
    elseScope:addReferenceToHigherScope(compiler.scope, compiler.upvaluesGcFunctionVar);

    local forScope = Scope:new(scope);
    local forArg = forScope:addVariable();
    forScope:addReferenceToHigherScope(compiler.scope, compiler.upvaluesReferenceCountsTable, 2);
    forScope:addReferenceToHigherScope(scope, entriesVar, 2);

    return Ast.FunctionLiteralExpression({Ast.VariableExpression(scope, entriesVar)}, Ast.Block({
        Ast.ForStatement(forScope, forArg, Ast.NumberExpression(1), Ast.LenExpression(Ast.VariableExpression(scope, entriesVar)), Ast.NumberExpression(1), Ast.Block({
            Ast.AssignmentStatement({
                Ast.AssignmentIndexing(Ast.VariableExpression(compiler.scope, compiler.upvaluesReferenceCountsTable), Ast.IndexExpression(Ast.VariableExpression(scope, entriesVar), Ast.VariableExpression(forScope, forArg)))
            }, {
                Ast.AddExpression(unpack(util.shuffle{
                    Ast.IndexExpression(Ast.VariableExpression(compiler.scope, compiler.upvaluesReferenceCountsTable), Ast.IndexExpression(Ast.VariableExpression(scope, entriesVar), Ast.VariableExpression(forScope, forArg))),
                    Ast.NumberExpression(1),
                }))
            })
        }, forScope), scope);
        Ast.IfStatement(Ast.VariableExpression(compiler.scope, compiler.newproxyVar), Ast.Block({
            Ast.LocalVariableDeclaration(ifScope, {proxyVar}, {
                Ast.FunctionCallExpression(Ast.VariableExpression(compiler.scope, compiler.newproxyVar), {
                    Ast.BooleanExpression(true)
                });
            });
            Ast.LocalVariableDeclaration(ifScope, {metatableVar}, {
                Ast.FunctionCallExpression(Ast.VariableExpression(compiler.scope, compiler.getmetatableVar), {
                    Ast.VariableExpression(ifScope, proxyVar);
                });
            });
            Ast.AssignmentStatement({
                Ast.AssignmentIndexing(Ast.VariableExpression(ifScope, metatableVar), Ast.StringExpression("__index")),
                Ast.AssignmentIndexing(Ast.VariableExpression(ifScope, metatableVar), Ast.StringExpression("__gc")),
                Ast.AssignmentIndexing(Ast.VariableExpression(ifScope, metatableVar), Ast.StringExpression("__len")),
            }, {
                Ast.VariableExpression(scope, entriesVar),
                Ast.VariableExpression(compiler.scope, compiler.upvaluesGcFunctionVar),
                Ast.FunctionLiteralExpression({}, Ast.Block({
                    Ast.ReturnStatement({Ast.NumberExpression(compiler.upvalsProxyLenReturn)})
                }, Scope:new(ifScope)));
            });
            Ast.ReturnStatement({
                Ast.VariableExpression(ifScope, proxyVar)
            })
        }, ifScope), {}, Ast.Block({
            Ast.ReturnStatement({Ast.FunctionCallExpression(Ast.VariableExpression(compiler.scope, compiler.setmetatableVar), {
                Ast.TableConstructorExpression({}),
                Ast.TableConstructorExpression({
                    Ast.KeyedTableEntry(Ast.StringExpression("__gc"), Ast.VariableExpression(compiler.scope, compiler.upvaluesGcFunctionVar)),
                    Ast.KeyedTableEntry(Ast.StringExpression("__index"), Ast.VariableExpression(scope, entriesVar)),
                    Ast.KeyedTableEntry(Ast.StringExpression("__len"), Ast.FunctionLiteralExpression({}, Ast.Block({
                        Ast.ReturnStatement({Ast.NumberExpression(compiler.upvalsProxyLenReturn)})
                    }, Scope:new(ifScope)))),
                })
            })})
        }, elseScope));
    }, scope));
end

-- Create the alloc upvalue function
function Upvalues.createAllocUpvalFunction(compiler)
    local scope = Scope:new(compiler.scope);
    scope:addReferenceToHigherScope(compiler.scope, compiler.currentUpvalId, 4);
    scope:addReferenceToHigherScope(compiler.scope, compiler.upvaluesReferenceCountsTable, 1);

    return Ast.FunctionLiteralExpression({}, Ast.Block({
        Ast.AssignmentStatement({
                Ast.AssignmentVariable(compiler.scope, compiler.currentUpvalId),
            },{
                Ast.AddExpression(unpack(util.shuffle({
                    Ast.VariableExpression(compiler.scope, compiler.currentUpvalId),
                    Ast.NumberExpression(1),
                }))),
            }
        ),
        Ast.AssignmentStatement({
            Ast.AssignmentIndexing(Ast.VariableExpression(compiler.scope, compiler.upvaluesReferenceCountsTable), Ast.VariableExpression(compiler.scope, compiler.currentUpvalId)),
        }, {
            Ast.NumberExpression(1),
        }),
        Ast.ReturnStatement({
            Ast.VariableExpression(compiler.scope, compiler.currentUpvalId),
        })
    }, scope));
end

-- Set an upvalue member
function Upvalues.setUpvalueMember(compiler, scope, idExpr, valExpr, compoundConstructor)
    scope:addReferenceToHigherScope(compiler.scope, compiler.upvaluesTable);
    if compoundConstructor then
        return compoundConstructor(Ast.AssignmentIndexing(Ast.VariableExpression(compiler.scope, compiler.upvaluesTable), idExpr), valExpr);
    end
    return Ast.AssignmentStatement({Ast.AssignmentIndexing(Ast.VariableExpression(compiler.scope, compiler.upvaluesTable), idExpr)}, {valExpr});
end

-- Get an upvalue member
function Upvalues.getUpvalueMember(compiler, scope, idExpr)
    scope:addReferenceToHigherScope(compiler.scope, compiler.upvaluesTable);
    return Ast.IndexExpression(Ast.VariableExpression(compiler.scope, compiler.upvaluesTable), idExpr);
end

return Upvalues
