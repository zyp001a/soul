////////define structure

ReprScopex = <Obj> {
 val: Dic
 scopeParents: Dic
}
ReprCurryx = <Obj> {
 curry: Dic,
 curryClass: Class
}
ReprClassx = <Obj> {
 classCurry: Dic,
 classSchema: Dic
 classParents: Dic
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
//TODO when key match _
 #x = scopePresetx(scope, name, parents)
 x->obj = scopec
 @return x
}
scopeIntox = &(scope, key:Str){
 #nscope = scope
 #arr = key.split("_")
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
