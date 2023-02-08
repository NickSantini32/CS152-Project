%{
#include <stdio.h>
extern FILE* yyin;
%}

%start prog_start
//etc... LIST ALL TOKEN NEMAES HERE (in print statements)
%token STATE_END PLUS MINUS MULT DIV L_ARRAY R_ARRAY L_PAREN R_PAREN L_BRACE R_BRACE EQUAL GREATER LESSER LEQ GEQ NEQ ASSIGN AND OR COMMA INT IF ELIF ELSE WHILE FOR DO READ WRITE FUNC RETURN VOID TRUE FALSE COMMENT NUM IDENT

%%
prog_start: /* epsilon */ {printf("prog_start -> epsilon\n");}
          | components {printf("prog_start -> components\n");}

components: /* epsilon */ {printf("components -> epsilon\n");}
          | function components {printf("components -> functions components\n");}
          | loop components {printf("components -> loop components\n");}
          | statement components {printf("components -> statement components\n");}

statement: int_declaration {printf("statement -> int_declaration\n");}
          | assignment {printf("statement -> int_assignment\n");}
          | int_dec_assignment {printf("statement -> int_dec_assignment\n");}
          | int_arr_declaration {printf("statement -> int_arr_declaration\n");}
          | if_exp {printf("statement -> if_exp\n");}
          | COMMENT {printf("statement -> COMMENT\n");}
          | return_statement {printf("statement -> return_statement\n");}
          | IO {printf("statement -> IO\n");}

int_declaration: INT identifier STATE_END {printf("int_declaration -> INT identifier STATE_END)\n");}
int_dec_assignment: INT identifier ASSIGN num_exp STATE_END {printf("int_dec_assignment -> INT identifier ASSIGN num_exp STATE_END)\n");}
int_arr_declaration: INT identifier L_ARRAY num_exp R_ARRAY STATE_END {printf("int_arr_declaration -> INT identifier L_ARRAY NUM R_ARRAY STATE_END)\n");}
int_arr_access: identifier L_ARRAY NUM R_ARRAY {printf("int_arr_access -> identifier L_ARRAY NUM R_ARRAY)\n");}

assignment: identifier ASSIGN num_exp STATE_END {printf("assignment -> identifier ASSIGN num_exp STATE_END)\n");}

return_statement: RETURN num_exp STATE_END {printf("return_statement -> RETURN num_exp STATE_END\n");}
        | RETURN STATE_END {printf("return_statement -> RETURN STATE_END\n");}

if_exp : IF L_PAREN bool_exp R_PAREN L_BRACE if_loop_body R_BRACE if_else_exp {printf("if_exp -> IF L_PAREN bool_exp R_PAREN L_BRACE if_loop_body R_BRACE if_else_exp\n");}
if_else_exp : /* epsilon */ {printf("if_else_exp -> epsilon\n");}
        | ELIF L_PAREN bool_exp R_PAREN L_BRACE if_loop_body R_BRACE if_else_exp {printf("if_else_exp -> ELIF L_PAREN bool_exp R_PAREN L_BRACE if_loop_body R_BRACE if_else_exp\n");}
        | ELSE L_BRACE if_loop_body R_BRACE {printf("if_else_exp -> ELSE L_BRACE if_loop_body R_BRACE\n");}

loop: WHILE L_PAREN bool_exp R_PAREN L_BRACE if_loop_body {printf("loop -> WHILE L_PAREN bool_exp R_PAREN L_BRACE if_loop_body\n");}
    | DO L_BRACE if_loop_body R_BRACE WHILE L_PAREN bool_exp R_PAREN {printf("loop -> DO L_BRACE if_loop_body R_BRACE WHILE L_PAREN bool_exp R_PAREN\n");}
    | FOR L_PAREN int_dec_assignment STATE_END bool_exp STATE_END statement R_PAREN L_BRACE if_loop_body R_BRACE {printf("loop -> FOR L_PAREN int_assignment STATE_END bool_exp STATE_END statement R_PAREN L_BRACE if_loop_body R_BRACE\n");}

if_loop_body:  /* epsilon */ {printf("if_loop_body -> epsilon\n");}
          | loop if_loop_body {printf("if_loop_body -> loop if_loop_body\n");}
          | statement if_loop_body {printf("if_loop_body -> statement if_loop_body\n");}

num_exp : num_exp num_op num_exp {printf("num_exp -> num_exp num_op num_exp\n");}
          | NUM {printf("num_exp -> NUM\n");}
          | identifier {printf("num_exp -> identifier\n");}
          | int_arr_access {printf("num_exp -> int_arr_access\n");}
          | func_call {printf("num_exp -> func_call\n");}
          | L_PAREN num_exp R_PAREN {printf("num_exp -> L_PAREN num_exp R_PAREN\n");}

bool_exp : num_exp comparator num_exp {printf("bool_exp -> num_exp comparator num_exp\n");}
         | bool_exp logic_op bool_exp {printf("bool_exp -> bool_exp logic_op bool_exp\n");}
         | bool {printf("bool_exp -> bool\n");}
         | num_exp {printf("bool_exp -> num_exp\n");}

num_op : PLUS {printf("num_op -> PLUS\n");}
        | MINUS {printf("num_op -> MINUS\n");}
        | MULT {printf("num_op -> MULT\n");}
        | DIV  {printf("num_op -> DIV\n");}
    
comparator : GREATER {printf("comparator -> GREATER\n");}
       | LESSER {printf("comparator -> LESSER\n");}
       | GEQ {printf("comparator -> GEQ\n");}
       | LEQ {printf("comparator -> LEQ\n");}
       | EQUAL {printf("comparator -> EQUAL\n");}
       | NEQ {printf("comparator -> NEQ\n");}

bool : TRUE {printf("bool -> TRUE\n");} 
    | FALSE {printf("bool -> FALSE\n");}

logic_op : AND {printf("logic_op -> AND\n");}
        | OR {printf("logic_op -> OR\n");}

IO : readWrite identifier STATE_END {printf("IO -> readWrite identifier STATE_END\n");}
    | readWrite identifier L_ARRAY num_exp R_ARRAY STATE_END {printf("IO -> readWrite identifier L_ARRAY num_exp R_ARRAY STATE_END\n");}

readWrite: READ
        | WRITE

return_type : INT {printf("return_type -> INT\n");}
            | VOID {printf("return_type -> VOID\n");}

function: FUNC return_type identifier L_PAREN arguments R_PAREN L_BRACE if_loop_body R_BRACE {printf("function -> FUNC INT identifier L_PAREN arguments R_PAREN L_BRACE if_loop_body R_BRACE\n");}

func_call: identifier L_PAREN literal_args R_PAREN {printf("func_call -> identifier L_PAREN arguments R_PAREN\n");}

arguments: argument {printf("arguments -> argument\n");}
          | argument COMMA arguments {printf("arguments -> COMMA arguments\n");}

literal_args: num_exp {printf("literal_args -> num_exp\n");}
            | num_exp COMMA literal_args {printf("literal_args -> num_exp COMMA literal_args\n");}

argument: /*epsilon*/ {printf("argument -> epsilon\n");}
          | INT identifier {printf("argument -> INT identifier\n");}

identifier: IDENT {printf("identifier -> IDENT %s\n", $$);}

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
