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
 oop: Oopx
 val: Voidp 
}

##rootsp
##defsp



##objc
##classc
##scopec
##curryc
##valc
/*
valx = &(o:Objx)Voidp{
 #t = o.type
 @if(t == "NUM"){
  @return 
 }
 @return 1
}
*/
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
  /*
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
 */  
 @return o;
}
//log(valx(@Metax{}))
