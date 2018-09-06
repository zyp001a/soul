////////define structure

ReprScopex = % Struct {
 val: Dic
 scopeParents: Dic
}
ReprClassx = % Struct {
 classSchema: Dic
 classParents: Dic
}
ReprConsx = % Struct {
 cons: Dic,
 consClass: Class
}
ReprFuncx = % Struct {
 func: Class
 funcArgts: Arr
 funcReturn: Class
}
ReprCallx = % Struct {
 callFunc: ReprFuncx,
 callArgs: Arr
}
ReprEnvx = % Struct {
 envLexScope: ReprScopex
 envExecScope: ReprScopex
 envExecCache: Dic,
 envState: Dic,
 envGlobal: Dic,
 envStack: Arr,
}

////////define basic class/cons

routex = &(o, scope, name){
 @if(!innateGet(o, "index")){
  innateSet(o, "index", 0)
 }
 @if(!scope){
  @return o
 }
 @if(!?name){
  name = str(innateGet(o, "index"))
  innateSet(o, "index", innateGet(o, "index") + 1);
  innateSet(o, "noname", 1)
 }
 scopeSet(scope, name, o);
 innateSet(o, "name", name)
 #id = innateGet(scope, "id")
 @if(!?id){
  innateSet(o, "id", ".")
  innateSet(o, "ns", name)
 }@elif(id == "."){
  innateSet(o, "id", name)
  innateSet(o, "ns", innateGet(scope, "ns"))
 }@else{
  innateSet(o, "id", id^"_"^name)
  innateSet(o, "ns", innateGet(scope, "ns"))
 }
 innateSet(o, "scope", scope)
 @return o;
}
scopeInitx = &(scope, name, parents){
 #x = @ReprScopex {
  scope: {}
  scopeParents: {}
 }
 @if parents {
  @foreach e parents{
   //TODO reduce
   x.scopeParents[innateGet(e, "id")] = e;
  }
 }
 routex(x, scope, name);
 @return x;
}
classInitx = &(scope, name, parents, schema){
 #x = @ReprClassx {
  classSchema: schema || {}
  classParents: {}
 }
 @if parents {
  @foreach e parents{
   //TODO reduce
   x.classParents[innateGet(e, "id")] = e;
  }
 }
 routex(x, scope, name);
 @return x;
}

##root = scopeInitx()
##def = scopeInitx(root, "def")

##objc = classInitx(def, "Obj")
##classc = classInitx(def, "Class", [objc])
##scopec = classInitx(def, "Scope", [objc])

innateSet(root, "obj", scopec)
innateSet(def, "obj", scopec)
innateSet(objc, "obj", classc)
innateSet(classc, "obj", classc)
innateSet(scopec, "obj", classc)

scopeNewx = &(scope, name, parents){
//TODO when key match "_"
 #x = scopeInitx(scope, name, parents)
 innateSet(x, "obj", scopec)
 @return x
}
classNewx = &(scope, name, parents, schema){
 #x = classInitx(scope, name, parents, schema)
 innateSet(x, "obj", classc)
 @return x
}

##consc = classNewx(def, "Cons", [objc])
##valc = classNewx(def, "Val", [objc])

consInitx = &(class, cons){
 #x = @ReprConsx {
  cons: cons || {}
  consClass: class
 }
 innateSet(x, "obj", consc)
 @return x
}
consNewx = &(scope, name, class, cons){
 #x = consInitx(class, cons)
 routex(x, scope, name)
 @return x;
}

##nullc = consNewx(def, "Null", valc)
##undfc = consNewx(def, "Undf", valc)
##numc = consNewx(def, "Num", valc)
##sizetc = consNewx(def, "Sizet", numc)
##strc = consNewx(def, "Str", valc)
##funcvc = consNewx(def, "Funcv", valc)
##itemsc =  classNewx(def, "Items", [valc], {
 itemsType: classc
})
##arrc = consNewx(def, "Arr", itemsc)
##dicc = consNewx(def, "Dic", itemsc)

##argtc = classNewx(def, "Argt", [objc], {
 argtName: strc
 argtType: classc
})
##funcc = classNewx(def, "Func", [objc], {
 funcArgts: consInitx(arrc, {itemsType: argtc})
 funcReturn: classc
})
##blockc = classNewx(def, "Block", [objc], {
 block: arrc,
 blockLabels: consInitx(arrc, {itemsType: strc})
})
##funcnativec = classNewx(def, "FuncNative", [funcc], {
 func: funcvc
})
##funcblockc = classNewx(def, "FuncBlock", [funcc], {
 func: blockc
})
##functplc = classNewx(def, "FuncTpl", [funcc], {
 func: strc
})
##funcinternalc = classNewx(def, "FuncInternal", [funcc], {
})

classc->classSchema = {
 classGetter: dicc
 classSetter: dicc
 classParents: dicc
 classSchema: dicc
}
consc->classSchema = {
 cons: dicc
 consClass: classc
}
scopec->classSchema = {
 scope: dicc
 scopeParents: dicc
}

////////define call class/cons

##envc = classNewx(def, "Env", [objc], {
 env: dicc
 envScope: scopec
 envExec: scopec
});
##callc = classNewx(def, "Call", [objc], {
 call: funcc
 callArgs: arrc
})
##calldicc =  consNewx(def, "DicCall", dicc)
##callarrc =  consNewx(def, "ArrCall", arrc)
##callarrc =  consNewx(def, "LazyCall", callc) //and or && ||

##ctrlc = classNewx(def, "Ctrl", [objc], {
 ctrlArgs: arrc
})
##ctrlreturnc = consNewx(def, "CtrlReturn", ctrlc)
##ctrlbreakc = consNewx(def, "CtrlBreak", ctrlc)
##ctrlcontinuec = consNewx(def, "CtrlContinue", ctrlc)
##ctrlgotoc = consNewx(def, "CtrlGoto", ctrlc)
##ctrlifc = consNewx(def, "CtrlIf", ctrlc)
##ctrlforc = consNewx(def, "CtrlFor", ctrlc)

##returnc = classNewx(def, "Return", [objc], {
 return: objc
})

fnNewx = &(scope, name, fn){
 innateSet(fn, "obj", funcnativec)
 routex(fn, scope, name);
 //TODO if  raw
 @return fn
}
callNewx = &(func, args){
 #x = @ReprCallx {
  callFunc: func
  callArgs: args
 }
 innateSet(x, "obj", callc)
 @return x;
}

////////define basic function

typex = &(o){
 @return innateGet(innateGet(o, "obj"), "id")
}
dbGetx = &(scope, key){

}
scopeGetSubx = &(scope, key, cache){
 #r = scopeGetLocal(scope, key)
 @if(?r){
  @return r
 }
 #str = dbGetx(scope, key);
 @if(str){
  //TODO scope get sub
  str = key^"="^str;
  @return
 }
 @each k v scope.scopeParents {
  @if(cache[k]){ @continue };
  cache[k] = 1;
  r = scopeGetSubx(v, key, cache)
  @if(?r){
   @return r;
  }
 }
}
scopeGetx = &(scope, key){
 #r = scopeGetSubx(scope, key, {})
 @if(?r){
  @return r;
 }
 #pscope = innateGet(scope, "scope")
 @if(?pscope){
  r = scopeGetx(pscope, key)
  @return r;
 }
}

//////////////define parser function
tplParser = &(){
}
proglParser = &(){
}
progl2obj = &(){
}
ast2obj = &(){
}

//////////////define call function

execGetx = &(t, env, cache){
 @if(?env[t]){
  @return env[t];
 }
 @if(!cache){
  cache = {};
 }
 #exect = scopeGetx(env.envExecScope, t)
 @if(?exect){
  env[t] = exect;
  @return exect
 }
 #deft = scopeGetx(env.envDefScope, t)
 #deftt = typex(deft)
 @if(deftt == "Cons"){
  exect = execGetx(innateGet(deft.consClass, "id"), env, cache);
  @if(?exect){
   env[t] = exect;	
   @return exect;
  } 
 }@else{
  @each k v deft.classParents{
   @if(cache[k]){ @return; }
   cache[k] = 1;
   exect = execGetx(k, env, cache);
   @if(?exect){
    env[t] = exect;	
    @return exect;
   }
  }
 }
}
callx = &(func, args, env){
 #t = typex(func);
 @if(t == "FuncNative"){
  @return callNative(func.func, args, env)
 }
}
execx = &(o, env){
 #t = typex(o)
 #ex = execGetx(t, env)
 @if(!?ex){
  die("exec: unknown type, "^t);
 }
 @return callx(ex, [o], env);
}

////////////////////define call objs

##execsp = scopeNewx(root, "exec");
##logf = fnNewx(def, "log", repr(&(env, x){
 log(x)
}))
fnNewx(execsp, "Obj", repr(&(env, o){
 @return o
}))
fnNewx(execsp, "Call", repr(&(env, o){
 #func = execx(o.callFunc, env)
 #args = []
 @foreach e o.callArgs{
  push(args, execx(e, env))
 }
 callx(func, args, env);
}))

////////////////////test 

##gensp = scopeNewx(root, "gen");
##testc = callNewx(logf, [repr(1)])
##env = @ReprEnvx {
 envDefScope: scopeNewx(def)
 envExecScope: scopeNewx(execsp)
 envExecCache: {},
 envState: {},
 envGlobal: {},
 envStack: [],
}

log(execx(testc, env))

