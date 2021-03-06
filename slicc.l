%{

#include <stdio.h>
#include <string.h>
#include "y.tab.h"

#define DEBUG 0
#define RET_TOKEN(x) if(DEBUG) printf(#x ": '%s'\n", yytext); return x;
#define PRINT_TOKEN_IF(x, y) if(DEBUG > y) printf(#x ": '%s'\n", yytext);
#define PRINT_TOKEN(x) PRINT_TOKEN_IF(x, 1)

char linebuf[1024];

%}

%%

[aA][lL][gG][oO][rR][iI][tT][hH][mM]  { RET_TOKEN(ALGORITHM); }
[cC][oO][uU][nN][tT][iI][nN][gG]      { RET_TOKEN(COUNTING); }
[dD][aA][tT][aA]                      { RET_TOKEN(DATA); }
[dD][oO][wW][nN][wW][aA][rR][dD]      { RET_TOKEN(DOWNWARD); }
[eE][lL][sS][eE]                      { RET_TOKEN(ELSE); }
[eE][nN][dD]                          { RET_TOKEN(END); }
[eE][xX][iI][tT]                      { RET_TOKEN(EXIT); }
[iI][fF]                              { RET_TOKEN(IF); }
[iI][nN][tT][eE][gG][eE][rR]          { RET_TOKEN(INT); }
[mM][aA][iI][nN]                      { RET_TOKEN(MAIN); }
[pP][rR][iI][nN][tT]                  { RET_TOKEN(PRINT); }
[rR][eE][aA][dD]                      { RET_TOKEN(READ); }
[rR][eE][aA][lL]                      { RET_TOKEN(REAL); }
[tT][oO]                              { RET_TOKEN(TO); }
[uU][pP][wW][aA][rR][dD]              { RET_TOKEN(UPWARD); }
[wW][hH][iI][lL][eE]                  { RET_TOKEN(WHILE); }

"!"                                   { RET_TOKEN(BANG); }
":"                                   { RET_TOKEN(COLON); }
","                                   { RET_TOKEN(COMMA); }
#.*$                                  { PRINT_TOKEN(COMMENT); }
"["                                   { RET_TOKEN(LBRACKET); }
"("                                   { RET_TOKEN(LPAREN); }
"]"                                   { RET_TOKEN(RBRACKET); }
")"                                   { RET_TOKEN(RPAREN); }
";"                                   { RET_TOKEN(SEMI); }

"+"                                   { RET_TOKEN(ADD); }
"&"                                   { RET_TOKEN(AND); }
":="                                  { RET_TOKEN(ASSIGN); }
"/"                                   { RET_TOKEN(DIV); }
"%"                                   { RET_TOKEN(MOD); }
"*"                                   { RET_TOKEN(MUL); }
"~"                                   { RET_TOKEN(NOT); }
"|"                                   { RET_TOKEN(OR); }
"-"                                   { RET_TOKEN(SUB); }

"="                                   { RET_TOKEN(EQ); }
">="                                  { RET_TOKEN(GTE); }
">"                                   { RET_TOKEN(GT); }
"<="                                  { RET_TOKEN(LTE); }
"<"                                   { RET_TOKEN(LT); }
"<>"                                  { RET_TOKEN(NEQ); }

[0-9]*                                {
                                        yylval.d = atoi(yytext);
                                        RET_TOKEN(INTLIT);
                                      }
([0-9]+\.[0-9]+([eE][+-]?[1-9][0-9]*)?|[1-9][0-9]*[eE][+-]?[1-9][0-9]*) {
                                                                          yylval.f = atof(yytext);
                                                                          RET_TOKEN(REALLIT);
                                                                        }
\"([^\n\r\"]|\"\")*\"                 {
                                        char* nyytext = yytext;
                                        nyytext++;

                                        int len = strlen(nyytext);

                                        yylval.str = strdup(yytext);

                                        strncpy(yylval.str, nyytext, len-1);
                                        yylval.str[len-1] = '\0';

                                        RET_TOKEN(STRINGLIT);
                                      }
[a-zA-Z][a-zA-Z0-9]*                  {
                                        yylval.str = strdup(yytext);
                                        RET_TOKEN(VARIABLE);
                                      }

[ \t]+                                { PRINT_TOKEN(BLANK); }
(\n|\r).*                             {
                                        strncpy(linebuf, yytext+1, sizeof(linebuf));
                                        yylineno++;
                                        yyless(1);
                                        PRINT_TOKEN(NL);
                                      }
.                                     { RET_TOKEN(UNKOWN); }

%%
