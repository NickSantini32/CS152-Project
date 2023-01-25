%{

%}

%%


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
[a - z A - Z _][a - z A - Z 0 - 9 _]* printf("IDENT ");
[0-9][0-9]* printf("NUMBER ");

%%

yywrap() {}

int main() {
     printf("Enter string: ");
     yylex();

     return 0;

}
