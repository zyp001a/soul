/////1 set class/structs
T = =>Enum {
 enum: [
  "NULL", "INT", "NUM", "STR", "CHAR", "DIC", "ARR", "VALFUNC",
  "FUNCTPL", "FUNCBLOCK",
  "CLASSM", "CLASSV", "CLASSC",
  "SCOPE",
  "BLOCK",
  "OBJ"
 ]
}
Routex = <>{
 name: Str
 id: Str
 ns: Str
 index: Uint
 scope: Scopex
 flagNoname: Boolean
}
Objx = <>{
 type: T
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

Blockx = <>{
}
DicUintx = => Dic {
 itemsType: Uint
}
Funcblockx = <>{
 obj: Objx
 block: Blockx
 labels: DicUintx
}
Functplx = <>{
 obj: Objx
 tpl: Str
}
Scopex = <>{
 obj: Objx
 val: Dicx
 parents: Dicx
}
Classmx = <>{
 obj: Objx
 schema: Dicx
 curry: Dicx
 parents: Dicx
}
Classvx = <>{
 obj: Objx
 schema: Dicx
 curry: Dicx
 class: Objx
}
Classcx = <>{
 obj: Objx
 curry: Dicx
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
 }
 scope.val[name] = o
 r.name = name;
 #id = sr.id
 @if(!id){
  r.id = name
  r.ns = sr.ns
 }@elif(sr.flagNoname){
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
 #val = &Classmx{  
  parents: parentsMakex(parentarr)
  curry: @Dicx{}
  schema: @Dicx{}
 }
 #x = &Objx {
  type: @T("CLASSM")
  val: val
 }
 val.obj = x;
 @return x;
}
classvPresetx = &(class Objx)Objx{
 #val = &Classvx{  
  class: class
  curry: @Dicx{}
  schema: @Dicx{}
 }
 #x = &Objx {
  type: @T("CLASSV")
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
 #val = &Classmx{  
  parents: parentsMakex(parentarr)
  curry: dicOrx(curry)
  schema: dicOrx(schema)
 }
 #x = &Objx {
  type: @T("CLASSM")
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
 #val = &Classvx{
  class: class
  schema: dicOrx(schema)
  curry: dicOrx(curry)
 }
 #x = &Objx {
  type: @T("CLASSV")
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
 #val = &Classcx{
  class: class
  curry: dicOrx(curry)
 }
 #x = &Objx {
  type: @T("CLASSC")
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

#classms = Classvx(classmc.val).schema
#classvs = Classvx(classvc.val).schema
#classcs = Classvx(classcc.val).schema
#scopes = Classmx(scopec.val).schema

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

/////8 def var/block/func
##funcrawc = classcNewx(defsp, "Funcraw", valc, {
 valDefault: nullv
})

/////9 def callable

/////10 def assign/op

/////11 def ctrl

/////12 def throw/error

/////13 func def
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

/////14 func oop

/////15 func scope

/////16 func exec

/////17 func parse

/////18 func ast

/////19 func io

/////20 init method

/////21 init internal func

/////22 init type exec func

/////23 main func




