$cmd = argv[1]
$file = argv[2]
$currsp = idGlobal(cmd)
$lexsp = subScope(currsp)
$execsp = subScope(currsp)
$elem = progl2elem(readFile(file), lexsp);
exec($elem, execsp)
