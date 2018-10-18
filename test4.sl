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
Classx = <>{
 name: Str
 id: Str
 ns: Str
 schema: DicMetax
 parents: DicClassx
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
DicScopex = => Dic {
 itemsType: Scopex
}
Scopex = <>{
 name: Str
 id: Str
 ns: Str
 index: Sizet
 parent: DicScopex
 val: DicMetax
}
