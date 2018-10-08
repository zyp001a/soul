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
