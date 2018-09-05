ReprScope = % Struct {
 val: Dic
 scopeParents: Dic
}
ReprClass = % Struct {
 classSchema: Dic
 classParents: Dic
}
ReprCons = % Struct {
 cons: Dic,
 consClass: Class
}
ReprCall = % Struct {
 callFunc: ReprFunc,
 callArgs: Arr
}
ReprEnv = % Struct {
 envLexScope: ReprScope
 envExecScope: ReprScope
 envExecCache: Dic,
 envState: Dic,
 envGlobal: Dic,
 envStack: Arr,
}

scopeInit = &(scope, name, parents){
 #x = @ReprScope {
  scope: {}
  scopeParents: {}
 }
 @if parents {
  @foreach e parents{
	 //TODO reduce
   x.scopeParents[routeGet(e, "id")] = e;
  }
 }
 route(x, scope, name);
 @return x;
}
classInit = &(scope, name, parents, schema){
 #x = @ReprClass {
  classSchema: schema
  classParents: {}
 }
 @if parents {
  @foreach e parents{
	 //TODO reduce
   x.classParents[routeGet(e, "id")] = e;
  }	
 }
 route(x, scope, name);	
 @return x;
}

##root = scopeInit()
##def = scopeInit(root, "def")

##objc = classInit(def, "Obj")
##classc = classInit(def, "Class", [objc])
##scopec = classInit(def, "Scope", [objc])

pset(root, "obj", scopec)
pset(def, "obj", scopec)
pset(objc, "obj", classc)
pset(classc, "obj", classc)
pset(scopec, "obj", classc)

scopeNew = &(scope, name, parents){
//TODO when key match "_"
 #x = scopeInit(scope, name, parents)
 pset(x, "obj", scopec)
 @return x
}
classNew = &(scope, name, parents, schema){
 #x = classInit(scope, name, parents, schema)
 pset(x, "obj", classc)
 @return x
}

##consc = classNew(def, "Cons", [objc])
##valc = classNew(def, "Val", [objc])

consNew = &(scope, name, class, cons){
 #x = @ReprCons {
  cons: cons
  consClass: class
 }
 route(x, scope, name)
 pset(x, "obj", consc) 
 @return x;
}

##nullc = consNew(def, "Null", valc)
##undfc = consNew(def, "Undf", valc)
##numc = consNew(def, "Num", valc)
##sizetc = consNew(def, "Sizet", numc)
##strc = consNew(def, "Str", valc)
##funcvc = consNew(def, "Funcv", valc)
##itemsc =  classNew(def, "Items", [valc], {
 itemsType: classc
})
##arrc = consNew(def, "Arr", itemsc)
##dicc = consNew(def, "Dic", itemsc)

##argtc = classNew(def, "Argt", [objc], {
 argtName: strc
 argtType: classc
})

##funcc = classNew(def, "Func", [objc], {
 funcArgts: consInit(arrc, {itemsType: argtc})
 funcReturn: classc
})
##blockc = classNew(def, "Block", [objc], {
 block: arrc,
 blockLabels: consInit(arrc, {itemsType: strc})
})
##funcnativec = classNew(def, "FuncNative", [funcc], {
 func: funcvc
})
##funcblockc = classNew(def, "FuncBlock", [funcc], {
 func: blockc
})
##functplc = classNew(def, "FuncTpl", [funcc], {
 func: strc
})
##funcinternalc = classNew(def, "FuncInternal", [funcc], {
})

classc->classSchema = {
 classGetter: dicc
 classSetter: dicc
 classParents: dicc
 classSchema: dicc
}
consc->classSchema = {
 consClass: classc
 cons: dicc
}
scopec->classSchema = {
 scopeParents: dicc
}

##envc = classNew(def, "Env", [objc], {
 env: dicc
 envScope: scopec
 envExec: scopec
});

##callc = classNew(def, "Call", [objc], {
 call: funcc
 callArgs: arrc
})
##calldicc =  consNew(def, "CallDic", dicc)
##callarrc =  consNew(def, "CallArr", arrc)

##ctrlc = classNew(def, "Ctrl", [objc], {
 ctrlArgs: arrc
})
##ctrlreturnc = consNew(def, "CtrlReturn", ctrlc)
##ctrlbreakc = consNew(def, "CtrlBreak", ctrlc)
##ctrlcontinuec = consNew(def, "CtrlContinue", ctrlc)
##ctrlgotoc = consNew(def, "CtrlGoto", ctrlc)
##ctrlifc = consNew(def, "CtrlIf", ctrlc)
##ctrlforc = consNew(def, "CtrlFor", ctrlc)

##returnc = classNew(def, "Return", [objc], {
 return: objc
})

fnNew = &(scope, name, fn){
 route(fn, scope, name);
 pset(fn, "obj", funcnativec)
 //TODO if  raw	
 @return fn
}
callNew = &(func, args){
 #x = @ReprCall {
  callFunc: func
  callArgs: args
 }
 pset(x, "obj", callc)
 @return x;
}

type = &(o){
 @return routeGet(pget(o, "obj"), "id")
}
scopeGet = &(scope, key){
 
}
execFind = &(t, env, cache){
 @if(!cache){
  cache = {};
 }
 #exect = scopeGet(env.envExecScope, t)
 @if(?exect){
  @return exect
 }
 #deft = scopeGet(env.envDefScope, t) 
 @each k v pget(deft, "classParents"){
  @if(cache[k]){ @return; }
	cache[k] = 1;
	exect = execFind(k, env, cache);
	@if(?exect){
	 @return exect;
	}
 }
}
objExec = &(o, env){
 #ex = execFind(type(o), env)
 log(ex)
// @return callExec(ex, [o], env, 1);
}
callExec = &(func, args, env, flag){
}

##execsp = scopeNew(root, "exec");

##logc = fnNew(def, "log", repr(&(x){
 log(x)
}))
##calle = fnNew(execsp, "Call", repr(&(o){
// #func = objExec
 log("exec Call")
}))

##testc = callNew(logc, [1])

##env = @ReprEnv {
 envDefScope: scopeNew(def)
 envExecScope: scopeNew(execsp)
 envExecCache: {},
 envState: {},
 envGlobal: {},
 envStack: [],
}

objExec(testc, env)