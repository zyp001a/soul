T = =>Enum {
 enum: [
  "NULL", "NUM", "STR", "DIC", "ARR", "FUNC",
  "SCOPE", "CLASS", "CURRY",
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
 itemsType: Objx 
 class: Objx
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

routex = &(o:Objx, scope:Objx, name:Str)Objx{
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

parentSetx = &(p:Objx, parents:Arrx){
 @foreach e parents{
  //TODO reduce
  p.oop.parents[e.route.id] = e;
 }
}
scopePresetx = &(scope:Objx, name:Str, parents:Arrx)Objx{
 #x = &Objx {
  type: @T("SCOPE")
  route: &Routex{}
  oop: &Oopx{
   parents: @Dicx{}
  }
  val: @Dicx{}
 }
 @if parents != _ {
  parentSetx(x, parents)
 }
 routex(x, scope, name);
 @return x;
}
classPresetx = &(scope:Objx, name:Str, parents:Arrx, schema:Dicx)Objx{
 #x = &Objx {
  type: @T("SCOPE")
  route: &Routex{}
  oop: &Oopx{
   parents: @Dicx{}  
  }
 }
 @if parents != _{
  parentSetx(x, parents)
 }
 routex(x, scope, name);
 @return x;
}

#rootsp = scopePresetx()
#defsp =  scopePresetx(rootsp, "def")

#objc = classPresetx(defsp, "Obj")
#classc = classPresetx(defsp, "Class", [objc])
#scopec = classPresetx(defsp, "Scope", [objc])

rootsp.obj = scopec
defsp.obj = scopec
objc.obj = classc
classc.obj = classc
scopec.obj = classc

