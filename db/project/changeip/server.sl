#a = @Server {
 serverApis: {
  ip: @Api {
   apiAddr: "ip"
	 apiFunc: &(params, req:Req){
	  @return req.ip()
 	 }
  }
 }
 serverPort: 5001
}
a.start()