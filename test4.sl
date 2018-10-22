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

