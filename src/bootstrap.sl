////////define structure

ReprScopex = <Obj> {
 val: Dic
 scopeParents: Dic
}
ReprClassx = <Obj> {
 classSchema: Dic
 classParents: Dic
}
ReprConsx = <Obj> {
 cons: Dic,
 consClass: Class
}

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
