%{

%}

%start prog_start
%token INT STATE_END IDENT //etc... LIST ALL TOKEN NEMAES HERE (in print statements)

%%
prog_start: /* epsilon */ {printf("prog_start->epsilon\n");}
          | functions {printf("prog_start->functions\n");}

functions: fun ction {printf("functions -> function\n");}
          | function functions {printf("function -> functions\n");}

//function: INT IDENT LPR arguments RPR LBR statements

arguments: argument {printf("arguments -> argument\n");}
          | COMMA arguments {printf("arguments -> COMMA arguments\n");}

argument: /*epsilon*/ {printf("argument -> epsilon\n");}
          | INT IDENT {printf("argument -> INT IDENT\n");}

statements: /*epsilon*/ {printf("statements -> epsilon\n");}
          | statement STATE_END statements {printf("statement -> STATE_END statements\n");}

statement: /*epsilon*/

%%
