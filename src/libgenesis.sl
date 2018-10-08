ObjTypex = @Enum {
 enum: ["NUM", "STR", "DIC", "ARR", "FUNC", "OBJ", "SCOPE", "CLASS", "CURRY"]
}
Metax = <>{
 type: ObjTypex
 val: Void
}
DicMetax = => Dic {
 itemsType: Metax
}
Dicx = => Dic {
 itemsType: Metax
}
Arrx = => Arr {
 itemsType: Metax
}
Classx = <>{
 name: Str
 id: Str
 ns: Str
 schema: DicMetax
 parents: DicClassx
}
DicClassx = => Dic {
 itemsType: Classx
}
Curryx = <>{
 name: Str
 id: Str
 ns: Str
 schema: DicMetax 
 class: Classx
}
Objx = <>{
 class: Classx
 val: Dicx
}
Scopex = <>{
 name: Str
 id: Str
 ns: Str
 index: Sizet
 parent: DicScopex
 val: DicMetax
}
DicScopex = => Dic {
 itemsType: Scopex
}

##rootsp
##defsp



##objc
##classc
##scopec
##curryc
##valc

asobjx = @@FuncInternal
asvalx = @@FuncInternal
reprx = @@FuncInternal
objNewx = @@FuncInternal
objSetx = @@FuncInternal
scopeGetLocal = @@FuncInternal
scopeSet = @@FuncInternal
routex = &(oo, scope, name){
 #o = asobjx(oo)
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
 scopeSetx(scope, name, o);
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
  dic(p.(k))[e->id] = e;
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
