%{
#include <stdio.h>
extern FILE* yyin;
%}

%start prog_start
%token INT STATE_END IDENT COMMA L_PAREN R_PAREN L_BRACE R_BRACE//etc... LIST ALL TOKEN NEMAES HERE (in print statements)

%%
prog_start: /* epsilon */ {printf("prog_start->epsilon\n");}
          | functions {printf("prog_start->functions\n");}

functions: function {printf("functions -> function\n");}
          | function functions {printf("function -> functions\n");}

function: INT IDENT L_PAREN arguments R_PAREN L_BRACE statements R_BRACE

arguments: argument {printf("arguments -> argument\n");}
          | argument COMMA arguments {printf("arguments -> COMMA arguments\n");}

argument: /*epsilon*/ {printf("argument -> epsilon\n");}
          | INT IDENT {printf("argument -> INT IDENT\n");}

statements: /*epsilon*/ {printf("statements -> epsilon\n");}
          | statement STATE_END statements {printf("statement -> STATE_END statements\n");}

statement: /*epsilon*/ {printf("statement -> epsilon\n");}

%%

void main(int argc, char** argv){
  if(argc >=2){
    yyin = fopen(argv[1], "r");
    if (yyin == NULL){
      yyin = stdin;
    }
  } else {
    yyin = stdin;
  }
  yyparse();
}
int yyerror(){}
