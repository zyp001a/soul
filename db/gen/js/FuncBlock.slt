~
#block = #0.func
#argdef = #0.funcArgts
#str = exec(block, #$env);

#x = "";
@each i v argdef{
 @if (i != 0) {x ^= ", "}
 #vv = "_" ^ v[0]
 x ^= vv;
}
@if(block){
 #nn = #0->id;
 @if(nn){ nn = " "^nn }
~function~=nn~(~=x~){
~=ind(str)~}~
}~