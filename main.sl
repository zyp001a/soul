$cmd = argv[1]
$file = argv[2]
$currsp = idGlobal(cmd)
$lexsp = scopeNew(currsp)
$execsp = scopeNew(currsp)
$elem = progl2obj(readFile(file), lexsp);
exec($elem, execsp)
