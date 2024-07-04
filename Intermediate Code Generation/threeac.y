%{

#include<stdio.h>
#include<math.h>
#include<stdlib.h>
#include <string.h>
#include <ctype.h>
extern int yylex();

extern int yyparse();
extern FILE *yyin;

int label=0;
int tempVariable=0;
int nestLabel[10];
int nesting = 0;

char* genTempVariable(int id){
    char* temp = (char*)malloc(10*sizeof(char));
    temp[0]='t';
    snprintf(temp,10,"t%d",id);
    return temp;
}

int gencode(char* lhs, char*op, char* rhs){
    printf("t%d = %s %s %s \n",tempVariable, lhs, op, rhs);
    return tempVariable;
}



void assignment(char* lhs, char* rhs){
    printf("%s = %s \n",lhs,rhs);
}

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

%token PROGRAM INT REAL BOOLEAN CHAR VAR FOR DO WHILE ARRAY NOT PROG_BEGIN END READ WRITE TO DOWNTO PERIOD TXT LCPAREN RCPAREN LPAREN RPAREN LSPAREN RSPAREN UNDERSCORE SQUOTE DQUOTE OF


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

assignment_stmt: IDENTIFIER ASSIGN expr {assignment($1,$3);} 
	| IDENTIFIER LSPAREN term RSPAREN ASSIGN  expr
	{
        char* temp1 = genTempVariable(tempVariable++);
        char* temp2 = genTempVariable(tempVariable++);
        char* temp3 = genTempVariable(tempVariable++);
        char* temp4 = genTempVariable(tempVariable++);
        printf("%s = %s\n", temp1, $3);
        int size=4;
        printf("%s = %d * %s\n", temp2, size, temp1); // t2 = size * t1
        printf("%s = &%s\n", temp3, $1); // t3 = &b
        printf("%s = %s + %s\n", temp4, temp2, temp3); // t4 = t2 + t3
        printf("*%s = %s\n", temp4, $6); // *(t4) = rhs
    }
    ;


read_stmt: READ LPAREN var_list RPAREN 
	| READ LPAREN arr_list RPAREN
        ;
        
        
arr_list: IDENTIFIER LSPAREN term RSPAREN COMMA var_list
    {
        char* temp = genTempVariable(tempVariable++);
        printf("%s = %s[%s]\n", temp, $1, $3);
        $$ = temp;
    }
	| IDENTIFIER LSPAREN term RSPAREN
	{
        char* temp = genTempVariable(tempVariable++);
        printf("%s = %s[%s]\n", temp, $1, $3);
        $$ = temp;
    }
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
	 
expr: term {$$=$1;}
    | expr  PLUS term  {
                                int a = gencode($1,"+", $3);
                                char* tempVar = genTempVariable(a);
                                $$=tempVar;
                                tempVariable++;
                          }
     | expr  MINUS term {
                                int a = gencode($1,"-", $3);
                                char* tempVar = genTempVariable(a);
                                $$=tempVar;
                                tempVariable++;
                          }
                                                                        
    | expr relop term {int a = gencode($1,$2,$3);
                        char* tempVar = genTempVariable(a);
                        $$ = tempVar;
                        tempVariable++;
                       }
  
    ;



term: term  MULT  factor {
                                int a = gencode($1,"*", $3);
                                char* tempVar = genTempVariable(a);
                                $$=tempVar;
                                tempVariable++;
                          }
    | term  DIV  factor  {
                                int a = gencode($1,"/", $3);
                                char* tempVar = genTempVariable(a);
                                $$=tempVar;
                                tempVariable++;
                          } 
    | term  MOD factor {
                                int a = gencode($1,"%", $3);
                                char* tempVar = genTempVariable(a);
                                $$=tempVar;
                                tempVariable++;
                          }
    
    | factor {$$=$1;}
    
    ;
    
factor: LPAREN expr RPAREN {$$=$2;}
       | IDENTIFIER {$$=$1;}
       | IDENTIFIER LSPAREN term RSPAREN
       {
        char* temp1 = genTempVariable(tempVariable++);
        char* temp2 = genTempVariable(tempVariable++);
        char* temp3 = genTempVariable(tempVariable++);
        char* temp4 = genTempVariable(tempVariable++);

        printf("%s = %s\n", temp1, $3); 
        int size=4;

        
        printf("%s = %d * %s\n", temp2, size, temp1); 
        printf("%s = &%s\n", temp3, $1); 
        printf("%s = %s + %s\n", temp4, temp2, temp3); 
        $$=temp4;
        } 
       | const {$$=$1;}
       | NOT factor 
       {
       char* temp1 = genTempVariable(tempVariable++);
        printf("%s = ! %s\n", temp1, $2); 
        $$=temp1;
        }
	;
const: INTVAL {$$=$1;}
     | REALVAL {$$=$1;}
     | BOOLVAL {$$=$1;}
     | CHARVAL {$$=$1;}
     ;
    	
	
	
conditional_stmt:  IF  expr THEN {printf("if not %s goto L%d\n",$2  ,++label);}block_stmt if_st 
     ;
     
if_st: {printf("goto L%d\n", label+1);} ELSE {printf("L%d: \n",label);} block_stmt {printf("L%d: \n", ++label);}
     | {printf("L%d: \n",label);}
     ;
		
	
loop: WHILE  expr  DO PROG_BEGIN
    {
        printf("L%d:\n", ++label);
        nestLabel[nesting]=label;

        
        printf("if not %s goto L%d\n", $2, ++label);
        nestLabel[nesting+1]=label; 
     }
     statement_list
     { 
        printf("goto L%d\n", nestLabel[nesting]);
        printf("L%d:\n", nestLabel[++nesting]); 
    }
    END

    |FOR IDENTIFIER ASSIGN expr TO expr DO PROG_BEGIN 
    {
                        printf("for_loop:\n");
                        printf("%s = %s\n", $2, $4);
                        printf("L%d:\n", ++label); 
                        nestLabel[nesting]=label;
                        printf("if %s < %s goto L%d\n", $2, $6, ++label); 
                        printf("goto L%d\n", ++label);
                        nestLabel[nesting+1]=label; 
                        printf("L%d:\n", label - 1); 
    }
        
    statement_list {
                        printf("%s = %s + 1\n", $2, $2);
                        printf("goto L%d\n", nestLabel[nesting]); 
                        printf("L%d:\n", nestLabel[++nesting]);
                    }    
    END
    | FOR  IDENTIFIER ASSIGN expr  DOWNTO expr DO PROG_BEGIN 
    {
                        printf("for_loop:\n");
                        printf("%s = %s\n", $2, $4);
                        printf("L%d:\n", ++label); 
                        nestLabel[nesting]=label;
                        printf("if %s > %s goto L%d\n", $2, $6, ++label);
                        printf("goto L%d\n", ++label);
                        nestLabel[nesting+1]=label; 
                        printf("L%d:\n", label - 1); 
    }
        
    statement_list {
                        printf("%s = %s - 1\n", $2, $2); 
                        printf("goto L%d\n", nestLabel[nesting]); 
                        printf("L%d:\n", nestLabel[++nesting]);
                    }    
    END
    ;

relop: EQ {$$=$1;}
    | NEQ {$$=$1;}
    | LT {$$=$1;}
    | GT {$$=$1;}
    | LTE {$$=$1;} 
    | GTE {$$=$1;}
    | OR {$$=$1;}
    | AND {$$=$1;}
    ; 

	
%%


void main(){

yyin=fopen("input.txt","r");

yyparse();
printf("parsed");


}




void yyerror(){
printf("Syntax error..\n");
exit(0);
}

