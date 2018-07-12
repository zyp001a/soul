
var fs = require("fs");
var proglparser = require("./proglparser");
var rootScope = elem("Scope", {})
var lexScope = elem("Scope", {}, rootScope);
//parser function
function xp(k, a1, a2){
  return elem("Ast", [k, a1, a2], lexScope);
}
function copy(item){
  let result = undefined;
  if(!item) return result;
  if(Array.isArray(item)){
    result = [];
    item.forEach(element=>{
      result.push(copy(element));
    });
  }
  else if(item instanceof Object && !(item instanceof Function)){ 
    result = {};
    for(let key in item){
      if(key){
        result[key] = copy(item[key]);
      }
    }
  }
  return result || item;
}
//internal function
var defaultProtos = {
	"Arr": []
}
function elem(type, proto, scope, name){
	if(proto == undefined && defaultProtos[type])
		proto = copy(defaultProtos[type]);
	var x = proto.__ = {
	  scope: scope
	}
	Object.defineProperty(proto, '__', {
		enumerable: false,
		configurable: false
	});
	if(type == "Scope")
	  x.index = 0;
  x.name = name;
	if(!scope){ //isroot
	  x.path = "";
	}else{
  	if(name == undefined){
  	  name = scope.__.index.toString();
  		scope.__.index++;
  	}	
  	if(!scope.__.scope){	//parent isroot
  		x.path = name;	  
  	}else{
  		x.path = scope.__.path + "/" + name;
  	}
	}
	return proto;
}
function haskey(x, k){
  return Object.getOwnPropertyDescriptor(x, k);
}
function dbget(){
  return "";
}
async function scopeGet(scope, key, config){
  if(!config) config = {};
	if(key == undefined){
	  key = scope.__.index;
		scope.__.index++;
	}
  if(haskey(scope, key)){
    return scope[key]
  }
	let str = dbget(scope.__.path + "/" + key)
	if(str)
	  return scope[key] = progl2elem(str, scope)
	else
	  return scope[key] =  elem("Scope", {}, scope)
}
async function dicGet(dic, key, config){
  
}
async function progl2elem(str, scope){
  var ast = proglparser.parse(str, xp);
	return await ast2elem(ast, scope)
}
async function ast2elem(ast, scope){
  if(typeof ast != "object") return ast;
  switch(ast[0]){
	  case "call":
		  var func = await ast2elem(ast[1], scope);
		  var args = await ast2elem(ast[2], scope);
			return elem("Call", [func, args], scope)
		case "id":
		  return scopeGet(scope, ast[1])
		case "arr":
		  var arres = [];
			for(var i in ast[1]){
			  arres[i] = await ast2elem(ast[1][i], scope);
			}
		  return elem("ArrDef", arres, scope);
	}
}


process.argv.shift();
var _argv = process.argv;
async function main(){
  var _cmd;
  var _file;
  var _readFile;
  var _subScope;
  var _idGlobal;
  var _elem;
  _cmd = _argv[1];
  _file = _argv[2];
  _elem = await progl2elem(fs.readFileSync(_file).toString(), await scopeGet(await scopeGet(rootScope, _cmd)));
  console.log(_elem);
  
}
main();
