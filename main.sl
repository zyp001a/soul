$cmd = argv[1]
$file = argv[2]
$ast = progl_parse(readfile(file));
$elem = progl_ast2elem(ast, idg(cmd));
