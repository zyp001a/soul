#a = @Server {
 serverApis: @DicApi {
  ip: @Api {
   apiAddr: "ip"
	 apiFunc: &(req){
	  return req.getIp()
 	 }
  }
 }
}
a.start()