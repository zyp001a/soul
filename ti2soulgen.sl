$file = argv[1]
$def = idGlobal("def")
$lexsp = scopeNew(def)
$sp = scopeNew(def)
$execr = idGlobal("gen_js_nodejs")
$execxsp = scopeNew(execr);
$elem = progl2obj("{"+readFile(file)+"}", lexsp);
exec(asmain($elem), sp, execxsp)