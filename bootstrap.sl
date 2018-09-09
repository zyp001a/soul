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
 envDefScope: ReprScope
 envGlobalScope: ReprScope
 envExecScope: ReprScope
 envExecCache: Dic
 envState: Dic
 envGlobal: Dic
 envStack: Arr 
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
 //TODO class cannot be def.Cons
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
 blockNovar: numc
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

classc.classSchema = {
 classGetter: dicc
 classSetter: dicc
 classParents: dicc
 classSchema: dicc
}
consc.classSchema = {
 cons: dicc
 consClass: classc
}
scopec.classSchema = {
 scope: dicc
 scopeParents: dicc
}

////////define call class/cons

##envc = classNewx(def, "Env", [objc], {
 envDefScope: scopec
 envGlobalScope: scopec
 envExecScope: scopec,
 envExecCache: dicc,
 envState: dicc,
 envGlobal: dicc,
 envStack: arrc, 
})

##callc = classNewx(def, "Call", [objc], {
 call: funcc
 callArgs: arrc
})
##calllazyc =  consNewx(def, "CallLazy", callc)
//and or assign
//&& || =

##calldicc =  consNewx(def, "DicCall", dicc)
##callarrc =  consNewx(def, "ArrCall", arrc)

##idc =  classNewx(def, "Id", [objc], {
 id: strc,
})
##idlocalc =  consNewx(def, "IdLocal", idc)
##idglobalc =  consNewx(def, "IdGlobal", idc)
##idlibc =  consNewx(def, "IdLib", idc, {
 idLib: scopec
})
##idobjc =  consNewx(def, "IdObj", idc, {
 idObj: objc
})
##iddic =  consNewx(def, "IdDic", idc, {
 idDic: dicc
})
##arridc = classNewx(def, "Arrid", [objc], {
 arrid: numc
 arridArr: arrc
})

##confidc = classNewx(def, "Confid", [objc], {
 confidName: strc,
 confidType: classc, 
})
##confidargc = consNewx(def, "ConfidArg", confid)
##confidlocalc = consNewx(def, "ConfidLocal", confid)

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
istypex = &(o, t){
 #c = innateGet(o, "obj")
 @if(innateGet(c, "id") == t){
  @return 1
 }
 @if(typex(c) == "Cons"){
  @return istypex(c, t);
 }
 @each k v c.classParents{
  @if(istypex(o, k)){
   @return 1
  }
 }
 @return 0;
}
dbGetx = &(scope, key){
 #p = ##$env["HOME"]^"/soul/db"
 @if(fileExists(p^".sl")){
  @return fileRead(p^".sl")
 }
 @if(fileExists(p^".slt")){
  @return "@`"^fileRead(p^".slt")^"`"
 }
 @if(fileExists(p)){
  @return "<<>>"
 }
}
scopeGetSubx = &(scope, key, cache){
 #r = scopeGetLocal(scope, key)
 @if(?r){
  @return r
 }
 @if(!?innateGet(scope, noname)){
  #str = dbGetx(scope, key);
  @if(?str){
   //TODO scope get sub
   str = key^"="^str;
   @return
  }  
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
ast2objx = &(scope, gscope, ast)
ast2arrx = &(scope, gscope, arr){
 #arrx = []
 @foreach k arr{
  push(arrx, ast2objx(scope, gscope, k))
 }
 @return arrx
}
ast2objx = &(scope, gscope, ast){
 #t = ast[0]
 #v = ast[1]
 @if(t == "str"){
  @return objNew(strc, {val: v});
 }
 @if(t == "num"){
  @return objNew(numc, {val: num(v)}); 
 }
 @if(t == "null"){
  @return objNew(nullc, {val: null()});  
 }
 
 @if(t == "call"){
  @return objNew(callc, {
   callFunc: ast2objx(scope, gscope, v);
   callArgs: ast2arrx(scope, gscope, ast[2])
  })
 }
 @if(t == "assign"){
 }
 @if(t == "get"){
 }
 @if(t == "ctrl"){
 } 
 
 @if(t == "id"){
  @if(scopeGetLocal(scope, v)){
   @return objNew(idlocalc, {id: v})
  }
  @if(scopeGetLocal(gscope, v)){
   @return objNew(idglobalc, {id: v})
  }  
  #r = scopeGetx(scope, v)
  @if(!?r){
   die(v^"not defined")
  }
  @return r;
 }
 @if(t == "idlib"){
  #r = scopeGetx(scope, v)
  @if(!?r){
   die(v^"not defined")
  }  
  @return r;
 }
 @if(t == "idglobal"){
  //varnew 
  @return objNew(idglobalc, {id: v}) 
 }
 @if(t == "idlocal"){
  //varnew
  @return objNew(idlocalc, {id: v}) 
 }

 @if(t == "arr"){
 }
 @if(t == "dic"){
  #tt = ast[2]
  @if(!?tt){
   #kall = 1;
   @each k va v{
    @if(?va[1]){
     kall = 0;
     @break
    }
   }
   @if(kall){
    tt = "Dic"
   }@else{
    tt = "Block"
   }
  }
  @if(tt == "Block" || tt == "BlockNovar"){
   #arr = []
   #labels = {}
   @each i e v{
    push(arr, ast2objx(scope, gscope, e[0]))
    labels[e[1]] = objNew(numc, {val: num(i)})
   }
   @if(tt == "BlockNovar"){
    @return objNew(blockc, {
     block: arr
     blockLabels: labels
     blockNovar: 1     
    })
   }
   @return objNew(blockc, {
    block: arr
    blockLabels: labels
   })
  }
  @if(tt == "Dic"){
  }
  
 }
 @if(t == "func"){
  #block = v[0];
  #argts = v[1][0];
  #return = v[1][1];
  #funcArgts = []
  @foreach argast argts{
   push(funcArgts, objNew(argtc, {
    argtName: argast[0]
    argtType: ast2objx(scope, gscope, argast[1])
   }))
  }
  @if(return){
   #funcReturn = ast2objx(scope, gscope, return);
  }
  @if(!?block){
   @return objNew(funcblockc, {
    funcArgts: funcArgts,
    funcReturn: funcReturn
   })
  }
  block[2] = "Block"
  #nscope = scopeNewx(scope);
  @each i a funcArgts{
   #x = objNew(confidargc, {
    confidName: a.argtName
    confidType: a.argtType
   })
   scopeSet(nscope, i, x) 
   scopeSet(nscope, a.argtName, x)  
  }
  #b = ast2objx(nscope, gscope, block)
  @return objNew(funcblockc, {
   func: b
   funcArgts: funcArgts,
   funcReturn: funcReturn
  })  
 }
 @if(t == "tpl"){
  @return objNew(functplc, {func: v})
 }
 @if(t == "class"){
 }
 @if(t == "cons"){
 }
 @if(t == "obj"){
 }
 @if(t == "scope"){
 }
 
 die("unknown type"^t)
}

progl2objx = &(scope, gscope, str){
 #ast = proglParse(str)
 #r = ast2objx(scope, gscope, ast)
 @return r
}

//////////////define call function

blockExecx = &(){
}
idExecx = &(){
}
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
 @if(typex(deft) == "Cons"){
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
tplCallx = &(str, args, env){
 @if(!str){ @return ""}
 #tstr = tplParse(str);
 #tscope = scopeNewx(def) 
 #o = progl2objx(tscope, env.envGlobalScope, tstr);
 #nenv = @ReprEnvx {
  envDefScope: tscope
  envGlobalScope: env.envGlobalScope
 
  envExecScope: execsp
  envExecCache: ##defExecCache,
  envState: {},
  envGlobal: env.envGlobal,
  envStack: [], 
 }
 
 
}
callx = &(func, args, env){
 #t = typex(func);
 @if(t == "FuncNative"){
  @return callNative(func.func, args, env)
 }
 @if(t == "FuncTpl"){
  @return tplCallx(func.func, args, env);
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

##globalsp = scopeNewx(root, "global");
##gensp = scopeNewx(root, "gen");
##defExecCache = {}

#deftmp = scopeNewx(def),
#globaltmp = scopeNewx(globalsp)


#testc = progl2objx(deftmp, globaltmp, fileRead(##$argv[0]))

#env = @ReprEnvx {
 envDefScope: deftmp
 envGlobalScope: globaltmp
 
 envExecScope: execsp,
 envExecCache: {},
 envState: {},
 envGlobal: {},
 envStack: [],
}


log(execx(testc, env))