%{
  #ifndef SCANNER_H
  #define SCANNER_H
  #include <string.h>
  #include "y.tab.h"

%}

sym [\+\-\*\/\!\<\>\(\)\[\]\{\}=;\,]
str \"([^"]|\\\")*\"
id [a-zA-Z0-9_]+
num [0-9]+
comment (\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/)|(\/\/.*)

%%

{sym} { return (int)yytext[0]; }
{num} { yylval.num1_val = atoi(yytext); return NUM; }
{str} {
  for (int i = 0; i < yyleng - 1; ++i) {
    yytext[i] = yytext[i + 1];
  }
  yytext[yyleng - 2] = '\0';
  yyleng = yyleng - 2;
  for (int i = 0; i < yyleng; ++i) {
    if (yytext[i] == '\\' &&
       (yytext[i + 1] == '\\' || yytext[i + 1] == '\"')) {
      for (int j = i; j < yyleng; ++j) {
        yytext[j] = yytext[j + 1];
      }
    }
  }
  yyleng = strlen(yytext);

  strcpy(yylval.str16_val, yytext);
  return STR;
}
{comment} {}

&& { strcpy(yylval.str0_val, yytext); return LOGICAL_AND; }
\|\| { strcpy(yylval.str1_val, yytext); return LOGICAL_OR; }
\<= { strcpy(yylval.str2_val, yytext); return LESS_OR_EQ; }
\>= { strcpy(yylval.str3_val, yytext); return MORE_OR_EQ; }
== { strcpy(yylval.str4_val, yytext); return EQ; }
\!= { strcpy(yylval.str5_val, yytext); return NOT_EQ; }
int { strcpy(yylval.str6_val, yytext); return INT; }
if { strcpy(yylval.str7_val, yytext); return IF; }
else { strcpy(yylval.str8_val, yytext); return ELSE; }
while { strcpy(yylval.str9_val, yytext); return WHILE; }
break { strcpy(yylval.str10_val, yytext); return BREAK; }
continue { strcpy(yylval.str11_val, yytext); return CONTINUE; }
scan { strcpy(yylval.str12_val, yytext); return SCAN; }
print { strcpy(yylval.str13_val, yytext); return PRINT; }
println { strcpy(yylval.str14_val, yytext); return PRINTLN; }
{id} { strcpy(yylval.str15_val, yytext); return ID; }

%%

#endif
