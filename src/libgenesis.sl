/////1 set class/structs
T = =>Enum {
 enum: [
  "NULL", "INT", "NUM", "STR", "CHAR", "DIC", "ARR", "VALFUNC"
  "CLASS", "SCOPE",  
  "VAR", "BLOCK", "FUNC",
  "CONV", "CALL", "ID", "ASSIGN", "OP"
  "RETURN", "GOTO", "CONTINUE", "BREAK", "ERROR"
  "OBJ"
 ]
}
Routex = <>{
 name: Str
 id: Str
 ns: Str
 index: Uint
 scope: Scopex
 noname: Int//TODO change to Boolean
}
Objx = <>{
 type: T
 callable: Boolean
 route: Routex
 class: Objx
 val: Voidp
}
Dicx = => Dic {
 itemsType: Objx
}
Arrx = => Arr {
 itemsType: Objx
}

Scopex = <>{
 obj: Objx
 val: Dicx
 parents: Dicx
}
Classx = <>{
 obj: Objx
 schema: Dicx
 curry: Dicx
 parents: Dicx
 class: Objx 
}


/////2 preset root ...
routex = &(o Objx, scope Scopex, name Str)Objx{
 @if(!o.route){
  o.route = &Routex{}
 }
 #r = o.route;
 #sr = scope.obj.route
 @if(!r.index){
  r.index = 0
 }
 @if(!name){
  name = str(r.index)
  r.index ++
  r.noname = 1
 }
 scope.val[name] = o
 r.name = name;
 #id = sr.id
 @if(!id){
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
scopePresetx = &(parentarr Arrx)Objx{
 #val = &Scopex{
  parents: parentsMakex(parentarr)
  val: @Dicx{}
 }
 #x = &Objx {
  type: @T("SCOPE")
  val: val
 }
 val.obj = x;
 @return x;
}
classmPresetx = &(parentarr Arrx)Objx{
 #val = &Classx{  
  parents: parentsMakex(parentarr)
  curry: @Dicx{}
  schema: @Dicx{}
 }
 #x = &Objx {
  type: @T("CLASS")
  val: val
 }
 val.obj = x;
 @return x;
}
classvPresetx = &(class Objx)Objx{
 #val = &Classx{  
  class: class
  curry: @Dicx{}
  schema: @Dicx{}
 }
 #x = &Objx {
  type: @T("CLASS")
  val: val
 }
 val.obj = x;
 @return x;
}
#root = scopePresetx()
root.route = &Routex{}
##rootsp = Scopex(root.val)
#def =  scopePresetx()
routex(def, rootsp, "Def")
##defsp = Scopex(def.val)

##objc = classmPresetx()
routex(objc, defsp, "Obj")
##objcc = Classx(objc.val)
##classc = classmPresetx([objc])
routex(classc, defsp, "Class")
##classmc = classvPresetx(classc)
routex(classmc, defsp, "ClassM")
##classvc = classvPresetx(classc)
routex(classvc, defsp, "ClassV")
##scopec = classmPresetx([objc])
routex(scopec, defsp, "Scope")

root.class = scopec
def.class = scopec
objc.class = classmc
classc.class = classmc
classmc.class = classvc
classvc.class = classvc
scopec.class = classmc

/////3 def scope/MVClasscNew
scopeNewx = &(scope Scopex, name Str, parents Arrx)Objx{
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
 #val = &Classx{  
  parents: parentsMakex(parentarr)
  curry: dicOrx(curry)
  schema: dicOrx(schema)
 }
 #x = &Objx {
  type: @T("CLASS")
  class: classmc
  val: val
 }
 val.obj = x;
 @return x;
}
classmNewx = &(scope Scopex, name Str, parentarr Arrx, schema Dicx, curry Dicx)Objx{
 #x = classmInitx(parentarr, schema, curry)
 routex(x, scope, name)
 @return x
}
classvInitx = &(class Objx, schema Dicx, curry Dicx)Objx{
 #val = &Classx{
  class: class
  schema: dicOrx(schema)
  curry: dicOrx(curry)
 }
 #x = &Objx {
  type: @T("CLASS")
  class: classvc
  val: val
 }
 val.obj = x;
 @return x
}
classvNewx = &(scope Scopex, name Str, class Objx, schema Dicx, curry Dicx)Objx{
 //TODO class cannot be defsp.Curry
 #x = classvInitx(class, schema, curry)
 routex(x, scope, name)
 @return x;
}
##classcc = classvNewx(defsp, "ClassC", classc)
classcInitx = &(class Objx, curry Dicx)Objx{
 #val = &Classx{
  class: class
  curry: dicOrx(curry)
 }
 #x = &Objx {
  type: @T("CLASS")
  class: classcc
  val: val
 }
 val.obj = x;
 @return x
}
classcNewx = &(scope Scopex, name Str, class Objx, curry Dicx)Objx{
 //TODO class cannot be defsp.Curry
 #x = classcInitx(class, curry)
 routex(x, scope, name)
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
ArrVarx = => Arr {
 itemsType: Varx
}
Varx = <>{
 name: Str
 type: Classx
 initval: Objx
}
Blockx = <>{
 val: ArrVarx
 labels: DicUintx 
}
Funcx = <>{
 obj: Objx
 block: Blockx
 tpl: Str
 native: Voidp
 
 args: ArrVarx
 return: Varx
}
##varc = classmNewx(defsp, "Var", [objc], {
 varName: strc
 varType: classc
 varInitVal: objc
})
##varargc = classcNewx(defsp, "VarArg", varc)
##varlocalc = classcNewx(defsp, "VarLocal", varc)

##funcc = classmNewx(defsp, "Func", [objc])
##funcprotoc = classvNewx(defsp, "FuncProto", funcc, {
 funcArgs: classcInitx(arrc, {itemsType: varargc})
 funcReturn: classc
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
##functplc = classmNewx(defsp, "FuncTpl", [funcc], {
 funcTpl: strc
 funcTplFileName: strc
})
funcInitx = &(args ArrVarx, return Varx, f Voidp)Objx{
 @if(f == _){
  #c = funcprotoc
 }@else{
  #c = funcnativec
 }
 #val = &Funcx{
  args: args
  return: return
  native: f
 }
 #x = &Objx{
  type: @T("FUNC")
  class: c
  val: val
 }
 val.obj = x;
 @return x
}
//TODO change funcArgts argtType
fx = @`funcInitx([]*Varx{~
 @foreach v #0.funcArgts{
  ~~="&"~Varx{_name: "~=v.argtName~"},~
 }
~}, ~="&"~Varx{}, &0)`
funcNewx = &(scope Scopex, name Str, fn Objx)Objx{//FuncNative new
 routex(fn, scope, name);
 //TODO if  raw
 @return fn
}
funcNewx(defsp, "log", fx(&(x Objx)Objx{
 log(x)
 @return nullv
}))

/////9 def mid

Convx = <>{
}
Callx = <>{
 
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
Profilex = <>{
 global: Scopex
 def: Scopex
 exec: Scopex
}
Envx = <>{
 profile: Profilex
 global: Scopex
 def: Scopex
}
##profilec = classmNewx(defsp, "Profile", [objc], {
 profileGlobal: scopec
 profileDef: scopec
 profileExec: scopec
})
##envc = classmNewx(defsp, "Envc", [objc], {
 envProfile: profilec
 envGlobal: scopec
 envDef: scopec
})

/////14 func oop

/////15 func scope
scopeIntox = &(scope Scopex, key Str)Scopex{
 @return _
}
scopeGetSubx = &(scope Scopex, key Str, cache Dic)Objx{
 #nscope = scope
 #nkey = key
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
execGetx = &(c Classx, env Envx, cache Dic)Funcx{
 #e = env.profile.exec
 @if(!cache){
  cache = {}
 }
 @if(c.obj.route != _){
  #t = c.obj.route.id
  #x = e.val[t]
  @if(x != _){
   @return Funcx(x.val)
  }
  #exect = scopeGetx(e, t)
  @if(exect != _){
   e.val[t] = exect
   @return Funcx(exect.val)
  }
 }
 
 @return _
}
execx = &(o Objx, env Envx){
 #ex = execGetx(Classx(o.class.val), env)
 /* 
 @if(!ex){
  die("exec: unknown type, "+t);
 }
 @return callx(ex, [o], env);
 */
}


/////17 func parse

/////18 func ast

/////19 func io/cmd

/////20 init method

/////21 init internal func

/////22 init type exec func

/////23 main func




