/////1 set class/structs
T = =>Enum {
 enum: [
  "NULL", "INT", "NUM", "STR", "CHAR", "DIC", "ARR", "VALFUNC"
  "CLASS", "OBJ", "NS", "SCOPE"
 ]
}
Dicx = => Dic {
 itemsType: Objx
}
Objx = <>{
 type: T
 mid: Boolean
 name: Str
 id: Str
 scope: Objx
 class: Objx
 parent: Objx
 parents: Dicx
 dic: Dicx
 val: Val
}
Arrx = => Arr {
 itemsType: Objx
}
/////2 preset root ...
Uint##uidi = 0;
uidx = &()Str{
 Str#r = str(uidi)
 uidi += 1
 @return r;
}
routex = &(o Objx, scope Objx, name Str){
 #dic = scope.dic;
 dic[name] = o 
 o.name = name;
 o.id = uidx()
 o.scope = scope
}
parentsMakex = &(parentarr Arrx)Dicx{
 @if parentarr == _ {
  @return
 }
 #x = @Dicx{}
 @foreach e parentarr{
  //TODO reduce
  @if(!e.id){
   die("no id")
  }
  x[e.id] = e;
 }
 @return x
}
classmPresetx = &(parentarr Arrx)Objx{
 #x = &Objx{
  type: @T("CLASS")   
  parents: parentsMakex(parentarr)
  dic: @Dicx{}
 }
 @return x;
}
classvPresetx = &(parent Objx)Objx{
 #x = &Objx{
  type: @T("CLASS") 
  parent: parent
  dic: @Dicx{}
 }
 @return x;
}
scopePresetx = &(ns Objx, name Str, parentarr Arrx)Objx{
 #x = &Objx{
  type: @T("SCOPE") 
  name: name
  scope: ns
  parents: parentsMakex(parentarr)
  dic: @Dicx{}
 }
 x.dic["."] = x
 x.dic[".."] = ns
 @return x;
}
##root = @Dicx{}
nsPresetx = &(name Str)Objx{
 #x = &Objx{
  type: @T("NS") 
  name: name
  dic: @Dicx{}
 }
 root[name] = x 
 @return x;
}
#defns = nsPresetx("def")
##defmain = scopePresetx(defns, "main")
##objc = classmPresetx();
routex(objc, defmain, "Obj");
##classc = classmPresetx([objc])
routex(classc, defmain, "Class")
##classmc = classvPresetx(classc)
routex(classmc, defmain, "ClassM")
##classvc = classvPresetx(classc)
routex(classvc, defmain, "ClassV")
##scopec = classmPresetx([classc])
routex(scopec, defmain, "Scope")
##nsc = classmPresetx([objc])
routex(nsc, defmain, "Ns")

defns.class = nsc
defmain.class = scopec
objc.class = classmc
classc.class = classmc
classmc.class = classvc
classvc.class = classvc
scopec.class = classmc
nsc.class = classmc

/////3 def scope/MVClasscNew
dicOrx = &(x Dicx)Dicx{
 @if(x == _){
  @return @Dicx{}
 }@else{
  @return x
 }
}
isclassx = &(c Objx, t Objx, cache Dic)Boolean{
 @if(c.id != "" && c.id == t.id){
  @return 1
 }
 @if(!cache){
  cache = {}
 }
 @if(c.parent != _){
  #k = c.parent.id
  @if(cache[k] != _){
   @return 0
  }
  cache[k] = 1
  @if(isclassx(c.parent, t, cache) != 0){
   @return 1
  }
 }
 @each k v c.parents{
  @if(cache[k] != _){
   @continue
  }
  cache[k] = 1
  @if(isclassx(v, t, cache) != 0){
   @return 1
  }
 }
 @return 0
}
classGetx = &(class Objx, key Str)Objx{
 #x = class.dic[key]
 @if(x != _){
  @return x
 }
 @foreach v class.parents{
  #x = classGetx(v, key)
  @if(x != _){
   @return x
  }  
 }
 @if(class.parent != _){
  #x = classGetx(class.parent, key)
  @if(x != _){
   @return x
  } 
 }
 @return _
}
objInitx = &(class Objx, dic Dicx)Objx{
 #x = &Objx{
  type: @T("OBJ")
  class: class
  dic: dicOrx(dic)
 }
 @if(dic != _){
  @each k v dic{
   #t = classGetx(class, k)
   @if(t == _){
    die("objInitx: not in "+ class.name + " "+k)
   }
   Objx#c = t.class
   @if(isclassx(v.class, c) == 0){
    die("objInitx: " + v.class.name + " is not " + c.name)
   }
  }
 }
 @return x; 
}
objNewx = &(scope Objx, name Str, class Objx, dic Dicx)Objx{
 #x = objInitx(class, dic)
 routex(x, scope, name)
 @return x
}
scopeDefx = &(ns Objx, name Str, parentarr Arrx)Objx{
//THROW when key match "_"
 #x = scopePresetx(ns, name, parentarr)
 x.class = scopec
 @return x
}
nsDefx = &(name Str)Objx{
 #x = nsPresetx(name)
 x.class = nsc
 @return x;
}
classmInitx = &(parentarr Arrx, schema Dicx)Objx{
 #x = classmPresetx(parentarr)
 x.class = classmc
 @each k v schema{
  x.dic[k] = objInitx(v)
 }
 @return x;
}
classmNewx = &(scope Objx, name Str, parentarr Arrx, schema Dicx)Objx{
 #x = classmInitx(parentarr, schema)
 routex(x, scope, name)
 @return x
}
classvInitx = &(parent Objx, schema Dicx)Objx{
 #x = classvPresetx(parent)
 x.class = classvc
 @each k v schema{
  x.dic[k] = objInitx(v)
 }
 @return x;
}
classvNewx = &(scope Objx, name Str, parent Objx, schema Dicx)Objx{
 #x = classvInitx(parent, schema)
 routex(x, scope, name)
 @return x
}
##classcc = classvNewx(defmain, "ClassC", classc)
classcInitx = &(parent Objx, dic Dicx)Objx{
 #x = &Objx{
  type: @T("CLASS")
  class: classcc
  parent: parent
  dic: dicOrx(dic)
 }
 @return x;
}
classcNewx = &(scope Objx, name Str, parent Objx, dic Dicx)Objx{
 #x = classcInitx(parent, dic)
 routex(x, scope, name)
 @return x
}

/////4 def val, voidp, null
##valc = classmNewx(defmain, "Val", [objc], {
 val: objc
})
##nullv =  &Objx{
 type: @T("NULL")
}
##nullc = classcNewx(defmain, "Null", valc, {
 val: nullv
})
nullv.class = nullc

##zerointv = &Objx{
 type: @T("INT")
 val: 0
}
##zeronumv = &Objx{
 type: @T("NUM")
 val: 0.0
}
##numc = classmNewx(defmain, "Num", [valc])
##intc = classmNewx(defmain, "Int", [numc])
##uintc = classmNewx(defmain, "Uint", [intc])

zeronumv.class = numc
zerointv.class = intc
inttDefx = &(x Str)Objx{
 @return classcNewx(defmain, x, intc, {
  val: zerointv
 })
}
uinttDefx = &(x Str)Objx{
 @return classcNewx(defmain, x, uintc, {
  val: zerointv
 })
}
numtDefx = &(x Str)Objx{
 @return classcNewx(defmain, x, numc, {
  val: zeronumv
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
##itemsc =  classmNewx(defmain, "Items", [valc], {
 itemsType: classc
})
##itemslimitedc =  classvNewx(defmain, "ItemsLimited", itemsc, {
 itemsLimitedLength: uintc
})
##arrc = classcNewx(defmain, "Arr", itemsc)
##arrcharc = classcNewx(defmain, "ArrChar", arrc, {
 itemsType: charc
})
##dicc = classcNewx(defmain, "Dic", itemsc)

arrDefx = &(class Objx, val Arrx)Objx{
 @if(class == _){
  class = arrc;
 }
 #x = &Objx{
  type: @T("ARR")
  class: class
 }
 @if(val != _){
  x.val = val
 }@else{
  x.val = @Arrx{}
 }
 @return x
}
dicDefx = &(class Objx, val Dicx)Objx{
 @if(class == _){
  class = dicc;
 }
 @return &Objx{
  type: @T("DIC")
  class: class
  dic: dicOrx(val)
 }
}


/////7 advanced type init: string, enum, unlimited number...
##zerostrv = &Objx{
 type: @T("STR")
 val: ""
}
##strc = classcNewx(defmain, "Str", valc)
strc.dic["val"] = zerostrv
zerostrv.class = strc

##enumc = classmNewx(defmain, "Enum", [valc], {
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
##arrstrc = classcNewx(defmain, "ArrStr", arrc, {
 itemsType: strc
})
##dicuintc = classcNewx(defmain, "DicUint", dicc, {
 itemsType: uintc
})
##dicclassc = classcNewx(defmain, "DicClass", dicc, {
 itemsType: classc
})
##arrclassc = classcNewx(defmain, "ArrClass", arrc, {
 itemsType: classc
})




##funcc = classmNewx(defmain, "Func", [objc])

##funcprotoc = classvNewx(defmain, "FuncProto", funcc, {
 funcVarNames: arrstrc
 funcVarTypes: arrc
 funcReturn: classc
})

##valfuncc = classcNewx(defmain, "ValFunc", valc)

##funcnativec = classmNewx(defmain, "FuncNative", [funcprotoc], {
 funcNative: valfuncc
})
##blockc = classmNewx(defmain, "Block", [objc], {
 blockVal: arrc,
 blockLabels: dicuintc
})
##blockc = classvNewx(defmain, "BlockState", blockc, {
 blockState: statec, 
})
##funcclassc = classvNewx(defmain, "FuncClass", funcprotoc, {
 funcClass: classc
})
##funcblockc = classvNewx(defmain, "FuncBlock", funcclassc, {
 funcBlock: blockc
})
##functplc = classvNewx(defmain, "FuncTpl", funcblockc, {
 funcTpl: strc
 funcTplFileName: strc
})
/////9 def mid
##midc = classmNewx(defmain, "Mid", [objc])

##convc = classmNewx(defmain, "Conv", [midc], {
 convToType: classc
 convFromVal: objc
})
##convimpc = classcNewx(defmain, "ConvImp", convc)
##convexpc = classcNewx(defmain, "ConvExp", convc)

##callc = classmNewx(defmain, "Call", [midc], {
 callFunc: funcc
 callArgs: arrc
})

##idc = classmNewx(defmain, "Id", [midc])
##idstrc =  classvNewx(defmain, "IdStr", idc, {
 idStr: strc,
})
##iduintc =  classvNewx(defmain, "IdUint", idc, {
 idUint: uintc,
})
##idscopec = classvNewx(defmain, "IdScope", idstrc, {
 idScope: scopec
})
##idlocalc = classcNewx(defmain, "IdLocal", idscopec)
##idglobalc = classcNewx(defmain, "IdGlobal", idscopec)
##idlibc = classvNewx(defmain, "IdLib", idstrc, {
 idVal: objc
})
##idobjc = classvNewx(defmain, "IdObj", idstrc, {
 idObj: objc
})
##iddicc = classvNewx(defmain, "IdDic", idstrc, {
 idDic: dicc
})
##idarrc = classvNewx(defmain, "IdArr", iduintc, {
 idArr: arrc
})

##assignc = classmNewx(defmain, "Assign", [midc], {
 assignL: idc
 assignR: objc
})
##assignafterc = classcNewx(defmain, "AssignAfter", assignc)

##opc = classmNewx(defmain, "Op", [midc], {
 opPrecedence: uintc
})
##op1c = classvNewx(defmain, "Op1", opc, {
 op: objc
})
##op2c = classvNewx(defmain, "Op2", opc, {
 opL: objc
 opR: objc
})
//https://en.cppreference.com/w/c/language/operator_precedence
//remove unused
//get and assign are not operators in Soul PL
##opnotc = classcNewx(defmain, "OpNot", op1c, {
 opPrecedence: intDefx(10)
})
##opdefinedc = classcNewx(defmain, "OpDefined", op1c, {
 opPrecedence: intDefx(10)
})
##optimesc = classcNewx(defmain, "OpTimes", op2c, {
 opPrecedence: intDefx(20)
})
##opobelusc = classcNewx(defmain, "OpObelus", op2c, {
 opPrecedence: intDefx(20)
})
##opmodc = classcNewx(defmain, "OpMod", op2c, {
 opPrecedence: intDefx(20)
})
##opplusc = classcNewx(defmain, "OpPlus", op2c, {
 opPrecedence: intDefx(30)
})
##opminusc = classcNewx(defmain, "OpMinus", op2c, {
 opPrecedence: intDefx(30)
})
##opgec = classcNewx(defmain, "OpGe", op2c, {
 opPrecedence: intDefx(40)
})
##oplec = classcNewx(defmain, "OpLe", op2c, {
 opPrecedence: intDefx(40)
})
##opgtc = classcNewx(defmain, "OpGt", op2c, {
 opPrecedence: intDefx(40)
})
##opltc = classcNewx(defmain, "OpLt", op2c, {
 opPrecedence: intDefx(40)
})
##opeqc = classcNewx(defmain, "OpEq", op2c, {
 opPrecedence: intDefx(50)
})
##opnec = classcNewx(defmain, "OpNe", op2c, {
 opPrecedence: intDefx(50)
})
##opandc = classcNewx(defmain, "OpAnd", op2c, {
 opPrecedence: intDefx(60)
})
##oporc = classcNewx(defmain, "OpOr", op2c, {
 opPrecedence: intDefx(70)
})

/////10 def signal
##signalc = classmNewx(defmain, "Signal", [objc]);
##continuec = classcNewx(defmain, "Continue", signalc)
##breakc = classcNewx(defmain, "Break", signalc)
##gotoc = classmNewx(defmain, "Goto", [signalc], {
 goto: uintc
})
##returnc = classmNewx(defmain, "Return", [signalc], {
 return: objc
})
##errorc = classmNewx(defmain, "Error", [signalc], {
 errorCode: uintc
 errorMsg: strc
})
/////11 def ctrl
##ctrlc = classmNewx(defmain, "Ctrl", [objc])
##ctrlargsc = classmNewx(defmain, "CtrlArgs", [ctrlc], {
 ctrlArgs: arrc
})
##ctrlifc = classcNewx(defmain, "CtrlIf", ctrlargsc)
##ctrlforc = classcNewx(defmain, "CtrlFor", ctrlargsc)
##ctrleachc = classcNewx(defmain, "CtrlEach", ctrlargsc)
##ctrlforeachc = classcNewx(defmain, "CtrlForeach", ctrlargsc)
##ctrlwhilec = classcNewx(defmain, "CtrlWhile", ctrlargsc)
##ctrlbreakc = classcNewx(defmain, "CtrlBreak", ctrlc)
##ctrlcontinuec = classcNewx(defmain, "CtrlContinue", ctrlc)
##ctrlgotoc = classcNewx(defmain, "CtrlGoto", ctrlargsc)

##ctrlreturnc = classcNewx(defmain, "CtrlReturn", ctrlargsc)
##ctrlerrorc = classcNewx(defmain, "CtrlError", ctrlargsc)

/////12 def  env
##envc = classmNewx(defmain, "Env", [objc], {
 envExec: scopec
 envDef: scopec
 envState: statec 
 envGlobal: statec 
})
##execc = classmNewx(defmain, "Exec", [objc], {
 execObj: objc
 execEnv: envc
})

/////13 func newfunc

Funcx = => Func{
 funcVars: arrDefx(arrstrc, [strDefx("o"), strDefx("env")])
 o: objInitx(arrc)
 env: objInitx(envc)
}
valfuncDefx = &(f Funcx)Objx{
 @return &Objx{
  type: @T("VALFUNC")
  class: valfuncc
  val: f
 } 
}

fnInitx = &(val Funcx, args ArrStrx, argtypes Arrx, return Objx)Objx{
 @if(val == _){
  #c = funcprotoc
 }@else{
  #c = funcnativec
 }
 #x = objInitx(c)
 #funcVars = arrDefx(arrstrc)
 @each i v argtypes{
  funcVars.val = push(Arrx(funcVars.val), strDefx(args[i]))
 }
 x.dic["funcVars"] = funcVars
 @if(return != _){
  x.dic["funcReturn"] = return
 } 
 @if(val != _){
  x.dic["funcNative"] = valfuncDefx(val)
 }
 @return x
}

fnNewx = &(scope Objx, name Str, val Funcx, args ArrStrx, argtypes Arrx, return Objx)Objx{//FuncNative new
 #fn = fnInitx(val, args, argtypes, return)
 routex(fn, scope, name);
 //TODO if  raw
 @return fn
}

/////14 func oop

/////15 func scope
dbGetx = &(scope Objx, key Str)Str{
 @return ""
}
scopeGetx = &(scope Objx, key Str, cache Dic)Objx{
 #r = scope.dic[key]
 @if(r != _){
  @return r
 }
 @if(!cache){
  cache = {}
 }

 #sstr = dbGetx(scope, key);
 @if(sstr != ""){
  sstr = key+" = "+sstr;
//   r = progl2objx(nscope, {}, sstr)
//   @return r;
  @return _
 }

 @each k v scope.parents {
  @if(cache[k] != _){ @continue };
  cache[k] = 1;
  r = scopeGetx(v, key, cache)
  @if(r != _){
   @return r;
  }
 }
 @return _
}
/////16 func exec
//exec use self as cache
callx = &(func Objx, args Arrx, env Objx)Objx{
 @return call(Funcx(func.dic["funcNative"].val), [args, env]);
}
execGetx = &(c Objx, env Objx, cache Dic)Objx{
 Objx#execsp = env.dic["envExec"]
 @if(!cache){
  cache = {}
 }
 @if(c.id != ""){
  #t = c.id
  #x = execsp.dic[t]
  @if(x != _){
   @return x
  }
  #execot = scopeGetx(execsp, t)
  @if(execot != _){
   execsp.dic[t] = execot
   @return execot
  }
 }
 @if(c.parent != _){
  #k = c.parent.id
  @if(k != ""){
   @if(cache[k] != _){ @return _; }
   cache[k] = 1;
  }
  Objx#exect = execGetx(c.parent, env, cache);
  @if(exect != _){
   execsp.dic[t] = exect
   @return exect
  }
 }@elif(c.parents != _){
  @each k v c.parents{
   @if(cache[k] != _){ @return; }
   cache[k] = 1;
   exect = execGetx(v, env, cache);
   @if(exect != _){
    execsp.dic[t] = exect;
    @return exect;
   }
  }
 }
 @return _
}
execx = &(o Objx, env Objx)Objx{
 #ex = execGetx(o.class, env)
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
#logf = fnNewx(defmain, "log", &(x Arrx, env Objx)Objx{
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
},["x"],[objc])

/////22 init type exec func
#exec = nsDefx("exec")
##execmain = scopeDefx(exec, "main")
feNewx = &(name Str, f Funcx)Objx{
 @return fnNewx(execmain, name, f, ["x"], [objc], objc)
}
feNewx("Exec", &(x Arrx, env Objx)Objx{
 log(x[0])
 @return nullv
})
feNewx("Call", &(x Arrx, env Objx)Objx{
 #c = x[0]
 #args = Arrx(c.dic["callArgs"].val)
 @return callx(c.dic["callFunc"], args, env)
})
/////23 main func
#env = objInitx(envc, {
 envGlobal: objInitx(classvInitx(statec))
 envState: objInitx(classvInitx(statec))
 envDef: defmain
 envExec: execmain
})
#main = objInitx(callc, {
 callFunc: logf,
 callArgs: arrDefx(arrc, [intDefx(1)])
})
execx(main, env);



