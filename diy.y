%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "node.h"
#include "tabid.h"
#ifndef YYERRCODE
#define YYERRCODE 256
#endif

#define YYDEBUG 1

extern int yylex();
extern void* yyin;
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
%token LE GE DIF ASSIGN INC DEC SC


%%
start:;
%%

int main(int argc, char *argv[]) {
	yyin = fopen(argv[1], "r");
	extern YYSTYPE yylval;
	int tk;

	while ((tk = yylex()))
		if (tk > YYERRCODE){
			printf("%d:\t%s\n", tk, yyname[tk]);
		}
		else
			printf("%d:\t%c\n", tk, tk);
	return 0;
}
