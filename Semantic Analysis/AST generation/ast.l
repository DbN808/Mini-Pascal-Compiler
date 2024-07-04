%{
#include "y.tab.h"
#include <stdio.h> 
#include <strings.h>


%}

DIGIT [0-9]
LETTER [a-zA-Z]
UNDERSCORE "_"
WHITESPACE [ \t\r]+
TEXT ([0-9A-Za-z]|[ \t\r])*

%%


"//".*      { /* ignore single-line comments */ }    
[\t\f] {}
[\n]      {}           
" " {}

[pP][rR][oO][gG][rR][aA][mM]   {yylval.lexeme=strdup(yytext);return PROGRAM;}
[iI][nN][tT][eE][gG][eE][rR]       {yylval.lexeme=strdup(yytext);return INT;}
[rR][eE][aA][lL]      {yylval.lexeme=strdup(yytext);return REAL;}
[bB][oO][oO][lL][eE][aA][nN]   {yylval.lexeme=strdup(yytext);return BOOLEAN;}
[cC][hH][aA][rR]     {yylval.lexeme=strdup(yytext);return CHAR;}
[vV][aA][rR]       {yylval.lexeme=strdup(yytext);return VAR ;}
[fF][oO][rR]    { yylval.lexeme=strdup(yytext);return FOR;}
[dD][oO]        { yylval.lexeme=strdup(yytext);return DO;}
[wW][hH][iI][lL][eE]     { yylval.lexeme=strdup(yytext);return WHILE;}
[aA][rR][rR][aA][yY]     { yylval.lexeme=strdup(yytext);return ARRAY;}
[aA][nN][dD]       { yylval.lexeme=strdup(yytext);return AND;}
[oO][rR]        { yylval.lexeme=strdup(yytext);return OR;}
[nN][oO][tT]       { yylval.lexeme=strdup(yytext);return NOT;}
[bB][eE][gG][iI][nN]     { yylval.lexeme=strdup(yytext);return PROG_BEGIN ;}
[eE][nN][dD]       { yylval.lexeme=strdup(yytext);return END;}
[rR][eE][aA][dD]      { yylval.lexeme=strdup(yytext);return READ;}
[wW][rR][iI][tT][eE]     { yylval.lexeme=strdup(yytext);return WRITE;}
[iI][fF]        { yylval.lexeme=strdup(yytext); return IF;}
[eE][lL][sS][eE]      { yylval.lexeme=strdup(yytext); return ELSE;}
[tT][oO]        { yylval.lexeme=strdup(yytext); return TO;}
[dD][oO][wW][nN][tT][oO]    { yylval.lexeme=strdup(yytext); return DOWNTO;}
[eE][lL][sS][eE][ ][iI][fF]   { yylval.lexeme=strdup(yytext); return ELSEIF;}  
[tT][hH][eE][nN]      { yylval.lexeme=strdup(yytext); return THEN;} 
[oO][fF]        {yylval.lexeme=strdup(yytext); return OF;}
\"([^\\"]*)\" { yylval.lexeme=strdup(yytext); return TXT;}

[tT][rR][uU][eE]  {yylval.lexeme=strdup(yytext); return BOOLVAL;}
[fF][aA][lL][sS][eE] {yylval.lexeme=strdup(yytext); return BOOLVAL;}

[a-zA-Z][_a-zA-Z0-9]* {yylval.lexeme=strdup(yytext); return IDENTIFIER;}


[-]?{DIGIT}+([eE][+-]?{DIGIT}+)?  { yylval.lexeme=strdup(yytext); return INTVAL;}
[-]?({DIGIT}+(\.{DIGIT}+))([eE][+-]?{DIGIT}+)?   {yylval.lexeme=strdup(yytext); return REALVAL;}

\'{LETTER}\'  {yylval.lexeme=strdup(yytext); return CHARVAL;} 

"="        { yylval.lexeme=strdup(yytext);return EQ;}
"<>"        { yylval.lexeme=strdup(yytext);return NEQ;}
"<"         { yylval.lexeme=strdup(yytext);return LT;}
">"         { yylval.lexeme=strdup(yytext);return GT;}
"<="        { yylval.lexeme=strdup(yytext);return LTE;}
">="        { yylval.lexeme=strdup(yytext);return GTE;}

"+"         { yylval.lexeme=strdup(yytext);return PLUS;}
"-"         { yylval.lexeme=strdup(yytext);return MINUS;}
"*"         { yylval.lexeme=strdup(yytext);return MULT;}
"/"         {yylval.lexeme=strdup(yytext); return DIV;}
"%"         { yylval.lexeme=strdup(yytext);return MOD;}

":="        { yylval.lexeme=strdup(yytext);return ASSIGN;}
","         { yylval.lexeme=strdup(yytext);return COMMA;}
":"         { yylval.lexeme=strdup(yytext);return COLON;}
";"         { yylval.lexeme=strdup(yytext);return SEMICOLON;}
"("         { yylval.lexeme=strdup(yytext);return LPAREN;}
")"         { yylval.lexeme=strdup(yytext);return RPAREN;}
"["         { yylval.lexeme=strdup(yytext);return LSPAREN;}
"]"         {yylval.lexeme=strdup(yytext); return RSPAREN;}
"_"         { yylval.lexeme=strdup(yytext);return UNDERSCORE;}

[\']        { yylval.lexeme=strdup(yytext);return SQUOTE;}
"{"         { yylval.lexeme=strdup(yytext);return LCPAREN;}
"}"         { yylval.lexeme=strdup(yytext);return RCPAREN;}
\.	    { yylval.lexeme=strdup(yytext);return PERIOD;}
.           { return -1;}


%%

int yywrap() {
    return 1;
}

/*
int main(int argc, char *argv[]) {
    
    FILE *input_file = fopen("ip.txt", "r");
    if (input_file == NULL) {
        fprintf(stderr, "Error: Unable to open file %s\n", argv[1]);
        return 1;
    }

    yyin = input_file;
    yylex();

    printf("Line number Lexeme Token type\n");
    for (int i = 0; i < token_count; i++) {
        printf("%d %s %s\n", tokens[i].lineno , tokens[i].lexeme, tokens[i].token_type);
    }

    fclose(input_file);
    return 0;
}*/
