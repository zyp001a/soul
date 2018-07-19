
var fs = require("fs");
var proglparser = require("./proglparser");
Object.defineProperty(global, '__stack', {
	get: function() {
    var orig = Error.prepareStackTrace;
    Error.prepareStackTrace = function(_, stack) {
      return stack;
    };
    var err = new Error;
    Error.captureStackTrace(err, arguments.callee);
    var stack = err.stack;
    Error.prepareStackTrace = orig;
    return stack;
  }
});
Object.defineProperty(global, '__line', {
	get: function() {
    return __stack[2].getLineNumber();
  }
});
Object.defineProperty(global, '__line2', {
	get: function() {
    return __stack[3].getLineNumber();
  }
});
Object.defineProperty(global, '__function', {
	get: function() {
    return __stack[2].getFunctionName();
  }
});
Object.defineProperty(global, '__file', {
	get: function() {
    return __stack[2].getFileName();
  }
});
function log(str){
	console.log(__line+":"+__file+":"+__function+":"+__line2);
	console.log(str);	
}
function die(){
  for(var i in arguments){
    console.error(arguments[i]);
  }
  console.error(getStackTrace());
  process.exit();
}
function getStackTrace(){
  var obj = {};
  Error.captureStackTrace(obj, getStackTrace);
  return obj.stack.toString().replace("[object Object]\n","");
}

var root = scopeNew();
var astScope = scopeNew(root);
classNew(root, "Class"),
classNew(root, "Undf", {
  default: {val: undefined}
}),
classNew(root, "Num", {
  default: {val: 0},
}),
classNew(root, "Str", {
  default: {val: ""},
}),	
classNew(root, "Arr", {
  default: {val: []}
}),
classNew(root, "Dic", {
  default: {val: {}}
}),
classNew(root, "Argdef", {
  default: {val: [[]]}
}),
classNew(root, "Func", {
  default: {val: function(){}} 
}),
classNew(root, "Obj"),
classNew(root, "Call", {
	schema:{
		func: root.Func,
		args: root.Arr,
	}
})
classNew(root, "ArrCall", {
	parent: [root.Arr],
	element: root.Call,
})
classNew(root, "Addr", {
	schema:{
		lexScope: root.Scope,
		args: root.Arr,
		level: root.Int
	}
})
classNew(root, "Stack", {
  default: {val: []}
})
funcNew(root, "Stack_pop", {
})
funcNew(root, "Stack_push", {
})
funcNew(root, "log", function(s){
	console.log(s);
}, [["s"]])

//parser function
function valCopy(item){
  let result = undefined;
  if(!item) return result;
  if(Array.isArray(item)){
    result = [];
    item.forEach(element=>{
      result.push(valCopy(element));
    });
  }else if(item instanceof Object && !(item instanceof Function) && !item.__){ 
    result = {};
    for(let key in item){
      if(key){
        result[key] = valCopy(item[key]);
      }
    }
  }
  return result || item;
}
//internal function
function funcNew(scope, name, func, argdef){
	var a = objNew(root.Argdef, argdef);
	var o = objNew(root.Func, {
		name: name,
		argdef: a,
		val: func
	})
	return scope[name] = o;
}
function objNew(cla, proto){
	if(!cla) die()
	if(!proto) proto = {};
	for(var k in cla.default){
		if(!haskey(proto, k))
			proto[k] = valCopy(cla.default[k])
	}
	proto.__ = {
		type: cla.__.id,
		ext: {}
	};
	return proto;
}
function classNew(pscope, name, conf){
	var p = pscope[name] = conf || {};
	var x = p.__ = {};
	p.parents = {
		Class: root.Class
	}
	x.name = name;
	if(!pscope){ //isroot
	  x.id = ".";
	}else{
  	if(name == undefined){
  	  name = pscope.__.index.toString();
  		pscope.__.index++;
  	}	
  	if(!pscope.__.parent){	//parent isroot
  		x.id = name;	  
  	}else{
  		x.id = pscope.__.id + "_" + name;
  	}
	}
	return p;
}
function scopeNew(pscope, name){
	var proto = {};
	var x = proto.__ = {
		parent: pscope,
		rels: {}
	};
	Object.defineProperty(proto, '__', {
		enumerable: false,
		configurable: false
	});
	x.index = 0;
	x.name = name;
	if(!pscope){ //isroot
	  x.id = ".";
	}else{
  	if(name == undefined){
  	  name = pscope.__.index.toString();
  		pscope.__.index++;
  	}	
  	if(!pscope.__.parent){	//parent isroot
  		x.id = name;	  
  	}else{
  		x.id = pscope.__.id + "_" + name;
  	}
	}
	if(pscope)
		pscope[name] = proto;
	return proto;
}
async function scopeGetOrNew(scope, key){	
	var x = await scopeGet(scope, key);
	if(!x) x = scopeNew(scope, key);
	return x;
}
async function scopeGetSub(scope, key, cache){
	if(haskey(scope, key)){
    return scope[key];
  }
	let str = await dbGet(scope.__.id, key)
	if(str){
		//TODO key match _, get subcpt		
		return await progl2obj(str, scope);
	}
	for(var k in scope.__.rels){
		if(cache[k]) continue;
		cache[k] = 1;		
		var r = scopeGetSub(scope.__.rels[k], key, cache);
		if(r) return r;		
	}
}
async function scopeGet(scope, key){
	var r = await scopeGetSub(scope, key, {});
	if(r) return scope[key] = r;
	if(scope.__.parent)
		return await scopeGet(scope.__.parent, key);	
	return undefined
}

function valType(e){
	switch(typeof e){
  case "boolean":
    return "Num";
  case "undefined":
    return "Undf";
  case "number":
    return "Num";
  case "string":
    return "Str";
  case "object":
		if(Array.isArray(e)) return "Arr";
		var x = Object.getOwnPropertyDescriptor(e, '__');
		if(!x) return "Dic";
		if(x.enumerable == true)
			return "Obj";
		return "Scope";
	case "function":
		return "Func";
  default:
    die("wrong cpt type", e);
  }
}
function haskey(x, k){
  return Object.getOwnPropertyDescriptor(x, k);
}
async function exec(obj, scope){	
	var t = obj.__;
	console.log(t)
	var executor = scopeGet(scope, t+"Exec");
	
}
async function callExec(obj, scope){
}
async function dbGet(id, sname){
  return "";
}
async function progl2obj(str, cpt){
  var ast = proglparser.parse(str);
	return await ast2obj(ast, cpt)
}
async function ast2obj(ast, scope){
  if(typeof ast != "object") return ast;
	var t = ast[0];
	var v = ast[1];
	var v2 = ast[2];	
  switch(t){
	case "num":
		var p = {};
		var c = 1;
		while(c){
			var l = v[v.length-1];
			v = v.substr(0, v.length - 1);			
			switch(l){
			case "u":
				p.unsigned = 1;
				break;
			case "s":
				p.storage = "short";
				break;
			case "l":
				p.storage = "long";
				break;
			case "b":
				p.storage = "big";
				break;
			case "f":
				p.storage = "float";
				break;
			default:
				c = 0;				
			}
		}
		if(v.match("\\.")) p.float = 1;
		if(v.match(/[eE]/)) p.sci = 1;
		if(v.match(/[xX]/)) p.hex = 1;
		p.val = Number(v);
		return objNew(root.Num, p);
		
	case "str":
		return objNew(root.Str, {val: v});
		
	case "call":
		var func = await ast2obj(v, scope);
		var args = await ast2obj(['arr', v2], scope);
		return objNew(root.Call, {
			func: func,
			args: args
		})
		
	case "id":
		var r = await scopeGet(scope, v);
		return r;

	case "arr":
		var arrx = [];
		for(var i in v){
			arrx[i] = await ast2obj(v[i], scope);
		}
		return objNew(root.Arr, {
			val: arrx
		})
		//		  return elem("ArrDef", arres, cpt);
	default:
		die("type error: "+t);
	}
}


process.argv.shift();
var _argv = process.argv;
async function main(){
  var _cmd;
  var _file;
  var _idGlobal;
  var _currsp;
  var _scopeNew;
  var _lexsp;
  var _execsp;
  var _progl2obj;
  var _readFile;
  var _elem;
  var _exec;
  _cmd = _argv[1];
  _file = _argv[2];
  _currsp = await scopeGetOrNew(root, _cmd);
  _lexsp = scopeNew(_currsp, undefined);
  _execsp = scopeNew(_currsp, undefined);
  _elem = await progl2obj(fs.readFileSync(_file).toString(), _lexsp);
  exec(_elem, _execsp);
  
}
main();
