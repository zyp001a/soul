$cmd = argv[1]
$file = argv[2]
$currsp = idGlobal(cmd)
$lexsp = scopeNew(currsp)
$sp = scopeNew(currsp)
$elem = progl2obj(readFile(file), lexsp);
exec($elem, sp)