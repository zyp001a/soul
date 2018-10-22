ObjTypex = @@Enum {
 enum: ["NUM", "STR", "DIC", "ARR", "FUNC", "OBJ", "SCOPE", "CLASS", "CURRY"]
}
Metax = <>{
 type: ObjTypex
 val: Voidp
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
DicClassx = => Dic {
 itemsType: Classx
}
Routex = <>{
 name: Str
 id: Str
 ns: Str
 index: Uint
}
Classx = <Routex>{
 schema: DicMetax
 parents: DicClassx
}
Curryx = <Routex>{
 schema: DicMetax 
 class: Classx
}
Objx = <>{
 class: Classx
 val: Dicx
}
DicScopex = => Dic {
 itemsType: Scopex
}
Scopex = <Routex>{
 parent: DicScopex
 val: DicMetax
}

##rootsp
##defsp



##objc
##classc
##scopec
##curryc
##valc

routex = &Routex(o:Routex, scope:Scopex, name:Str){
 @if(!o.index){
  o.index = 0
 }
 @if(!scope){
  @return o
 }
 /*
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
 */
 @return o;
}