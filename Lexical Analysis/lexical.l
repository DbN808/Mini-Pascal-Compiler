%{

#include <stdio.h> 
#include <strings.h>

int line_no=1;
int token_count = 0;

typedef struct {
    int lineno;
    char lexeme[100];
    char token_type[100];
} token_info;

token_info tokens[100];

%}

DIGIT [0-9]
LETTER [a-zA-Z]
UNDERSCORE "_"
WHITESPACE [ \t\r]+
TEXT ([0-9A-Za-z]|[ \t\r])*
%%


"//".*      { /* ignore single-line comments */ }    
[\t\f] {}
[\n]      {line_no++;}           
" " {}

[pP][rR][oO][gG][rR][aA][mM]   { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[iI][nN][tT][eE][gG][eE][rR]     { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[rR][eE][aA][lL]      { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[bB][oO][oO][lL][eE][aA][nN]   { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[cC][hH][aA][rR]     { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[vV][aA][rR]      { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[fF][oO][rR]    { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[dD][oO]        { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[wW][hH][iI][lL][eE]    { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[aA][rR][rR][aA][yY]     { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[aA][nN][dD]      { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[oO][rR]        { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[nN][oO][tT]     { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[bB][eE][gG][iI][nN]     { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[eE][nN][dD]      { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[rR][eE][aA][dD]     { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[wW][rR][iI][tT][eE]     { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[iI][fF]       { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[eE][lL][sS][eE]     { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[tT][oO]       { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[dD][oO][wW][nN][tT][oO]    { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[eE][lL][sS][eE][ ][iI][fF]   { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;} 
[tT][hH][eE][nN]     { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
[oO][fF]       { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "KEYWORD");tokens[token_count].lineno = line_no; token_count++;}
\"([^\\"]*)\" { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "STRING");tokens[token_count].lineno = line_no; token_count++;}

[tT][rR][uU][eE]  { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "BOOL_VAL");tokens[token_count].lineno = line_no; token_count++;}
[fF][aA][lL][sS][eE] { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "BOOL_VAL");tokens[token_count].lineno = line_no; token_count++;}

[a-zA-Z][_a-zA-Z0-9]* { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "IDENTIFIER");tokens[token_count].lineno = line_no; token_count++;}


[-]?{DIGIT}+([eE][+-]?{DIGIT}+)?  { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "INT_VAL");tokens[token_count].lineno = line_no; token_count++;}
[-]?({DIGIT}+(\.{DIGIT}+))([eE][+-]?{DIGIT}+)?   { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "REAL_VAL");tokens[token_count].lineno = line_no; token_count++;}

\'{LETTER}\'  { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "CHAR_VAL");tokens[token_count].lineno = line_no; token_count++;} 

"="        { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "OPERATOR");tokens[token_count].lineno = line_no; token_count++;}
"<>"        { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "OPERATOR");tokens[token_count].lineno = line_no; token_count++;}
"<"        { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "OPERATOR");tokens[token_count].lineno = line_no; token_count++;}
">"         { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "OPERATOR");tokens[token_count].lineno = line_no; token_count++;}
"<="        { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "OPERATOR");tokens[token_count].lineno = line_no; token_count++;}
">="        { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "OPERATOR");tokens[token_count].lineno = line_no; token_count++;}

"+"         { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "OPERATOR");tokens[token_count].lineno = line_no; token_count++;}
"-"         { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "OPERATOR");tokens[token_count].lineno = line_no; token_count++;}
"*"         { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "OPERATOR");tokens[token_count].lineno = line_no; token_count++;}
"/"        { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "OPERATOR");tokens[token_count].lineno = line_no; token_count++;}
"%"         { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "OPERATOR");tokens[token_count].lineno = line_no; token_count++;}

":="        { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "PUNCTUATOR");tokens[token_count].lineno = line_no; token_count++;}
","         { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "PUNCTUATOR");tokens[token_count].lineno = line_no; token_count++;}
":"         { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "PUNCTUATOR");tokens[token_count].lineno = line_no; token_count++;}
";"         { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "PUNCTUATOR");tokens[token_count].lineno = line_no; token_count++;}
"("         { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "PUNCTUATOR");tokens[token_count].lineno = line_no; token_count++;}
")"         { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "PUNCTUATOR");tokens[token_count].lineno = line_no; token_count++;}
"["         { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "PUNCTUATOR");tokens[token_count].lineno = line_no; token_count++;}
"]"         { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "PUNCTUATOR");tokens[token_count].lineno = line_no; token_count++;}
"_"        { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "PUNCTUATOR");tokens[token_count].lineno = line_no; token_count++;}

[\']       { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "PUNCTUATOR");tokens[token_count].lineno = line_no; token_count++;}
"{"         { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "PUNCTUATOR");tokens[token_count].lineno = line_no; token_count++;}
"}"         { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "PUNCTUATOR");tokens[token_count].lineno = line_no; token_count++;}
\.	    { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "PUNCTUATOR");tokens[token_count].lineno = line_no; token_count++;}
.	    { strcpy(tokens[token_count].lexeme, yytext); strcpy(tokens[token_count].token_type, "INVALID_TOKEN");tokens[token_count].lineno = line_no; token_count++;}


%%

int yywrap() {
    return 1;
}


int main(int argc, char *argv[]) {
    
    FILE *input_file = fopen("input.txt", "r");
    if (input_file == NULL) {
        fprintf(stderr, "Error: Unable to open file %s\n", argv[1]);
        return 1;
    }

    yyin = input_file;
    yylex();

    printf("LineNo\t\tLexeme\t\tTokentype\n");
    for (int i = 0; i < token_count; i++) {
        printf("%d\t\t%s\t\t%s\n", tokens[i].lineno , tokens[i].lexeme, tokens[i].token_type);
    }

    fclose(input_file);
    return 0;
}






