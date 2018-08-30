# bootstrap (minimum runnable)

objInit(with no class)?

0. internal func:
 objInit
 route
 scopeInit
 classInit
 consInit
 
 exec

1. fundamental class init:
//Obj is an instance of Class;
//Class is child of Obj;

 -> scopeInit: root -> def 
 -> classInit: Obj -> Class | Scope 
 -> fix root, def, Obj, Class, Scope -> scopeNew 
 -> classNew: Val | Cons
 -> consInit: consNew -> Null | Num | Sizet | Str | Funcv | Set | Arr | Dic | List
 -> Argt -> Block -> Func -> FuncBlock | FuncNative | FuncTpl
 -> fix: Class | Cons | Scope

2. eval-related class init:
 -> classNew: Call -> CallDic | CallArr
 -> Ctrl | CtrlReturn | CtrlIf ... | Return
 
 -> funcnativeNew: log 
 -> execScope -> Main -> Block -> Call -> Num
 -> 

3. run
 fbNew
 exec

# bootstrap cmd
'''ti jssl ti2soulgen.sl bootstrap.sl
'''node bootstrap0.sl.js bootstrap.sl

# interface
 progl2ast
 valInit
 scopeGet
 ast2obj
 -> Ref -> Main 

# advanced
1. Ctrl
2. Self funcs
3. Operators
4. FuncTpl

# gen 

