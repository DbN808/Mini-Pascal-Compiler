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
%union{
char* lexeme;
char* arrtype;
}

%left  PLUS MINUS
%left  MULT DIV MOD
%right NOT

%token <lexeme>  EQ NEQ LT GT LTE GTE OR AND
%token <lexeme>  PLUS MINUS MULT DIV MOD ASSIGN COMMA COLON SEMICOLON 
%token <lexeme> IDENTIFIER INTVAL REALVAL BOOLVAL CHARVAL IF ELSE ELSEIF THEN

%type <lexeme> const factor term expr relop assignment_stmt conditional_stmt statement_list arr_list 

%token <lexeme> PROGRAM INT REAL BOOLEAN CHAR VAR FOR DO WHILE ARRAY NOT PROG_BEGIN END READ WRITE TO DOWNTO PERIOD TXT LCPAREN RCPAREN LPAREN RPAREN LSPAREN RSPAREN UNDERSCORE SQUOTE DQUOTE OF


%%

s: program { return 0;}

program: PROGRAM IDENTIFIER SEMICOLON var_decl_section PROG_BEGIN statement_list END PERIOD
{
    char intermediate[5000];
    sprintf(intermediate, "[PROGRAMid:{%s};%s[BEGIN[BLOCK%s]][END][.]]", $<lexeme>2, $<lexeme>4, $<lexeme>6);
    $<lexeme>$=strdup(intermediate);
    printf("%s",intermediate);
}
    ;


var_decl_section: VAR var_decl_list 
{
    char intermediate[5000];
    sprintf(intermediate,"[VRBL%s]",$<lexeme>2);
    $<lexeme>$=strdup(intermediate);

}
    ;
    
var_decl_list: var_list COLON type SEMICOLON var_decl_list
{
    char intermediate[5000];
        sprintf(intermediate, "[%s[%s]:];%s", $<lexeme>3, $<lexeme>1, $<lexeme>5);
        
    $<lexeme>$=strdup(intermediate);

}
    | var_list COLON ARRAY LSPAREN INTVAL PERIOD PERIOD INTVAL RSPAREN OF type SEMICOLON var_decl_list
    {
    char intermediate[5000];
    sprintf(intermediate, "[ARRAYOF%s[%s][range:%s..%s]];%s", $<lexeme>11,   $<lexeme>1, $<lexeme>5, $<lexeme>8, $<lexeme>13);
    $<lexeme>$ = strdup(intermediate);
}
    | var_list COLON type SEMICOLON
    {
    char intermediate[5000];
    sprintf(intermediate, "[%s[%s]:];", $<lexeme>3, $<lexeme>1);
    $<lexeme>$=strdup(intermediate);
    } 
    | var_list COLON ARRAY LSPAREN INTVAL PERIOD PERIOD INTVAL RSPAREN OF type SEMICOLON 
    {
    char intermediate[5000];
    sprintf(intermediate, "[ARRAYOF%s[%s][range:%s..%s]];", $<lexeme>11,   $<lexeme>1, $<lexeme>5, $<lexeme>8);
    $<lexeme>$ = strdup(intermediate);
}
;

var_list: IDENTIFIER COMMA var_list
{
    char intermediate[5000];
    sprintf(intermediate, "[,[id:{%s}]%s]", $<lexeme>1, $<lexeme>3);
    $<lexeme>$ = strdup(intermediate);
}
	| IDENTIFIER
	{
	char intermediate[5000];
    sprintf(intermediate, "id:{%s}", $<lexeme>1);
    $<lexeme>$ = strdup(intermediate);
	}
	;

type: INT {$<lexeme>$=strdup("INT");}
    | REAL {$<lexeme>$=strdup("REAL");}
    | BOOLEAN {$<lexeme>$=strdup("BOOL");}
    | CHAR {$<lexeme>$=strdup("CHAR");}
    ;

statement_list : statement SEMICOLON statement_list
{
    char intermediate[5000];
    sprintf(intermediate,"[%s][%s]%s",$<lexeme>1,$<lexeme>2,$<lexeme>3);
    $<lexeme>$ = strdup(intermediate);
}
    |statement SEMICOLON
{
    char intermediate[5000];
    sprintf(intermediate,"[%s][%s]",$<lexeme>1,$<lexeme>2);
    $<lexeme>$ = strdup(intermediate);
}  
    ;
    
    
statement: assignment_stmt {$<lexeme>$=strdup($<lexeme>1);}
	| read_stmt {$<lexeme>$=strdup($<lexeme>1);}
	| write_stmt {$<lexeme>$=strdup($<lexeme>1);}
	| conditional_stmt {$<lexeme>$=strdup($<lexeme>1);}
	| loop {$<lexeme>$=strdup($<lexeme>1);}
	| block_stmt {$<lexeme>$=strdup($<lexeme>1);}
	;

assignment_stmt: IDENTIFIER ASSIGN expr
{
    char intermediate[5000];
    sprintf(intermediate, "ASSIGN[id:{%s}][%s]", $<lexeme>1, $<lexeme>3);
    $<lexeme>$ = strdup(intermediate);
} 
	| IDENTIFIER LSPAREN term RSPAREN ASSIGN  expr
{
    char intermediate[5000];
    sprintf(intermediate, "ASSIGN[atindex[id:{%s}][%s]][%s]", $<lexeme>1, $<lexeme>3, $<lexeme>6);
    $<lexeme>$ = strdup(intermediate);
}
    ;


read_stmt: READ LPAREN var_list RPAREN 
{
    char intermediate[5000];
    sprintf(intermediate, "READ[%s]", $<lexeme>3);
    $<lexeme>$ = strdup(intermediate);
}
	| READ LPAREN arr_list RPAREN
	{
    char intermediate[5000];
    sprintf(intermediate, "READ%s", $<lexeme>3);
    $<lexeme>$ = strdup(intermediate);
}
        ;
        
        
arr_list: IDENTIFIER LSPAREN term RSPAREN COMMA var_list
{
    char intermediate[5000];
    sprintf(intermediate, "[atindex[id:{%s}][%s]],%s", $<lexeme>1, $<lexeme>3, $<lexeme>6);
    $<lexeme>$ = strdup(intermediate);
}
	| IDENTIFIER LSPAREN term RSPAREN
{
    char intermediate[5000];
    sprintf(intermediate, "[atindex[id:{%s}][%s]]", $<lexeme>1, $<lexeme>3);
    $<lexeme>$ = strdup(intermediate);
}
	;
	
	
write_stmt: WRITE LPAREN write_list RPAREN 
{
    char intermediate[5000];
    sprintf(intermediate, "WRITE%s", $<lexeme>3);
    $<lexeme>$ = strdup(intermediate);
}
         ;
    
    
write_list: TXT
{
    char intermediate[5000];
    sprintf(intermediate, "[{%s}]", $<lexeme>1);
    $<lexeme>$ = strdup(intermediate);
}
	| var_list { $<lexeme>$ = strdup($<lexeme>1); }
	| arr_list { $<lexeme>$ = strdup($<lexeme>1); }
	;

	
block_stmt: PROG_BEGIN statement_list END 	
{
    char intermediate[5000];
    sprintf(intermediate, "[BLOCK%s]", $<lexeme>2);
    $<lexeme>$ = strdup(intermediate);
}
	 ;
	 
expr: term { $<lexeme>$ = strdup($<lexeme>1); }
    | expr  PLUS term 
    {
    char intermediate[5000];
    sprintf(intermediate, "+[%s][%s]", $<lexeme>1, $<lexeme>3);
    $<lexeme>$ = strdup(intermediate);
} 
     | expr  MINUS term    
{
    char intermediate[5000];
    sprintf(intermediate, "-[%s][%s]", $<lexeme>1, $<lexeme>3);
    $<lexeme>$ = strdup(intermediate);
}                                                     
    | expr relop term 
    {
    char intermediate[5000];
    sprintf(intermediate, "%s[%s][%s]", $<lexeme>2, $<lexeme>1, $<lexeme>3);
    $<lexeme>$ = strdup(intermediate);
}
    ;



term: term  MULT  factor 
{
    char intermediate[5000];
    sprintf(intermediate, "*[%s][%s]", $<lexeme>1, $<lexeme>3);
    $<lexeme>$ = strdup(intermediate);
}
    | term  DIV  factor
{
    char intermediate[5000];
    sprintf(intermediate, "/[%s][%s]", $<lexeme>1, $<lexeme>3);
    $<lexeme>$ = strdup(intermediate);
} 
    | term  MOD factor 
{
    char intermediate[5000];
    sprintf(intermediate, "%%[%s][%s]", $<lexeme>1, $<lexeme>3);
    $<lexeme>$ = strdup(intermediate);
}
    | factor { $<lexeme>$ = strdup($<lexeme>1); }
    
    ;
    
factor: LPAREN expr RPAREN { $<lexeme>$ = strdup($<lexeme>2); }
       | IDENTIFIER { $<lexeme>$ = strdup($<lexeme>1); }
       | IDENTIFIER LSPAREN term RSPAREN
       {
    char intermediate[5000];
    sprintf(intermediate, "atindex[id:{%s}][%s]", $<lexeme>1, $<lexeme>3);
    $<lexeme>$ = strdup(intermediate);
}
       | const { $<lexeme>$ = strdup($<lexeme>1); }
       | NOT factor 
       {
    char intermediate[5000];
    sprintf(intermediate, "[NOT[%s]]", $<lexeme>2);
    $<lexeme>$ = strdup(intermediate);
}
	;
const: INTVAL { $<lexeme>$ = strdup($<lexeme>1); }
     | REALVAL { $<lexeme>$ = strdup($<lexeme>1); }
     | BOOLVAL { $<lexeme>$ = strdup($<lexeme>1); }
     | CHARVAL { $<lexeme>$ = strdup($<lexeme>1); }
     ;
    	
	
	
conditional_stmt:  IF  expr THEN block_stmt
{
    char intermediate[5000];
    sprintf(intermediate,"IF[BRANCH[COND[%s]][THEN[%s]]]",$<lexeme>2,$<lexeme>4);
    $<lexeme>$ = strdup(intermediate);
}
    |
    IF  expr THEN block_stmt if_st 
{
    char intermediate[5000];
    sprintf(intermediate,"IF[BRANCH[COND[%s]][THEN[%s]][%s]]",$<lexeme>2,$<lexeme>4,$<lexeme>5);
    $<lexeme>$ = strdup(intermediate);
}
     ;
     
if_st:  ELSE block_stmt 
{
    char intermediate[5000];
    sprintf(intermediate,"[ELSE[%s]]",$<lexeme>2);
    $<lexeme>$ = strdup(intermediate);
}
     ;
		
	
loop: WHILE  expr  DO PROG_BEGIN statement_list END
{
    char intermediate[5000];
    sprintf(intermediate,"WHILE[COND[%s]][DO[%s]]",$<lexeme>2,$<lexeme>5);
    $<lexeme>$ = strdup(intermediate);
}
    |FOR IDENTIFIER ASSIGN expr TO expr DO PROG_BEGIN statement_list END
{
    char intermediate[5000];
	sprintf(intermediate, "FOR[COND[=[id:{%s}]%s][TO][=[id:{%s}]%s]][BODY%s]", 						$<lexeme>2,$<lexeme>4,$<lexeme>2,$<lexeme>6,$<lexeme>9);
	strcpy($<lexeme>$, intermediate);
}
    |FOR  IDENTIFIER ASSIGN expr  DOWNTO expr DO PROG_BEGIN statement_list END
    
{
    char intermediate[5000];
	sprintf(intermediate, "FOR[COND[=[id:{%s}]%s][DOWNTO][=[id:{%s}]%s]][BODY%s]", 						$<lexeme>2,$<lexeme>4,$<lexeme>2,$<lexeme>6,$<lexeme>9);
	strcpy($<lexeme>$, intermediate);
}
    ;

relop:    EQ { $<lexeme>$ = strdup($<lexeme>1); }
        | NEQ { $<lexeme>$ = strdup($<lexeme>1); }
        | LT { $<lexeme>$ = strdup($<lexeme>1); }
        | GT { $<lexeme>$ = strdup($<lexeme>1); }
        | LTE  { $<lexeme>$ = strdup($<lexeme>1); }
        | GTE { $<lexeme>$ = strdup($<lexeme>1); }
        | OR { $<lexeme>$ = strdup($<lexeme>1); }
        | AND { $<lexeme>$ = strdup($<lexeme>1); }  
        ; 

	    
%%


void main(){

yyin=fopen("input.txt","r");

yyparse();
//printf("parsed");
//
//exit(0);

}




void yyerror(){
printf("Syntax error..\n");
exit(0);
}

