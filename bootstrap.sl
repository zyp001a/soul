scopeInit = &(scope, name, parents){
  #x =  @ReprScope {
    val: {}
  }
  setParents(x, parents);
  route(x, scope, name);
}
##root = scopeInit()
##def = scopeInit(root, "def")

##objc = classInit(def, "Obj")
##classc = classInit(def, "Class", [objc])
##scopec = classInit(def, "Scope", [objc])

pset(root, "class", scopec)
pset(def, "class", scopec)
pset(objc, "class", classc)
pset(classc, "class", classc)
pset(scopec, "class", classc)

classNew = &(scope, name, parents, schema){
 #x = classInit(scope, name, parents, schema)
 pset(x, "class", classc)
 @return x
}
scopeNew = &(scope, name, parents){
//TODO when key match "_"
 #x = scopeInit(scope, name, parents)
 pset(x, "class", classc)
 @return x
}

##consc = classNew(def, "Cons", [objc])
##valc = classNew(def, "Val", [objc])

consNew = &(scope, name, class, cons){
 #x = consInit(class, cons)
 route(scope, name, x)
 pset(x, "class", consc) 
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

##argtc = classNew(def, "Argt", {
 argtName: strc
 argtType: classc
}, [objc])

##funcc = classNew(def, "Func", {
 funcArgts: consInit(arrc, {itemsType: argtc})
 funcReturn: classc
}, [objc])
##blockc = classNew(def, "Block", {
 block: arrc,
 blockLabels: consInit(arrc, {itemsType: strc})
}, [objc])
##funcnativec = classNew(def, "FuncNative", {
 func: funcvc
}, [funcc])
##funcblockc = classNew(def, "FuncBlock", {
 func: blockc
}, [funcc])
##functplc = classNew(def, "FuncTpl", {
 func: strc
}, [funcc])
##funcspecc = classNew(def, "FuncSpec", {
}, [funcc])

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

////////////////call////////////////

##callc = classNew(def, "Call", [objc], {
 callFunc: funcc
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
  #o = fnInit(scope, name, fn.func, fn.funcArgts, fn.funcReturn);
  pset(o, "class", funcnativec)
  //TODO if ** raw
  @return o;
}

fnNew(def, "log", @ReprFunc &(x){
  log(x)
})

##testc = callNew()
exec(testc)