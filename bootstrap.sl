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

##callablec = classNewx(def, "Callable", [objc])

##callc = classNewx(def, "Call", [callablec], {
 call: funcc
 callArgs: arrc
})

##diccallablec =  consNewx(def, "DicCallable", dicc)
##arrcallablec =  consNewx(def, "ArrCallable", arrc)

##idc = classNewx(def, "Id", [objc])
##sidc =  classNewx(def, "Sid", [idc], {
 sid: strc,
})
##sidlocalc =  consNewx(def, "SidLocal", sidc)
##sidglobalc =  consNewx(def, "SidGlobal", sidc)
##sidlibc =  classNewx(def, "SidLib", [sidc], {
 sidLib: scopec
})
##sidobjc =  classNewx(def, "SidObj", [sidc], {
 sidObj: objc
})
##siddic = classNewx(def, "SidDic", [sidc], {
 sidDic: dicc
})
##aidc = classNewx(def, "Aid", [idc], {
 aid: numc
 aidArr: arrc
})


##confidc = classNewx(def, "Confid", [objc], {
 confidName: strc,
 confidType: classc, 
})
##confidargc = consNewx(def, "ConfidArg", confid)
##confidlocalc = consNewx(def, "ConfidLocal", confid)

##assignc = classNewx(def, "Assign", [objc], {
 assignLeft: idc
 assignRight: objc
})

##opc = classNewx(def, "Op", [objc])
##op1c = classNewx(def, "Op1", [opc], {
 op1: objc
})
##op2c = classNewx(def, "Op2", [opc], {
 op2Left: objc
 op2Right: objc 
})
##notc = consNewx(def, "Not", op1c)
##definedc = consNewx(def, "Defined", op1c)
##plusc = consNewx(def, "Plus", op2c)
##splusc = consNewx(def, "Splus", op2c)


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

//predefined basic function, like c header
scopeGetx = &()
idExecx = &()
execx = &()
callx = &()

/////////define bridge internal function 
##logf = fnNewx(def, "log", repr(&(env, x){
 log(x)
}))
##assignf = fnNewx(def, "assign", repr(&(env, l, r){
 #left = idExecx(l, env)
 
}))


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
  #leftt = v[0][0] 
  #rightt = v[1][0]  
  @if(leftt == "id"){
   #leftname = v[0][1]
   @if(rightt == "class" || rightt == "cons" || \
    rightt == "scope" || rightt == "tpl" || rightt == "obj"){
    #r = ast2objx(scope, gscope, v[1])
    routex(r, scope, leftname)
    innateSet(r, "isdef", 1)    
    @return r
   }
   @if(rightt == "func"){
    #prefunc = objNew(funcblockc, {})
    routex(prefunc, scope, leftname)
    #actfunc = ast2objx(scope, gscope, v[1])
    prefunc.func = actfunc.func
    prefunc.funcArgts = actfunc.funcArgts
    prefunc.funcReturn = actfunc.funcReturn
    innateSet(prefunc, "isdef", 1)
    @return prefunc;
   }
  }
  #left = ast2objx(scope, gscope, v[0]);
  #right = ast2objx(scope, gscope, v[1]);  
  @return objNew(calllazyc, {
   callFunc: assignf,
   callArgs: [left, right]
  })
 }
 @if(t == "get"){
 }
 @if(t == "ctrl"){
 } 
 
 @if(t == "id"){
  @if(scopeGetLocal(scope, v)){
   @return objNew(sidlocalc, {id: v})
  }
  @if(scopeGetLocal(gscope, v)){
   @return objNew(sidglobalc, {id: v})
  }  
  #r = scopeGetx(scope, v)
  @if(!?r){
   die(v^" not defined")
  }
  @return objNew(sidlibc, {
   id: v
   idLib: innateGet(r, "scope")
  })
 }
 @if(t == "idlib"){
  #r = scopeGetx(scope, v)
  @if(!?r){
   @return;
  }
  @return objNew(sidlibc, {
   id: v
   idLib: innateGet(r, "scope")
  })  
  @return r;
 }
 @if(t == "idglobal"){
  #x = objNew(confidargc, {
   confidName: v
//    confidType: a.argtType
  })
  scopeSet(gscope, v, x)   
  @return objNew(sidglobalc, {id: v}) 
 }
 @if(t == "idlocal"){
  #x = objNew(confidargc, {
   confidName: v
//    confidType: a.argtType
  })
  scopeSet(scope, v, x)
  @return objNew(sidlocalc, {id: v}) 
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
    @if(?e[1]){
     labels[e[1]] = objNew(numc, {val: num(i)})
    }
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
   @if(?argast[1]){
    push(funcArgts, objNew(argtc, {
     argtName: argast[0]
     argtType: ast2objx(scope, gscope, argast[1])    
    }))   
   }@else{
    push(funcArgts, objNew(argtc, {
     argtName: argast[0]
    }))
   }
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
 @if(t == "op"){
 }
 @if(t == "class"){
 }
 @if(t == "cons"){
 }
 @if(t == "obj"){
 }
 @if(t == "scope"){
 }
 
 die("unknown type "^t)
}

progl2objx = &(scope, gscope, str){
 #ast = proglParse(str)
 #r = ast2objx(scope, gscope, ast)
 @return r
}

//////////////define call function

blockExecx = &(){
}
idExecx = &(o, env){
 #t = typex(o)
 @if(istypex(t, "Id")){
  @return o;
 }
 @return execx(o, env)
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
fnNewx(execsp, "Obj", repr(&(env, o){
 @return o
}))
fnNewx(execsp, "Call", repr(&(env, o){
 #func = execx(o.callFunc, env)
 #args = []
 @foreach e o.callArgs{
  push(args, execx(e, env))
 }
 @return callx(func, args, env);
}))
fnNewx(execsp, "CallLazy", repr(&(env, o){
 #func = execx(o.callFunc, env)
 @return callx(func, o.callArgs, env);
}))

////////////////////test

##globalsp = scopeNewx(root, "global");
##gensp = scopeNewx(root, "gen");
##defExecCache = {}

#deftmp = scopeNewx(def),
#globaltmp = scopeNewx(globalsp)


#testc = progl2objx(deftmp, globaltmp, fileRead(##$argv[0]))

log(testc)

#env = @ReprEnvx {
 envDefScope: deftmp
 envGlobalScope: globaltmp
 
 envExecScope: execsp,
 envExecCache: {},
 envState: {},
 envGlobal: {},
 envStack: [],
}


//log(execx(testc, env))
