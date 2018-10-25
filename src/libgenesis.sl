/////1 set class/structs
T = =>Enum {
 enum: [
  "NULL", "INT", "NUM", "STR", "CHAR", "DIC", "ARR", "FUNCVAL",
  "TFUNC", "BFUNC",
  "MCLASS", "VCLASS", "CCLASS",
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
Mclassx = <>{
 obj: Objx
 schema: Dicx
 curry: Dicx
 parents: Dicx
}
Vclassx = <>{
 obj: Objx
 schema: Dicx
 curry: Dicx
 class: Objx
}
Cclassx = <>{
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
mclassPresetx = &(parentarr Arrx)Objx{
 #val = &Mclassx{  
  parents: parentsMakex(parentarr)
  curry: @Dicx{}
  schema: @Dicx{}
 }
 #x = &Objx {
  type: @T("MCLASS")
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

##objc = mclassPresetx()
routex(objc, defsp, "Obj")
##classc = mclassPresetx([objc])
routex(classc, defsp, "Class")
##mclassc = mclassPresetx([classc])
routex(mclassc, defsp, "Mclass")
##scopec = mclassPresetx([objc])
routex(scopec, defsp, "Scope")

root.class = scopec
def.class = scopec
objc.class = mclassc
mclassc.class = mclassc
classc.class = mclassc
scopec.class = mclassc

/////3 def scope/MVCclassNew
scopeNewx = &(scope Scopex, name Str, parents Arrx)Objx{
//THROW when key match "_"
 #x = scopePresetx(parents)
 x.class = scopec 
 routex(x, scope, name);
 @return x
}
dicOrx = &(x Dicx)Dicx{
 @if(x != _){
  @return @Dicx{}
 }@else{
  @return x
 }
}
mclassInitx = &(parentarr Arrx, schema Dicx, curry Dicx)Objx{
 #val = &Mclassx{  
  parents: parentsMakex(parentarr)
  curry: dicOrx(curry)
  schema: dicOrx(schema)
 }
 #x = &Objx {
  type: @T("MCLASS")
  class: mclassc
  val: val
 }
 val.obj = x;
 @return x;
}
mclassNewx = &(scope Scopex, name Str, parentarr Arrx, schema Dicx, curry Dicx)Objx{
 #x = mclassInitx(parentarr, schema, curry)
 routex(x, scope, name)
 @return x
}
##vclassc = mclassNewx(defsp, "Vclass", [classc])
##cclassc = mclassNewx(defsp, "Cclass", [classc])
vclassInitx = &(class Objx, schema Dicx, curry Dicx)Objx{
 #val = &Vclassx{
  class: class
  schema: schema
  curry: dicOrx(curry)
 }
 #x = &Objx {
  type: @T("VCLASS")
  class: vclassc
  val: val
 }
 val.obj = x;
 @return x
}
vclassNewx = &(scope Scopex, name Str, class Objx, schema Dicx, curry Dicx)Objx{
 //TODO class cannot be defsp.Curry
 #x = vclassInitx(class, schema, curry)
 routex(x, scope, name)
 @return x;
}
cclassInitx = &(class Objx, curry Dicx)Objx{
 #val = &Cclassx{
  class: class
  curry: dicOrx(curry)
 }
 #x = &Objx {
  type: @T("CCLASS")
  class: cclassc
  val: val
 }
 val.obj = x;
 @return x
}
cclassNewx = &(scope Scopex, name Str, class Objx, curry Dicx)Objx{
 //TODO class cannot be defsp.Curry
 #x = cclassInitx(class, curry)
 routex(x, scope, name)
 @return x;
}

/////4 def val, voidp, null
##voidpc = mclassNewx(defsp, "Voidp", [objc])
##valc = mclassNewx(defsp, "Val", [objc], {
 valDefault: objc
 val: voidpc
})
##nullv =  &Objx{
 type: @T("NULL")
}
##nullc = cclassNewx(defsp, "Null", valc, {
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
##numc = mclassNewx(defsp, "Num", [valc])
##intc = mclassNewx(defsp, "Int", [numc])
##uintc = mclassNewx(defsp, "Uint", [intc])

zeronumv.class = numc
zerointv.class = intc
inttDefx = &(x Str){
 cclassNewx(defsp, x, intc, {
  valDefault: zerointv
 })
}
uinttDefx = &(x Str){
 cclassNewx(defsp, x, uintc, {
  valDefault: zerointv
 })
}
numtDefx = &(x Str){
 cclassNewx(defsp, x, numc, {
  valDefault: zeronumv
 })
}
inttDefx("Boolean")//Int1
inttDefx("Char")//Int8
inttDefx("Int16")
inttDefx("Int32")
inttDefx("Int64")
uinttDefx("Uint8")
uinttDefx("Uint16")
uinttDefx("Uint32")
uinttDefx("Uint64")
numtDefx("Float")
numtDefx("Double")


/////6 def items 
##itemsc =  mclassNewx(defsp, "Items", [valc], {
 itemsType: classc
})
##itemslimitedc =  vclassNewx(defsp, "ItemsLimited", itemsc, {
 itemsLimitedLength: uintc
})
##arrc = cclassNewx(defsp, "Arr", itemsc)
##dicc = cclassNewx(defsp, "Dic", itemsc)


/////7 advanced type init: string, enum, unlimited number...
##zerostrv = &Objx{
 type: @T("STR")
 val: ""
}
##strc = cclassNewx(defsp, "Str", valc, {
 valDefault: zerostrv
})
zerostrv.class = strc

/////8 function init
##funcrawc = cclassNewx(defsp, "Funcraw", valc, {
 valDefault: nullv
})















intDefx = &(x Int)Objx{
 @return &Objx{
  type: @T("INT")
  val: x
 }
}
numDefx = &(x Num)Objx{
 @return &Objx{
  type: @T("NUM")
  val: x
 }
}
strDefx = &(x Str)Objx{
 @return &Objx{
  type: @T("STR")
  val: x
 }
}
charDefx = &(x Char)Objx{
 @return &Objx{
  type: @T("CHAR")
  val: x
 } 
}
