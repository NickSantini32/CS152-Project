%{
#include<stdio.h>
#include<vector>
#include<string>
#include "y.tab.h"
extern FILE* yyin;


extern int yylex(void);
void yyerror(const char *msg);
extern int currLine;

char *identToken;
int numberToken;
int  count_names = 0;


enum Type { Integer, Array };
struct Symbol {
  std::string name;
  Type type;
};
struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

std::vector <Function> symbol_table;


Function *get_function() {
  int last = symbol_table.size()-1;
  return &symbol_table[last];
}

bool find(std::string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

%}

%start prog_start
//etc... LIST ALL TOKEN NAMES HERE (in print statements)
%token STATE_END PLUS MINUS MULT DIV L_ARRAY R_ARRAY L_PAREN R_PAREN L_BRACE R_BRACE EQUAL GREATER LESSER LEQ GEQ NEQ ASSIGN AND OR COMMA INT IF ELIF ELSE WHILE FOR DO READ WRITE FUNC RETURN VOID TRUE FALSE COMMENT
//DONT FORGET TO ADD FUNCTION INSTEAD OF COMPONENT
%union {
  char *op_val;
}
%token <op_val> NUM
%token <op_val> IDENT
%type <op_val> identifier


%%
prog_start: function 

function: FUNC return_type
{printf("func ");} 
        identifier 
{printf("\n");} 
        L_PAREN arguments R_PAREN L_BRACE components R_BRACE 



func_call: identifier L_PAREN literal_args R_PAREN 

components: /* epsilon */
        | loop components
        | statement components

statement: int_declaration
        | assignment
        | int_dec_assignment
        | int_arr_declaration
        | if_exp
        | COMMENT
        | return_statement
        | IO

int_declaration: INT 
        identifier 
{printf("\n");} 
        STATE_END

int_dec_assignment: INT identifier ASSIGN num_exp STATE_END
int_arr_declaration: INT identifier L_ARRAY num_exp R_ARRAY STATE_END
int_arr_access: identifier L_ARRAY NUM R_ARRAY

assignment: identifier ASSIGN num_exp STATE_END

return_statement: RETURN num_exp STATE_END
        | RETURN STATE_END

if_exp : IF L_PAREN bool_exp R_PAREN L_BRACE if_loop_body R_BRACE if_else_exp
if_else_exp : /* epsilon */
        | ELIF L_PAREN bool_exp R_PAREN L_BRACE if_loop_body R_BRACE if_else_exp
        | ELSE L_BRACE if_loop_body R_BRACE

loop: WHILE L_PAREN bool_exp R_PAREN L_BRACE if_loop_body R_BRACE
        | DO L_BRACE if_loop_body R_BRACE WHILE L_PAREN bool_exp R_PAREN
        | FOR L_PAREN int_dec_assignment STATE_END bool_exp STATE_END statement R_PAREN L_BRACE if_loop_body R_BRACE

if_loop_body: /* epsilon */
        | loop if_loop_body
        | statement if_loop_body

num_exp : num_exp num_op num_exp
        | NUM
        | identifier
        | int_arr_access
        | func_call
        | L_PAREN num_exp R_PAREN

bool_exp : num_exp comparator num_exp
        | bool_exp logic_op bool_exp
        | bool
        | num_exp

num_op : PLUS
        | MINUS
        | MULT
        | DIV

comparator : GREATER
        | LESSER
        | GEQ
        | LEQ
        | EQUAL
        | NEQ

bool : TRUE
        | FALSE

logic_op : AND
        | OR

IO : readWrite identifier STATE_END
        | readWrite identifier L_ARRAY num_exp R_ARRAY STATE_END

readWrite: READ
        | WRITE

return_type : INT
        | VOID

arguments: argument 
          | argument COMMA arguments 

literal_args: num_exp 
            | num_exp COMMA literal_args 

argument: /*epsilon*/ 
          | INT identifier

identifier: IDENT 
{ 
  printf("%s", $1); 
  $$ = $1; 
}

%%

int main(int argc, char **argv)
{
   yyparse();
   print_symbol_table();
   return 0;
}


/* void yyerror(const char *msg)
{
   printf("** Line %d: %s\n", currLine, msg);
   exit(1);
} */

/* void main(int argc, char** argv){
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
} */

