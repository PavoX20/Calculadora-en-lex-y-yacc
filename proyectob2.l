%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <math.h>
#include "y.tab.h"

float romanoADecimal(char cadena[]);
float binarioADecimal(char binario[]);
float octalADecimal(char octal[]);
float hexadecimalADecimal(char hexa[]);
void stringToUpper(char s[]);
int find(char c[], char target);

%}

WS 		[ \t]+
agrupacionA	"("|"{"|"("|"<"|"["
agrupacionC	")"|"}"|")"|">"|"]"
DIGITO		[0-9]
romano		(i|I){1,3}|(v|V)|(x|X){1,3}|(l|L)|(c|C){1,3}|(d|D)|(m|M){1,3}|(p|P)|(t|T){1,3}
binario	(b|B)(0|1){1,14}
octal		(o|O)[0-7]{1,5}
hexadecimal	(h|H)[0-9A-Fa-f]{1,4}
ID		[a-zA-Z][a-zA-Z0-9]*

%%
"="				{return(TKN_ASIGN);}
";"				{return(TKN_PTOCOMA);}
{agrupacionA}	{printf("Símbolo de agrupación (abrir) \"%s\"\n", yytext);
return(TKN_PAA);}
{agrupacionC}	{printf("Símbolo de agrupación (cerrar) \"%s\"\n", yytext);
return(TKN_PAC);}
"+" 	{printf("Operador Aritmético: Suma \"%s\"\n", yytext);
return(TKN_MAS);}
"-" 	{printf("Operador Aritmético: Resta \"%s\"\n", yytext);
return(TKN_MENOS);}
"*" 	{printf("Operador Aritmético: Multiplicación \"%s\"\n", yytext);
return(TKN_MULT);}
"/" 	{printf("Operador Aritmético: División \"%s\"\n", yytext);
return(TKN_DIV);}
"^"	{printf("Operador Aritmético: Potencia \"%s\"\n", yytext);
return(TKN_POW);}
{romano}+	{ printf("Número romano: \"%s\", su correspondiente en decimal es %5.2f\n", yytext, romanoADecimal(yytext)); 
yylval.real=romanoADecimal(yytext); return(TKN_NUM);}
{DIGITO}+("."{DIGITO}+)?	{ printf("Número decimal: \"%s\"\n", yytext); 
		  yylval.real=atof(yytext); return(TKN_NUM); }
{binario}+	{ printf("Número binario: \"%s\", su correspondiente en decimal es %5.2f\n", yytext, binarioADecimal(yytext));
yylval.real=binarioADecimal(yytext); return(TKN_NUM); }
{octal}+	{ printf("Número octal: \"%s\", su correspondiente en decimal es %5.2f\n", yytext, octalADecimal(yytext)); 
yylval.real=octalADecimal(yytext); return(TKN_NUM); }
{hexadecimal}+	{ printf("Número hexadecimal: \"%s\", su correspondiente en decimal es %5.2f\n", yytext, hexadecimalADecimal(yytext)); 
yylval.real=hexadecimalADecimal(yytext); return(TKN_NUM); }

"sqrt"		{ printf("Operador Aritmético: Radicación \"%s\"\n", yytext); 
return(TKN_SQRT); }
"cos"		{ printf("Función Trigonométrica: Coseno \"%s\"\n", yytext);
return(TKN_COS);}
"sen"		{ printf("Función Trigonométrica: Seno \"%s\"\n", yytext);
return(TKN_SEN);}
"tan"		{ printf("Función Trigonométrica: Tangente \"%s\"\n", yytext);
return(TKN_TAN);}
"ln"		{ printf("Función logarítmica natural \"%s\"\n", yytext);
return(TKN_LOG);}
"exp"		{ printf("Función exponencial \"%s\"\n", yytext);
return(TKN_EXP);}

{ID}		{ printf("\n\t\t-*Análisis de la expresión*-\n");
return(TKN_ID);}
.	ECHO;

%%
float romanoADecimal(char cadena[]){
    float valor[] = {10000,5000, 1000, 500, 100, 50, 10, 5, 1}; //Definimos T=10000 y P=5000
    char simbolo[] = "TPMDCLXVI";
    stringToUpper(cadena);
    char c;
    float resultado=0, ultimovalor=0;
    int i=0,j=0;
    bool valido=true;
   
    while(valido && (i < strlen(cadena)))
    {
        c = cadena[i];
        j = find(simbolo, c);
        if(j>=0)
        {
            resultado += valor[j];
          
            if(valor[j] > ultimovalor)
            {
                resultado -= 2 * ultimovalor;
            }
            
            ultimovalor = valor[j];
        }
        else
        {
            valido = false;
            resultado = -1;
        }
        i++;
    }
    return resultado;
}

float binarioADecimal(char binario[]){
    float decimal = 0;
    for(int i = strlen(binario)-1; i>=1; i--){
        float num = binario[i] - '0';
        decimal += num*pow(2,(strlen(binario)-1)-i);
    }
    return decimal;
}

float octalADecimal(char octal[]){
    float decimal = 0;
    for(int i = strlen(octal)-1; i>=1; i--){
        float num = octal[i] - '0';
        decimal += num*pow(8,(strlen(octal)-1)-i);
    }
    return decimal;
}

float hexadecimalADecimal(char hexa[]){
    char letras[] = "ABCDEF";
    stringToUpper(hexa);
    float decimal = 0;
    for(int i = strlen(hexa)-1; i>=1; i--){
        if(hexa[i] == 'A' || hexa[i] == 'B' || hexa[i] == 'C' || hexa[i] == 'D' || hexa[i] == 'E' || hexa[i] == 'F'){
            int aux = find(letras, hexa[i]);
            decimal += (aux + 10)*pow(16,(strlen(hexa)-1)-i);
        }
        else{
            int num = hexa[i] - '0';
            decimal += num*pow(16,(strlen(hexa)-1)-i);
        }
        
    }
    return decimal;
}

void stringToUpper(char s[])
{
    for(int i=0; i<strlen(s);i++)
        s[i] = toupper(s[i]);
}

int find(char c[], char target){
    int pos;
    bool found = false;
    int i=0;
    do{
        if(c[i]==target){
            pos = i;
            found = true;
        }
        i++;
    }
    while(found == false && i<strlen(c));
    return pos;
}
