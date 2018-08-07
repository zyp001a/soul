&Num(x:Str, i:Num, y:Str){
 #k=0;
 #m = max(strlen(x), i+strlen(y))
 @for #j = i; j<strlen(x); j+=1 {
  @if x[j] != y[k] {@return 0};
  k+=1
  @if k == len(y){@return j+1}
 }
 @if k != len(y){@return 0}
 @return j
}