#c = 1
#b = [c]
b[0] = 3
Metax = <>{
 type: Str
 val: Num
}
#x = @Metax{
 type:"x",
 val: 1+1
}
log(x.type)
log(b[0])