&Arr(x:Str, c:Str){
 #arr = []
 #start =0
 #topush = "";
 @while start < strlen(x){
  #tmp = strieq(x, start, c)
  @if tmp {
   push(arr, topush)
   topush = "";
   start = tmp
  }@else{
   topush+=x[start]
   start+=1
  }
 }
 push(arr, topush)
 @return arr
}
