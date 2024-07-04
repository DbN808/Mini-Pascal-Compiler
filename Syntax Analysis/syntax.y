%{
#include<stdio.h>
#include<math.h>
#include<stdlib.h>
#include <string.h>
#include <ctype.h>
extern int yylex();
extern int yyparse();
extern FILE *yyin;

void yyerror();

%}

%left  PLUS MINUS
%left  MULT DIV MOD
%right NOT

%token PROGRAM INT REAL BOOLEAN CHAR VAR FOR DO WHILE ARRAY AND OR NOT PROG_BEGIN END READ WRITE IF ELSE ELSEIF THEN TO DOWNTO PERIOD TXT LCPAREN RCPAREN IDENTIFIER INTVAL REALVAL BOOLVAL CHARVAL EQ NEQ LT GT LTE GTE PLUS MINUS MULT DIV MOD ASSIGN COMMA COLON SEMICOLON LPAREN RPAREN LSPAREN RSPAREN UNDERSCORE SQUOTE DQUOTE OF


%%

s: program { printf("valid input");return 0;}

program: PROGRAM IDENTIFIER SEMICOLON var_decl_section PROG_BEGIN statement_list END PERIOD
    ;


var_decl_section: VAR var_decl_list 
    ;
    
var_decl_list: var_list COLON type SEMICOLON var_decl_list
    | var_list COLON ARRAY LSPAREN INTVAL PERIOD PERIOD INTVAL RSPAREN OF type SEMICOLON var_decl_list
    |
;


type: INT
    | REAL
    | BOOLEAN
    | CHAR
    ;

statement_list : statement SEMICOLON statement_list
    |
    ;
    
    
statement: assignment_stmt
	| read_stmt
	| write_stmt
	| conditional_stmt
	| loop
	| block_stmt
	;

assignment_stmt: IDENTIFIER ASSIGN expr 
	| IDENTIFIER LSPAREN arr_type RSPAREN ASSIGN expr
    ;


read_stmt: READ LPAREN var_list RPAREN 
	| READ LPAREN arr_list RPAREN
        ;
        
        
arr_list: IDENTIFIER LSPAREN arr_type RSPAREN COMMA var_list
	| IDENTIFIER LSPAREN arr_type RSPAREN
	;
	
	
write_stmt: WRITE LPAREN write_list RPAREN 
         ;
    
    
write_list: TXT
	| var_list
	| arr_list
	;

var_list: IDENTIFIER COMMA var_list
	| IDENTIFIER
	;
	
block_stmt: PROG_BEGIN statement_list END 	
	 ;
	 
expr: term
     | expr relop term
     ;

term: term MULT factor
    | term DIV factor
    | term MOD factor
     | term PLUS factor
     | term MINUS factor
    | factor
    ;
    
factor: LPAREN expr RPAREN
       | IDENTIFIER 
       | IDENTIFIER LSPAREN arr_type RSPAREN
       | const 
       | NOT factor
	;
const: INTVAL
     | REALVAL
     | BOOLVAL
     | CHARVAL
     ;
     

   
arr_type: term
	;
	
	
	
conditional_stmt:  IF  expr THEN PROG_BEGIN statement_list END ELSE PROG_BEGIN statement_list END
		|  IF  expr THEN PROG_BEGIN statement_list END 
		;
	
loop: WHILE expr DO PROG_BEGIN statement_list END  
    | FOR IDENTIFIER ASSIGN expr TO expr DO PROG_BEGIN statement_list END 
    | FOR IDENTIFIER ASSIGN expr DOWNTO expr DO PROG_BEGIN statement_list END 
    ;

relop: EQ
    | NEQ
    | LT
    | GT
    | LTE
    | GTE
    | OR
    | AND
    ; 

	
%%


void main(){
yyin=fopen("input.txt","r");

yyparse();
printf("parsed");
exit(0);
}

void yyerror(){
printf("Syntax error..\n");
exit(0);
}

