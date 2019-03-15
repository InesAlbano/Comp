%option debug
%{
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "node.h"
#include "y.tab.h"
void  yyerror(char *s);
char* dupstr(const char *s);
%}

SPC [ \t\n\r]+;
%x  COM STR DS

%%
"-"	        return SUB;
"+"	        return ADD;
"*"	        return MUL;
"/"	        return DIV;
"%"	        return MOD;
"<"	        return LESS;
">"	        return GREATER;
"="	        return EQUAL;
">="	      return LE;
"<="	      return GE;
"<>"	      return DIF;
":="	      return ATRIBUTE;
"++"	      return ; /*TODO*/
"--"	      return ; /*TODO*/
"!"	        return ; /*TODO*/
"|"	        return OR;
"&"	        return AND;
"~"         return NEG;
"void"      return VOID;
"integer"   return INTEGER;
"string"    return STRING;
"public"    return PUBLIC;
"number"    return NUMBER;
"const"     return CONST;
"if"        return IF;
"then"      return THEN;
"else"      return ELSE;
"while"     return WHILE;
"do"        return DO;
"for"       return FOR;
"in"        return IN;
"step"      return STEP;
"upto"      return UPTO;
"downto"    return DOWNTO;
"break"     return BREAK;
"continue"  return CONTINUE;
"for"			  return FOR;

  /*Strings*/
([A-Za-z][A-Za-z0-9]*)|([A-Za-z]_) yylval.s = dupstr(yytext); return NAME;

  /*Literals*/ /*correct?*/
 /* base 10? */
([1-9]+[0-9]*)|("-"[1-9]+[0-9]*)   {errno = 0; yylval.i = strtol(yytext, 0, 0);
                                   if(errno == ERANGE)   yyerror("decimal overflow");
                                   return CTE; }
 /* base 8? */
0[0-9]*        {errno = 0; yylval.i = strtol(yytext, 0, 0);
               if(errno == ERANGE)   yyerror("octal overflow");
               return CTE; }
 /* base 2? */
0b[01]+        {errno = 0; yylval.i = strtol(yytext, 0, 0);
               if(errno == ERANGE)   yyerror("binary overflow");
               return CTE; }

 /* Floating Point */
([0-9]+\.[0-9]*)|([0-9]+\.[0-9]*e["+""-"][0-9]*) return FP;


 /*Delimitadores de texto*/
[#{}()[];,]              return *yytext;

 /* Strings */
\"			                 BEGIN STR;
<STR>\"			             BEGIN 0; return STRING;
<STR>"HR"		             strcat(yylval.s, "\n");
<STR>"CR"		             strcat(yylval.s, "\r");
<STR>"HT"		             strcat(yylval.s, "\t");
<STR>"\""		             strcat(yylval.s, """);/*correct?*/
<STR>(\\[0-9a-fA-F])|(\\[0-9a-fA-F][0-9a-fA-F]) strcat(yylval.s, yytext+1); /*?*/
<STR>.|\n		             strcat(yylval.s, yytext);

"=<"        BEGIN COM
<COM> "=>"  BEGIN 0;
<COM> .|\n  ;

"==".*$     ;

SPC         ;
.           yyerror("Unknown character");

%%
int yywrap(void) { return 1; }
char *getyytext() { return yytext; }
