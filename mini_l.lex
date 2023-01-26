%{

//Needed to call yyerror, which is the error function for task 1
void yyerror (char const *s) {
   fprintf (stderr, "%s\n", s);
   exit(1);
}
int lc=1;
int pn=0;

%}

/* temp code
^[a - z A - Z _][a - z A - Z 0 - 9 _]* printf("IDENT ", yytext);
^[0-9][0-9]*[a - z A - Z _][a - z A - Z 0 - 9 _]* printf("INVALID IDENT ", yytext);
{STRING} {printf("STRING: %s\n", yytext);}

*/

/* Rules */
NUM [0-9]+
COMMENT "#".*"\n"
STRING "[a-zA-Z_0-9]*"
IDENT [a-zA-Z_][a-zA-Z0-9_]*
INVIDENT [0-9][a-zA-Z0-9_]+

STR_QUOTE "\""

%%
" " {pn += yyleng;}
"\n" { pn=0; lc++;}
";" {printf("STATE_END\n"); pn += yyleng;}
"+" {printf("PLUS\n"); pn += yyleng;}
"-" {printf("MINUS\n"); pn += yyleng;}
"*" {printf("MULT\n"); pn += yyleng;}
"/" {printf("DIV\n"); pn += yyleng;}
"[" {printf("L_ARRAY\n"); pn += yyleng;}
"]" {printf("R_ARRAY\n"); pn += yyleng;}
"(" {printf("L_PAREN\n"); pn += yyleng;}
")" {printf("R_PAREN\n"); pn += yyleng;}
"{" {printf("L_BRACE\n"); pn += yyleng;}
"}" {printf("R_BRACE\n"); pn += yyleng;}
"==" {printf("EQUAL\n"); pn += yyleng;}
">" {printf("GREATER\n"); pn += yyleng;}
"<" {printf("LESSER\n"); pn += yyleng;}
"<=" {printf("LEQ\n"); pn += yyleng;}
">=" {printf("GEQ\n"); pn += yyleng;}
"!=" {printf("NEQ\n"); pn += yyleng;}
"=" {printf("ASSIGN\n"); pn += yyleng;}
"&&" {printf("AND\n"); pn += yyleng;}
"||" {printf("OR\n"); pn += yyleng;}

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
