%{
#include "y.tab.h"
int lc=1;
int pn=0;
//Needed to call yyerror, which is the error function for task 1
void yyerror (char const *s) {
   fprintf (stderr, "%s\n", s);
   printf("lc: %d, pn: %d\n", lc, pn);
   exit(1);
}


// change all the prints to return
// STR_QUOTE "\""
// STRING "[a-zA-Z_0-9]*"


%}

/* Rules */
NUM [0-9]+
COMMENT "#".*"\n"
IDENT [a-zA-Z_][a-zA-Z0-9_]*
INVIDENT [0-9][a-zA-Z0-9_]*[a-zA-Z_]+[a-zA-Z0-9_]*

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
"}" { pn += yyleng; return R_BRACE; }
"==" { pn += yyleng; return EQUAL; }
">" { pn += yyleng; return GREATER; }
"<" { pn += yyleng; return LESSER; }
"<=" { pn += yyleng; return LEQ; }
">=" { pn += yyleng; return GEQ; }
"!=" { pn += yyleng; return NEQ; }
"=" { pn += yyleng; return ASSIGN; }
"&&" { pn += yyleng; return AND; }
"||" { pn += yyleng; return OR; }

"," { pn += yyleng; return COMMA;}
"int" { pn += yyleng; return INT;}
"if" { pn += yyleng; return IF;}
"elif" { pn += yyleng; return ELIF;}
"else" { pn += yyleng; return ELSE;}
"while" { pn += yyleng; return WHILE;}
"for" { pn += yyleng; return FOR;}
"do" { pn += yyleng; return DO;}
"read" { pn += yyleng; return READ;}
"write" { pn += yyleng; return WRITE;}
"function" { pn += yyleng; return FUNC;}
"return" { pn += yyleng; return RETURN;}
"void" { pn += yyleng; return VOID;}
"true" { pn += yyleng; return TRUE;}
"false" { pn += yyleng; return FALSE;}

{COMMENT} { lc++; pn=0; return COMMENT;}
{NUM} { pn += yyleng; return NUM;}
{IDENT} { pn += yyleng; ECHO; return IDENT;}

{INVIDENT} {
   printf("ERROR in line %d column %d: INVALID IDENTIFIER: %s. Identifiers cannot start with numbers\n", lc, pn, yytext);
   yyerror("");
   pn += yyleng;
}
. {printf("Unrecognized input: %s\n Terminating program.", yytext); yyerror("");}
%%

yywrap() {}

// int main() {
//      //printf("Enter string: ");
//      yylex();
//      printf("Number of lines: %d\n", lc);
//      return 0;

// }
