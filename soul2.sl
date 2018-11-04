/////1 set class/structs
T = =>Enum {
 enum: [
  "NULL", "INT", "NUM", "STR", "CHAR", "DIC", "ARR", "VALFUNC"
  "CLASS", "OBJ"
 ]
}
Routex = <>{
 name: Str
 id: Str
 ns: Str
 index: Uint
 scope: Objx
 noname: Int//TODO change to Boolean
}
Dicx = => Dic {
 itemsType: Objx
}
Objx = <>{
 type: T
 mid: Boolean
 route: Routex
 class: Objx
 parents: Dicx 
 dic: Dicx
 val: Val
}
Arrx = => Arr {
 itemsType: Objx
}
/////2 preset root ...
routex = &(o Objx, scope Objx, name Str)Objx{
 @if(!o.route){
  o.route = &Routex{}
 }
 #r = o.route;
 #sr = scope.route
 @if(!r.index){
  r.index = 0
 }
 @if(!name){
  name = str(r.index)
  r.index ++
  r.noname = 1
 }
 scope.dic[name] = o
 r.name = name;
 #id = sr.id
 @if(!id){
  r.id = "."
  r.ns = name
 }@elif(id == "."){
  r.id = name
  r.ns = sr.ns  
 }@elif(sr.noname != 0){
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
classmPresetx = &(parentarr Arrx)Objx{
 #x = &Objx{
  type: @T("CLASS") 
  def: &Classx{  
   parents: parentsMakex(parentarr)
   schema: @Dicx{}
   curry: @Dicx{}   
  }
 }
 @return x;
}
classvPresetx = &(class Objx)Objx{
 #x = &Objx{
  type: @T("CLASS") 
  def: &Classx{
   class: class
   schema: @Dicx{}
   curry: @Dicx{}   
  }
 }
 @return x;
}
scopePresetx = &(class Objx)Objx{
 #x = &Objx{
  type: @T("OBJ")
  def: &Class{
   class: class
   parents: @Dicx{}
   schema: @Dicx{}
   curry: @Dicx{}   
  }
  dic: @Dicx{}
 }
 @return x;
}
