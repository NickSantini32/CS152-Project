%{
#include<stdio.h>
#include<sstream>
#include<vector>
#include<string>
#include "y.tab.h"
extern FILE* yyin;

//cat math.min | compiler > fdsf.mil

extern int yylex(void);
void yyerror(const char *msg);
extern int currLine;

char *identToken;
int numberToken;
int count_names = 0;
int tempCount = 0;

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

bool existsInVec(std::vector<Symbol> v, std::string& val){
  for (int i = 0; i < v.size(); i++){
    if (v.at(i).name == val){
      return true;
    }
  }
  return false;
}

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

  if (existsInVec(f->declarations, value)){
    yyerror("ERROR: Duplicate variable declaration");
  }

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

std::string createTempVar(){ 
  std::stringstream ss;
  ss << "_temp" << tempCount;  
  printf(". %s\n", ss.str().c_str());
  tempCount++;
  return ss.str(); 
 }

%}

%start prog_start
//etc... LIST ALL TOKEN NAMES HERE (in print statements)
%token STATE_END PLUS MINUS MULT DIV MOD L_ARRAY R_ARRAY L_PAREN R_PAREN L_BRACE R_BRACE EQUAL GREATER LESSER LEQ GEQ NEQ ASSIGN AND OR COMMA INT IF ELIF ELSE WHILE FOR DO READ WRITE FUNC RETURN VOID TRUE FALSE COMMENT

%left PLUS MINUS
%left MULT DIV MOD
%left R_PAREN L_PAREN

%union {
  const char *op_val;
}
%token <op_val> NUM IDENT
%type <op_val> identifier num_op num_or_ident num_exp num_exp_2 int_arr_access readWrite


%%
prog_start: functions

functions: /* epsilon */
        | function functions

function: FUNC return_type identifier 
{
        std::string func_name = $3;
        add_function_to_symbol_table(func_name);
        printf("func %s\n", $3);
} 
        L_PAREN arguments R_PAREN L_BRACE components R_BRACE 
{printf("endfunc\n");} 


func_call: identifier L_PAREN literal_args R_PAREN 

components: /* epsilon */
        | loop components
        | statement components

statement: int_declaration
        | assignment
        | int_arr_assignment
        | int_dec_assignment
        | int_arr_declaration
        | if_exp
        | COMMENT
        | return_statement
        | IO

int_declaration: INT identifier STATE_END 
{ 
        // add the variable to the symbol table.
        std::string value = $2;
        Type t = Integer;
        add_variable_to_symbol_table(value, t);
        printf(". %s\n", $2); 
} 
        
int_dec_assignment: INT identifier ASSIGN num_exp STATE_END

int_arr_declaration: INT identifier L_ARRAY num_exp R_ARRAY STATE_END
{ 
        // add the variable to the symbol table.
        std::string value = $2;
        Type t = Integer;
        add_variable_to_symbol_table(value, t);
        printf(".[] %s, %s\n", $2, $4); 
} 

int_arr_access: identifier L_ARRAY num_exp R_ARRAY 
{
  std::string temp = createTempVar();
  printf("=[] %s, %s, %s\n", temp.c_str(), $1, $3);
  // printf("%s\n", (char*)temp.c_str());
  $$ = (char*)temp.c_str();
}

int_arr_assignment: identifier L_ARRAY num_exp R_ARRAY ASSIGN num_exp STATE_END
{
  printf("[]= %s, %s, %s\n", $1, $3, $6);
}

assignment: identifier ASSIGN num_exp STATE_END 
{ printf("= %s, %s\n", $1, $3); }

/* identifier ASSIGN NUM STATE_END 
{ printf("= %s, %s\n", $1, $3); } 
        |  */

return_statement: RETURN num_exp STATE_END
        | RETURN STATE_END

if_exp : IF L_PAREN bool_exp R_PAREN L_BRACE components R_BRACE if_else_exp
if_else_exp : /* epsilon */
        | ELIF L_PAREN bool_exp R_PAREN L_BRACE components R_BRACE if_else_exp
        | ELSE L_BRACE components R_BRACE

loop: WHILE L_PAREN bool_exp R_PAREN L_BRACE components R_BRACE
        | DO L_BRACE components R_BRACE WHILE L_PAREN bool_exp R_PAREN
        | FOR L_PAREN int_dec_assignment STATE_END bool_exp STATE_END statement R_PAREN L_BRACE components R_BRACE


num_exp : num_exp_2 num_op num_exp
{
  const std::string right = $1;
  const std::string left = $3;
  printf("eeeeee %s, %s\n", right.c_str(), left.c_str());
  std::string t = createTempVar();
  printf("%s %s, %s, %s\n", $2, t.c_str(), right.c_str(), left.c_str());
  $$ = (char*)(t.c_str());
}
        | num_exp_2 { $$ = $1; }

num_exp_2 : num_or_ident
        | int_arr_access 
        | L_PAREN num_exp R_PAREN { $$ = $2; }
        /* | func_call */

num_or_ident : NUM 
        | identifier        

bool_exp : num_exp comparator num_exp
        | bool_exp logic_op bool_exp
        | bool
        | num_exp

num_op : PLUS { char e[] = "+"; $$ = e;}
        | MINUS { char e[] = "-"; $$ = e;}
        | MULT { char e[] = "*"; $$ = e;}
        | DIV { char e[] = "/"; $$ = e;}
        | MOD { char e[] = "%"; $$ = e;}

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

IO : readWrite identifier STATE_END {printf("%s %s\n", $1, $2);}
        | readWrite identifier L_ARRAY num_exp R_ARRAY STATE_END
{
  std::string t = createTempVar();
  printf("=[] %s, %s, %s\n", t.c_str(), $2, $4);
  printf("%s %s\n", $1, t.c_str());
}

readWrite: READ  { char e[] = ".<"; $$ = e;}
        | WRITE { char e[] = ".>"; $$ = e;}

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
  //printf("%s", $1); 
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

