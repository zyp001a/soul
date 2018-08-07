&Str(x:Str){
 #arr = split(x, "\n")
 @for #i =0;i<len(arr);i+=1 {
  @if arr[i] != "" {
   arr[i] = indent + arr[i]
	}
 }
 #r = join(arr, "\n")
 @return r
}
