
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
var execsp = scopeNew(root, "exec");
var definesp = scopeNew(root, "define");
classNew(definesp, "Class")
classNew(definesp, "Obj")
classNew(definesp, "Raw")
classNew(definesp, "Undf", {
  default: {val: undefined}
}, [definesp.Raw])
classNew(definesp, "Num", {
  default: {val: 0},
}, [definesp.Raw])
classNew(definesp, "Str", {
  default: {val: ""},
}, [definesp.Raw])
classNew(definesp, "Arr", {
  default: {val: []}
}, [definesp.Raw])
classNew(definesp, "Dic", {
  default: {val: {}}
}, [definesp.Raw])
classNew(definesp, "Argdef", {
  default: {val: [[]]}
}, [definesp.Raw])
classNew(definesp, "Call", {
	schema:{
		func: definesp.Func,
		args: definesp.Arr,
	}
})
classNew(definesp, "ArrObj", {
	element: definesp.Obj,
}, [definesp.Arr])
classNew(definesp, "Block", {
  schema: {
    arrobj: definesp.ArrObj,
    label: classSub(definesp.Dic, {element: definesp.Num})
  }
})
classNew(definesp, "Func", {
  default: {val: function(){}}
}, [definesp.Raw]);
classNew(definesp, "FuncNative", {
  schema: {
    func: definesp.Func,
    argdef: definesp.Argdef,
  }
});
classNew(definesp, "FuncBlock", {
  schema: {
    func: definesp.Block,
    argdef: definesp.Argdef,
  }  
});
classNew(definesp, "Stack", {
  default: {val: []}
})
funcNew(definesp, "log", function(s){
	console.log(s);
}, [["s"]])

funcNew(execsp, "Call", async function(o, s, e){
  var func = await exec(o.func, s, e);
  var args = await exec(o.args, s, e);
  execSub()
}, [["o"], ["s"], ["e"]])

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
	var a = objNew(definesp.Argdef, argdef);
	var o = objNew(definesp.Func, {
		argdef: a,
		val: func
	}, name)
	return scope[name] = o;
}
function objNew(cla, proto, name){
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
  if(name)
    proto.__.name = name
	return proto;
}
function classSub(c, conf){
  var name = c.__.name + JSON.stringify(conf);
  classNew(c.__.parent, name, conf, [c]);
}
function classNew(pscope, name, conf, cla){
	var p = pscope[name] = {};
	var x = p.__ = conf || {};
  x.parent = pscope
	x.parents = {};
  if(!cla) cla = [definesp.Class];
  for(var i in cla){
    x.parents[cla[i].__.name] = cla;
  }
	Object.defineProperty(p, '__', {
		enumerable: false,
		configurable: false
	});  
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
  x.conf = conf;
	return p;
}
function scopeNew(pscope, name){
	var proto = {};
	var x = proto.__ = {
		parent: pscope,
		parents: {}
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
async function istype(obj, type){
  
}
async function exec(obj, scope, execScope, execx){
	var t = obj.__.type;
	console.log(t)
  var ex;
  if(!execx[t]){
    ex = execx[t] = await scopeGet(execScope, t);
    console.log(t)
  }
  call(ex, [obj, scope, execx]);
  
  
}
async function call(func, args){
  if(func.val){    
    return await func.val.apply({
    }, args)
  }
  
  for(var i in func.arrobj){
    var o = func.arrobj[i];
//    await 
  }
  
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
		return objNew(definesp.Num, p);
		
	case "str":
		return objNew(definesp.Str, {val: v});
		
	case "call":
		var func = await ast2obj(v, scope);
		var args = await ast2obj(['arr', v2], scope);
		return objNew(definesp.Call, {
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
		return objNew(definesp.Arr, {
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
  var _sp;
  var _progl2obj;
  var _readFile;
  var _elem;
  var _exec;
  _cmd = _argv[1];
  _file = _argv[2];
  _currsp = await scopeGetOrNew(definesp, _cmd);
  _lexsp = scopeNew(_currsp, undefined);
  _sp = scopeNew(_currsp, undefined);
  _elem = await progl2obj(fs.readFileSync(_file).toString(), _lexsp);
  exec(_elem, _sp, execsp, {});
  
}
main();
