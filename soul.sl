/////1 set class/structs
T = =>Enum {
 enum: [
  "NULL", "INT", "NUM", "STR", "CHAR", "DIC", "ARR", "VALFUNC"
  "CLASS", "OBJ"
 ]
}
Routex = <>{
 name: Str
 id: Str
 ns: Str
 index: Uint
 scope: Objx
 noname: Int//TODO change to Boolean
}
Dicx = => Dic {
 itemsType: Objx
}
Objx = <>{
 type: T
 mid: Boolean
 route: Routex
 class: Objx
 schema: Dicx
 curry: Dicx
 parents: Dicx
 val: Val
}
Arrx = => Arr {
 itemsType: Objx
}
Classx = <>{
}
/////2 preset root ...
routex = &(o Objx, scope Objx, name Str)Objx{
 @if(!o.route){
  o.route = &Routex{}
 }
 #r = o.route;
 #sr = scope.route
 @if(!r.index){
  r.index = 0
 }
 @if(!name){
  name = str(r.index)
  r.index ++
  r.noname = 1
 }
 scope.dic[name] = o
 r.name = name;
 #id = sr.id
 @if(!id){
  r.id = "."
  r.ns = name
 }@elif(id == "."){
  r.id = name
  r.ns = sr.ns  
 }@elif(sr.noname != 0){
  r.id = name
  r.ns = sr.ns + "/" + id
 }@else{
  r.id = id + "_" + name
  r.ns = sr.ns
 }
 r.scope = scope
 @return o;
}
parentsMakex = &(parentarr Arrx)Dicx{
 @if parentarr == _ {
  @return
 }
 #x = @Dicx{}
 @foreach e parentarr{
  //TODO reduce
  x[e.route.id] = e;
 }
 @return x
}
classmPresetx = &(parentarr Arrx)Objx{
 #x = &Objx{
  type: @T("CLASS") 
  def: &Classx{  
   parents: parentsMakex(parentarr)
   schema: @Dicx{}
   curry: @Dicx{}   
  }
 }
 @return x;
}
classvPresetx = &(class Objx)Objx{
 #x = &Objx{
  type: @T("CLASS") 
  def: &Classx{
   class: class
   schema: @Dicx{}
   curry: @Dicx{}   
  }
 }
 @return x;
}
scopePresetx = &(class Objx)Objx{
 #x = &Objx{
  type: @T("OBJ")
  def: &Class{
   class: class
   parents: @Dicx{}
   schema: @Dicx{}
   curry: @Dicx{}   
  }
  dic: @Dicx{}
 }
 @return x;
}

#rootsp = objPresetx()
root.route = &Routex{
 id: ""
 ns: ""
}
#defsp =  scopePresetx()
routex(defsp, rootsp, "def")

##objc = classmPresetx()
routex(objc, defsp, "Obj")
##classc = classmPresetx([objc])
routex(classc, defsp, "Class")
##classmc = classvPresetx(classc)
routex(classmc, defsp, "ClassM")
##classvc = classvPresetx(classc)
routex(classvc, defsp, "ClassV")
##scopec = classmPresetx([objc])
routex(scopec, defsp, "Scope")

rootsp.class = scopec
defsp.class = scopec
objc.class = classmc
classc.class = classmc
classmc.class = classvc
classvc.class = classvc
scopec.class = classmc

/////3 def scope/MVClasscNew
scopeNewx = &(scope Objx, name Str, parents Arrx)Objx{
//THROW when key match "_"
 #x = scopePresetx(parents)
 x.class = scopec 
 routex(x, scope, name);
 @return x
}
dicOrx = &(x Dicx)Dicx{
 @if(x == _){
  @return @Dicx{}
 }@else{
  @return x
 }
}
classmInitx = &(parentarr Arrx, schema Dicx, curry Dicx)Objx{
 #x = &Objx{
  type: @T("CLASS")
  class: classmc
  def: &Classx{  
   parents: parentsMakex(parentarr)
   schema: dicOrx(schema)
   curry: dicOrx(curry)
  }
 }
 @return x;
}
classmNewx = &(scope Objx, name Str, parentarr Arrx, schema Dicx, curry Dicx)Objx{
 #x = classmInitx(parentarr, schema, curry)
 routex(x, scope, name)
 @return x
}
classvInitx = &(class Objx, schema Dicx, curry Dicx)Objx{
 #x = &Objx{
  type: @T("CLASS")
  class: classmc
  def: &Classx{  
   class: class
   schema: dicOrx(schema)
   curry: dicOrx(curry)
  }
 }
 @return x;
}
classvNewx = &(scope Objx, name Str, class Objx, schema Dicx, curry Dicx)Objx{
 //TODO class cannot be defsp.Curry
 #x = classvInitx(class, schema, curry)
 routex(x, scope, name)
 @return x;
}
##classcc = classvNewx(defsp, "ClassC", classc)
classcInitx = &(class Objx, curry Dicx)Objx{
 #x = &Objx{
  type: @T("CLASS")
  class: classmc
  def: &Classx{  
   class: class
   curry: dicOrx(curry)
  }
 }
 @return x;
}
classcNewx = &(scope Objx, name Str, class Objx, curry Dicx)Objx{
 //TODO class cannot be defsp.Curry
 #x = classcInitx(class, curry)
 routex(x, scope, name)
 @return x;
}
objInitx = &(class Objx, dic Dicx){
 #x = &Objx{
  type: @T("OBJ")
  class: class
  dic: @Dicx
 }
 @return x; 
}
/////4 def val, voidp, null
##voidpc = classmNewx(defsp, "Voidp", [objc])
##valc = classmNewx(defsp, "Val", [objc], {
 valDefault: objc
 val: voidpc
})
##nullv =  &Objx{
 type: @T("NULL")
}
##nullc = classcNewx(defsp, "Null", valc, {
 valDefault: nullv
})
nullv.class = nullc

/////5 def num
##zerointv = &Objx{
 type: @T("INT")
 val: 0
}
##zeronumv = &Objx{
 type: @T("NUM")
 val: 0.0
}
##numc = classmNewx(defsp, "Num", [valc])
##intc = classmNewx(defsp, "Int", [numc])
##uintc = classmNewx(defsp, "Uint", [intc])

zeronumv.class = numc
zerointv.class = intc
inttDefx = &(x Str)Objx{
 @return classcNewx(defsp, x, intc, {
  valDefault: zerointv
 })
}
uinttDefx = &(x Str)Objx{
 @return classcNewx(defsp, x, uintc, {
  valDefault: zerointv
 })
}
numtDefx = &(x Str)Objx{
 @return classcNewx(defsp, x, numc, {
  valDefault: zeronumv
 })
}
inttDefx("Boolean")//Int1
##charc = inttDefx("Char")//Int8
inttDefx("Int16")
inttDefx("Int32")
inttDefx("Int64")
uinttDefx("Uint8")
uinttDefx("Uint16")
uinttDefx("Uint32")
uinttDefx("Uint64")
numtDefx("Float")
numtDefx("Double")
numtDefx("NumBig")


/////6 def items 
##itemsc =  classmNewx(defsp, "Items", [valc], {
 itemsType: classc
})
##itemslimitedc =  classvNewx(defsp, "ItemsLimited", itemsc, {
 itemsLimitedLength: uintc
})
##arrc = classcNewx(defsp, "Arr", itemsc)
##arrcharc = classcNewx(defsp, "CharArr", arrc, {
 itemsType: charc
})
##dicc = classcNewx(defsp, "Dic", itemsc)

#classms = Classx(classmc.val).schema
#classvs = Classx(classvc.val).schema
#classcs = Classx(classcc.val).schema
#scopes = Classx(scopec.val).schema

//fix schema
classms["classSchema"] = dicc
classms["classParents"] = dicc
classms["classCurry"] = dicc

classvs["classCurry"] = dicc
classvs["classSchema"] = dicc
classvs["classClass"] = dicc

classcs["classCurry"] = dicc
classcs["classClass"] = dicc

scopes["scopeVal"] = dicc
scopes["scopeParents"] = dicc

/////7 advanced type init: string, enum, unlimited number...
##zerostrv = &Objx{
 type: @T("STR")
 val: ""
}
##strc = classcNewx(defsp, "Str", valc, {
 valDefault: zerostrv
})
zerostrv.class = strc

##enumc = classmNewx(defsp, "Enum", [valc], {
 enum: arrc
})

intDefx = &(x Int)Objx{
 @return &Objx{
  type: @T("INT")
  class: intc
  val: x
 }
}
numDefx = &(x Num)Objx{
 @return &Objx{
  type: @T("NUM")
  class: numc
  val: x
 }
}
strDefx = &(x Str)Objx{
 @return &Objx{
  type: @T("STR")
  class: strc
  val: x
 }
}
charDefx = &(x Char)Objx{
 @return &Objx{
  type: @T("CHAR")
  class: charc
  val: x
 } 
}


/////8 def var/block/func
DicUintx = => Dic {
 itemsType: Uint
}
ArrStrx = => Arr {
 itemsType: Str
}
Blockx = <>{
 val: Arrx
 labels: DicUintx 
}
##funcc = classmNewx(defsp, "Func", [objc])
##funcprotoc = classvNewx(defsp, "FuncProto", funcc, {
 funcArgs: classcInitx(arrc, {itemsType: strc})
})

##valfuncc = classcNewx(defsp, "ValFunc", valc, {
 valDefault: nullv
})
##funcnativec = classmNewx(defsp, "FuncNative", [funcprotoc], {
 funcNative: valfuncc
})
##blockc = classmNewx(defsp, "Block", [objc], {
 blockVal: arrc,
 blockLabels: classcInitx(arrc, {itemsType: uintc})
})
##funcblockc = classmNewx(defsp, "FuncBlock", [funcprotoc], {
 funcBlock: blockc
})
##functplc = classmNewx(defsp, "FuncTpl", [funcprotoc], {
 funcTpl: strc
 funcTplFileName: strc
})
funcInitx = &(val Objx, args ArrStrx, argtypes Arrx, return Objx)Objx{
 @if(val == _){
  #c = funcprotoc
 }@else{
  #id = val.class.route.id 
  @if(id == "FuncNative"){
   #c = funcnativec
  }@elif(id == "FuncTpl"){
   #c = functplc
  }@elif(id == "FuncBlock"){
   #c = funcblockc  
  }
 }
 #x = classvInitx(c, {
  funcReturn: return
 }, {
  funcArgs: args  
 })
 @each i v argtypes{
  x.def.schema[args[i]] = v
 }
 @return x
}
funcNewx = &(scope Objx, name Str, val Objx, args ArrStrx, argtypes Arrx, return Objx)Objx{//FuncNative new
 #fn = funcInitx(val, args, argtypes, return)
 routex(fn, scope, name);
 //TODO if  raw
 @return fn
}

/////9 def mid

Convx = <>{
}
Callx = <>{
 func: Objx
 args: Arrx
}
##midc = classmNewx(defsp, "Mid", [objc])

##convc = classmNewx(defsp, "Conv", [midc], {
 convToType: classc
 convFromVal: objc
})
##convimpc = classcNewx(defsp, "ConvImp", convc)
##convexpc = classcNewx(defsp, "ConvExp", convc)

##callc = classmNewx(defsp, "Call", [midc], {
 callFunc: funcc
 callArgs: arrc
})

callInitx = &(func Objx, args Arrx)Objx{
 #val = &Callx{
  func: func
  args: args
 }
 @if(args == _){
  val.args = @Arrx{}
 }
 #x = &Objx{
  type: @T("CALL")
  class: callc
  val: val
 }
 @return x
}

##idc = classmNewx(defsp, "Id", [midc])
##idstrc =  classvNewx(defsp, "IdStr", idc, {
 idStr: strc,
})
##iduintc =  classvNewx(defsp, "IdUint", idc, {
 idUint: uintc,
})
##idscopec = classvNewx(defsp, "IdScope", idstrc, {
 idScope: scopec
})
##idlocalc = classcNewx(defsp, "IdLocal", idscopec)
##idglobalc = classcNewx(defsp, "IdGlobal", idscopec)
##idlibc = classvNewx(defsp, "IdLib", idstrc, {
 idVal: objc
})
##idobjc = classvNewx(defsp, "IdObj", idstrc, {
 idObj: objc
})
##iddicc = classvNewx(defsp, "IdDic", idstrc, {
 idDic: dicc
})
##idarrc = classvNewx(defsp, "IdArr", iduintc, {
 idArr: arrc
})

##assignc = classmNewx(defsp, "Assign", [midc], {
 assignL: idc
 assignR: objc
})
##assignafterc = classcNewx(defsp, "AssignAfter", assignc)

##opc = classmNewx(defsp, "Op", [midc], {
 opPrecedence: uintc
})
##op1c = classvNewx(defsp, "Op1", opc, {
 op: objc
})
##op2c = classvNewx(defsp, "Op2", opc, {
 opL: objc
 opR: objc
})
//https://en.cppreference.com/w/c/language/operator_precedence
//remove unused
//get and assign are not operators in Soul PL
##opnotc = classcNewx(defsp, "OpNot", op1c, {
 opPrecedence: intDefx(10)
})
##opdefinedc = classcNewx(defsp, "OpDefined", op1c, {
 opPrecedence: intDefx(10)
})
##optimesc = classcNewx(defsp, "OpTimes", op2c, {
 opPrecedence: intDefx(20)
})
##opobelusc = classcNewx(defsp, "OpObelus", op2c, {
 opPrecedence: intDefx(20)
})
##opmodc = classcNewx(defsp, "OpMod", op2c, {
 opPrecedence: intDefx(20)
})
##opplusc = classcNewx(defsp, "OpPlus", op2c, {
 opPrecedence: intDefx(30)
})
##opminusc = classcNewx(defsp, "OpMinus", op2c, {
 opPrecedence: intDefx(30)
})
##opgec = classcNewx(defsp, "OpGe", op2c, {
 opPrecedence: intDefx(40)
})
##oplec = classcNewx(defsp, "OpLe", op2c, {
 opPrecedence: intDefx(40)
})
##opgtc = classcNewx(defsp, "OpGt", op2c, {
 opPrecedence: intDefx(40)
})
##opltc = classcNewx(defsp, "OpLt", op2c, {
 opPrecedence: intDefx(40)
})
##opeqc = classcNewx(defsp, "OpEq", op2c, {
 opPrecedence: intDefx(50)
})
##opnec = classcNewx(defsp, "OpNe", op2c, {
 opPrecedence: intDefx(50)
})
##opandc = classcNewx(defsp, "OpAnd", op2c, {
 opPrecedence: intDefx(60)
})
##oporc = classcNewx(defsp, "OpOr", op2c, {
 opPrecedence: intDefx(70)
})

/////10 def signal
Error = <>{
 code: Uint
 msg: Str
}
##signalc = classmNewx(defsp, "Signal", [objc]);
##continuec = classcNewx(defsp, "Continue", signalc)
##breakc = classcNewx(defsp, "Break", signalc)
##gotoc = classmNewx(defsp, "Goto", [signalc], {
 goto: uintc
})
##returnc = classmNewx(defsp, "Return", [signalc], {
 return: objc
})
##errorc = classmNewx(defsp, "Error", [signalc], {
 errorCode: uintc
 errorMsg: strc
})

/////11 def ctrl
##ctrlc = classmNewx(defsp, "Ctrl", [objc])
##ctrlargsc = classmNewx(defsp, "CtrlArgs", [ctrlc], {
 ctrlArgs: arrc
})
##ctrlifc = classcNewx(defsp, "CtrlIf", ctrlargsc)
##ctrlforc = classcNewx(defsp, "CtrlFor", ctrlargsc)
##ctrleachc = classcNewx(defsp, "CtrlEach", ctrlargsc)
##ctrlforeachc = classcNewx(defsp, "CtrlForeach", ctrlargsc)
##ctrlwhilec = classcNewx(defsp, "CtrlWhile", ctrlargsc)
##ctrlbreakc = classcNewx(defsp, "CtrlBreak", ctrlc)
##ctrlcontinuec = classcNewx(defsp, "CtrlContinue", ctrlc)
##ctrlgotoc = classcNewx(defsp, "CtrlGoto", ctrlargsc)

##ctrlreturnc = classcNewx(defsp, "CtrlReturn", ctrlargsc)
##ctrlerrorc = classcNewx(defsp, "CtrlError", ctrlargsc)

/////12 def  env
##profilec = classmNewx(defsp, "Profile", [objc], {
 profileGlobal: scopec
 profileDef: scopec
 profileExec: scopec
})
##envc = classmNewx(defsp, "Env", [objc], {
 envProfile: profilec
 envGlobal: scopec
 envDef: scopec
})
##execc = classmNewx(defsp, "Exec", [objc], {
 execObj: objc
 execEnv: envc
})

/////14 func oop

/////15 func scope
dbGetx = &(scope Scopex, key Str)Str{
 @return ""
}
scopeIntox = &(scope Scopex, key Str)Scopex{
 #nscope = scope
 =>Arr{itemsType:Str}#arr = key.split("_")
 @foreach e arr{
  #xr = scope.val[e]
  @if(!xr){
   nscope = Scopex(scopeNewx(nscope, e).val)
  }@else{
   nscope = Scopex(xr.val);
  }
 }
 @return _
}
scopeGetSubx = &(scope Scopex, key Str, cache Dic)Objx{
 #nscope = scope
 #nkey = key
 =>Arr{itemsType:Str}#arr = key.match("(\\S+)_([^_]+)$")
 @if(arr != _){
  nscope = scopeIntox(scope, arr[1])
  nkey = arr[2]
 }
 #r = nscope.val[nkey]
 @if(r != _){
  @return r
 }

 @if(!scope.obj.route.noname){

  
  #sstr = dbGetx(scope, key);
  @if(sstr != ""){
   sstr = nkey+" = "+sstr;
//   r = progl2objx(nscope, {}, sstr)
//   @return r;
   @return _
  }
 }
 @each k v scope.parents {
  @if(cache[k] != _){ @continue };
  cache[k] = 1;
  r = scopeGetSubx(Scopex(v.val), key, cache)
  @if(r != _){
   @return r;
  }
 }

 @return _
}
scopeGetx = &(scope Scopex, key Str)Objx{
 #r = scopeGetSubx(scope, key, {})
 @if(r != _){
  @return r;
 }
 #pscope = scope.obj.route.scope
 @if(pscope != _){
  r = scopeGetx(pscope, key)
  @return r;
 }
 @return _
}
/////16 func exec
//exec use self as cache
callx = &(func Funcx, args Arrx, env Envx)Objx{
 @return call(func.native, [args, env]);
}
execGetx = &(c Classx, env Envx, cache Dic)Funcx{
 #profexec = env.profile.exec.val
 @if(!cache){
  cache = {}
 }
 @if(c.obj.route != _){
  #t = c.obj.route.id
  #x = profexec[t]
  @if(x != _){
   @return Funcx(x.val)
  }
  #execot = scopeGetx(env.profile.exec, t)
  @if(execot != _){
   profexec[t] = execot
   @return Funcx(execot.val)
  }
 }
 @if(c.class != _){
  #k = c.class.route.id
  @if(cache[k] != _){ @return _; }
  cache[k] = 1;
  Funcx#exect = execGetx(Classx(c.class.val), env, cache);
  @if(exect != _){
   profexec[t] = exect.obj
   @return exect
  }  
 }@elif(c.parents != _){
  @each k v c.parents{
   @if(cache[k] != _){ @return; }
   cache[k] = 1;
   exect = execGetx(Classx(v.val), env, cache);
   @if(exect != _){
    profexec[t] = exect.obj;
    @return exect;
   }
  }
 }
 @return _
}
execx = &(o Objx, env Envx)Objx{
 #ex = execGetx(Classx(o.class.val), env)
 @if(!ex){
  die("exec: unknown type");
 }
 @return callx(ex, [o], env);
}


/////17 func parse

/////18 func ast

/////19 func io/cmd

/////20 init method

/////21 init internal func
#logf = funcNewx(defsp, "log", &(x Arrx, env Envx)Objx{
 #o = x[0].type
 #v = x[0].val
 @if(o == "INT"){
  log(Int(v)) 
 }@elif(o == "NUM"){
  log(Num(v))
 }@elif(o == "STR"){
  log(Str(v))   
 }
 @return nullv
})
/////22 init type exec func
#exec = scopeNewx(rootsp, "exec")
#execsp = Scopex(exec.val)
funcNewx(execsp, "Exec", &(x Arrx, env Envx)Objx{
 log(x[0])
 @return nullv
})
funcNewx(execsp, "Call", &(x Arrx, env Envx)Objx{
 #c = Callx(x[0].val)
 
 @return callx(Funcx(c.func.val), c.args, env)
})
/////23 main func
#global = scopeNewx(rootsp, "global")
#globalsp = Scopex(global.val)
#prof = &Profilex{
 global: globalsp
 def: defsp
 exec: execsp
}
#env = &Envx{
 profile: prof
 def: Scopex(scopeNewx(defsp).val)
 global: Scopex(scopeNewx(globalsp).val)
}
#main = callInitx(logf, [intDefx(1)])
execx(main, env);


