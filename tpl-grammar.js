var jison = require("jison");
var fs = require("fs");
var grammar = {
  "lex": {
		"macros":{},
    "rules": [
			["~=(\\\\.|[^\\\\\~])*~",	"yytext = yytext.substr(2,yyleng-3).replace(/\\\\~/g, '~'); return 'GET';"],
			//			["[\\t ]*~[^=](\\\\.|[^\\\\\~])*~[\\n\\r]*",	"yytext = yytext.replace(/^[\\t ]*~/, '').replace(/~[\\n\\r]*$/, '').replace(/\\\\~/g, '~'); return 'INS';"],
			["~[^=](\\\\.|[^\\\\\~])*~",	"yytext = yytext.replace(/^[\\t ]*~/, '').replace(/~[\\n\\r]*$/, '').replace(/\\\\~/g, '~'); return 'INS';"],			
			//			["~(\\\\.|[^\\\\\~])*~",	"yytext = yytext.substr(1,yyleng-2).replace(/\\\\~/g, '~'); return 'INS';"],
			["\\&[0-9]+", "yytext=yytext.substr(1);return 'EXEC'"],
//			["\\&[A-Z]+", "yytext=yytext.substr(1);return 'MACRO'"],			
			["(\\\\.|[^\\\\\~])", "return 'RAW';"]
		]
	},
  "start": "Start",
//	"parseParams": [""],
  "bnf": {
		"Start": [
			["ES", "return $$ = '{#$arr = [];push(#$arr, `' + $1 + '`);@return join(#$arr, ``);}'"]
		],
		"ES": [
			["E", "$$ = $1"],
			["ES E", "$$ = $1 + $2"],			
		],
		"E": [
			["GET", "$$ = '`);push(#$arr, ' + $1 + ');push(#$arr, `'"],
			["INS", "$$ = '`);' + $1 + ';push(#$arr, `'"],
			["EXEC", "$$ = '`);push(#$arr, exec(#' + $1 + ', #$conf));push(#$arr, `'"],
//			["MACRO", "$$ = '`);' + $1 + ';push(#$arr, `'"],
			["RAW", "$$ = $1"],
		],
  }
};
var options = {};
var code = new jison.Generator(grammar, options).generate();
var filename = "tpl-parser.js";
fs.writeFileSync(filename, code);


