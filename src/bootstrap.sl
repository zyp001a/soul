////////define structure

ReprScopex = <> {
 val: Dic
 scopeParents: Dic
}
ReprClassx = <> {
 classSchema: Dic
 classParents: Dic
}
ReprConsx = <> {
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
 }@else{
  o->id = id^"_"^name
	o->ns = scope->ns
 }
 o->scope = scope
 @return o;
}
