%{

//Needed to call yyerror, which is the error function for task 1
void yyerror (char const *s) {
   fprintf (stderr, "%s\n", s);
   exit(1);
}

%}

/* temp code
^[a - z A - Z _][a - z A - Z 0 - 9 _]* printf("IDENT ", yytext);
^[0-9][0-9]*[a - z A - Z _][a - z A - Z 0 - 9 _]* printf("INVALID IDENT ", yytext);

"function" printf("FUNC\n");
"int"   printf("INT\n");
"string" printf("STRING\n");
"\""    printf("STR_QUOTE\n");
";"     printf("STATE_END\n");
"+"     printf("ADD\n");
"-"     printf("SUB\n");
"/"     printf("DIV\n");
"*"     printf("MULT\n");
"=="    printf("EQUAL\n");
">"     printf("GREATER\n");
"<"     printf("LESSER\n");
"<="    printf("LEQ\n");
">="    printf("GEQ\n");
"!="    printf("NEQ\n");
"="     printf("ASSIGN\n");
"&&"   printf("AND\n");
"||"  printf("OR\n");
"if"  printf("IF\n");
"elif"     printf("ELSE IF\n");
"else"  printf("ELSE\n");
"while" printf("WHILE\n");
"for"  printf("FOR\n");
"do"   printf("DO\n");
"read"  printf("READ\n");
"write"  printf("WRITE\n");
"("     printf("L_PAREN\n");
")"  printf("R_PAREN\n");
"[" printf("L_ARRAY\n");
"]" printf("R_ARRAY\n");
"{" printf("L_CURLY\n");
"}" printf("R_CURLY\n");
"#" printf("COMMENT\n");
"," printf("COMMA\n");
"return" printf("RETURN\n");

{STRING} {printf("STRING: %s\n", yytext);}
.        yyerror("Unrecognized input. Terminating program.");
{NUM}+ {printf("NUMBER: %s\n", yytext);}
*/

/* Rules */
NUM [0-9]
INT "int"
STR_QUOTE "\""
STATE_END ";"
ADD "+"
SUB "-"
MULT "*"
DIV "/"
EQUAL "=="
GREATER ">"
LESSER "<"
LEQ "<="
GEQ ">="
NEQ "!="
ASSIGN "="
AND "&&"
OR "||"
IF "if"
ELSE_IF "elif"
ELSE "else"
WHILE "while"
FOR "for"
DO "do"
READ "read"
WRITE "write"
L_PAREN "("
R_PAREN ")"
L_ARRAY "["
R_ARRAY "]"
COMMENT "#"
COLON ":"
APOS "'"
PERIOD "."
COMMA ","
UNDERSCORE "_"
STRING "[a-zA-Z]*"
IDENT [a-zA-Z][a-zA-Z0-9]*" "

%%

{ADD} {printf("PLUS\n");}
{IF} {printf("IF\n");}
{SUB} {printf("MINUS\n");}
{MULT} {printf("MULT\n");}
{DIV} {printf("DIV\n");}
{L_PAREN} {printf("L_PAREN\n");}
{R_PAREN} {printf("R_PAREN\n");}
{EQUAL} {printf("EQUAL\n");}
{ASSIGN} {printf("ASSIGN\n");}
{INT} {printf("INT\n");}

{IDENT} {printf("IDENT: \"%s\"\n", yytext);}





%%

yywrap() {}

int main() {
     //printf("Enter string: ");
     yylex();

     return 0;

}
