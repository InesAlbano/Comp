%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "node.h"
#include "tabid.h"
extern int yylex();
void yyerror(char *s);
%}

%union {
	int i;			/* integer value */
	double d;
	char*  s;
};

%token <i> INT
%token <d> FP
%token <s> NAME
%token VOID INTEGER STRING PUBLIC NUMBER CONST IF THEN ELSE WHILE DO IN STEP UPTO DOWNTO BREAK CONTINUE FOR
%token LE GE DIF ATRIBUTE INC DEC


%%
file	:
	;
%%
char **yynames =
#if YYDEBUG > 0
		 (char**)yyname;
#else
		 0;
#endif
