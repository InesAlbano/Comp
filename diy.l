%option stack
%{
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "node.h"
#include "y.tab.h"
int   yyerror(char *s)     { printf("%s\n",s); return 1; }
char *dupstr(const char*s) { return strdup(s); }
int flagSC = 0;

void trueOctal(char* octal){
  int len = 0;

  len = strlen(octal);

  for (int i = len-1; i > -1; --i){
    if (octal[i] > '7'){
      octal[i] -= 8;
      octal[i-1]++;
    }
  }
}

%}
%x COM STR
%%
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
">="	      return LE;
"<="	      return GE;
"<>"	      return DIF;
":="	      return ASSIGN;
"++"	      return INC;
"--"	      return DEC;
";"         return SC;

\"[.\n]*[^\\]\"	yylval.s = malloc(yyleng); *yylval.s = 0; REJECT;

([A-Za-z][A-Za-z0-9]*)|([A-Za-z]_) {flagSC = 1; yylval.s = dupstr(yytext); return NAME;}

-?[1-9]+[0-9]* {errno = 0; flagSC = 1; yylval.i = strtol(yytext, 0, 10);
                if(errno == ERANGE)   yyerror("decimal overflow");
                return INT; }
0[0-9]*        {errno = 0; flagSC = 1; trueOctal(yytext); yylval.i = strtol(yytext, 0, 8);
                if(errno == ERANGE)   yyerror("octal overflow");
                return INT; }
0b[01]+        {errno = 0; flagSC = 1; yylval.i = strtol(yytext+2, 0, 2);
                if(errno == ERANGE)   yyerror("binary overflow");
                return INT; }

([0-9]+\.[0-9]*)|([0-9]+\.[0-9]*[Ee][+-]?[0-9]*) {errno = 0; flagSC = 1; yylval.d = strtod(yytext, 0);
                                                  if(errno == ERANGE)   yyerror("floating point overflow");
                                                  return FP; }
\! {flagSC = 1; return *yytext;}
\) {flagSC = 1; return *yytext;}
[-+*/%&|~^<>(?:;,\[\]{}#=]	return *yytext;

\"			                 yylval.s = dupstr(yytext+1); yy_push_state(STR);
<STR>\"			             {flagSC = 1; yy_pop_state(); return STRING;}
<STR>"\0"			           ;
<STR>\\n		             strcat(yylval.s, "\n");
<STR>\\r		             strcat(yylval.s, "\r");
<STR>\\t		             strcat(yylval.s, "\t");
<STR>\\\"		             strcat(yylval.s, "\"");
<STR>(\\[0-9A-Fa-f])|(\\[0-9A-Fa-f][0-9A-Fa-fA-F]) {char aux = (char)strtol(yytext+1, 0, 16); strncat(yylval.s, &aux, 1);}
<STR>.		               strcat(yylval.s, yytext);

"=<"       yy_push_state(COM);
<COM>"=<"  yy_push_state(COM);
<COM>"=>"  yy_pop_state();

\n          {if(flagSC == 1){flagSC = 0; return SC;}}
[^ \t\n\r]  {if(flagSC == 1){flagSC = 0; return *yytext;}}

<COM>.|\n  ;

"==".*\n   ;

[ \t\r]+ ;

%%
int yywrap(void)  { return 1; }
char *getyytext() { return yytext; }
