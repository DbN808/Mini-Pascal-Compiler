%{
#include<stdio.h>
#include<math.h>
#include<stdlib.h>
#include <string.h>
#include <ctype.h>
#define HASH_TABLE_SIZE 1000
#define ARRAY_SIZE 1000

extern int yylex();
extern int yyparse();
extern FILE *yyin;

void yyerror();

typedef struct
{
	char* name;
	int start_idx;
	int end_idx;
	union{
	  	int ival;
	  	float fval;
	  	char cval;
	  	char* sval;
	  	int intArray[ARRAY_SIZE];  
		float floatArray[ARRAY_SIZE]; 
		char charArray[ARRAY_SIZE]; 
		char* booleanArray[ARRAY_SIZE]; 
	}vi;
	int init;
	char* arr_tp;
	char* tp;
}T;

int token_ct = 0;
T symbol_table[HASH_TABLE_SIZE];

char *varnames[100];
char *arrtypes[100];
int arrvals[100];
int var_idx=0;

int execute = 1;

int search_table(char *lexeme){
	for(int i=0;i<token_ct;i++){
		if(strcmp(symbol_table[i].name,lexeme)==0)return i;
	}
	return -1;
}

void assign_type_to_var(char *typ){
	for(int i=0;i<var_idx;i++){
		if(search_table(varnames[i])!=-1) printf("ERROR : multiple declarations of a variable '%s'.\n",varnames[i]);
		else{
			symbol_table[token_ct].name = strdup(varnames[i]);
			symbol_table[token_ct].tp = strdup(typ);
			
			//default values
			/*if(strcmp(typ,"integer")==0)symbol_table[token_ct].vi.ival = 0;
	       		else if(strcmp(typ,"real")==0)symbol_table[token_ct].vi.fval = 0;
	       		else if(strcmp(typ,"boolean")==0)symbol_table[token_ct].vi.sval = strdup("false");
	       		else if(strcmp(typ,"char")==0)symbol_table[token_ct].vi.cval = '\0';*/
	       		
	       		symbol_table[token_ct].init = 0;  //init = 0 : not initialised
	       		
	       		token_ct++;	
       		}
	}
	var_idx=0;
}

void assign_array_to_var(char* typ,int sind,int eind){
	for(int i=0;i<var_idx;i++){
		if(search_table(varnames[i])!=-1) printf("ERROR : multiple declarations of a variable '%s'.\n",varnames[i]);
		else{
			symbol_table[token_ct].name = strdup(varnames[i]);
			symbol_table[token_ct].tp = strdup("array");
			symbol_table[token_ct].arr_tp = strdup(typ);
			symbol_table[token_ct].start_idx = sind;
			symbol_table[token_ct].end_idx = eind;
			
			//default values
			/*if(strcmp(typ,"integer")==0)symbol_table[token_ct].vi.ival = 0;
	       		else if(strcmp(typ,"real")==0)symbol_table[token_ct].vi.fval = 0;
	       		else if(strcmp(typ,"boolean")==0)symbol_table[token_ct].vi.sval = strdup("false");
	       		else if(strcmp(typ,"char")==0)symbol_table[token_ct].vi.cval = '\0';
	       		*/
	       		
	       		token_ct++;;	
       		}
	}
	var_idx=0;
}

//if type checked it return the index of the varible in the symbo_table
int typecheck(char *var_name,char* tp2){
	int idx = search_table(var_name);
	if(idx==-1){
		printf("ERROR : undeclared variable '%s' .\n",var_name);
		return -1;
	}
	else{
		char *tp1 = symbol_table[idx].tp;
		if(strcmp(tp1,"real")==0 && strcmp(tp2,"integer")==0)return idx; //handling int assigned to real
		if(strcmp(tp1,tp2)!=0){
			printf("ERROR : a '%s' value assigned to '%s' variable .\n",tp2,tp1);
			return -1;
		}
		return idx;
	}
}

int array_check_var_int_bound(char* var_name,char* term_type,int arr_ind){
	int idx = search_table(var_name);
	if(idx==-1){
		printf("ERROR : undeclared variable '%s'.\n",var_name);
		return -1;
	}
	else{
		if(strcmp(term_type,"integer")==0){
			int s = symbol_table[idx].start_idx;
			int e = symbol_table[idx].end_idx;
			if(arr_ind>=s && arr_ind<=e){
				return idx;
			}
			else{
				printf("ERROR : index '%d' out of bound.\n",arr_ind);
				return -1;
			}
		
		}
		else{
			printf("ERROR : not found 'integer' inside '[..]'.\n");
			return -1;
		}
	}
}


int is_any_bool_char(char *tp1,char *tp2){
	if(strcmp(tp1,"char")==0 || strcmp(tp2,"char")==0){printf("ERROR : Trying to perform arithematic operation on 'char'.\n");return 1;}
	if(strcmp(tp1,"boolean")==0 || strcmp(tp2,"boolean")==0){printf("ERROR : Trying to perform arithematic operation on 'boolean'.\n");return 1;}
	
	return 0;
}

void is_bool(char *str1){
	if(strcmp(str1,"boolean")!=0){
		printf("ERROR : condition inside 'if' is not 'boolean'.\n");	
	}
}

void is_int(char *str1){
	if(strcmp(str1,"integer")!=0){
		printf("ERROR : condition inside 'for' is not 'arithematic expression'.\n");	
	}
}

void display_stable()
{
    printf("\n====================================================\n");
    printf(" %-20s %-20s %-20s\n","lexeme_name","value","data_type");
    printf("====================================================\n");

	for(int i=0; i < token_ct; i++){
		if(strcmp(symbol_table[i].tp,"integer")==0)printf(" %-20s %-20d %-20s \n", symbol_table[i].name, symbol_table[i].vi.ival, symbol_table[i].tp);
       		else if(strcmp(symbol_table[i].tp,"real")==0)printf(" %-20s %-20lf %-20s \n", symbol_table[i].name, symbol_table[i].vi.fval, symbol_table[i].tp);
       		else if(strcmp(symbol_table[i].tp,"boolean")==0)printf(" %-20s %-20s %-20s \n", symbol_table[i].name, symbol_table[i].vi.sval, symbol_table[i].tp);
       		else if(strcmp(symbol_table[i].tp,"char")==0)printf(" %-20s %-20c %-20s \n", symbol_table[i].name, symbol_table[i].vi.cval, symbol_table[i].tp);
       		else if(strcmp(symbol_table[i].tp,"array")==0){
       			printf(" %-20s %-20s %-20s \n", symbol_table[i].name, symbol_table[i].arr_tp, symbol_table[i].tp);
       			for(int j=0 ;j<=symbol_table[i].end_idx;j++){
       				printf("%d ",symbol_table[i].vi.intArray[j]);
       			}
       			printf("\n");
       		}
       		
		
	}
    	printf("====================================================\n");

}



%}

%left  PLUS MINUS
%left  MULT DIV MOD
%right NOT

%token PROGRAM INT REAL BOOLEAN CHAR VAR FOR DO WHILE ARRAY AND OR NOT PROG_BEGIN END READ WRITE IF ELSE ELSEIF THEN TO DOWNTO PERIOD TXT LCPAREN RCPAREN IDENTIFIER INTVAL REALVAL BOOLVAL CHARVAL EQ NEQ LT GT LTE GTE PLUS MINUS MULT DIV MOD ASSIGN COMMA COLON SEMICOLON LPAREN RPAREN LSPAREN RSPAREN UNDERSCORE SQUOTE DQUOTE OF


//note: for identifier its name is in the type attribute
%union{
 struct{
  char *type;
  union{
  	int ival;
  	float fval;
  	char cval;
  	char* sval;
  }v;
 }t;
}

%%

s: program {return 0;}

program: PROGRAM IDENTIFIER SEMICOLON var_decl_section PROG_BEGIN statement_list END PERIOD
    ;


var_decl_section: VAR var_decl_list 
    ;
    
var_decl_list: var_list COLON type {assign_type_to_var($<t.type>3);} SEMICOLON var_decl_list 
    | var_list COLON ARRAY LSPAREN INTVAL PERIOD PERIOD INTVAL RSPAREN OF type SEMICOLON {assign_array_to_var($<t.type>11,$<t.v.ival>5,$<t.v.ival>8);} var_decl_list 
    |
;

var_list: IDENTIFIER {varnames[var_idx]=$<t.type>1;var_idx++;} COMMA var_list 
	| IDENTIFIER {varnames[var_idx]=$<t.type>1;var_idx++;}    
	;

type: INT      {$<t.type>$=$<t.type>1;}
    | REAL     {$<t.type>$=$<t.type>1;}
    | BOOLEAN  {$<t.type>$=$<t.type>1;}
    | CHAR     {$<t.type>$=$<t.type>1;}
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

read_stmt: READ LPAREN var_list RPAREN {
		for(int i=0;i<var_idx;i++){
			int idx = search_table(varnames[i]);
			if(idx==-1){
				printf("ERROR : undeclared variable '%s'.\n",varnames[i]);
			}
			else{
				if(strcmp(symbol_table[idx].tp,"integer")==0){
					if(scanf("%d",&symbol_table[idx].vi.ival)!=1){
						printf("ERROR : input is not 'integer' type\n");
					}
					else symbol_table[idx].init=1;			
				}
				else if(strcmp(symbol_table[idx].tp,"real")==0){
					if(scanf("%f",&symbol_table[idx].vi.fval)!=1){
						printf("ERROR : input is not 'real' type\n");
					}
					else symbol_table[idx].init=1;
				}
				else if(strcmp(symbol_table[idx].tp,"char")==0){
					if(scanf("%c",&symbol_table[idx].vi.cval)!=1){
						printf("ERROR : input is not 'char' type\n");
					}
					else symbol_table[idx].init=1;
				}
				else if(strcmp(symbol_table[idx].tp,"boolean")==0){
					char str[100];
					if(scanf("%s",str)==1){
						if(strcmp(str,"true")==0 || strcmp(str,"false")==0){ symbol_table[idx].vi.sval = strdup(str);symbol_table[idx].init=1;}
						else printf("ERROR : input is not 'boolean' type\n");
					}
					else{
						printf("ERROR : input is not 'boolean' type\n");
					}
				}
			}
		}
		var_idx=0;
		printf("\n");

	}
	| READ LPAREN arr_list RPAREN {
		for(int i=0;i<var_idx;i++){
			int ind = array_check_var_int_bound(varnames[i],arrtypes[i],arrvals[i]);
			if(ind!=-1){
				int arr_ind = arrvals[i];
				if(strcmp(symbol_table[ind].arr_tp,"integer")==0){
					if(scanf("%d",&symbol_table[ind].vi.intArray[arr_ind])!=1){
						printf("ERROR : input is not 'integer' type\n");
					}				
				}
				else if(strcmp(symbol_table[ind].arr_tp,"real")==0){
					if(scanf("%f",&symbol_table[ind].vi.floatArray[arr_ind])!=1){
						printf("ERROR : input is not 'real' type\n");
					}
				}
				else if(strcmp(symbol_table[ind].arr_tp,"char")==0){
					if(scanf("%c",&symbol_table[ind].vi.charArray[arr_ind])!=1){
						printf("ERROR : input is not 'char' type\n");
					}
				}
				else if(strcmp(symbol_table[ind].arr_tp,"boolean")==0){
					char str[100];
					if(scanf("%s",str)==1){
						if(strcmp(str,"true")==0 || strcmp(str,"false")==0) symbol_table[ind].vi.booleanArray[arr_ind] = strdup(str);	
						else printf("ERROR : input is not 'boolean' type\n");
					}
					else{
						printf("ERROR : input is not 'boolean' type\n");
					}
				}
			}
		}
		var_idx=0;
	}
        ;
        
        
arr_list: IDENTIFIER LSPAREN term RSPAREN {varnames[var_idx]=$<t.type>1;arrtypes[var_idx]=$<t.type>3;arrvals[var_idx]=$<t.v.ival>3;var_idx++;} COMMA arr_list
	| IDENTIFIER LSPAREN term RSPAREN {varnames[var_idx]=$<t.type>1;arrtypes[var_idx]=$<t.type>3;arrvals[var_idx]=$<t.v.ival>3;var_idx++;}
	;

	
write_stmt: WRITE LPAREN write_list RPAREN 
         ;
    
    
write_list: TXT {
		/*char* str = strdup($<t.v.sval>1);
		int length = strlen(str);
		
		char result[length-1];
		strncpy(result,str+1,length-2);
		result[length-2]='\0';
		printf("%s\n",result);*/
	}
	| var_list{
		for(int i=0;i<var_idx;i++){
			int idx = search_table(varnames[i]);
			if(idx==-1){
				printf("ERROR : undeclared variable '%s'.\n",varnames[i]);
			}
			/*else{
				if(strcmp(symbol_table[idx].tp,"integer")==0)printf("%d ",symbol_table[idx].vi.ival);
				else if(strcmp(symbol_table[idx].tp,"real")==0)printf("%f ",symbol_table[idx].vi.fval);
				else if(strcmp(symbol_table[idx].tp,"char")==0)printf("%c ",symbol_table[idx].vi.cval);
				else if(strcmp(symbol_table[idx].tp,"boolean")==0)printf("%s ",symbol_table[idx].vi.sval);
			}*/
		}
		var_idx=0;
		printf("\n");
	}
	| arr_list{
		for(int i=0;i<var_idx;i++){
			int ind = array_check_var_int_bound(varnames[i],arrtypes[i],arrvals[i]);
			int arr_ind = arrvals[i];
			
			/*if(strcmp(symbol_table[ind].arr_tp,"integer")==0)printf("%d ",symbol_table[ind].vi.intArray[arr_ind]);
			else if(strcmp(symbol_table[ind].arr_tp,"real")==0)printf("%f ",symbol_table[ind].vi.floatArray[arr_ind]);
			else if(strcmp(symbol_table[ind].arr_tp,"char")==0)printf("%c ",symbol_table[ind].vi.charArray[arr_ind]);
			else if(strcmp(symbol_table[ind].arr_tp,"boolean")==0)printf("%s ",symbol_table[ind].vi.booleanArray[arr_ind]);*/
		}
		var_idx=0;
	}
	;
	
block_stmt: PROG_BEGIN statement_list END 	
	 ;


assignment_stmt: IDENTIFIER ASSIGN expr {
		int idx = typecheck($<t.type>1,$<t.type>3);
		if(idx!=-1){
			symbol_table[idx].init=1;
			/*if(strcmp($<t.type>3,"integer")==0){
				if(strcmp(symbol_table[idx].tp,"real")==0)symbol_table[idx].vi.fval = $<t.v.ival>3;
				else symbol_table[idx].vi.ival = $<t.v.ival>3;
			}
	       		else if(strcmp($<t.type>3,"real")==0)symbol_table[idx].vi.fval = $<t.v.fval>3;
	       		else if(strcmp($<t.type>3,"boolean")==0)symbol_table[idx].vi.sval = $<t.v.sval>3;
	       		else if(strcmp($<t.type>3,"char")==0)symbol_table[idx].vi.cval = $<t.v.cval>3;*/
		}	
	}
	| IDENTIFIER LSPAREN term RSPAREN ASSIGN expr  {
		int idx = array_check_var_int_bound($<t.type>1,$<t.type>3,$<t.v.ival>3);
		int arr_ind = $<t.v.ival>3;
		if(strcmp(symbol_table[idx].arr_tp,$<t.type>6)!=0){
			printf("ERROR : trying to assign '%s' to '%s' .\n",$<t.type>6,symbol_table[idx].arr_tp);	
		}
	}
    ;
    
    	 
expr: term{
       		$<t.type>$=strdup($<t.type>1);
       		/*if(strcmp($<t.type>1,"integer")==0)$<t.v.ival>$=$<t.v.ival>1;
       		else if(strcmp($<t.type>1,"real")==0)$<t.v.fval>$=$<t.v.fval>1;
       		else if(strcmp($<t.type>1,"boolean")==0)$<t.v.sval>$=$<t.v.sval>1;
       		else if(strcmp($<t.type>1,"char")==0)$<t.v.cval>$=$<t.v.cval>1;	*/		
     }
     | expr EQ term {
     		$<t.type>$=strdup("boolean");
     		if(strcmp($<t.type>1,$<t.type>3)==0){
     			if(strcmp($<t.type>1,"boolean")!=0){
     				//$<t.type>$=strdup("boolean");
	     			/*if(strcmp($<t.type>1,"integer")==0){
	     				if($<t.v.ival>1==$<t.v.ival>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
	     			}
		       		else if(strcmp($<t.type>1,"real")==0){
		       			if($<t.v.fval>1==$<t.v.fval>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
		       		}
		       		else if(strcmp($<t.type>1,"char")==0){
		       			if($<t.v.cval>1==$<t.v.cval>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
		       		}*/
     			}
     			else {printf("ERROR : cannot perform '=' on 'boolean'.\n");}  	
     		}
     		else {printf("ERROR : type mismatch for '=' relop.\n");}   
     }
     | expr NEQ term{
     		$<t.type>$=strdup("boolean");
     		if(strcmp($<t.type>1,$<t.type>3)==0){
     			if(strcmp($<t.type>1,"boolean")!=0){
     				//$<t.type>$=strdup("boolean");
	     			/*if(strcmp($<t.type>1,"integer")==0){
	     				if($<t.v.ival>1 != $<t.v.ival>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
	     			}
		       		else if(strcmp($<t.type>1,"real")==0){
		       			if($<t.v.fval>1 != $<t.v.fval>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
		       		}
		       		else if(strcmp($<t.type>1,"char")==0){
		       			if($<t.v.cval>1 != $<t.v.cval>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
		       		}*/
     			}
     			else {printf("ERROR : cannot perform '<>' on 'boolean'.\n");}  	
     		}
     		else {printf("ERROR : type mismatch for '<>' relop.\n");}   
     }
     | expr LT term{
     		$<t.type>$=strdup("boolean");
     		if(strcmp($<t.type>1,$<t.type>3)==0){
     			if(strcmp($<t.type>1,"boolean")!=0){
     				//$<t.type>$=strdup("boolean");
	     			/*if(strcmp($<t.type>1,"integer")==0){
	     				if($<t.v.ival>1 < $<t.v.ival>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
	     			}
		       		else if(strcmp($<t.type>1,"real")==0){
		       			if($<t.v.fval>1 < $<t.v.fval>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
		       		}
		       		else if(strcmp($<t.type>1,"char")==0){
		       			if($<t.v.cval>1 < $<t.v.cval>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
		       		}*/
     			}
     			else {printf("ERROR : cannot perform '<' on 'boolean'.\n");}  	
     		}
     		else {printf("ERROR : type mismatch for '<' relop.\n");}   
     }
     | expr GT term{
     		$<t.type>$=strdup("boolean");
     		if(strcmp($<t.type>1,$<t.type>3)==0){
     			if(strcmp($<t.type>1,"boolean")!=0){
     				//$<t.type>$=strdup("boolean");
	     			/*if(strcmp($<t.type>1,"integer")==0){
	     				if($<t.v.ival>1 > $<t.v.ival>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
	     			}
		       		else if(strcmp($<t.type>1,"real")==0){
		       			if($<t.v.fval>1 > $<t.v.fval>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
		       		}
		       		else if(strcmp($<t.type>1,"char")==0){
		       			if($<t.v.cval>1 > $<t.v.cval>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
		       		}*/
     			}
     			else {printf("ERROR : cannot perform '>' on 'boolean'.\n");}  	
     		}
     		else {printf("ERROR : type mismatch for '>' relop.\n");}  
     }
     | expr LTE term{
     		$<t.type>$=strdup("boolean");
     		if(strcmp($<t.type>1,$<t.type>3)==0){
     			if(strcmp($<t.type>1,"boolean")!=0){
     				//$<t.type>$=strdup("boolean");
	     			/*if(strcmp($<t.type>1,"integer")==0){
	     				if($<t.v.ival>1 <= $<t.v.ival>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
	     			}
		       		else if(strcmp($<t.type>1,"real")==0){
		       			if($<t.v.fval>1 <= $<t.v.fval>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
		       		}
		       		else if(strcmp($<t.type>1,"char")==0){
		       			if($<t.v.cval>1 <= $<t.v.cval>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
		       		}*/
     			}
     			else {printf("ERROR : cannot perform '<=' on 'boolean'.\n");}  	
     		}
     		else {printf("ERROR : type mismatch for '<=' relop.\n");}//$<t.v.sval>$=strdup("true");}   
     }
     | expr GTE term{
     		$<t.type>$=strdup("boolean");
     		if(strcmp($<t.type>1,$<t.type>3)==0){
     			if(strcmp($<t.type>1,"boolean")!=0){
     				//$<t.type>$=strdup("boolean");
	     			/*if(strcmp($<t.type>1,"integer")==0){
	     				if($<t.v.ival>1 >= $<t.v.ival>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
	     			}
		       		else if(strcmp($<t.type>1,"real")==0){
		       			if($<t.v.fval>1 >= $<t.v.fval>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
		       		}
		       		else if(strcmp($<t.type>1,"char")==0){
		       			if($<t.v.cval>1 >= $<t.v.cval>3)$<t.v.sval>$ = strdup("true");
	     				else $<t.v.sval>$ = strdup("false");
		       		}*/
     			}
     			else {printf("ERROR : cannot perform '>=' on 'boolean'.\n");}  	
     		}
     		else {printf("ERROR : type mismatch for '>=' relop.\n");}   
     }
     | expr OR term{
     		$<t.type>$=strdup("boolean");
     		if(strcmp($<t.type>1,"boolean")==0 && strcmp($<t.type>3,"boolean")==0){
     			//$<t.type>$=strdup("boolean");
     			/*if(strcmp($<t.v.sval>1,"true")==0 || strcmp($<t.v.sval>3,"true")==0)$<t.v.sval>$ = strdup("true");
     			else $<t.v.sval>$ = strdup("false");*/
     		}
     		else {printf("ERROR : type mismatch for 'OR' relop.\n");}
     }
     | expr AND term{
     		$<t.type>$=strdup("boolean");
     		if(strcmp($<t.type>1,"boolean")==0 && strcmp($<t.type>3,"boolean")==0){
     			//$<t.type>$=strdup("boolean");
     			/*if(strcmp($<t.v.sval>1,"true")==0 && strcmp($<t.v.sval>3,"true")==0)$<t.v.sval>$ = strdup("true");
     			else $<t.v.sval>$ = strdup("false");*/
     		}
     		else {printf("ERROR : type mismatch for 'OR' relop.\n");}
     }
     | expr PLUS term{
    		if(is_any_bool_char($<t.type>1,$<t.type>3)==0){
			if(strcmp($<t.type>1,"real")==0 && strcmp($<t.type>3,"real")==0){
				$<t.type>$ = strdup("real");
				$<t.v.fval>$ = $<t.v.fval>1 + $<t.v.fval>3;
			}
			else if(strcmp($<t.type>1,"real")==0 && strcmp($<t.type>3,"integer")==0){
				$<t.type>$ = strdup("real");
				$<t.v.fval>$ = $<t.v.fval>1 + $<t.v.ival>3;
			}
			else if(strcmp($<t.type>1,"integer")==0 && strcmp($<t.type>3,"real")==0){
				$<t.type>$ = strdup("real");
				$<t.v.fval>$ = $<t.v.ival>1 + $<t.v.fval>3;
			}
			else if(strcmp($<t.type>1,"integer")==0 && strcmp($<t.type>3,"integer")==0){
				$<t.type>$ = strdup("integer");
				$<t.v.ival>$ = $<t.v.ival>1 + $<t.v.ival>3;
			} 
		}
    }
    | expr MINUS term{
    		if(is_any_bool_char($<t.type>1,$<t.type>3)==0){
			if(strcmp($<t.type>1,"real")==0 && strcmp($<t.type>3,"real")==0){
				$<t.type>$ = strdup("real");
				//$<t.v.fval>$ = $<t.v.fval>1 - $<t.v.fval>3;
			}
			else if(strcmp($<t.type>1,"real")==0 && strcmp($<t.type>3,"integer")==0){
				$<t.type>$ = strdup("real");
				//$<t.v.fval>$ = $<t.v.fval>1 - $<t.v.ival>3;
			}
			else if(strcmp($<t.type>1,"integer")==0 && strcmp($<t.type>3,"real")==0){
				$<t.type>$ = strdup("real");
				//$<t.v.fval>$ = $<t.v.ival>1 - $<t.v.fval>3;
			}
			else if(strcmp($<t.type>1,"integer")==0 && strcmp($<t.type>3,"integer")==0){
				$<t.type>$ = strdup("integer");
				//$<t.v.ival>$ = $<t.v.ival>1 - $<t.v.ival>3;
			} 
		}
    }
     ;
     

term: term MULT factor{
		if(is_any_bool_char($<t.type>1,$<t.type>3)==0){
			if(strcmp($<t.type>1,"real")==0 && strcmp($<t.type>3,"real")==0){
				$<t.type>$ = strdup("real");
				//$<t.v.fval>$ = $<t.v.fval>1 * $<t.v.fval>3;
			}
			else if(strcmp($<t.type>1,"real")==0 && strcmp($<t.type>3,"integer")==0){
				$<t.type>$ = strdup("real");
				//$<t.v.fval>$ = $<t.v.fval>1 * $<t.v.ival>3;
			}
			else if(strcmp($<t.type>1,"integer")==0 && strcmp($<t.type>3,"real")==0){
				$<t.type>$ = strdup("real");
				//$<t.v.fval>$ = $<t.v.ival>1 * $<t.v.fval>3;
			}
			else if(strcmp($<t.type>1,"integer")==0 && strcmp($<t.type>3,"integer")==0){
				$<t.type>$ = strdup("integer");
				//$<t.v.ival>$ = $<t.v.ival>1 * $<t.v.ival>3;
			} 
		}
		//else $<t.type>$ = strdup($<t.type>3);
		//else not written

	}
    | term DIV factor{
    		if(is_any_bool_char($<t.type>1,$<t.type>3)==0){
    			$<t.type>$ = strdup("real");
			/*if(strcmp($<t.type>1,"real")==0 && strcmp($<t.type>3,"real")==0)$<t.v.fval>$ = $<t.v.fval>1 / $<t.v.fval>3;
			else if(strcmp($<t.type>1,"real")==0 && strcmp($<t.type>3,"integer")==0)$<t.v.fval>$ = $<t.v.fval>1 / (float)$<t.v.ival>3;
			else if(strcmp($<t.type>1,"integer")==0 && strcmp($<t.type>3,"real")==0)$<t.v.fval>$ = (float)$<t.v.ival>1 / $<t.v.fval>3;
			else if(strcmp($<t.type>1,"integer")==0 && strcmp($<t.type>3,"integer")==0)$<t.v.fval>$ = (float)$<t.v.ival>1 / (float)$<t.v.ival>3;*/
		}	
    }
    | term MOD factor{
    		if(is_any_bool_char($<t.type>1,$<t.type>3)==0){
    			if(strcmp($<t.type>1,"real")==0 || strcmp($<t.type>3,"real")==0){
    				printf("ERROR : cannot perform modulo '%%' operation on 'real' datatype.\n");
    			}
    			else{
    				$<t.type>$ = strdup("integer");
    				//$<t.v.ival>$ = $<t.v.ival>1 % $<t.v.ival>3;
    			}
    		}
    }
    | factor{
       		$<t.type>$=strdup($<t.type>1);
       		/*if(strcmp($<t.type>1,"integer")==0)$<t.v.ival>$=$<t.v.ival>1;
       		else if(strcmp($<t.type>1,"real")==0)$<t.v.fval>$=$<t.v.fval>1;
       		else if(strcmp($<t.type>1,"boolean")==0)$<t.v.sval>$=$<t.v.sval>1;
       		else if(strcmp($<t.type>1,"char")==0)$<t.v.cval>$=$<t.v.cval>1;	*/
       }
    ;
     
factor: LPAREN expr RPAREN {
		$<t.type>$=strdup($<t.type>2);
       		/*if(strcmp($<t.type>2,"integer")==0)$<t.v.ival>$=$<t.v.ival>2;
       		else if(strcmp($<t.type>2,"real")==0)$<t.v.fval>$=$<t.v.fval>2;
       		else if(strcmp($<t.type>2,"boolean")==0)$<t.v.sval>$=$<t.v.sval>2;
       		else if(strcmp($<t.type>2,"char")==0)$<t.v.cval>$=$<t.v.cval>2;	*/
	}
       | IDENTIFIER {
       		int ind = search_table($<t.type>1);
       		if(ind==-1) printf("ERROR : undeclared variable '%s' .\n",$<t.type>1);
       		else{
       			$<t.type>$=strdup(symbol_table[ind].tp);
       			if(symbol_table[ind].init==1){
	       			$<t.type>$=strdup(symbol_table[ind].tp);
	       			/*if(strcmp($<t.type>$,"integer")==0)$<t.v.ival>$=symbol_table[ind].vi.ival;
		       		else if(strcmp($<t.type>$,"real")==0)$<t.v.fval>$=symbol_table[ind].vi.fval;
		       		else if(strcmp($<t.type>$,"boolean")==0)$<t.v.sval>$=symbol_table[ind].vi.sval;
		       		else if(strcmp($<t.type>$,"char")==0)$<t.v.cval>$=symbol_table[ind].vi.cval;*/	
	       		}
	       		else{
	       			printf("ERROR : using the variable '%s' before a value is set.\n",$<t.type>1);
	       		}
	       	}
       	}
       | IDENTIFIER LSPAREN term RSPAREN {
       		int ind = array_check_var_int_bound($<t.type>1,$<t.type>3,$<t.v.ival>3);
       		if(ind!=-1){
       			int arr_ind = $<t.v.ival>3;
			$<t.type>$=strdup(symbol_table[ind].arr_tp);
			/*if(strcmp($<t.type>$,"integer")==0)$<t.v.ival>$ = symbol_table[ind].vi.intArray[arr_ind];
			else if(strcmp($<t.type>$,"real")==0)$<t.v.fval>$ = symbol_table[ind].vi.floatArray[arr_ind];
			else if(strcmp($<t.type>$,"char")==0)$<t.v.cval>$ = symbol_table[ind].vi.intArray[arr_ind];
			else if(strcmp($<t.type>$,"boolean")==0)$<t.v.sval>$ = strdup(symbol_table[ind].vi.booleanArray[arr_ind]);*/
       		}
		
       		    
       }
       | const {
       		$<t.type>$=strdup($<t.type>1);
       		/*if(strcmp($<t.type>1,"integer")==0)$<t.v.ival>$=$<t.v.ival>1;
       		else if(strcmp($<t.type>1,"real")==0)$<t.v.fval>$=$<t.v.fval>1;
       		else if(strcmp($<t.type>1,"boolean")==0)$<t.v.sval>$=$<t.v.sval>1;
       		else if(strcmp($<t.type>1,"char")==0)$<t.v.cval>$=$<t.v.cval>1;	*/
       }
       | NOT factor {
       		$<t.type>$=strdup("boolean");
       		if(strcmp($<t.type>2,"boolean")!=0){
     			printf("ERROR : type mismatch for 'NOT' relop.\n");
     		}
       }
	;
const: INTVAL  {$<t.type>$=$<t.type>1;}
     | REALVAL {$<t.type>$=$<t.type>1;}
     | BOOLVAL {$<t.type>$=$<t.type>1;}
     | CHARVAL {$<t.type>$=$<t.type>1;}
     ;
     

   

			
				
conditional_stmt:  IF  expr {is_bool($<t.type>2);} THEN block_stmt if_st
		;
			
if_st: ELSE block_stmt 
   | 
   ;
	
loop: WHILE expr {is_bool($<t.type>2);} DO PROG_BEGIN statement_list END  
    | FOR IDENTIFIER ASSIGN expr {is_int($<t.type>4);} TO expr {is_int($<t.type>6);} DO PROG_BEGIN statement_list END 
    | FOR IDENTIFIER ASSIGN expr {is_int($<t.type>4);} DOWNTO expr {is_int($<t.type>6);} DO PROG_BEGIN statement_list END 
    ;


	
%%


void main(){
	yyin=fopen("input.txt","r");
	yyparse();
	//display_stable();
	exit(0);
}

void yyerror(){
	printf("Syntax error..\n");
	exit(0);
}

