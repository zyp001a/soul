////////define structure

ReprScopex = % Struct {
 val: Dic
 scopeParents: Dic
}
ReprCurryx = % Struct {
 curry: Dic,
 curryClass: Class
}
ReprClassx = % Struct {
 classCurry: Dic,
 classSchema: Dic
 classParents: Dic
}
////////define basic class/curry
routex = &(oo, scope, name){
 #o = asobj(oo)
 @if(!o->index){
  o->index = 0
 }
 @if(!scope){
  @return o
 }
 @if(!?name){
  name = str(o->index)
  o->index ++
  o->noname = 1
 }
 scopeSet(scope, name, o);
 o->name = name
 #id = scope->id
 @if(!?id){
  o->id = "."
  o->ns = name
 }@elif(id == "."){
  o->id = name
  o->ns = scope->ns
 }@elif(scope->noname){
  o->id = name
  o->ns = scope->ns^"/"^id
 }@else{
  o->id = id^"_"^name
  o->ns = scope->ns
 }
 o->scope = scope
 @return o;
}

parentSetx = &(p, k, parents){
 @foreach e parents{
  //TODO reduce
  p.(k)[e->id] = e;
 }
}
scopePresetx = &(scope, name, parents){
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
classPresetx = &(scope, name, parents, schema){
 #x = @ReprClassx {
  classCurry: {}
  classSchema: schema || {}
  classParents: {}
 }
 @if parents {
  parentSetx(x, "classParents", parents)
 }
 routex(x, scope, name);
 @return x;
}

##root = scopePresetx()
##def = scopePresetx(root, "def")

##objc = classPresetx(def, "Obj")
##classc = classPresetx(def, "Class", [objc])
##scopec = classPresetx(def, "Scope", [objc])

root->obj = scopec
def->obj = scopec
objc->obj = classc
classc->obj = classc
scopec->obj = classc


scopeNewx = &(scope, name, parents){
//TODO when key match "_"
 #x = scopePresetx(scope, name, parents)
 innateSet(x, "obj", scopec)
 @return x
}
scopeIntox = &(scope, key){
 #nscope = scope
 #arr = split(key, "_")
 @each i e arr{
  #xr = scopeGetLocal(scope, e)
  @if(!?xr){
   nscope = scopeNewx(nscope, e)
  }@else{
   nscope = xr;
  }
 }
 @return nscope
}

classNewx = &(scope, name, parents, schema){
 #x = classPresetx(scope, name, parents, schema)
 x->obj = classc
 @return x
}

##curryc = classNewx(def, "Curry", [objc])
##valc = classNewx(def, "Val", [objc])

curryInitx = &(class, curry){
 #x = @ReprCurryx {
  curry: curry || {}
  curryClass: class
 }
 x->obj = curryc
 @return x
}
curryNewx = &(scope, name, class, curry){
 //TODO class cannot be def.Curry
 #x = curryInitx(class, curry)
 routex(x, scope, name)
 @return x;
}



##nullc = curryNewx(def, "Null", valc)
##undfc = curryNewx(def, "Undf", valc)
##numc = curryNewx(def, "Num", valc)
##sizetc = curryNewx(def, "Sizet", numc)
##strc = curryNewx(def, "Str", valc)
##charc = curryNewx(def, "Char", strc)
##funcvc = curryNewx(def, "Funcv", valc)

##argtc = classNewx(def, "Argt", [objc], {
 argtName: strc
 argtType: classc
})
##funcc = classNewx(def, "Func", [objc], {
 funcArgts: curryInitx(arrc, {itemsType: argtc})
 funcReturn: classc
})
##blockc = classNewx(def, "Block", [objc], {
 block: arrc,
 blockLabels: curryInitx(arrc, {itemsType: numc})
})
##blocknovarc = curryNewx(def, "BlockNovar", blockc)
##mainc = curryNewx(def, "Main", blockc)

##funcnativec = classNewx(def, "FuncNative", [funcc], {
 func: funcvc
})
##funcblockc = classNewx(def, "FuncBlock", [funcc], {
 func: blockc
 funcCatch: blockc 
})
##functplc = classNewx(def, "FuncTpl", [funcc], {
 func: strc
 funcTplFile: strc
})
##funcinternalc = classNewx(def, "FuncInternal", [funcc], {
})


##itemsc =  classNewx(def, "Items", [valc], {
 itemsType: classc
})
##arrc = curryNewx(def, "Arr", itemsc)
##dicc = curryNewx(def, "Dic", itemsc)
##diccallablec =  curryNewx(def, "DicClass", dicc)


classc.classSchema = {
 classParents: dicc
 classSchema: dicc
}
curryc.classSchema = {
 curry: dicc
 curryClass: classc
}
scopec.classSchema = {
 scope: dicc
 scopeParents: dicc
}

////////define call class/curry

##envc = classNewx(def, "Env", [objc], {
 envFile: strc
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
 callFunc: funcc
 callArgs: arrc
})

##diccallablec =  curryNewx(def, "DicCallable", dicc, {
 itemsType: callablec
})
##arrcallablec =  curryNewx(def, "ArrCallable", arrc, {
 itemsType: callablec
})

##idc = classNewx(def, "Id", [objc])
##sidc =  classNewx(def, "Sid", [idc], {
 sid: strc,
})
##sidlocalc =  classNewx(def, "SidLocal", [sidc], {
 sidLocal: scopec
})
##sidglobalc =  classNewx(def, "SidGlobal", [sidc], {
 sidGlobal: scopec
})
##sidobjc =  classNewx(def, "SidObj", [sidc], {
 sidObj: objc
})
##sidinnatec =  classNewx(def, "SidInnate", [sidc], {
 sidInnate: objc
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
##confidargc = curryNewx(def, "ConfidArg", confidc)
##confidlocalc = curryNewx(def, "ConfidLocal", confidc)

##assignc = classNewx(def, "Assign", [objc], {
 assignLeft: idc
 assignRight: objc
})

##opc = classNewx(def, "Op", [objc], {
 opPrecedence: numc
})
##op1c = classNewx(def, "Op1", [opc], {
 op1: objc
})
##op2c = classNewx(def, "Op2", [opc], {
 op2Left: objc
 op2Right: objc
})
//https://en.cppreference.com/w/c/language/operator_precedence
//remove unused
//get and assign are not operators in Soul
##notc = curryNewx(def, "OpNot", op1c, {
 opPrecedence: 10
})
##definedc = curryNewx(def, "OpDefined", op1c, {
 opPrecedence: 10
})
##splusc = curryNewx(def, "OpTimes", op2c, {
 opPrecedence: 20
})
##splusc = curryNewx(def, "OpObelus", op2c, {
 opPrecedence: 20
})
##splusc = curryNewx(def, "OpMod", op2c, {
 opPrecedence: 20
})
##plusc = curryNewx(def, "OpPlus", op2c, {
 opPrecedence: 30
})
##plusc = curryNewx(def, "OpSplus", op2c, {
 opPrecedence: 30
})
##splusc = curryNewx(def, "OpMinus", op2c, {
 opPrecedence: 30
})
##splusc = curryNewx(def, "OpGe", op2c, {
 opPrecedence: 40
})
##splusc = curryNewx(def, "OpLe", op2c, {
 opPrecedence: 40
})
##splusc = curryNewx(def, "OpGt", op2c, {
 opPrecedence: 40
})
##splusc = curryNewx(def, "OpLt", op2c, {
 opPrecedence: 40
})

##splusc = curryNewx(def, "OpEq", op2c, {
 opPrecedence: 50
})
##splusc = curryNewx(def, "OpNe", op2c, {
 opPrecedence: 50
})

##splusc = curryNewx(def, "OpAnd", op2c, {
 opPrecedence: 60
})
##splusc = curryNewx(def, "OpOr", op2c, {
 opPrecedence: 70
})
##definedc = curryNewx(def, "OpDefinedor", op1c, {
 opPrecedence: 80
})

##includec = classNewx(def, "Include", [objc], {
 include: strc
})

##ctrlc = classNewx(def, "Ctrl", [objc])
##ctrlargsc = classNewx(def, "CtrlArgs", [ctrlc], {
 ctrlArgs: arrc
})

##ctrlifc = curryNewx(def, "CtrlIf", ctrlargsc)
##ctrlforc = curryNewx(def, "CtrlFor", ctrlargsc)
##ctrleachc = curryNewx(def, "CtrlEach", ctrlargsc)
##ctrlforeachc = curryNewx(def, "CtrlForeach", ctrlargsc)
##ctrlwhilec = curryNewx(def, "CtrlWhile", ctrlargsc)

##ctrlbreakc = curryNewx(def, "CtrlBreak", ctrlc)
##ctrlcontinuec = curryNewx(def, "CtrlContinue", ctrlc)
##ctrlgotoc = curryNewx(def, "CtrlGoto", ctrlargsc)

##ctrlreturnc = curryNewx(def, "CtrlReturn", ctrlargsc)
##ctrlthrowc = curryNewx(def, "CtrlThrow", ctrlargsc)

##returnc = classNewx(def, "Return", [ctrlc], {
 return: objc
})
##throwc = classNewx(def, "Throw", [ctrlc], {
 throw: errorc
})

##errorc = classNewx(def, "Error", [objc], {
 errorCode: numc
 errorMsg: strc
})

typex = &()
curryInitx = &()
methodNewx = &(c, name, fn){
 fn->name = name
 fn->id = c->id^"$"^name
 #t = typex(c)
 @if(t == "Curry"){
  c.curry[name] = fn;
  @return fn
 }
 @if(t == "Class"){
  c.classCurry[name] = fn
  c.classSchema[name] = curryInitx(funcc, {
   funcArgts: fn.funcArgts
   funcReturn: fn.funcReturn
  })
  @return fn
 }
 die("methodNewx: type not defined, "^typex(c))
}

////////////define types for gen




fnNewx = &(scope, name, fn){
 routex(fn, scope, name);
 //TODO if  raw
 @return fn
}
callNewx = &(func, args){
 #x = objNew(callc, {
  callFunc: func
  callArgs: args
 })
 x->obj = callc
 @return x;
}

//predefined basic function, like c header, TODO delete
scopeGetx = &()
execx = &()
blockExecx = &()
callx = &()
istypex = &()
typex = &()
progl2objx = &()
curryGetx = &()
curryListx = &()
classGetx = &()
/////////define method
methodNewx(strc, "split", repr(&(env, s, sep){
 @return split(s, sep)
}))
methodNewx(dicc, "get", repr(&(env, dic, key){
 @return objNew(siddicc, {
  sid: key
  sidDic: dic
 })
}))
methodNewx(arrc, "get", repr(&(env, arr, key){
 @return objNew(aidc, {
  aid: key
  aidArr: arr
 })
}))

/////////define bridge internal function
fnNewx(def, "tilde", repr(&(env, x){
 @return "~"
}))
fnNewx(def, "genuid", repr(&(env, eenv){
 #x = str(eenv.envDefScope->index)
 eenv.envDefScope->index ++
 @return x
}))
fnNewx(def, "log", repr(&(env, x){
 log(x)
}))
fnNewx(def, "logx", repr(&(env, x){
 logx(x)
}))
fnNewx(def, "ucfirst", repr(&(env, x){
 @return ucfirst(x)
}))
fnNewx(def, "uc", repr(&(env, x){
 @return uc(x)
}))
fnNewx(def, "lc", repr(&(env, x){
 @return lc(x)
}))
fnNewx(def, "die", repr(&(env, x){
 die(x)
}))
fnNewx(def, "len", repr(&(env, x){
 @return len(x)
}))
fnNewx(def, "strlen", repr(&(env, x){
 @return strlen(x)
}))
fnNewx(def, "str", repr(&(env, x){
 @return str(x)
}))
fnNewx(def, "num", repr(&(env, x){
 @return num(x)
}))
fnNewx(def, "dic", repr(&Dic(env, x){
 @return x
}))
fnNewx(def, "push", repr(&(env, a, e){
 push(a, e)
 @return e;
}))
fnNewx(def, "join", repr(&(env, a, s){
 @return join(a, s)
}))
fnNewx(def, "split", repr(&Arr(env, a:Str, s){
 @return split(a, s)
}))
fnNewx(def, "escape", repr(&(env, s){
 @return replaceAll(s, "[\n\t\r]", &(x){
  @if(x == "\n"){ @return "\\n" }
  @if(x == "\t"){ @return "\\t" }
  @if(x == "\r"){ @return "\\r" }
 })
}))
fnNewx(def, "opp", repr(&(env, subo, o, nenv){
//op with parenthesis or not
 @if(!istypex(subo, "Op")){
  @return execx(subo, nenv)
 }
 @if(subo.opPrecedence > o.opPrecedence){
  @return "(" + execx(subo, nenv) + ")"
 }
 @return execx(subo, nenv)
}))
//TODO change ind to replace \n to \n__
fnNewx(def, "indInline", repr(&(env, x){

}));
fnNewx(def, "ind", repr(&(env, x){
//indent text
 #indent = env.envGlobal["$indent"]
 #arr = split(x, "\n")
 @for #i =0;i<len(arr);i+=1 {
  @if arr[i] != "" {
   arr[i] = indent + arr[i]
  }
 }
 #r = join(arr, "\n")
 @return r
}))
##concatf = fnNewx(def, "concat", repr(&(env, l, r){
 @return l+r
}))
fnNewx(def, "str", repr(&(env, o){
 @return str(o)
}))
fnNewx(def, "num", repr(&(env, o){
 @return num(o)
}))
##currygetf = fnNewx(def, "curryGet", repr(&(env, class, key){
 @return curryGetx(class, key)
}))
fnNewx(def, "curryList", repr(&(env, class){
 @return curryListx(class, {})
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
fnNewx(def, "innateGet", repr(&(env, o, k){
 @return objNew(sidinnatec, {
  sid: k
  sidInnate: o
 })
}))
fnNewx(def, "scopeGet", repr(&(env, s, key){
 @return scopeGetx(s, key)
}))
fnNewx(def, "scopeGetLocal", repr(&(env, s, key){
 @return scopeGetLocal(s, key)
}))
fnNewx(def, "scopeSet", repr(&(env, s, key, v){
 @return scopeSet(s, key, v)
}))
fnNewx(def, "call", repr(&(env, func, args, env){
 @return callx(func, args, env)
}))
fnNewx(def, "exec", repr(&(env, o, eenv){
 @if(eenv){
  @return execx(o, eenv)
 }
 @return execx(o, env) 
}))
fnNewx(def, "fileRead", repr(&(env, f){
 @return fileRead(f)
}))
fnNewx(def, "fileWrite", repr(&(env, f, sstr){
 @return fileWrite(f, sstr)
}))
fnNewx(def, "fileExists", repr(&(env, f){
 @return fileExists(f)
}))
fnNewx(def, "progl2obj", repr(&(env, scope, gscope, sstr){
 @return progl2objx(scope, gscope, sstr)
}))
fnNewx(def, "istype", repr(&(env, o, s){
 @return istypex(o, s)
}))
fnNewx(def, "type", repr(&(env, o){
 @return typex(o)
}))
fnNewx(def, "asval", repr(&(env, o){
 @return asval(o)
}))
fnNewx(def, "asobj", repr(&(env, o){
 @return asobj(o)
}))
objnewf = fnNewx(def, "objNew", repr(&(env, class, val){
 @return execx(objNew(class, val), env)
}))

////////define basic function
classGetx = &(c, t){
 @if(typex(c) == "Curry"){
  @return classGetx(c.curryClass, t)
 }
 @if(typex(c) == "Class"){
  #x = c.classSchema[t]
  @if(?x){
   @return x;
  }
  @each k v c.classParents{
   #x = classGetx(v, t)
   @if(?x){
    @return x
   }
  }
 }
}
curryListx = &(c, cache){
 @if(typex(c) == "Curry"){
  @each k v c.curry{
	 @if(!?cache[k]){
    cache[k] = v   
	 }
	}
  @return curryListx(c.curryClass, cache)
 }
 @if(typex(c) == "Class"){
  @each k v c.classCurry{
	 @if(!?cache[k]){
    cache[k] = v   
	 }
	}
  @each k v c.classParents{
   curryListx(v, cache)  
  }  
 }
 @return cache
}
curryGetx = &(c, t){
 @if(typex(c) == "Curry"){
  #x = c.curry[t]
  @if(?x){
   @return x
  }
  @return curryGetx(c.curryClass, t)
 }
 @if(typex(c) == "Class"){
  #x = c.classCurry[t]
  @if(?x){
   @return x;
  }
  @each k v c.classParents{
   #x = curryGetx(v, t)
   @if(?x){
    @return x
   }
  }
//  die("curryGet: key not found, "^t)
 }
// die("curryGet: type error, "^typex(c))
}
typex = &(oo){
 #o = asobj(oo)
 @return o->obj->id
}
typepredx = &(oo){
//type prediction
 #o = asobj(oo)
 #t = typex(o)
 @if(t == "Call"){
  @if(o.callFunc->id == "objNew"){
   @return o.callArgs[0]
  }
  @if(o.callFunc->id == "objGet"){
   #key = o.callArgs[1]
   @if(typex(o.callArgs[1]) != "Str"){
    @return
   }
   #c = typepredx(o.callArgs[0])
   @return classGetx(c, asval(key))
  }
  @if(o.callFunc->id == "Dic$get"){
   @return o->itemsType
  }
  @if(o.callFunc->id == "Arr$get"){
   @return o->itemsType
  }
  @if(o.callFunc->id == "Str$get"){
   @return charc
  }
  @return o.callFunc.funcReturn
 }@elif(t == "SidLocal"){
  @return scopeGetLocal(o.sidLocal, o.sid).confidType
 }@elif(t == "SidGlobal"){
  @return scopeGetLocal(o.sidGlobal, o.sid).confidType
 }@elif(t == "SidObj"){
  @return classGetx(o.sidObj->obj, o.sid)
 }@elif(t == "SidDic"){
  @return o.sidDic.itemsTypes
 }@elif(t == "Aid"){
  @return o.aidArr.itemsTypes
 }@else{
  @return o->obj
 }
}
isclassrx = &(c, t){
 @each k v c.classParents{
  @if(k == "Obj"){
   @return 0
  }
  @if(k == t){
   @return 1;
  }
  @if(isclassrx(v, t)){
   @return 1
  }
 }
 @return 0
}
isclassx = &(c, t){
 @if(c->id == t){
  @return 1
 }
 @if(typex(c) == "Curry"){
  @return isclassx(c.curryClass, t);
 }
 @return isclassrx(c, t);
}
istypex = &(oo, t){
 #o = asobj(oo)
 @return isclassx(o->obj, t)
}
dbPath = &(x){
 @if(!x->ns){
  #ns = ""
 }@else{
  #ns = "/" + x->ns
 }
 @if(!x->id){
  @return ns
 }
 @return ns^"/"^replaceAll(x->id, "_", "/")
}
dbGetx = &(scope, key){
 #p = pathResolve(##$sysenv["HOME"]^"/soul/db"^dbPath(scope)^"/"^replaceAll(key, "_", "/"))
 p = replaceAll(p, "\\$", "-")
 @if(fileExists(p^".sl")){
  @return fileRead(p^".sl")
 }
 @if(fileExists(p^".slt")){
  @return "@`"^fileRead(p^".slt")^"` '"^p^"'"
 }
 @if(fileExists(p)){
  @return "<<>>"
 }
}
progl2objx = &()
scopeGetSubx = &(scope, key, cache){
 #nscope = scope
 #nkey = key; 
 #arr = match(key, "(\\S+)_([^_]+)$")
// SCOPEINTO
 @if(arr){
  nscope = scopeIntox(scope, arr[1])
  nkey = arr[2]
 }
 
 #r = scopeGetLocal(nscope, nkey)
 @if(?r){
  @return r
 }
 @if(!?scope->noname){
  #sstr = dbGetx(scope, key);
  @if(?sstr){
   sstr = nkey^" = "^sstr;
   r = progl2objx(nscope, {}, sstr)
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
 #pscope = scope->scope
 @if(?pscope){
  r = scopeGetx(pscope, key)
  @return r;
 }
}

//////////////define parser function
ast2objx = &(scope, gscope, ast)
ast2arrx = &(scope, gscope, arr){
 #arrx = objNew(arrcallablec, [])
 @foreach v arr{
  push(arrx, ast2objx(scope, gscope, v))
 }
 @return arrx
}
ast2dicx = &(scope, gscope, dic){
 #dicx = objNew(diccallablec, {})
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
  @return asobj(_);
 }
 @if(t == "undf"){
  @return asobj(__);
 }

 @if(t == "call"){
  #f = ast2objx(scope, gscope, v);
  @if(!?f){
   @if(v[0] != "id"){
    log(v)
    die("call func not defined for unknown reason")
   }
  //func not defined, if v[0] is id, do predefine
   #f = objNew(funcblockc, {})
   #pscope = innateGet(scope, "scope")
   routex(f, pscope, v[1])
   innateSet(f, "predefined", 1)
  }
  #arr = ast2arrx(scope, gscope, ast[2])
  @if(v[0] == "get" && v[3] == "obj"){
   #oo = f.callArgs[0]
   #okey = f.callArgs[1]
   unshift(arr, oo)
	 
   #to = typepredx(oo) || objc
   @if(typex(okey) == "Str"){
    f = curryGetx(to, asval(okey))
   }@else{
     f = objNew(callc, {
     callFunc: currygetf,
     callArgs: [to, okey]
    })
   }
  }
  @return objNew(callc, {
   callFunc: f
   callArgs: arr
  })
 }
 @if(t == "assign"){
  #lexdef = 0
  @if(v[0][0] == "id"){
   #key = v[0][1]
	 #nscope = scope
	 #leftname = key
   #arr = match(key, "(\\S+)_([^_]+)$")
  // SCOPEINTO
   @if(arr){
    nscope = scopeIntox(scope, arr[1])
    leftname = arr[2]
   }
   #lv = scopeGetLocal(nscope, leftname)
   @if(lv && (typex(lv) == "ConfidLocal" || typex(lv) == "ConfidArg")){
    lexdef = 0
   }@elif(scopeGetLocal(gscope, leftname)){
    lexdef = 0
   }@else{
    lexdef = 1   //is not global or local var
   }
   @if(lexdef){
    @if(v[1][0] == "func"){
   //func need predefined
     #prefunc = scopeGetLocal(scope, leftname);
     @if(!?prefunc){
      prefunc = objNew(funcblockc, {})
      routex(prefunc, scope, leftname)
     }
     #actfunc = ast2objx(scope, gscope, v[1])
     prefunc.func = actfunc.func
     prefunc.funcArgts = actfunc.funcArgts
     prefunc.funcReturn = actfunc.funcReturn
     prefunc.funcCatch = actfunc.funcCatch     
     innateSet(prefunc, "isdef", 1)
     @return prefunc;
    }@else{
     #r = ast2objx(scope, gscope, v[1])
     routex(r, scope, leftname)
     innateSet(r, "isdef", 1)
		 @if(v[1][0] == "class"){
      @each k currye r.classCurry{
       @if(typex(currye) == "FuncBlock"){
		    methodNewx(r, k, currye)
		   }
			}
		 }
     @return r
    }
   }
	}
  #left = ast2objx(scope, gscope, v[0]);
  #right = ast2objx(scope, gscope, v[1]);
  #op = v[2]
  @if(?op){
   @if(op == "splus"){
    right = objNew(callc, {
     callFunc: concatf
     callArgs: [left, right]
    })
   }@else{
    right = ast2objx(scope, gscope, ["op", op, [v[0], v[1]]])
   }
  }
  #predt = typepredx(right)
  @if(?predt){
    @if(typex(left) == "SidLocal"){
    @if(!?left.sidLocal[left.sid].confidType){
     left.sidLocal[left.sid].confidType = predt
    }
   }
    @if(typex(left) == "SidGlobal"){
    @if(!?left.sidGlobal[left.sid].confidType){
     left.sidGlobal[left.sid].confidType = predt
    }
   }
  }
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
   #to = typepredx(a0)
   @if(!to){
    log(a0)
    die("typepred error")
   }
   @return objNew(callc, {
    callFunc: curryGetx(to, "get")
    callArgs: [a0, a1]
   })	 
  }
  @return objNew(callc, {
   callFunc: scopeGetLocal(def, v3^"Get")
   callArgs: [a0, a1]
  })
 }
 @if(t == "include"){
  @if(!match(v, "\.sl$")){
   v+=".sl"
  }
  #ss = pathResolve(v);
  @if(!fileExists(ss)){
   die("import: file "^s^" not defined")
  }
  @return objNew(includec, {
   include: ss
  })
 }

 @if(t == "ctrl"){
  #args = ast[2]
  @if(v == "foreach"){
   scopeSet(scope, args[0], objNew(confidlocalc, {
    confidName: args[0]
 //    confidType: a.argtType
   }))
   args[2][2] = "BlockNovar"
   @return objNew(ctrlforeachc, {
    ctrlArgs: [
     args[0]
     ast2objx(scope, gscope, args[1])
     ast2objx(scope, gscope, args[2])
    ]
   })
  }
  @if(v == "each"){
   scopeSet(scope, args[0], objNew(confidlocalc, {
    confidName: args[0]
 //    confidType: a.argtType
   }))
   scopeSet(scope, args[1], objNew(confidlocalc, {
    confidName: args[1]
 //    confidType: a.argtType
   }))
   args[3][2] = "BlockNovar"
   @return objNew(ctrleachc, {
    ctrlArgs: [
     args[0]
     args[1]
     ast2objx(scope, gscope, args[2])
     ast2objx(scope, gscope, args[3])
    ]
   })
  }
  @if(v == "if"){
   #l = len(args)
   @for #i=1;i<l;i+=2{
    args[i][2] = "BlockNovar"
   }
   @if(l%2 == 1){
    args[l-1][2] = "BlockNovar"
   }
   @return objNew(ctrlifc, {ctrlArgs: ast2arrx(scope, gscope, args)})
  }
  @if(v == "for"){
   args[3][2] = "BlockNovar"
   @return objNew(ctrlforc, {ctrlArgs: ast2arrx(scope, gscope, args)})
  }
  @if(v == "while"){
   args[1][2] = "BlockNovar"
   @return objNew(ctrlwhilec, {ctrlArgs: ast2arrx(scope, gscope, args)})
  }
  @if(v == "throw"){
   #x = ast2objx(scope, gscope, args[0])
   #tt = typepredx(x) 
   @if(isclassx(tt,"Str")){
    x = objNew(callc, {
     callFunc: objnewf,
	   callArgs: [errorc, objNew(diccallablec, {
      errorCode: 1
      errorMsg: x      
     })]
    })   
   }@elif(!isclassx(tt, "Error")){
    log(x)
    log(tt)
    die("ast2obj: throw grammar error, must be error or string");
   }
   @return objNew(ctrlthrowc, {ctrlArgs: [x]}) 
  }  
  @if(v == "return"){
	 @if(args){
    @return objNew(ctrlreturnc, {
     ctrlArgs: [ast2objx(scope, gscope, args[0])]
    })
	 }@else{
    @return objNew(ctrlreturnc, {
     ctrlArgs: __
    })	 
	 }
  }
  @if(v == "break"){
   @return objNew(ctrlbreakc, {})
  }
  @if(v == "continue"){
   @return objNew(ctrlcontinuec, {})
  }
  @if(v == "goto"){
   @return objNew(ctrlgotoc, {
    ctrlArgs: [ast2objx(scope, gscope, args[0])]
   })
  }
 }

 @if(t == "id"){
  #lv = scopeGetLocal(scope, v)
  @if(lv && (typex(lv) == "ConfidLocal" || typex(lv) == "ConfidArg")){
   @return objNew(sidlocalc, {
    sid: v
    sidLocal: scope
   })
  }
  @if(scopeGetLocal(gscope, v)){
   @return objNew(sidglobalc, {
    sid: v
    sidGlobal: gscope
   })
  }
  #r = scopeGetx(scope, v)
  @if(!?r){
   die("ast2obj: id is not defined, "^v)
  }
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
  @if(!scopeGetLocal(gscope, v)){
   #x = objNew(confidc, {
    confidName: v
    //confidType: a.argtType
   })
   scopeSet(gscope, v, x)	 
	}
  @return objNew(sidglobalc, {
   sid: v
   sidGlobal: gscope
  })
 }
 @if(t == "idlocal"){
  @if(!scopeGetLocal(scope, v)){
   #tt = ast[2]
   @if(tt){
    #x = objNew(confidlocalc, {
     confidName: v
     confidType: ast2objx(scope, gscope, ast[2])
    })
   }@else{
    #x = objNew(confidlocalc, {
     confidName: v
    })   
   }   
   scopeSet(scope, v, x)
	}
  @return objNew(sidlocalc, {
   sid: v
   sidLocal: scope
  })
 }

 @if(t == "arr"){
  #arr = ast2arrx(scope, gscope, v)
  @return arr;
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
    #x = objNew(blocknovarc, {
     block: arr
     blockLabels: labels
    })
   }@else{
    #x = objNew(blockc, {
     block: arr
     blockLabels: labels
    })
   }
   x->scope = scope
   @return x
  }
  @if(tt == "Dic"){
   #dic = ast2dicx(scope, gscope, v)
   @return dic;
  }
  die("cannot determine dic or block");
 }
 @if(t == "func"){
  #block = v[0];
  #argts = v[1][0];
  #return = v[1][1];
  #catch = v[2];  
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
  @if(catch){
   catch[2] = "Block"
   scopeSet(nscope, "$err", objNew(confidargc, {
    confidName: "$err"
    confidType: errorc    
   }))
   #funcCatch = ast2objx(nscope, gscope, catch)
  }
  @return objNew(funcblockc, {
   func: b
   funcArgts: funcArgts,
   funcReturn: funcReturn
   funcCatch: funcCatch   
  })
 }
 @if(t == "tpl"){
  @return objNew(functplc, {
   func: v
   funcTplFile: ast[2]   
  })
 }
 @if(t == "op"){
  #cname = "Op"^ucfirst(v)
  #class = scopeGetLocal(def, cname)
  #args = ast[2]
  @if(len(args) == 1){
   @return objNew(class, {
    op1: ast2objx(scope, gscope, args[0])
   })
  }@else{
   @return objNew(class, {
    op2Left: ast2objx(scope, gscope, args[0])
    op2Right: ast2objx(scope, gscope, args[1])
   })
  }
 }
 @if(t == "class"){
  #parents = ast2arrx(scope, gscope, v);
  #schema = ast2objx(scope, gscope, ast[2])
	@if(?ast[3]){
   #curry = ast2objx(scope, gscope, ast[3])
	}
  #x = @ReprClassx {
   classSchema: schema || {}
   classParents: {}
	 classCurry: curry || {}
  }
  @if parents {
   parentSetx(x, "classParents", parents)
  }
	x->obj = classc
  @return x
 }
 @if(t == "curry"){
  #class = ast2objx(scope, gscope, v)
  #dic = ast2objx(scope, gscope, ast[2])
  @return curryInitx(class, dic)
 }
 @if(t == "obj"){
 //TODO func, dic, arr with spec class
  #c = ast2objx(scope, gscope, v);
	
  @return objNew(callc, {
   callFunc: objnewf,
	 callArgs: [c, ast2objx(scope, gscope, ast[2])]
  })
 }
 @if(t == "scope"){
  #parents = ast2arrx(scope, gscope, v)
  #x = @ReprScopex {
   scope: {}
   scopeParents: {}
  }
  parentSetx(x, "scopeParents", parents)
  innateSet(x, "obj", scopec)
  @return x
 }
 die("ast: unknown type, "^t)
}

progl2objx = &(scope, gscope, sstr){
 #ast = proglParse(sstr)
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
execGetx = &(t, env, cache){
 #e = env.envExecScope
 @if(?scopeGetLocal(e, t)){
  @return scopeGetLocal(e, t);
 }
 @if(!cache){
  cache = {};
 }
 #exect = scopeGetx(e, t)
 @if(?exect){
  e[t] = exect;
  @return exect
 }
 #deft = scopeGetx(env.envDefScope, t)
 @if(typex(deft) == "Curry"){
  #k = innateGet(deft.curryClass, "id")
  @if(cache[k]){ @return; }
  cache[k] = 1;

  exect = execGetx(k, env, cache);
  @if(?exect){
   e[t] = exect;
   @return exect;
  }
 }@else{
  @if(!?deft){
   die("execGet: type not defined, "^t)
  }
  @each k v deft.classParents{
   @if(cache[k]){ @return; }
   cache[k] = 1;
   exect = execGetx(k, env, cache);
   @if(?exect){
    e[t] = exect;
    @return exect;
   }
  }
 }
}
tplCallx = &(functpl, args, env){
 #sstr = functpl.func
 @if(!sstr){ @return ""}
 #tstr = tplParse(sstr);
 #tscope = scopeNewx(def)
 scopeSet(tscope, "$env", objNew(confidlocalc, {
  confidName: "$env"
  confidType: envc
 }))
 @if(functpl.funcTplFile){
  #m = match(functpl.funcTplFile, "([^\\/]+)$")
  @if uc(m[1][0]) == m[1][0] && !match(m[1], "-") {
   tstr = replace(tstr, "#0", m[1]^"#0")
  }
 }
 
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
 @if(functpl.funcTplFile){
  nenv.envFile = functpl.funcTplFile
 }
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
  @return tplCallx(func, args, env);
 }
 @if(t == "FuncBlock"){
  #state = stateNewx(func.funcArgts, args)
  push(env.envStack, env.envState)
  env.envState = state;
  #r = blockExecx(func.func, env)
  @if(r){
   @if(typex(r) == "Return"){
    r = r.return
   }
   @if(typex(r) == "Throw"){
    @if(?func.funcCatch){
     state["$err"] = r.throw
     r = blockExecx(func.funcCatch, env)
     @if(r && typex(r) == "Return"){
      r = r.return
     }
    }
   }
  }
  env.envState = pop(env.envStack)
  @return r;
 }
 log(func)
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
 log("Obj to be defined: "^o->obj->id)
 log(o)
 @return o
}))
fnNewx(execsp, "Val", repr(&(env, o){
 @return asval(o)
}))
fnNewx(execsp, "Func", repr(&(env, o){
 @return o
}))
fnNewx(execsp, "Class", repr(&(env, o){
 @return o
}))
fnNewx(execsp, "Curry", repr(&(env, o){
 @return o
}))
fnNewx(execsp, "Block", repr(&(env, o){
 @return o
}))
fnNewx(execsp, "Scope", repr(&(env, o){
 @return o
}))
fnNewx(execsp, "Error", repr(&(env, o){
 @return o
}))
fnNewx(execsp, "Main", repr(&(env, o){
 #x = blockExecx(o, env)
 @if(typex(x) == "Throw"){
  log("THROW ERROR")
  die(x.throw.errorMsg)
 }
 @return x
}))
fnNewx(execsp, "Call", repr(&(env, o){
 #func = execx(o.callFunc, env)
 @if(!?func){
  log(o.callFunc)
  die("func not defined"); 
 }
 @if(func->predefined){
  log(o.callFunc->scope)
  log(o.callFunc->id)
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
 #v = asval(execx(o.assignRight, env))
 #ov = asobj(v)
 @if(t == "SidGlobal"){
  @return env.envGlobal[l.sid] = v
 }
 @if(t == "SidLocal"){
  @return env.envState[l.sid] = v
 }
 @if(t == "SidObj"){
  @return l.sidObj.(l.sid) = v
 }
 @if(t == "SidInnate"){
  @return (l.sidInnate)->(l.sid) = v
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
fnNewx(execsp, "Include", repr(&(env, inc){
 #s = inc.include
 #gscope = env.envGlobalScope
 #x = gscope["$includes"][s]
 @if(?x){
  @return
 }
 gscope["$includes"][ss] = 1
 #o = progl2objx(env.envDefScope, gscope, "{"^fileRead(s)^"}")
 blockExecx(o, env)
}))
fnNewx(execsp, "CtrlReturn", repr(&(env, o){
 @return objNew(returnc, {
  return: execx(o.ctrlArgs[0], env)
 })
}))
fnNewx(execsp, "CtrlThrow", repr(&(env, o){
 @return objNew(throwc, {
  throw: execx(o.ctrlArgs[0], env)
 })
}))
fnNewx(execsp, "CtrlEach", repr(&(env, o){
 #dic = asval(execx(o.ctrlArgs[2], env))
 #k = o.ctrlArgs[0]
 #v = o.ctrlArgs[1]
 @each key val dic{
  env.envState[k] = key;
  env.envState[v] = val;
  #r = blockExecx(o.ctrlArgs[3], env)
  @if(?r){
   @if(typex(r) == "Return" || typex(r) == "Throw"){
    @return r
   }
   @if(typex(r) == "CtrlBreak"){
    @break
   }
   @if(typex(r) == "CtrlContinue"){
    @continue
   }
  }
 }
}))
fnNewx(execsp, "CtrlForeach", repr(&(env, o){
 #arr = asval(execx(o.ctrlArgs[1], env))
 #k = o.ctrlArgs[0]
 @foreach e arr{
  env.envState[k] = e;
  #r = blockExecx(o.ctrlArgs[2], env)
  @if(?r){
   @if(typex(r) == "Return" || typex(r) == "Throw"){
    @return r
   }
   @if(typex(r) == "CtrlBreak"){
    @break
   }
   @if(typex(r) == "CtrlContinue"){
    @continue
   }
  }
 }
}))
fnNewx(execsp, "CtrlFor", repr(&(env, o){
 execx(o.ctrlArgs[0], env)
 @while(1){
  #c = execx(o.ctrlArgs[1], env)
  @if(c){
   #r = blockExecx(o.ctrlArgs[3], env)
   @if(?r){
    @if(typex(r) == "Return" || typex(r) == "Throw"){
     @return r
    }
    @if(typex(r) == "CtrlBreak"){
     @break
    }
    @if(typex(r) == "CtrlContinue"){
     @continue
    }
   }
  }@else{
   @break
  }
  execx(o.ctrlArgs[2], env)
 }
}))
fnNewx(execsp, "CtrlWhile", repr(&(env, o){
 @while(execx(o.ctrlArgs[0], env)){
  #r = blockExecx(o.ctrlArgs[1], env)
  @if(?r){
   @if(typex(r) == "Return" || typex(r) == "Throw"){
    @return r
   }
   @if(typex(r) == "CtrlBreak"){
    @break
   }
   @if(typex(r) == "CtrlContinue"){
    @continue
   }
  }
 }
}))
fnNewx(execsp, "CtrlIf", repr(&(env, o){
 #l = len(o.ctrlArgs)
 @for #i=0;i<l-1;i+=2 {
  #c = execx(o.ctrlArgs[i], env)
  @if(asval(c)){
   @return blockExecx(o.ctrlArgs[i+1], env)
  }
 }
 @if(l%2 == 1){
  @return blockExecx(o.ctrlArgs[l-1], env)
 }
}))

fnNewx(execsp, "ArrCallable", repr(&(env, o){
 #newo = objNew(arrc, [])
 @each i v o{
  newo[i] = execx(v, env)
 }
// innateSet(newo, "notval", 1)
 @return newo;
}))
fnNewx(execsp, "DicCallable", repr(&(env, o){
 #newo = objNew(dicc, {})
 @each i v o{
  newo[i] = execx(v, env)
 }
// innateSet(newo, "notval", 1)
 @return newo;
}))
fnNewx(execsp, "SidLocal", repr(&(env, o){
 @return env.envState[o.sid]
}))
fnNewx(execsp, "SidGlobal", repr(&(env, o){
 @return env.envGlobal[o.sid]
}))
fnNewx(execsp, "SidInnate", repr(&(env, o){
 @return o.sidInnate->(o.sid)
}))
fnNewx(execsp, "SidObj", repr(&(env, o){
 @return o.sidObj.(o.sid)
}))
fnNewx(execsp, "SidDic", repr(&(env, o){
 @return o.sidDic[o.sid]
}))
fnNewx(execsp, "Aid", repr(&(env, o){
 @return o.aidArr[o.aid]
}))


fnNewx(execsp, "OpSplus", repr(&(env, o){
 @return asval(execx(o.op2Left, env)) + asval(execx(o.op2Right, env))
}))
fnNewx(execsp, "OpPlus", repr(&(env, o){
 @return asval(execx(o.op2Left, env)) + asval(execx(o.op2Right, env))
}))
fnNewx(execsp, "OpMinus", repr(&(env, o){
 @return asval(execx(o.op2Left, env)) - asval(execx(o.op2Right, env))
}))
fnNewx(execsp, "OpTimes", repr(&(env, o){
 @return asval(execx(o.op2Left, env)) * asval(execx(o.op2Right, env))
}))
fnNewx(execsp, "OpObelus", repr(&(env, o){
 @return asval(execx(o.op2Left, env)) / asval(execx(o.op2Right, env))
}))
fnNewx(execsp, "OpMod", repr(&(env, o){
 @return asval(execx(o.op2Left, env)) % asval(execx(o.op2Right, env))
}))
fnNewx(execsp, "OpAnd", repr(&(env, o){
 @if(!asval(execx(o.op2Left, env))){ @return 0 }
 @return asval(execx(o.op2Right, env))
}))
fnNewx(execsp, "OpOr", repr(&(env, o){
 @if(asval(execx(o.op2Left, env))){ @return 1 }
 @return asval(execx(o.op2Right, env))
}))
fnNewx(execsp, "OpDefinedor", repr(&(env, o){
 #x = asval(execx(o.op2Left, env))
 @if(?x){ @return x }
 @return asval(execx(o.op2Right, env))
}))
fnNewx(execsp, "OpNot", repr(&(env, o){
 @return !asval(execx(o.op1, env))
}))
fnNewx(execsp, "OpDefined", repr(&(env, o){
 @return ?asval(execx(o.op1, env))
}))
fnNewx(execsp, "OpNe", repr(&(env, o){
 @return asval(execx(o.op2Left, env)) != asval(execx(o.op2Right, env))
}))
fnNewx(execsp, "OpEq", repr(&(env, o){
 @return asval(execx(o.op2Left, env)) == asval(execx(o.op2Right, env))
}))
fnNewx(execsp, "OpGt", repr(&(env, o){
 @return asval(execx(o.op2Left, env)) > asval(execx(o.op2Right, env))
}))
fnNewx(execsp, "OpLt", repr(&(env, o){
 @return asval(execx(o.op2Left, env)) < asval(execx(o.op2Right, env))
}))
fnNewx(execsp, "OpGe", repr(&(env, o){
 @return asval(execx(o.op2Left, env)) >= asval(execx(o.op2Right, env))
}))
fnNewx(execsp, "OpLe", repr(&(env, o){
 @return asval(execx(o.op2Left, env)) <= asval(execx(o.op2Right, env))
}))


////////////////////utils function

##globalsp = scopeNewx(root, "global");
##gensp = scopeNewx(root, "gen");
##defExecCache = {}


envInitx = &(defsp, execsp, f){
 #defsptmp = scopeNewx(defsp),
 #globalsptmp = scopeNewx(globalsp)
 scopeSet(globalsptmp, "$argv", objNew(confidlocalc, {
  confidName: "$argv",
  confidType: arrc
 }))
 scopeSet(globalsptmp, "$includes", objNew(confidlocalc, {
  confidName: "$includes"
  confidType: dicc
 }))
 scopeSet(globalsptmp, "$funcs", objNew(confidlocalc, {
  confidName: "$funcs"
  confidType: dicc
 }))
 scopeSet(globalsptmp, "$dirname", objNew(confidlocalc, {
  confidName: "$dirname"
  confidType: strc
 }))
 scopeSet(globalsptmp, "$filename", objNew(confidlocalc, {
  confidName: "$filename"
  confidType: strc
 }))
 #globaltmp = {
  $includes: {}
  $funcs: {}
  $argv: ##$argv
  $filename: f
  $dirname: pathDirname(f)
 }
 #deftmp = {}
 @return objNew(envc, {
  envFile: f
  envGlobalScope: globalsptmp
  envDefScope: defsptmp

  envGlobal: globaltmp
  envState: deftmp,
  envStack: [],

  envExecScope: execsp
  envExecCache: {},
 })
}

//////////test
#f = ##$argv[0]
#defsptmp = scopeGetx(def, "web"),
#execsptmp = scopeGetx(gensp, "expressjs"),
#env = envInitx(defsptmp, execsptmp, f)
@if(##$argv[1] == 1){
 env.envExecScope = execsp
}
@if(##$argv[1] == 2){
 env.envExecScope = scopeGetx(gensp, "jssoul"),
}
#objmain = progl2objx(env.envDefScope, env.envGlobalScope, "@Main {"^fileRead(f)^"}")
fileWrite(##$argv[0]^".js", execx(objmain, env))
