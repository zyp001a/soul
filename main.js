
var fs = require("fs");
var proglparser = require("./proglparser");
var tplparser = require("./tplparser");
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
var prefix = process.env.HOME+"/soul/db";
var root = scopeNew();
var execsp = scopeNew(root, "exec");
var def = scopeNew(root, "def");
classNew(def, "Class")
classNew(def, "Obj")
classNew(def, "Callable")
classNew(def, "Raw", {}, [def.Callable])
classNew(def, "RawObj", {}, [def.Raw])
classNew(def, "Var", {
	schema: {
		type: def.Class
	}
})
classNew(def, "Undf", {
  default: undefined
}, [def.Raw])
classNew(def, "Num", {
  default: 0
}, [def.Raw])
classNew(def, "Str", {
  default: "",
}, [def.Raw])
classNew(def, "Function", {
  default: function(){}
}, [def.Raw]);
classNew(def, "Arr", {
  default: []
}, [def.RawObj])
classNew(def, "Dic", {
  default: {}
}, [def.RawObj])
classNew(def, "Argdef", {
  default: [[]]
}, [def.RawObj])
classNew(def, "Call", {
}, [def.RawObj])
classNew(def, "Ctrl", {
}, [def.RawObj])
classNew(def, "Block", {
}, [def.RawObj])
classNew(def, "Func", {}, [def.RawObj]);	
classNew(def, "FuncNative", {
}, [def.Func]);
classNew(def, "FuncBlock", {
}, [def.Func]);
classNew(def, "FuncTpl", {
}, [def.Func]);
classNew(def, "Main", {
});

funcNew(def, "log", function(s){
	console.log(s);
}, [["s"]])
funcNew(def, "push", function(arr, e){
	arr.push(e);
	return e;
}, [["arr"], ["e"]])
funcNew(def, "join", function(arr, str){
	return arr.join(str)
}, [["arr"],["str"]])
funcNew(def, "state", function(){
	var self = this;
	return self.x.state;
})
funcNew(def, "root", function(){
  return root;
})
funcNew(def, "global", function(){
	var self = this;
	return self.x.global;
})
funcNew(def, "set", function(p, k, v, t){//t is type 
  //TODO if type, check type
	return scopeSet(p, k, v)
}, [["p"], ["k"], ["v"], ["t"]])
funcNew(def, "get", function(p, k){
	return scopeGet(p, k);
}, [["p"], ["k"]])
funcNew(def, "concat", function(p, k, v){
	return p[k] += v;
}, [["p"], ["k"], ["v"]])
funcNew(def, "plus", function(l, r){
	return l + r;
}, [["l"], ["r"]])
funcNew(def, "minus", function(l, r){
	return l - r;
}, [["l"], ["r"]])
funcNew(def, "exec", async function(o){
	if(o === undefined) return;
	return await exec(o, this);
}, [["o"], ["conf"]], 1)

var execarg = [["o"]];
funcNew(execsp, "Call", async function(o){
  var func = await exec(o.func, this);
  return await call(func, o.args, this);
}, execarg)

//funcNew(execsp, "Block", async function(o){
//	return blockExec(o, this)
//}, execarg)

funcNew(execsp, "Arr$elementCallable", async function(o){
	var self = this;
	var arrx = [];
	for(var i in o.val){
		arrx[i] = await exec(o.val[i], self);
	}
	return arrx;
}, execarg)

funcNew(execsp, "Dic$elementCallable", async function(o){
	var dicx = [];
	for(var k in o.val){
		dicx[k] = await exec(o.val[k], this);
	}
	return dicx;
}, execarg)
funcNew(execsp, "Main", async function(o){
	return await blockExec(o.content, this)
}, execarg)
funcNew(execsp, "Raw", function(o){
	return o.val;
}, execarg)
funcNew(execsp, "RawObj", function(o){
	return o;
}, execarg)
funcNew(execsp, "Class", function(o){
	return o;
}, execarg)


funcNew(execsp, "Ctrl", async function(o){
	var self = this;
	switch(o.ctrl){
	case "if":
	case "for":
	case "while":
		while(await exec(o.args[0], self)){
			var r = await blockExec(o.args[1], self);
		}
		break;
	case "foreach":
	case "each":
		break;
	case "goto":
		break;
	case "return":
		o.return = await exec(o.args[0], self);
	case "continue":
	case "break":
		break;
	default:
		console.log(o);
		die("wrong ctrl")
	}
	return o;
}, [["o"]])

var objList = {};
objList.undf = objNew(def.Undf, {val: undefined})
//parser function
function valCopy(item){
  let result = undefined;
  if(!item) return result;
  if(Array.isArray(item)){
    result = [];
    item.forEach(element=>{
      result.push(valCopy(element));
    });
  }else if(item instanceof Object && !(item instanceof Function) && !item.__ && !item.__){ 
    result = {};
    for(let key in item){
      if(key){
        result[key] = valCopy(item[key]);
      }
    }
  }
  return result || item;
}
function callNew(func, args){
	if(!args) args = []
	return objNew(def.Call, {
		func: func,
		args: args
	});
}
//internal function
function fbNew(block, argdef){
	return objNew(def.FuncBlock, {
		block: block,
		argdef: argdef
	})
}
function ftNew(str){
	return objNew(def.FuncTpl, {
		str: str
	})
}
function funcNew(scope, name, func, argdef, flagraw){
	var o = objNew(def.FuncNative, {
		argdef: argdef,
		func: func
	});
  if(name)
		route(scope, name, o);
	if(flagraw)
		o.__.rawargs = 1;
	return o;
}

function objNew(cla, proto){
	if(!cla) die()
	if(!proto) proto = {};
	for(var k in cla.default){
		if(!haskey(proto, k))
			proto[k] = valCopy(cla.default[k])
	}
	proto.___ = {
		type: cla.__.id,
		ext: {}
	};
	Object.defineProperty(proto, '___', {
		enumerable: false,
		configurable: false
	});	
	return proto;
}
function extname(conf){
	var r = "";
	for(var k in conf){
		r+=k;
		var v = conf[k];
		switch(rawType(v)){
		case "Class":
			r+=v.__.id.replace("_", "");
			break;
		case "Num":
			r+=v.toString();
			break;
		case "Str":
			r+=v;
			break;
		default:
			die("TODO: "+rawType(v))					
		}
	}
	return r;
}
function classSub(c, conf){
  var name = c.__.name + "$"+extname(conf);
	if(c.__.parent[name])
		return c.__.parent[name];
  return classNew(c.__.parent, name, conf, [c]);
}
function route(pscope, name, p){
	if(!p) p = {};
	var x = p.__ = {};
	Object.defineProperty(p, '__', {
		enumerable: false,
		configurable: false
	});
	if(!pscope) return p;
	pscope[name] = p;	
  if(name == undefined){
  	name = pscope.__.index.toString();
		x.tmp = 1;
  	pscope.__.index++;
  }
	x.name = name;	
	
  if(!pscope.__.id){	//parent isroot
		x.id = ".";
		x.ns = name;
  }else if(pscope.__.id == "."){	//grandparent is root
  	x.id = name;
		x.ns = pscope.__.ns;		
  }else{
  	x.id = pscope.__.id + "_" + name;
		x.ns = pscope.__.ns;				
  }
	x.parent = pscope
	return p;
}
function classNew(pscope, name, conf, cla){
	var p = route(pscope, name);
	var x = p.__;
	for(var k in conf){
		x[k] = conf[k];
	}
	x.parents = {};
  if(!cla)
		cla = [def.Class];		
  for(var i in cla){
    x.parents[cla[i].__.name] = cla[i];
  }	
	return p;
}
function varNew(pscope, name, cla){
	var p = route(pscope, name);
	p.type = cla;
	return p;
}
function scopeNew(pscope, k){
  if(pscope && k && k.match("_")){
    var arr = k.split("_");
    var xx = pscope;
    var xr;
    var i;
    for(i=0; i<arr.length;i++){
      xr = haskey(xx, arr[i]);
      if(!xr) scopeNew(xx, arr[i]);
      xx = xx[arr[i]];
    }
    return xx;
  }
  
	var p = route(pscope, k);	
	var x = p.__;
	x.parents = {};
	x.index = 0;
	return p;
}
async function scopeGetOrNew(scope, key){
	var x = await scopeGet(scope, key);
	if(!x) x = scopeNew(scope, key);
	return x;
}
async function scopeGetSub(scope, key, cache){
  var v = haskeyr(scope, key);
	if(v){
    return v.value;
  }
  
	let str = await dbGet(scope, key);
	if(str){
		//TODO key match _, get subcpt
		var rtn = await progl2obj(scope, str);
		if(rtn.___.type == "FuncBlock")
			route(scope, key, rtn);
		return rtn;
	}
	for(var k in scope.__.parents){
		if(cache[k]) continue;
		cache[k] = 1;		
		var r = await scopeGetSub(scope.__.parents[k], key, cache);
		if(r) return r;
	}
}
async function scopeGet(scope, key){
	var r = await scopeGetSub(scope, key, {});
	if(r) return r//scopeSet(scope, key, r);
	if(scope.__.parent)
		return await scopeGet(scope.__.parent, key);
}
function scopeSet(x, k, r){
  if(k.match("_")){
    var arr = k.split("_");
    var xx = x;
    var xr;
    var i;
    for(i=0; i<arr.length - 1;i++){
      xr = haskey(xx, arr[i]);
      if(!xr) scopeNew(xx, arr[i]);
      xx = xx[arr[i]];
    }
    return xx[arr[i]] = r;
  }else{
  
    return x[k] = r;
  }
}

function rawType(e){
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
		var x = Object.getOwnPropertyDescriptor(e, '__');//route
		var y = Object.getOwnPropertyDescriptor(e, '___');//class
		if(x && !x.enumerable){
			if(haskey(x.value, "index"))
				return "Scope";
			return "Class"
		}
		if(y && !y.enumerable)
			return "Obj"
		if(Array.isArray(e)) return "Arr";		
		return "Dic";
	case "function":
		return "Func";
  default:
    die("wrong cpt type", e);
  }
}

function haskey(x, k){
  return Object.getOwnPropertyDescriptor(x, k);
}
function haskeyr(x, k){
  if(k.match("_")){
    var arr = k.split("_");
    var xx = x;
    var xr;
    for(var i in arr){
      if(!xx) return;
      xr = haskey(xx, arr[i]);
      if(!xr) return;
      xx = xr.value
    }
    return xr;
  }else{
    return Object.getOwnPropertyDescriptor(x, k);
  }
}
async function istype(obj, type){
  
}
async function execGet(sp, esp, t){
	var r = await scopeGet(esp, t);
	if(r) return r;
	var tt = await scopeGet(sp, t);
	for(var k in tt.__.parents){
		r = await execGet(sp, esp, k);
		if(r) return r;
	}	
}
function execInit(x, g){
	if(!x.init){
		x.state = objNew(def.Dic, {})
		x.stack = objNew(def.Arr, [])
		x.global = g || objNew(def.Dic, {})
		x.init = 1;
	}
	return x
}
async function exec(obj, conf){
	var s = conf.s;
	var e = conf.e;
	var x = conf.x;
	var t = obj.___.type;
  var ex;
	execInit(x);
  if(!x[t]){
		ex = await execGet(s, e, t);
		if(!ex)
			die(t+" not exec defined");
    x[t] = ex
  }else{
		ex = x[t];
	}
  return await call(ex, objNew(def.Arr, [obj]), conf, 1);
}
function stateNew(a0, args){
	var state = objNew(def.Dic, {});
	for(var i in args){
		var d = a0[i];
		state[i] = state[d[0]] = args[i];
	}
	state.$arglen$ = args.length;
	return state;
}
function scopeLoad(a0, scope){
}
async function blockExec(b, conf, stt){
	if(stt) stt = b.labels[stt];
	for(var i in b.arr){
		if(stt && stt < i)
			continue;
		var r = await exec(b.arr[i], conf);

		if(rawType(r) == "Obj" &&
       (r.ctrl == "return" || r.ctrl == "break" || r.ctrl == "continue"))
			return r;
	}
}
async function tplCall(str, args, conf){
	var tstr = tplparser.parse(str);
	var scope = scopeNew(def);
	var obj = await progl2obj(scope, tstr);
	var nconf = {
		s: scopeNew(def),
		e: execsp,
		x: execInit({}, conf.global)
	}
	for(var i in args){
		nconf.x.state[i] = args[i]
	}
	nconf.x.state.$arglen$ = args.length;
	var r = await blockExec(obj, nconf);
	return r.return;
}
async function call(func, argsn, conf, rawflag){
	if(func.str){//is FuncTpl
		return await tplCall(func.str, argsn, conf);
	}
	//Process args
	if(!rawflag){
		var args = [];
		for(var i in argsn){
			args[i] = await exec(argsn[i], conf);
		}
	}else{
		args = argsn;
	}
	
  if(func.func){//is FuncNative
		//log(func.__.name)
		if(func.___.rawargs)
			return await func.func.apply(conf, argsn)
		else
			return await func.func.apply(conf, args)			
  }
	//is FuncBlock

	var x = conf.x;
	var state = stateNew(func.argdef[0], args);
	x.stack.push(x.state);
	x.state = state;
	var r = await blockExec(func.block, conf);
	if(rawType(r) == "Obj" && r.ctrl == "return")
    r = r.return;
	x.state = x.stack.pop();
	return r;
}
function dbPath(x){
	var ns;	
	if(!x.__.ns)
		ns = ""
	else
		ns = "/" + x.__.ns
	if(!x.__.id)
		return ns;
	return ns + "/" + x.__.id.replace("_", "/")
}
async function dbGet(scope, key){
	if(scope.__.tmp) return "";
	var p = prefix + dbPath(scope) + "/"+ key;
	if(fs.existsSync(p+".sl")){
		return fs.readFileSync(p+".sl").toString();
	}
	if(fs.existsSync(p+".slt")){
		return "@`"+fs.readFileSync(p+".slt").toString()+"`";
	}
	
  return "";
}
function raw2obj(r){
	var t = rawType(r)
	switch(t){
	case "Num":
		return objNew(def.Num, {val: r});
	case "Str":
		return objNew(def.Str, {val: r});
	case "Undf":
		return objList.undf;
	default:
		return r;
	}
}

async function progl2obj(scope, str){
  var ast = proglparser.parse(str);
	log(ast[1])
	var r = await ast2obj(scope, ast);
	return r;
}
async function ast2obj(scope, ast){
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
				continue;
			}
			v = v.substr(0, v.length - 1);			
		}
		if(v.match("\\.")) p.float = 1;
		if(v.match(/[eE]/)) p.sci = 1;
		if(v.match(/[xX]/)) p.hex = 1;
		p.val = Number(v);
		return objNew(def.Num, p);
		
	case "str":
		return objNew(def.Str, {val: v});
	
	case "call":
		
		var func = await ast2obj(scope, v);
	//TODO classSub		
		var args = await ast2obj(scope, ['arr', v2]);
		if(v[0] == "get")
			args.val.unshift(func.args[0]);
		return callNew(func, args.val);
		
	case "assign":
		var args = [];
		var getv = await ast2obj(scope, v[0]);
		var vv = await ast2obj(scope, v[1]);
		if(vv.___.type == "Func" && v[0][0] == "id"){
			route(scope, v[0][1], vv);
			return vv;
		}
		args[2] = vv;
		if(getv.___.type == "Call"){
			args[0] = getv.args[0];
			args[1] = getv.args[1];
		}else{
			args[0] = getv.__.parent;
			args[1] = raw2obj(getv.__.name);
		}
		if(!v[2]){
			return callNew(def.set, args);
		}
		if(v[2] == "plus"){
			return callNew(def.concat, args);
		}
		args[2] = callNew(def[v[2]], [getv, args[2]]);
		return callNew(def.set, args);
		
	case "idf":
		return await scopeGet(scope, v);
		
	case "id":
		var a0;
		if(haskey(scope, v)){
			a0 = callNew(def.state);
		}else{
			var r = await scopeGet(scope, v);
			if(r)
				return r;
			a0 = callNew(def.global);
		}
		a1 = raw2obj(v);
		return callNew(def.get, [a0, a1]);
		
	case "local":
		var t;
		if(v2)
			t = await ast2obj(scope, v2);
		else
			t = def.Class;
		varNew(scope, v, t);
		var a0 = callNew(def.state);
		var a1 = raw2obj(v);
		return callNew(def.get, [a0, a1]);		
		
	case "get":
		var a0 = await ast2obj(scope, v[0]);
		var a1 = await ast2obj(scope, v[0]);
		return callNew(def.get, [a0, a1]);
		
	case "arr":
		var arrx = [];
		for(var i in v){
			arrx[i] = await ast2obj(scope, v[i]);
		}
		var c = classSub(def.Arr, {element: def.Callable});
		return objNew(c, {
			val: arrx
		})
	case "func":
		var block = v[0];
		var argdef = v[1];
		var a = [[]];
		var a0 = argdef[0];
		for(var i in a0){
			var d = a0[i];
			a[0][i] = [d[0]];
			if(d[1])
				a[0][i][1] = await ast2obj(scope, d[1])
		}
		if(argdef[1])
			a[1] = await ast2obj(scope, argdef[1]);
		block[2] = "Block";
		var nscope = scopeNew(scope);
		for(var i in a0){
			var d = a0[i];
			nscope[i] = nscope[d[0]] = {type: d[1]};
		}
		var b = await ast2obj(nscope, block);
		return fbNew(b, a)
	case "tpl":		
		return ftNew(v);	
	case "dic":
		if(!v2){
			var kall = 1;
			for(var i in v){
				if(!haskey(v[i], 1)){
					kall = 0;
					break;
				}
			}
			if(kall) v2 = "Dic";
			else v2 = "Block";
		}
		if(v2 == "Block"){
			var arr = [];
			var labels = {};
			for(var i in v){
				var x = v[i];
				var y = await ast2obj(scope, x[0]);
				arr.push(y);
				labels[x[1]] = i;
			}
			return objNew(def.Block, {arr:arr, labels: {}});
		}
		if(v2 == "Dic"){
			var dicx = {};
			var iscallable = 0;
			for(var i in v){
				var x = v[i];
				var y = await ast2obj(scope, x[0]);
				dicx[x[1]] = y;
				if(!iscallable && istype(y, "Callable")){
					iscallable = 1;
				}
			}
			var c;
			if(iscallable)
				c = classSub(def.Dic, {element: def.Callable});
			else
				c = def.Dic;
			return objNew(c, {val: dicx});			
		}
	case "ctrl":
		var args = [];
		for(var i in v2){
			args[i] = await ast2obj(scope, v2[i]);
		}
		var r = objNew(def.Ctrl, {
			ctrl: v,
			args: args,
		});
		return r;
	default:
		console.log(ast);
		die("type error");
	}
}


process.argv.shift();
var _argv = process.argv;
async function main(){
  var _file;
  var _idGlobal;
  var _def;
  var _scopeNew;
  var _lexsp;
  var _sp;
  var _execr;
  var _execsp;
  var _progl2obj;
  var _readFile;
  var _elem;
  var _exec;
  var _asmain;
  _file = _argv[1];
  _def = await scopeGetOrNew(root, "def");
  _lexsp = scopeNew(_def, undefined);
  _sp = scopeNew(_def, undefined);
  _execr = await scopeGetOrNew(root, "exec");
  _execsp = scopeNew(_execr, undefined);
  _elem = await progl2obj(_lexsp, (("{" + fs.readFileSync(_file).toString()) + "}"), def.Main);
  exec(objNew(def.Main, {content: _elem}), {s:_sp, e:_execsp, x:{}});
  
}
main();
