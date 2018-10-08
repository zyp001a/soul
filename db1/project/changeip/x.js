//npm install express
let express = require("express")
let _a
_a = {
  start:   function web_Server$start(_this){
    console.log("start")
  },
  serverPort:   5001,
  serverApis:   {
    "ip":   {
      apiMethod:   "get",
      apiAddr:   "ip",
      apiFunc:   function(_params, _req){
        return _req.headers['x-forwarded-for'] || _req.connection.remoteAddress;
      },
    },
  },
  ex: express(),
}
for(let k in _a.serverApis){
  let v = _a.serverApis[k]
  _a.ex[v.apiMethod]("/"+v.apiAddr, function(req, res){
    let p = new Promise(function(resolve, reject){
      try {
        let ret = v.apiFunc(req.body, req, res)
        if(typeof ret != "string" || typeof ret != "object")
          reject()
        else
          resolve(ret)
      }catch(e){
        reject()
      }
    })
    p.then(function(r){
      res.send(r)
    }, function(e){
			console.log(e)
      res.send("ERROR")
    })
  })
}
_a.ex.listen(_a.serverPort, function(err){
  if(err) console.log(err)
  else console.log("Server start at port "+_a.serverPort)
})

