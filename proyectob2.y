%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
extern int yylex(void);
extern char *yytext;
extern int nlines;
extern FILE *yyin;
void yyerror(char *s);
FILE * fsalida;
char* itoa (unsigned long long  value,  char str[],  int radix);
void decimalARomano(char cadena[], float x);
%}
%union
{
	float real;
}
%start Calculadora
%token <real> TKN_NUM
%token TKN_ASIGN
%token TKN_PTOCOMA
%token TKN_MULT
%token TKN_DIV
%token TKN_MAS
%token TKN_MENOS
%token TKN_PAA
%token TKN_PAC
%token TKN_POW
%token TKN_SQRT
%token TKN_COS
%token TKN_SEN
%token TKN_TAN
%token TKN_LOG
%token TKN_EXP
%token <real> TKN_ID
%type Calculadora
%type <real> Expresion
%left TKN_MAS TKN_MENOS
%left TKN_MULT TKN_DIV
%right TKN_POW
%%
Calculadora:	Expresion TKN_PTOCOMA {
		fprintf(fsalida,"Valor indefinido\n");
		}|
		TKN_ID {}
		TKN_ASIGN Expresion TKN_PTOCOMA {
		printf("\nEl valor de la expresión aritmética en los siguientes formatos, es:\nDecimal 	-> %5.2f", $4);
		float decimal = $4;
		char bin[63];
		char octal[63];
		char hexa[63];
		char romano[63]="";
		itoa(decimal, bin, 2);
		printf("\nBinario 	-> %s", bin);
		itoa(decimal, octal, 8);
		printf("\nOctal 		-> %s", octal);
		itoa(decimal, hexa, 16);
		printf("\nHexadecimal 	-> %s", hexa);
		decimalARomano(romano,decimal);
		printf("\nRomano		-> %s", romano);
		};
Expresion:	TKN_NUM {$$=$1;} |
		Expresion TKN_MAS Expresion	{$$=$1+$3;} |
		Expresion TKN_MENOS Expresion	{$$=$1-$3;} |
		Expresion TKN_MULT Expresion	{$$=$1*$3;} |
		Expresion TKN_DIV Expresion	{$$=$1/$3;} |
		Expresion TKN_POW Expresion	{$$=pow($1,$3);} |
		TKN_PAA Expresion TKN_PAC	{$$=$2;}|
		TKN_SQRT TKN_PAA Expresion TKN_PAC	{$$=sqrt($3);}|
		TKN_COS TKN_PAA Expresion TKN_PAC	{$$=cos($3);}|
		TKN_SEN TKN_PAA Expresion TKN_PAC	{$$=sin($3);}|
		TKN_TAN TKN_PAA Expresion TKN_PAC	{$$=tan($3);}|
		TKN_LOG TKN_PAA Expresion TKN_PAC	{$$=log($3);}|
		TKN_EXP TKN_PAA Expresion TKN_PAC	{$$=exp($3);};
%%
void yyerror(char *s){
	printf("\nError %s", s);
}

int main(int argc, char **argv){
	printf("\nIngrese una expresión aritmética mixta:\n");
	if(argc>2){
		yyin=fopen(argv[1], "rt");
		fsalida = fopen(argv[2],"w");
	}
	else
		yyin=stdin;	
	yyparse();
	printf("\nFin del análisis de la expresión aritmética mixta.\n");
	return 0;
}

char* itoa (unsigned long long  value,  char str[],  int radix)
{
    char        buf [66];
    char*       dest = buf + sizeof(buf);
    bool     sign = false;
    
    if (value == 0) {
        memcpy (str, "0", 2);
        return str;
    }

    if (radix < 0) {
        radix = -radix;
        if ( (long long) value < 0) {
            value = -value;
            sign = true;
        }
    }

    *--dest = '\0';

    switch (radix)
    {
    case 16:
        while (value) {
            * --dest = '0' + (value & 0xF);
            if (*dest > '9') *dest += 'A' - '9' - 1;
            value >>= 4;
        }
        break;
    case 10:
        while (value) {
            *--dest = '0' + (value % 10);
            value /= 10;
        }
        break;

    case 8:
        while (value) {
            *--dest = '0' + (value & 7);
            value >>= 3;
        }
        break;

    case 2:
        while (value) {
            *--dest = '0' + (value & 1);
            value >>= 1;
        }
        break;

    default:            // The slow version, but universal
        while (value) {
            *--dest = '0' + (value % radix);
            if (*dest > '9') *dest += 'A' - '9' - 1;
            value /= radix;
        }
        break;
    }

    if (sign) *--dest = '-';

    memcpy (str, dest, buf +sizeof(buf) - dest);
    return str;
}

void decimalARomano(char cadena[], float x){
    char simbolos[17][3] = {"T","MT","P","MP","M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"};
    float valores[] = {10000, 9000, 5000, 4000, 1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1};
    if(x<0){
    	x=-x;
    	strcat(cadena,"-");
    }
    for(int i = 0; i < 17; ++i) {
        while(x >= valores[i]) {
            strcat(cadena,simbolos[i]);
            x -= valores[i];
        }
    }    	
}
//Cadena a probar:{d-(M/C/L*b100)^o2+[sqrt(mMm/cCc*10)*H2]/h5+<hAfB+(MMXLVIII/512*IiI)>+666}
