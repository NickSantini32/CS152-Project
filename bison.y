%{
// #include "defs.h"
#include<stdio.h>
#include<sstream>
#include<vector>
#include<string>
#include<cstdlib>
#include<iostream>

#include "y.tab.h"
extern FILE* yyin;

//cat math.min | compiler > fdsf.mil

extern int yylex(void);
void yyerror(const char *msg);
extern int currLine;

std::vector<std::string> args;
bool inLoop = false;

char *identToken;
int numberToken;
int count_names = 0;
int tempCount = 0;
int loopCount = 0;

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

bool find(const std::string &value) {
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

std::string createTempVarNOPRINT(){ 
  std::stringstream ss;
  ss << "_temp" << tempCount;    
  tempCount++;
  return ss.str(); 
}

std::string createTempVar(){ 
  std::string s = createTempVarNOPRINT();
  printf(". %s\n", s.c_str());
  return s; 
}

// std::string new_label(){
//   std::stringstream ss;
//   ss << "_label" << loopCount;
//   loopCount++;
//   return ss.str();
// }
// std::string new_label(std::string s){
//   std::stringstream ss;
//   ss << s << loopCount;
//   loopCount++;
//   return ss.str();
// }

void checkIfVarIsDuplicate(const std::string value){
  if (find(value)){
    std::stringstream ss;
    ss << "ERROR: Duplicate variable declaration '" << value << "'";
    yyerror(ss.str().c_str());
  }
}

void checkIfVarIsKeyword(const std::string value){
  if (value == "int" || value == "if" || value == "elif" || value == "else" || 
  value == "while" || value == "for" || value == "do" || value == "read" || 
  value == "write" || value == "function" || value == "return" || value == "void" || 
   value == "true" || value == "false" || value == "continue"){
    std::stringstream ss;
    ss << "ERROR: Variable '" << value << "' is a keyword";
    yyerror(ss.str().c_str());
  }
}

void checkIfVarDeclared(const std::string value){
  if (!find(value)){
    std::stringstream ss;
    ss << "ERROR: Variable '" << value << "' not declared";
    yyerror(ss.str().c_str());
  }
  checkIfVarIsKeyword(value);
}

void checkIfVarIsArray(const std::string value){
  Function *f = get_function();
  for (int i = 0; i < f->declarations.size(); i++){
    if (f->declarations.at(i).name == value){
      if (f->declarations.at(i).type == Array){
        return;
      }
    }
  }

  std::stringstream ss;
  ss << "ERROR: Variable '" << value << "' is not an array";
  yyerror(ss.str().c_str());
}

void checkArrayIndex(const std::string value){
  int i = std::atoi(value.c_str());
  if (i < 0){
    std::stringstream ss;
    ss << "ERROR: Array index '" << value << "' is negative";
    yyerror(ss.str().c_str());
  }
}

void runArrayChecks(const std::string value){
  checkIfVarDeclared(value);
  checkIfVarIsArray(value);
}

void checkIfFuncDefined(const std::string value){
  for (int i = 0; i < symbol_table.size(); i++){
    if (symbol_table.at(i).name == value){
      return;
    }
  }

  std::stringstream ss;
  ss << "ERROR: Function '" << value << "' not defined";
  yyerror(ss.str().c_str()); 
}

void checkIfMainDefined(){
  for (int i = 0; i < symbol_table.size(); i++){
    if (symbol_table.at(i).name == "main"){
      return;
    }
  }

  yyerror("ERROR: Main function not defined");
}

%}

%start prog_start
//etc... LIST ALL TOKEN NAMES HERE (in print statements)
%token STATE_END PLUS MINUS MULT DIV MOD L_ARRAY R_ARRAY L_PAREN R_PAREN L_BRACE R_BRACE EQUAL GREATER LESSER LEQ GEQ NEQ ASSIGN AND OR COMMA INT IF ELIF ELSE WHILE FOR DO READ WRITE FUNC RETURN VOID TRUE FALSE COMMENT CONTINUE

%left PLUS MINUS
%left MULT DIV MOD
%left R_PAREN L_PAREN

%code requires {
  struct Node {
    std::string code;
    std::string name;
  };
}
%union {
  const char *op_val;
  struct Node *node;
}
%token <op_val> NUM IDENT 
%type <op_val> addop num_op readWrite
%type <node> identifier 
%type <node> int_arr_access num_exp num_exp_terminal paren_exp num_or_ident func_call//dynamic allocation cleaned up in num_exp
%type <node> comparator logic_op bool_exp loop components statement
%type <node> int_declaration int_arr_declaration int_arr_assignment assignment IO //statements

%%
prog_start: functions { checkIfMainDefined(); }

functions: /* epsilon */
        | function functions

function: FUNC return_type identifier L_PAREN args R_PAREN L_BRACE components R_BRACE {
          std::string func_name = $3->name;
          add_function_to_symbol_table(func_name);
          printf("func %s\n", func_name.c_str());
          printf($8->code.c_str()); 
          delete $8; 
          printf("endfunc\n\n");
        }
        | COMMENT

components: /* epsilon */ { Node* n = new Node(); n->code = ""; $$ = n;}
        | loop components { Node* n = new Node(); n->code = $1->code + $2->code; delete $1; delete $2; $$ = n;}
        | statement components { printf("e-2"); Node* n = new Node(); n->code = $1->code + $2->code; delete $1; delete $2; $$ = n;}

statement: int_declaration { printf("e-1"); $$ = $1; }
        | assignment
        | int_arr_assignment
        /* | int_dec_assignment */
        | int_arr_declaration
        | if_exp
        | COMMENT { Node* n = new Node(); n->code = ""; $$ = n;}
        | return_statement { Node* n = new Node(); n->code = ""; $$ = n;}
        | CONTINUE { if (!inLoop) yyerror("ERROR: Continue statement not in loop"); }
        | IO

int_declaration: INT identifier STATE_END 
{  
  // add the variable to the symbol table.
  std::string ident = $2->name;
  checkIfVarIsDuplicate(ident);
  Type t = Integer;
  add_variable_to_symbol_table(ident, t);
  printf("e0");
  $$ = new Node();
  $$->code = ". " + ident;
  // printf(". %s\n", ident.c_str()); 
  printf("e1");
} 

int_arr_declaration: INT identifier L_ARRAY num_exp R_ARRAY STATE_END
{ 
  // add the variable to the symbol table.
  std::string ident = $2->name;
  std::string size = $4->name;
  checkIfVarIsDuplicate(ident);
  checkArrayIndex(size);
  Type t = Array;
  add_variable_to_symbol_table(ident, t);
  $$ = new Node();
  $$->code = ".[] " + ident + ", " + size;
  // printf(".[] %s, %s\n", ident.c_str(), size.c_str());
} 

int_arr_access: identifier L_ARRAY num_exp R_ARRAY 
{
  std::string ident = $1->name;
  std::string index = $3->name;
  runArrayChecks(ident);
  checkArrayIndex(index);
  std::string temp = createTempVar();
  printf("=[] %s, %s, %s\n", temp.c_str(), ident.c_str(), index.c_str());
  $$ = new Node();
  $$->name = temp;
  $$->code = "=[] " + temp + ", " + ident + ", " + index;
}

int_arr_assignment: identifier L_ARRAY num_exp R_ARRAY ASSIGN num_exp STATE_END
{
  std::string ident = $1->name;
  std::string index = $3->name;
  std::string value = $6->name;
  runArrayChecks(ident);
  checkArrayIndex(index);
  $$ = new Node();
  $$->code = "[]= " + ident + ", " + index + ", " + value;
  // printf("[]= %s, %s, %s\n", ident.c_str(), index.c_str(), value.c_str());
}

assignment: identifier ASSIGN num_exp STATE_END 
{ 
  std::string ident = $1->name;
  std::string value = $3->name;
  checkIfVarDeclared(ident);
  // printf("= %s, %s\n", ident.c_str(), value.c_str()); 
  $$ = new Node();
  $$->code = "= " + ident + ", " + value;
}

/* identifier ASSIGN NUM STATE_END 
{ printf("= %s, %s\n", $1, $3); } 
        |  */

return_statement: RETURN num_exp STATE_END {printf("ret %s\n", $2->name.c_str());}
        | RETURN STATE_END

if_exp : IF L_PAREN bool_exp R_PAREN L_BRACE components R_BRACE if_else_exp
{
     
}

if_else_exp : /* epsilon */
        | ELIF L_PAREN bool_exp R_PAREN L_BRACE components R_BRACE if_else_exp
        | ELSE L_BRACE components R_BRACE

loop: WHILE L_PAREN bool_exp R_PAREN L_BRACE components R_BRACE {
        std::string name;
        Node * node = new Node();
        printf("e");
        Node * bool_exp_node = $3;    
        Node * components_node = $6;
        std::string start_label= "beginloop" + loopCount;
        std::string body_label = "loopbody" + loopCount;
        std::string end_label= "loopend" + loopCount; 
        loopCount++;
        node->code += ": " + start_label + "\n";
        node->code += ". " + bool_exp_node->name + "\n";      
        node->code += bool_exp_node->code;
        node->code += "?:= "+ body_label + ", " + bool_exp_node->name + "\n";
        //node->code += components_node->code;
        node->code += ":= " + end_label + "\n";
        node->code += ": " + body_label + "\n";
        

        delete bool_exp_node;      
        printf(node->code.c_str());
        delete node;
        $$ = node;
      }
        /* | DO L_BRACE components R_BRACE WHILE L_PAREN bool_exp R_PAREN */
      | FOR L_PAREN int_dec_assignment STATE_END bool_exp STATE_END statement R_PAREN L_BRACE components R_BRACE

int_dec_assignment: INT identifier ASSIGN num_exp STATE_END

num_exp: num_exp_terminal
        | num_exp_terminal num_op num_exp
{
  const std::string right = $1->name;
  const std::string left = $3->name;
  delete $1;
  delete $3;
  std::string t = createTempVar();

  printf("%s %s, %s, %s\n", $2, t.c_str(), right.c_str(), left.c_str());
  $$ = new Node();
  $$->name = t;
}

num_exp_terminal : num_or_ident
        | int_arr_access 
        | paren_exp
        | func_call

paren_exp : L_PAREN num_exp R_PAREN { $$ = $2; }

num_or_ident : NUM { $$ = new Node(); $$->name = $1;}      
        | IDENT { $$ = new Node(); $$->name = $1;}
        | addop NUM { $$ = new Node(); $$->name = std::string($1) + $2;}

func_call: identifier L_PAREN literal_args R_PAREN
{
  std::string func_name = $1->name;
  checkIfFuncDefined(func_name);
  $$ = new Node();
  $$->name = createTempVar();
  printf("call %s, %s\n", func_name.c_str(), $$->name.c_str());
}       

bool_exp : num_exp comparator num_exp {
	   std::string exp1 = $1->name;
	   std::string exp2 = $3->name;
     $$ = $2;
     $$->code = $$->code + " " + $$->name + ", " + exp1 + ", " + exp2 +"\n";
	   //printf("%s, %s\n", exp1.c_str(), exp2.c_str());	   
	}
        | bool
        //| bool_exp logic_op bool_exp {
	   /*
	   std::string exp1 = $1->name;
	   std::string exp2 = $3->name;
	   printf("%s, %s\n", exp1.c_str(), exp2.c_str());
	   */
	//}
        

num_op : PLUS { char e[] = "+"; $$ = e;}
        | MINUS { char e[] = "-"; $$ = e;}
        | MULT { char e[] = "*"; $$ = e;}
        | DIV { char e[] = "/"; $$ = e;}
        | MOD { char e[] = "%"; $$ = e;}
        

addop : PLUS { char e[] = "+"; $$ = e;}
        | MINUS { char e[] = "-"; $$ = e;}

comparator : GREATER {
	   std::string x = createTempVarNOPRINT();
     $$ = new Node();
     $$->name = x;
     $$->code = ">";
	}
        | LESSER {
	   std::string x = createTempVarNOPRINT();
     $$ = new Node();
     $$->name = x;
     $$->code = "<";
	}
        | GEQ {
	   std::string x = createTempVarNOPRINT();
     $$ = new Node();
     $$->name = x;
     $$->code = ">=";
	}
        | LEQ {
	   std::string x = createTempVarNOPRINT();
     $$ = new Node();
     $$->name = x;
     $$->code = "<=";
        }
        | EQUAL {
	   std::string x = createTempVarNOPRINT();
     $$ = new Node();
     $$->name = x;
     $$->code = "==";
	}          
        | NEQ {
	   std::string x = createTempVarNOPRINT();
     $$ = new Node();
     $$->name = x;
     $$->code = "!=";
	}

bool : TRUE
        | FALSE

logic_op : AND {
	   std::string x = createTempVar();
     $$ = new Node();
     $$->name = x;
     $$->code = "&&";
	}
        | OR {
	   std::string x = createTempVar();
     $$ = new Node();
     $$->name = x;
	   $$->code = "||";
	}

IO : readWrite identifier STATE_END {
  // printf("%s %s\n", $1, $2->name.c_str());
  $$ = new Node();
  std::string t = $1;
  $$->code = t + " " + $2->name + "\n";
  }
        | readWrite identifier L_ARRAY num_exp R_ARRAY STATE_END
{
  std::string t = createTempVarNOPRINT();
  // printf("=[] %s, %s, %s\n", t.c_str(), $2->name.c_str(), $4->name.c_str());
  // printf("%s %s\n", $1, t.c_str());
  $$ = new Node();
  $$->code = "=[] " + t + ", " + $2->name + ", " + $4->name + "\n";
  std::string s = $1;
  $$->code += s + " " + t + "\n";
}

readWrite: READ  { char e[] = ".<"; $$ = e;}
        | WRITE { char e[] = ".>"; $$ = e;}

return_type : INT
        | VOID

args: /* epsilon */
        | arguments
{
  for (int i = 0; i < args.size(); i++)
  {
    printf("= %s, $%i\n", args.at(i).c_str(), i);
  }
  args.clear();
}

arguments: argument
          | argument COMMA arguments 

argument: INT identifier 
{ 
  // add the variable to the symbol table.
  std::string name = $2->name;
  Type t = Integer;
  add_variable_to_symbol_table(name, t);
  args.push_back(name);
  printf(". %s\n", name.c_str());
}

literal_args: /* epsilon */
            | literal_arguments

literal_arguments: literal_argument
            | literal_argument COMMA literal_arguments

literal_argument: num_exp
{ 
  // add the variable to the symbol table.
  std::string name = $1->name;
  printf("param %s\n", name.c_str());
}

identifier: IDENT 
{ 
  printf("%s", $1); 
  $$ = new Node();
  $$->name = $1; 
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

