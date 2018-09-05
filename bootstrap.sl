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
 env: Dic
 envScope: ReprScope
 envExec: ReprExec
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

##logc = fnNew(def, "log", repr(&(x){
 log(x)
}))

callNew = &(func, args){
 @return @ReprCall {
  callFunc: func
  callArgs: args
 }
}

##execsp = scopeNew(root, "exec");

##testc = callNew(logc, [1])

##env = @ReprEnv {
 env: {},
 envScope: scopeNew(def)
 envExec: scopeNew(execsp)
}

callExec = &(o, env){
 log(2)
}
callExec(testc, env)