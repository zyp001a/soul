T = =>Enum {
 enum: [
  "NULL", "INT", "NUM", "STR", "CHAR", "DIC", "ARR", "FUNC",
  "SCOPE", "CLASS", "CURRY",
  "BLOCK",
  "OBJ"
 ]
}
Routex = <>{
 name: Str
 id: Str
 ns: Str
 index: Uint
 scope: Objx
 flagNoname: Boolean
}
Dicx = => Dic {
 itemsType: Objx
}
Arrx = => Arr {
 itemsType: Objx
}

Oopx = <>{
 class: Objx//store curryClass and itemsType
 schema: Dicx
 curry: Dicx
 parents: Dicx
}
Objx = <>{
 type: T
 route: Routex
 obj: Objx
 oop: Oopx
 val: Voidp 
}
Funcx = <>{
}
Blockx = <>{
 
}
routex = &(o Objx, scope Objx, name Str)Objx{
 @if(!o.route){
  o.route = &Routex{}
 }
 #r = o.route;
 @if(!r.index){
  r.index = 0
 }
 @if(!scope){
  @return o
 }
 @if(!name){
  name = str(r.index)
  r.index ++
 }
 Dicx(scope.val)[name] = o
 r.name = name;
 #id = scope.route.id
 @if(!id){
  r.id = "."
  r.ns = name
 }@elif(id == "."){
  r.id = name
  r.ns = scope.route.ns
 }@elif(scope.route.flagNoname){
  r.id = name
  r.ns = scope.route.ns + "/" + id
 }@else{
  r.id = id + "_" + name
  r.ns = scope.route.ns
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
//Def: struct
//Preset: struct + route
//Init: struct + obj
//New: struct + route + obj
scopeDefx = &(parents Dicx, val Dicx)Objx{
 #x = &Objx {
  type: @T("SCOPE")
  route: &Routex{}
  oop: &Oopx{}
 }
 @if(parents != _){
  x.oop.parents = parents
 }@else{
  x.oop.parents = @Dicx{}
 }
 @if(val != _){
  x.val = val
 }@else{
  x.val = @Dicx{}
 }
 @return x
}
classDefx = &(parents Dicx, schema Dicx, curry Dicx)Objx{
 #x = &Objx {
  type: @T("CLASS")
  route: &Routex{}
  oop: &Oopx{}
 }
 @if(parents != _){
  x.oop.parents = parents
 }@else{
  x.oop.parents = @Dicx{} 
 }
 @if(schema != _){
  x.oop.schema = schema
 }@else{
  x.oop.schema = @Dicx{} 
 }
 @if(curry != _){
  x.oop.curry = curry
 }@else{
  x.oop.curry = @Dicx{} 
 }
 @return x
}
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
curryDefx = &(class Objx, curry Dicx)Objx{
 #x = &Objx {
  type: @T("CURRY")
  route: &Routex{}
  oop: &Oopx{
   class: class
  }
 }
 @if(curry != _){
  x.oop.curry = curry
 }@else{
  x.oop.curry = @Dicx{} 
 }
 @return x
}

scopePresetx = &(scope Objx, name Str, parentarr Arrx)Objx{
 #x = scopeDefx(parentsMakex(parentarr))
 routex(x, scope, name);
 @return x;
}
classPresetx = &(scope Objx, name Str, parentarr Arrx, schema Dicx)Objx{
 #x = classDefx(parentsMakex(parentarr))
 routex(x, scope, name);
 @return x;
}


##rootsp = scopePresetx()
##defsp =  scopePresetx(rootsp, "def")

##objc = classPresetx(defsp, "Obj")
##classc = classPresetx(defsp, "Class", [objc])
##scopec = classPresetx(defsp, "Scope", [objc])

rootsp.obj = scopec
defsp.obj = scopec
objc.obj = classc
classc.obj = classc
scopec.obj = classc

scopeNewx = &(scope Objx, name Str, parents Arrx)Objx{
//TODO when key match "_"
 #x = scopePresetx(scope, name, parents)
 x.obj = scopec
 @return x
}

classInitx = &(parentarr Arrx, schema Dicx, curry Dicx)Objx{
 #x = classDefx(parentsMakex(parentarr), schema, curry)
 x.obj = classc
 @return x
}

classNewx = &(scope Objx, name Str, parentarr Arrx, schema Dicx)Objx{
 #x = classPresetx(scope, name, parentarr, schema)
 x.obj = classc
 @return x
}

##curryc = classNewx(defsp, "Curry", [objc])
##valc = classNewx(defsp, "Val", [objc], {
 valDefault: objc
})

curryInitx = &(class Objx, curry Dicx)Objx{
 #x = curryDefx(class, curry)
 x.obj = curryc
 @return x
}

curryNewx = &(scope Objx, name Str, class Objx, curry Dicx)Objx{
 //TODO class cannot be defsp.Curry
 #x = curryInitx(class, curry)
 routex(x, scope, name)
 @return x;
}
##nullv =  &Objx{
 type: @T("NULL")
}
##zerointv = intDefx(0)
##zeronumv = numDefx(0)
##nullc = curryNewx(defsp, "Null", valc, {
 valDefault: nullv
})
##numc = classNewx(defsp, "Num", [valc])
##intc = classNewx(defsp, "Int", [numc])
inttDefx = &(x Str){
 curryNewx(defsp, x, intc, {
  valDefault: zerointv
 })
}
numtDefx = &(x Str){
 curryNewx(defsp, x, numc, {
  valDefault: zeronumv
 })
}
inttDefx("Boolean")
inttDefx("Int8")
inttDefx("Int16")
inttDefx("Int32")
inttDefx("Int64")
inttDefx("Uint8")
inttDefx("Uint16")
inttDefx("Uint32")
inttDefx("Uint64")
numtDefx("Float")
numtDefx("Double")
numtDefx("Unlimited")

##strc = curryNewx(defsp, "Str", valc, {
 valDefault: strDefx("")
})
##charc = curryNewx(defsp, "Char", valc, {
 valDefault: charDefx(0)
})
##voidpc = classNewx(defsp, "Voidp", [objc])


##itemsc =  classNewx(defsp, "Items", [valc], {
 itemsType: classc
})



##funcvc = curryNewx(defsp, "Funcv", valc, {
 valDefault: nullv
})
