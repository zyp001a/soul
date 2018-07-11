$cmd = argv[1]
$file = argv[2]
$elem = progl2elem(readFile(file), subScope(idGlobal(cmd)));
print($elem)
