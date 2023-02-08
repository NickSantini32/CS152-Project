%{
#include "y.tab.h"
//Needed to call yyerror, which is the error function for task 1
void yyerror (char const *s) {
   fprintf (stderr, "%s\n", s);
   exit(1);
}
int lc=1;
int pn=0;

// change all the prints to return

%}

/* Rules */
NUM [0-9]+
COMMENT "#".*"\n"
STRING "[a-zA-Z_0-9]*"
IDENT [a-zA-Z_][a-zA-Z0-9_]*
INVIDENT [0-9][a-zA-Z0-9_]*[a-zA-Z_]+[a-zA-Z0-9_]*
STR_QUOTE "\""

%%
" " {pn += yyleng;}
"\n" { pn=0; lc++;}
";" { pn += yyleng; return STATE_END; }
"+" { pn += yyleng; return PLUS; }
"-" { pn += yyleng; return MINUS; }
"*" { pn += yyleng; return MULT; }
"/" { pn += yyleng; return DIV; }
"[" { pn += yyleng; return L_ARRAY; }
"]" { pn += yyleng; return R_ARRAY; }
"(" { pn += yyleng; return L_PAREN; }
")" { pn += yyleng; return R_PAREN; }
"{" { pn += yyleng; return L_BRACE; }
"; }" { pn += yyleng; return R_BRACE; }
"==" { pn += yyleng; return EQUAL; }
">" { pn += yyleng; return GREATER; }
"<" { pn += yyleng; return LESSER; }
"<=" { pn += yyleng; return LEQ; }
">=" { pn += yyleng; return GEQ; }
"!=" { pn += yyleng; return NEQ; }
"=" { pn += yyleng; return ASSIGN; }
"&&" { pn += yyleng; return AND; }
"||" { pn += yyleng; return OR; }

"," {printf("COMMA\n"); pn += yyleng;}
"int" {printf("INT\n"); pn += yyleng;}
"if" {printf("IF\n"); pn += yyleng;}
"elif" {printf("ELSE IF\n"); pn += yyleng;}
"else" {printf("ELSE\n"); pn += yyleng;}
"while" {printf("WHILE\n"); pn += yyleng;}
"for" {printf("FOR\n"); pn += yyleng;}
"do" {printf("DO\n"); pn += yyleng;}
"read" {printf("READ\n"); pn += yyleng;}
"write" {printf("WRITE\n"); pn += yyleng;}
"function" {printf("FUNC\n"); pn += yyleng;}
"return" {printf("RETURN\n"); pn += yyleng;}

{COMMENT} {printf("COMMENT: %s\n", yytext); lc++; pn=0;}
{IDENT} {printf("IDENT: %s\n", yytext); pn += yyleng;}
{INVIDENT} {printf("ERROR in line %d column %d: INVALID IDENTIFIER: %s. Identifiers cannot start with numbers\n", lc, pn, yytext); yyerror(""); pn += yyleng;}
{NUM} {printf("NUMBER: %s\n", yytext); pn += yyleng;}

. {printf("Unrecognized input: %s\n Terminating program.", yytext); yyerror("");}
%%

yywrap() {}

int main() {
     //printf("Enter string: ");
     yylex();
     printf("Number of lines: %d\n", lc);
     return 0;

}
