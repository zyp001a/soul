
process.argv.shift();
process.argv.shift();
global._$argv = process.argv;
global._$sysenv = process.env;
function ucfirst(str){
  str += '';
  var f = str.charAt(0).toUpperCase();
  return f + str.substr(1);
}
function haskey(x, k){
  return Object.getOwnPropertyDescriptor(x, k);
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
function log(str){
  console.log(__line+":"+__file+":"+__function+":"+__line2);
  console.log(str);
}
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
function initp(p, o){
  if(!p) p = {};
  if(p.__){
   for(var k in o){
    p.__[k] = o[k]
   }
  }else{
   p.__ = o || {}
  }
  Object.defineProperty(p, '__', {
    enumerable: false,
    configurable: false
  });
  return p;
}
function reprp(p, o){
  var x = initp(p, o)
  x.__.obj = global._funcnativec
  return x
}
function objNewp(c, d){
  var o
  if(isclassx(c, "Items")){
    o = initp(d, {obj: c, prop: {}})
  }else{
    o = initp(d, {obj: c})
    delete o.__.prop
  }
  var x = curryListx(c, {})
  for(var k in x){
    if(objGetp(o, k) == undefined){
      objSetp(o, k, x[k])
    }
  }
  return o;
}
function asvalp(o){
  var t = typeof o;
  if(t != "object"){
    return o;
  }
  if(!o.__){
    return o;
  }
  if(o.__.isval)
    return o.val

  var tid = o.__.obj.__.id;
  if(tid == "SidDic"){
   return asvalp(o.sidDic[o.sid])
  }
  if(tid == "SidObj"){
   return asvalp(o.sidObj[o.sid])
  }
  if(tid == "SidInnate"){
   return asvalp(o.sidInnate.__[o.sid])
  }
  if(tid == "Aid"){
   return asvalp(o.aidArr[o.aid])
  }
  return o;
}
function asobjp(o){
  var t = typeof o;
  if(t == "undefined"){
    return initp({val: undefined}, {obj: global._undfc, isval:1});
  }
  if(t == "object"){
    if(!t) return initp({val: null}, {obj: global._nullc, isval:1});
    if(!o.__){
      if(Array.isArray(o)){
        return initp(o, {obj: global._arrc, prop:{}});
      }else{
        return initp(o, {obj: global._dicc, prop:{}});
      }
    }
    return o;
  }
  if(t == "string"){
    return initp({val: o}, {obj: global._strc, isval:1});
  }
  if(t == "number"){
    return initp({val: o}, {obj: global._numc, isval:1});
  }
  die(t + " not defined, asobj")
}
function objGetp(o, k){
  if(k == "scopeParents"){
    return o.__.parents
  }
  if(k == "scope"){
    return o[k]
  }
  if(o.__ && o.__.prop){
    return o.__.prop[k]
  }
  return o[k]
}
function objSetp(o, k, v){
  if(k == "scopeParents"){
    return o.__.parents = v
  }
  if(k == "scope"){
    return o[k] = v
  }
  if(o.__ && o.__.prop){
    return o.__.prop[k] = v
  }
  return o[k] = v
}

/*ReprScopex*/
/*ReprCurryx*/
/*ReprClassx*/
function routex(_oo, _scope, _name){
  let _o
  let _id
  _o = asobjp(_oo)
  if(!_o.__.index){
    _o.__.index = 0
  }
  if(!_scope){
    return _o
  }
  if(!(_name !== undefined)){
    _name = _o.__.index.toString()
    _o.__.index = _o.__.index + 1
    _o.__.noname = 1
  }
  _scope[_name] = _o
  _o.__.name = _name
  _id = _scope.__.id
  if(!(_id !== undefined)){
    _o.__.id = "."
    _o.__.ns = _name
  }else if(_id == "."){
    _o.__.id = _name
    _o.__.ns = _scope.__.ns
  }else if(_scope.__.noname){
    _o.__.id = _name
    _o.__.ns = _scope.__.ns + "/" + _id
  }else{
    _o.__.id = _id + "_" + _name
    _o.__.ns = _scope.__.ns
  }
  _o.__.scope = _scope
  return _o
}
function parentSetx(_p, _k, _parents){
  let _e

  for(let _e of _parents){
    objGetp(_p, _k)
    [_e.__.id] = _e
  }

}
function scopePresetx(_scope, _name, _parents){
  let _x
  _x = initp({
    scope:   {
    },
    scopeParents:   {
    },
  })
  if(_parents){
    parentSetx(_x, "scopeParents", _parents)
  }
  routex(_x, _scope, _name)
  return _x
}
function classPresetx(_scope, _name, _parents, _schema){
  let _x
  _x = initp({
    classCurry:   {
    },
    classSchema:   _schema || {
    },
    classParents:   {
    },
  })
  if(_parents){
    parentSetx(_x, "classParents", _parents)
  }
  routex(_x, _scope, _name)
  return _x
}
global._root = scopePresetx()
global._def = scopePresetx(global._root, "def")
global._objc = classPresetx(global._def, "Obj")
global._classc = classPresetx(global._def, "Class", [global._objc])
global._scopec = classPresetx(global._def, "Scope", [global._objc])
global._root.__.obj = global._scopec
global._def.__.obj = global._scopec
global._objc.__.obj = global._classc
global._classc.__.obj = global._classc
global._scopec.__.obj = global._classc
function scopeNewx(_scope, _name, _parents){
  let _x
  _x = scopePresetx(_scope, _name, _parents)
  _x.__.obj = global._scopec
  return _x
}
function scopeIntox(_scope, _key){
  let _nscope
  let _arr
  let _i
  let _e
  let _xr
  _nscope = _scope
  _arr = _key.split("_")
  let _tmp1 = _arr;
  for(let _i in _tmp1){
    let _e = _tmp1[_i];
    _xr = _scope[_e]
    if(!(_xr !== undefined)){
      _nscope = scopeNewx(_nscope, _e)
    }else{
      _nscope = _xr
    }
  }
  return _nscope
}
function classNewx(_scope, _name, _parents, _schema){
  let _x
  _x = classPresetx(_scope, _name, _parents, _schema)
  _x.__.obj = global._classc
  return _x
}
global._curryc = classNewx(global._def, "Curry", [global._objc])
global._valc = classNewx(global._def, "Val", [global._objc])
function curryInitx(_class, _curry){
  let _x
  _x = initp({
    curry:   _curry || {
    },
    curryClass:   _class,
  })
  _x.__.obj = global._curryc
  return _x
}
function curryNewx(_scope, _name, _class, _curry){
  let _x
  _x = curryInitx(_class, _curry)
  routex(_x, _scope, _name)
  return _x
}
global._nullc = curryNewx(global._def, "Null", global._valc)
global._undfc = curryNewx(global._def, "Undf", global._valc)
global._numc = curryNewx(global._def, "Num", global._valc)
global._sizetc = curryNewx(global._def, "Sizet", global._numc)
global._strc = curryNewx(global._def, "Str", global._valc)
global._charc = curryNewx(global._def, "Char", global._strc)
global._funcvc = curryNewx(global._def, "Funcv", global._valc)
1







