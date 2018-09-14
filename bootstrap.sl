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

////////define basic class/cons

routex = &(oo, scope, name){
 #o = asobj(oo)
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
parentSetx = &(p, k, parents){
 @foreach e parents{
  //TODO reduce
  p[k][innateGet(e, "id")] = e;
 }
}
scopeInitx = &(scope, name, parents){
 #x = @ReprScopex {
  scope: {}
  scopeParents: {}
 }
 @if parents {
  parentSetx(x, "scopeParents", parents)
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
  parentSetx(x, "classParents", parents) 
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
 blockLabels: consInitx(arrc, {itemsType: numc})
})
##blocknovarc = consNewx(def, "BlockNovar", blockc)
##mainc = consNewx(def, "Main", blockc)

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
##sidobjc =  classNewx(def, "SidObj", [sidc], {
 sidObj: objc
})
##siddicc = classNewx(def, "SidDic", [sidc], {
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

##ctrlc = classNewx(def, "Ctrl", [objc])
##ctrlArgsc = classNewx(def, "CtrlArgs", [], {
 ctrlArgs: arrc
})

##ctrlbreakc = consNewx(def, "CtrlBreak", ctrlc)
##ctrlcontinuec = consNewx(def, "CtrlContinue", ctrlc)

##ctrlreturnc = consNewx(def, "CtrlReturn", ctrlargsc)
##ctrlgotoc = consNewx(def, "CtrlGoto", ctrlargsc)

##ctrlifc = consNewx(def, "CtrlIf", ctrlargsc)
##ctrlforc = consNewx(def, "CtrlFor", ctrlargsc)
##ctrleachc = consNewx(def, "CtrlEach", ctrlargsc)
##ctrlforeachc = consNewx(def, "CtrlForeach", ctrlargsc)
##ctrlwhilec = consNewx(def, "CtrlWhile", ctrlargsc)

##returnc = classNewx(def, "Return", [ctrlc], {
 return: objc
})

fnNewx = &(scope, name, fn){
 innateSet(fn, "obj", funcnativec)
 routex(fn, scope, name);
 //TODO if  raw
 @return fn
}
callNewx = &(func, args){
 #x = objNew(callc, {
  callFunc: func
  callArgs: args
 })
 innateSet(x, "obj", callc)
 @return x;
}

//predefined basic function, like c header
scopeGetx = &()
idExecx = &()
execx = &()
callx = &()

/////////define bridge internal function 
fnNewx(def, "log", repr(&(env, x){
 log(x)
}))
fnNewx(def, "push", repr(&(env, a, e){
 push(a, e)
 @return e;
}))
fnNewx(def, "join", repr(&(env, a, s){
 @return join(a, s) 
}))
fnNewx(def, "dicGet", repr(&(env, dic, key){
 @return objNew(siddicc, {
  sid: key
	sidDic: dic
 })
}))
fnNewx(def, "objGet", repr(&(env, obj, key){
 @return objNew(sidobjc, {
  sid: key
	sidObj: obj
 })
}))
fnNewx(def, "scopeGet", repr(&(env, obj, key){
 @return scopeGetx(obj, key)
}))
fnNewx(def, "call", repr(&(env, func, args, env){
 @return callx(func, args, env)
}))


////////define basic function

typex = &(oo){
 #o = asobj(oo)
 @return innateGet(innateGet(o, "obj"), "id")
}
istypex = &(oo, t){
 #o = asobj(oo)
 #c = innateGet(o, "obj")
 @if(innateGet(c, "id") == t){
  @return 1
 }
 @if(typex(c) == "Cons"){
  @return istypex(c.consClass, t);
 }
 @each k v c.classParents{
  @if(k == "Obj"){
   @return 0
  }
  @if(k == t){
   @return 1;
  }
  @if(istypex(v, t)){
   @return 1
  }
 }
 @return 0;
}
dbPath = &(x){
 @if(!innateGet(x, "ns")){
  #ns = ""
 }@else{
  #ns = "/" + innateGet(x, "ns")
 }
 @if(!innateGet(x, "id")){
  @return ns
 }
 @return ns^"/"^replaceAll(innateGet(x, "id"), "_", "/")
}
dbGetx = &(scope, key){
 #p = ##$sysenv["HOME"]^"/soul/db"^dbPath(scope)^"/"^replaceAll(key, "_", "/")
 log(p)
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
progl2objx = &()
scopeGetSubx = &(scope, key, cache){
//  TODO scope get sub
 #nscope = scope;
 #nkey = key; 
 #r = scopeGetLocal(nscope, nkey)
 @if(?r){
  @return r
 }
 @if(!?innateGet(scope, "noname")){
  #str = dbGetx(scope, key);
  @if(?str){
   str = nkey^"="^str;
	 r = progl2objx(nscope, {}, str)
   @return r;
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
 @foreach v arr{
  push(arrx, ast2objx(scope, gscope, v))
 }
 @return arrx
}
ast2dicx = &(scope, gscope, dic){
 #dicx = {}
 @foreach v dic{
  dicx[v[1]] = ast2objx(scope, gscope, v[0])
 }
 @return dicx
}
ast2objx = &(scope, gscope, ast){
 #t = ast[0]
 #v = ast[1]
 @if(t == "str"){
  @return asobj(v);
 }
 @if(t == "num"){
  @return asobj(num(v)); 
 }
 @if(t == "null"){
  @return asobj(null());  
 }
 
 @if(t == "call"){
  #f = ast2objx(scope, gscope, v);
	@if(!?f){
	 @if(v[0] != "id"){
    log(v)
	  die("call func not defined for unknown reason")	 
	 }
   #f = objNew(funcblockc, {})
	 #pscope = innateGet(scope, "scope")
   routex(f, pscope, v[1])
	 innateSet(f, "predefined", 1)	 
	}
  @return objNew(callc, {
   callFunc: f
   callArgs: ast2arrx(scope, gscope, ast[2])
  })
 }
 @if(t == "assign"){
	#lexdef = 0
  @if(v[0][0] == "id"){
	 #vv = v[0][1]
   #lv = scopeGetLocal(scope, vv)
   @if(lv && (typex(lv) == "ConfidLocal" || typex(lv) == "ConfidArg")){
    lexdef = 0
   }@elif(scopeGetLocal(gscope, vv)){
    lexdef = 0
   }@else{
    lexdef = 1	 
	 }
  }
	@if(lexdef){
   #leftname = v[0][1]
   @if(v[1][0] == "func"){
	 //func need predefined
	  #prefunc = scopeGetLocal(scope, leftname);
		@if(!?prefunc){
     prefunc = objNew(funcblockc, {})
     routex(prefunc, scope, leftname)
		 innateSet(prefunc, "predefined", 1)
		}
    #actfunc = ast2objx(scope, gscope, v[1])
    prefunc.func = actfunc.func
    prefunc.funcArgts = actfunc.funcArgts
    prefunc.funcReturn = actfunc.funcReturn
    innateSet(prefunc, "isdef", 1)
    @return prefunc;
   }@else{
    #r = ast2objx(scope, gscope, v[1])
    routex(r, scope, leftname)
    innateSet(r, "isdef", 1)    
    @return r
   }
  }
  #left = ast2objx(scope, gscope, v[0]);
  #right = ast2objx(scope, gscope, v[1]);  
  @return objNew(assignc, {
   assignLeft: left,
   assignRight: right
  })
 }
 @if(t == "get"){
  #a0 = ast2objx(scope, gscope, v)
  #a1 = ast2objx(scope, gscope, ast[2])
	#v3 = ast[3]
	@if(ast[3] == "items"){
	 v3 = "dic" //TODO check dic or arr
	}
	@return objNew(callc, {
	 callFunc: scopeGetLocal(def, v3^"Get")
	 callArgs: [a0, a1]
	})
 }
 @if(t == "ctrl"){
  #args = ast[2]
  @if(v == "foreach"){
   #x = objNew(confidlocalc, {
    confidName: args[0]
 //    confidType: a.argtType
   })
   args[2][2] = "BlockNovar"
   @return objNew(ctrlforeachc, {
    ctrlArgs: [
     asobj(args[0])
     ast2objx(scope, gscope, args[1])
     ast2objx(scope, gscope, args[2])     
    ]
   })
  }
  @if(v == "if"){
   
  }
  @if(v == "return"){
   @return objNew(ctrlreturnc, {
    ctrlArgs: [ast2objx(scope, gscope, args[0])]
   })  
  }
  @if(v == "break"){
   @return objNew(ctrlbreakc, {})
  }
  
 } 
 
 @if(t == "id"){
  #lv = scopeGetLocal(scope, v)
  @if(lv && (typex(lv) == "ConfidLocal" || typex(lv) == "ConfidArg")){
   @return objNew(sidlocalc, {sid: v})
  }
  @if(scopeGetLocal(gscope, v)){
   @return objNew(sidglobalc, {sid: v})
  }  
  #r = scopeGetx(scope, v)
	@return r;
 }
 @if(t == "idlib"){
  #r = scopeGetx(scope, v)
  @if(!?r){
   die(v^" not defined")	
  }
	@return r;
 }
 @if(t == "idglobal"){
  #x = objNew(confidc, {
   confidName: v
//    confidType: a.argtType
  })
  scopeSet(gscope, v, x)   
  @return objNew(sidglobalc, {sid: v}) 
 }
 @if(t == "idlocal"){
  #x = objNew(confidlocalc, {
   confidName: v
//    confidType: a.argtType
  })
  scopeSet(scope, v, x)
  @return objNew(sidlocalc, {sid: v}) 
 }

 @if(t == "arr"){
  #arr = ast2arrx(scope, gscope, v)
  #arrx = objNew(arrcallablec, arr)
  @return arrx;
 }
 @if(t == "dic"){
  #tt = ast[2]
  @if(!?tt){
   #kall = 1;
   @each k va v{
    @if(!?va[1]){
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
    @return objNew(blocknovarc, {
     block: arr
     blockLabels: labels
    })
   }
   @return objNew(blockc, {
    block: arr
    blockLabels: labels
   })
  }
  @if(tt == "Dic"){
   #dic = ast2dicx(scope, gscope, v)
   #dicx = objNew(diccallablec, dic)
   @return dicx;
  }
  die("cannot determine dic or block");
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
 //TODO func, dic, arr with spec class
	#c = ast2objx(scope, gscope, v);
  @return objNew(c, ast2objx(scope, gscope, ast[2]))
 }
 @if(t == "scope"){
  #parents = ast2arrx(scope, gscope, v)
	#x = objNew(scopec, {})
  parentSetx(x, "scopeParents", parents) 	
	@return x
 }
 die("ast: unknown type, "^t)
}

progl2objx = &(scope, gscope, str){
 #ast = proglParse(str)
 #r = ast2objx(scope, gscope, ast)
 @return r
}

//////////////define call function

blockExecx = &(block, env, sttlabel){
 @if(sttlabel){
  #stt = block.labels[sttlabel]
 }
 @each i v block.block{
  @if(sttlabel && stt < i){
   @continue
  }
  #r = execx(v, env)
  @if(r && istypex(r, "Ctrl")){
   @return r;
  }
 }
}
idExecx = &(oo, env){
 #o = asobj(oo)
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
 #s = {}
 s["$env"] = env;
 s["$arglen"] = args.length
 @each i v args{
  s[i] = v;
 }
 #nenv = objNew(envc,  {
  envDefScope: tscope
  envGlobalScope: env.envGlobalScope
 
  envExecScope: execsp
  envExecCache: ##defExecCache,
  envState: s,
  envGlobal: env.envGlobal,
  envStack: [], 
 })
 #r = blockExecx(o, nenv);
 @return r.return;  
}
stateNewx = &(argts, args){
 #state = {}
 @each i v args{
  state[i] = state[argts[i].argtName] = v
 }
 state["$arglen"] = len(args);
 @return state
}
callx = &(func, args, env){
 #t = typex(func);
 @if(t == "FuncNative"){
  @return callNative(func.func, args, env)
 }
 @if(t == "FuncTpl"){
  @return tplCallx(func.func, args, env);
 }
 @if(t == "FuncBlock"){
  #state = stateNewx(func.funcArgts, args)
  push(env.envStack, env.envState)
  env.envState = state;
  #r = blockExecx(func.func, env)
  @if(r && typex(r) == "Return"){
   r = r.return
  }
  env.envState = pop(env.envStack)
  @return r;
 }
 die(t^": exec not defined")
}
execx = &(oo, env){
 #o = asobj(oo)
 #t = typex(o)
 @if(!?t){
  log(o)
	die("no type defined")
 }
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
fnNewx(execsp, "Main", repr(&(env, o){
 @return blockExecx(o, env)
}))
fnNewx(execsp, "Call", repr(&(env, o){
 #func = execx(o.callFunc, env)
 @if(innateGet(func, "predefined")){
  log(innateGet(o.callFunc, "id"))
  die("func not defined");
 }  
 #args = []
 @foreach e o.callArgs{
  push(args, asval(execx(e, env)))
 }
 @return callx(func, args, env);
}))
fnNewx(execsp, "Assign", repr(&(env, o){
 #l = o.assignLeft
 #t = typex(l)
 @if(t == "Call"){
  l = execx(o.assignLeft, env);
	t = typex(l)
 }
 #v = execx(o.assignRight, env);
 @if(t == "SidGlobal"){
  @return env.envGlobal[l.sid] = v
 }
 @if(t == "SidLocal"){
  @return env.envState[l.sid] = v
 }
 @if(t == "SidObj"){
  @return l.sidObj[l.sid] = v 
 }
 @if(t == "SidDic"){
  @return l.sidDic[l.sid] = v 
 }
 @if(t == "Aid"){
  @return l.aidArr[l.aid] = v  
 }
 log(l)
 die("left not assignable");
}))
fnNewx(execsp, "CtrlReturn", repr(&(env, o){
 @return objNew(returnc, {
  return: execx(o.ctrlArgs[0], env)
 })
}))
fnNewx(execsp, "ArrCallable", repr(&(env, o){
 #newo = objNew(arrc, [])
 @each i v o{
  newo[i] = execx(v, env)  
 }
 innateSet(newo, "notval", 1)
 @return newo;
}))
fnNewx(execsp, "SidLocal", repr(&(env, o){
 @return env.envState[o.sid]
}))
fnNewx(execsp, "SidGlobal", repr(&(env, o){
 @return env.envGlobal[o.sid]
}))
////////////////////test

##globalsp = scopeNewx(root, "global");
##gensp = scopeNewx(root, "gen");
##defExecCache = {}

#deftmp = scopeNewx(def),
#globaltmp = scopeNewx(globalsp)


#testc = progl2objx(deftmp, globaltmp, "@Main {"^fileRead(##$argv[0])^"}")

#env = objNew(envc, {
 envDefScope: deftmp
 envGlobalScope: globaltmp
 
 envExecScope: scopeGetx(gensp, "soul"),
 //envExecScope: scopeNewx(execsp), 
 envExecCache: {},
 envState: {},
 envGlobal: {},
 envStack: [],
})


log(execx(testc, env))