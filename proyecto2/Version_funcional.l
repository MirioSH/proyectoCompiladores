%{
/* 
* OBJETIVO: Construir un analizador Sintáctico Descendente Recursivo    
*
* INTEGRANTES:
* - Soto Huerta Gustavo Isaac
* - Peña Rodríguez Eduardo
* - Guerrero Gutiérrez Héctor
* FECHA: 2024
*/

// Incluimos las librerías necesarias
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>

// Declaración de variables globales y estructuras
char cadenaAtomos[99999] = "";
char next_atomo;
int n = 0;
int numSimbolos = 0, numLitCad = 0, numLitNum = 0, numTokens = 0;

// Estructuras
typedef struct {
    int valor;
    char palabra[100];
} PalRes;

typedef struct {
    int valor;
    char op[100];
} Operadores;

typedef struct {
    int posicion;
    char nombre[100];
    int tipo;
} TablaSimbolos;

typedef struct {
    int posicion;
    char dato[100];
} TablaLiterales;

typedef struct {
    int clase;
    char valor[100];
    char info[100];
    char atomo;
} TokenInfo;

// Declaración de arreglos
TablaSimbolos tablaSimbolos[99999];
TablaLiterales tablaLiteralesCadenas[99999];
TablaLiterales tablaLiteralesNumericas[99999];
TokenInfo tokens[99999];
PalRes catalogoRes[17];
Operadores catalogoOp[13];

extern FILE* yyin;
extern char* yytext;

// Declaración de funciones
int Palabras_res(char* pal);
int Operadores_rel(char* Op);
int Operadores_asig(char* Op);

int posTabSimb(char* nombre);
int posTabLitCads(char* dato);
int posTabLitNum(char* dato);

int buscaTabSimb(char* nombre);
int buscaTabLitCads(char* dato);
int buscaTabLitNum(char* dato);

char asignarAtomoPalRes(char *palabra);
char asignarAtomoSimEspe(const char* yytext);
char asignarAtomoOpArit(const char* yytext);
char asignarAtomoOpRel(const char* yytext);
char asignarAtomoOpAsig(const char* yytext);

void Program();
void otraFunc();
void Func();
void Tipo();
void Param();
void Cuerpo();
void Decl();
void D();
void K();
void N();
void C();
void listaP();
void P();
void I();
void J();
void W();
void Devuelve();
void Llama();
void arg();
void otroArg();
void V();
void R();
void RP();
void Y();
void X();
void Z();
void E();

%}

%option noyywrap

%%

"cadena"|"caracter"|"else"|"entero"|"for"|"if"|"do"|"real"|"return"|"void"|"while" {
    printf("[Clase 0] Palabra reservada: %s\n", yytext);
    int val = Palabras_res(yytext);
    char cadena[20];
    tokens[numTokens].clase = 0;
    sprintf(cadena, "%d", val);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = asignarAtomoPalRes(yytext);
    char atomo_str[2] = { tokens[numTokens].atomo, '\0' };
    strcat(cadenaAtomos, atomo_str);
    numTokens++;
}

"+"|"-"|"*"|"/"|"\\$" {
    printf("[Clase 1] Operador aritmético: %s\n", yytext);
    tokens[numTokens].clase = 1;
    strcpy(tokens[numTokens].valor, yytext);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = asignarAtomoOpArit(yytext);
    char atomo_str[2] = { tokens[numTokens].atomo, '\0' };
    strcat(cadenaAtomos, atomo_str);
    numTokens++;
}

"~"|"\\+~"|"\\-~"|"\\*~"|"/~"|"\\$~" {
    printf("[Clase 2] Operador de asignación: %s\n", yytext);
    int val = Operadores_asig(yytext);
    char cadena[20];
    tokens[numTokens].clase = 2;
    sprintf(cadena, "%d", val);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = asignarAtomoOpAsig(yytext);
    char atomo_str[2] = { tokens[numTokens].atomo, '\0' };
    strcat(cadenaAtomos, atomo_str);
    numTokens++;
}

"("|")"|"{"|"}"|"["|"]"|"&"|","|":" {
    printf("[Clase 3] Símbolo especial: %s\n", yytext);
    tokens[numTokens].clase = 3;
    strcpy(tokens[numTokens].valor, yytext);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = asignarAtomoSimEspe(yytext);
    char atomo_str[2] = { tokens[numTokens].atomo, '\0' };
    strcat(cadenaAtomos, atomo_str);
    numTokens++;
}

"\\^\\^"|"\\^\""|"=="|"\\^\\^="|"\\^\"="|"<>" {
    printf("[Clase 4] Operador relacional: %s\n", yytext);
    int val = Operadores_rel(yytext);
    char cadena[20];
    tokens[numTokens].clase = 4;
    sprintf(cadena, "%d", val);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = asignarAtomoOpRel(yytext);
    char atomo_str[2] = { tokens[numTokens].atomo, '\0' };
    strcat(cadenaAtomos, atomo_str);
    numTokens++;
}

[A-Za-z][A-Za-z0-9_]{0,5} {
    printf("[Clase 5] Identificador válido: %s\n", yytext);
    int pos = buscaTabSimb(yytext);
    char cadena[20];
    if (pos == -1) {
        tablaSimbolos[numSimbolos].posicion = numSimbolos + 1;
        strcpy(tablaSimbolos[numSimbolos].nombre, yytext);
        tablaSimbolos[numSimbolos].tipo = -1;
        pos = numSimbolos;
        numSimbolos++;
    }
    tokens[numTokens].clase = 5;
    sprintf(cadena, "%d", tablaSimbolos[pos].posicion);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = 'i';
    char atomo_str[2] = { tokens[numTokens].atomo, '\0' };
    strcat(cadenaAtomos, atomo_str);
    numTokens++;
}

[+-]?[0-9]{1,6} {
    printf("[Clase 6] Constante numérica válida: %s\n", yytext);
    int pos = buscaTabLitNum(yytext);
    char cadena[20];
    if (pos == -1) {
        tablaLiteralesNumericas[numLitNum].posicion = numLitNum + 1;
        strcpy(tablaLiteralesNumericas[numLitNum].dato, yytext);
        numLitNum++;
    }
    tokens[numTokens].clase = 6;
    int val = posTabLitNum(yytext);
    sprintf(cadena, "%d", val);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = 'z';
    char atomo_str[2] = { tokens[numTokens].atomo, '\0' };
    strcat(cadenaAtomos, atomo_str);
    numTokens++;
}

([0-9]+\.[0-9]+|\.[0-9]+|[0-9]+\.) {
    printf("[Clase 7] Constante decimal válida: %s\n", yytext);
    int pos = buscaTabLitNum(yytext);
    char cadena[20];
    if (pos == -1) {
        tablaLiteralesNumericas[numLitNum].posicion = numLitNum + 1;
        strcpy(tablaLiteralesNumericas[numLitNum].dato, yytext);
        numLitNum++;
    }
    tokens[numTokens].clase = 7;
    int val = posTabLitNum(yytext);
    sprintf(cadena, "%d", val);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = 'r';
    char atomo_str[2] = { tokens[numTokens].atomo, '\0' };
    strcat(cadenaAtomos, atomo_str);
    numTokens++;
}

\"[^\"]{1,38}\" {
    printf("[Clase 8] Cadena válida: %s\n", yytext);
    int pos = buscaTabLitCads(yytext);
    char cadena[20];
    if (pos == -1) {
        tablaLiteralesCadenas[numLitCad].posicion = numLitCad + 1;
        strcpy(tablaLiteralesCadenas[numLitCad].dato, yytext);
        numLitCad++;
    }
    tokens[numTokens].clase = 8;
    int val = posTabLitCads(yytext);
    sprintf(cadena, "%d", val);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = 's';
    char atomo_str[2] = { tokens[numTokens].atomo, '\0' };
    strcat(cadenaAtomos, atomo_str);
    numTokens++;
}

\'.\' {
    printf("[Clase 9] Carácter válido: %s\n", yytext);
    tokens[numTokens].clase = 9;
    strcpy(tokens[numTokens].valor, yytext);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = 'c';
    char atomo_str[2] = { tokens[numTokens].atomo, '\0' };
    strcat(cadenaAtomos, atomo_str);
    numTokens++;
}

[ \t\n]+    ; // Ignora espacios, tabuladores y saltos de línea

. {
    fprintf(stderr, "No se reconoce el carácter (%s)\n", yytext);
}

%%

// Implementación de funciones

int Palabras_res(char* pal) {
    // Inicializamos el catálogo si no está inicializado
    static bool inicializado = false;
    if (!inicializado) {
        const char* palabras[] = { "cadena", "caracter", "else", "entero", "for", "if", "do", "real", "return", "void", "while" };
        for (int i = 0; i < 11; i++) {
            catalogoRes[i].valor = i;
            strcpy(catalogoRes[i].palabra, palabras[i]);
        }
        inicializado = true;
    }

    for (int i = 0; i < 11; i++) {
        if (strcmp(pal, catalogoRes[i].palabra) == 0) {
            return catalogoRes[i].valor;
        }
    }
    return -1;
}

int Operadores_rel(char* Op) {
    static bool inicializado = false;
    if (!inicializado) {
        const char* ops[] = { "^^", "^\"", "==", "^^=", "^\"=", "<>" };
        for (int i = 0; i < 6; i++) {
            catalogoOp[i].valor = i;
            strcpy(catalogoOp[i].op, ops[i]);
        }
        inicializado = true;
    }

    for (int i = 0; i < 6; i++) {
        if (strcmp(Op, catalogoOp[i].op) == 0) {
            return catalogoOp[i].valor;
        }
    }
    return -1;
}

int Operadores_asig(char* Op) {
    static bool inicializado = false;
    if (!inicializado) {
        const char* ops[] = { "~", "+~", "-~", "*~", "/~", "$~" };
        for (int i = 0; i < 6; i++) {
            catalogoOp[i + 6].valor = i + 6;
            strcpy(catalogoOp[i + 6].op, ops[i]);
        }
        inicializado = true;
    }

    for (int i = 6; i < 12; i++) {
        if (strcmp(Op, catalogoOp[i].op) == 0) {
            return catalogoOp[i].valor;
        }
    }
    return -1;
}

int posTabSimb(char* nombre) {
    for (int i = 0; i < numSimbolos; i++) {
        if (strcmp(tablaSimbolos[i].nombre, nombre) == 0) {
            return tablaSimbolos[i].posicion;
        }
    }
    return -1;
}

int posTabLitCads(char* dato) {
    for (int i = 0; i < numLitCad; i++) {
        if (strcmp(tablaLiteralesCadenas[i].dato, dato) == 0) {
            return tablaLiteralesCadenas[i].posicion;
        }
    }
    return -1;
}

int posTabLitNum(char* dato) {
    for (int i = 0; i < numLitNum; i++) {
        if (strcmp(tablaLiteralesNumericas[i].dato, dato) == 0) {
            return tablaLiteralesNumericas[i].posicion;
        }
    }
    return -1;
}

int buscaTabSimb(char* nombre) {
    for (int i = 0; i < numSimbolos; i++) {
        if (strcmp(tablaSimbolos[i].nombre, nombre) == 0) {
            return i;
        }
    }
    return -1;
}

int buscaTabLitCads(char* dato) {
    for (int i = 0; i < numLitCad; i++) {
        if (strcmp(tablaLiteralesCadenas[i].dato, dato) == 0) {
            return i;
        }
    }
    return -1;
}

int buscaTabLitNum(char* dato) {
    for (int i = 0; i < numLitNum; i++) {
        if (strcmp(tablaLiteralesNumericas[i].dato, dato) == 0) {
            return i;
        }
    }
    return -1;
}

char asignarAtomoPalRes(char *palabra) {
    if (strcmp(palabra, "cadena") == 0) return 'h';
    if (strcmp(palabra, "caracter") == 0) return 'g';
    if (strcmp(palabra, "else") == 0) return 'e';
    if (strcmp(palabra, "entero") == 0) return 'n';
    if (strcmp(palabra, "for") == 0) return 'j';
    if (strcmp(palabra, "if") == 0) return 'f';
    if (strcmp(palabra, "do") == 0) return 'o';
    if (strcmp(palabra, "real") == 0) return 'd';
    if (strcmp(palabra, "return") == 0) return 'b';
    if (strcmp(palabra, "void") == 0) return 'v';
    if (strcmp(palabra, "while") == 0) return 'w';
    return 'N';
}

char asignarAtomoSimEspe(const char* palabra) {
    if (strcmp(palabra, "(") == 0) return '(';
    if (strcmp(palabra, ")") == 0) return ')';
    if (strcmp(palabra, "{") == 0) return '{';
    if (strcmp(palabra, "}") == 0) return '}';
    if (strcmp(palabra, "[") == 0) return '[';
    if (strcmp(palabra, "]") == 0) return ']';
    if (strcmp(palabra, "&") == 0) return '&';
    if (strcmp(palabra, ",") == 0) return ',';
    if (strcmp(palabra, ":") == 0) return ':';
    return 'N';
}

char asignarAtomoOpArit(const char* palabra) {
    if (strcmp(palabra, "+") == 0) return '+';
    if (strcmp(palabra, "-") == 0) return '-';
    if (strcmp(palabra, "*") == 0) return '*';
    if (strcmp(palabra, "/") == 0) return '/';
    if (strcmp(palabra, "$") == 0) return '$';
    return 'N';
}

char asignarAtomoOpRel(const char* op) {
    if (strcmp(op, "^^") == 0) return '>';
    if (strcmp(op, "^\"") == 0) return '<';
    if (strcmp(op, "==") == 0) return '?';
    if (strcmp(op, "^^=") == 0) return 'y';
    if (strcmp(op, "^\"=") == 0) return 'l';
    if (strcmp(op, "<>") == 0) return 'x';
    return 'N';
}

char asignarAtomoOpAsig(const char* op) {
    if (strcmp(op, "~") == 0) return '=';
    if (strcmp(op, "+~") == 0) return 'm';
    if (strcmp(op, "-~") == 0) return 'k';
    if (strcmp(op, "*~") == 0) return 'p';
    if (strcmp(op, "/~") == 0) return 't';
    if (strcmp(op, "$~") == 0) return 'u';
    return 'N';
}

// Implementación del analizador sintáctico

void Program() {
    printf("Program\n");
    if (next_atomo == 'h' || next_atomo == 'g' || next_atomo == 'n' || next_atomo == 'd' || next_atomo == 'v') {
        Func();
        otraFunc();
    } else {
        printf("Error de sintaxis en el atomo %c en la posición %d. Se esperaba un tipo de dato\n", next_atomo, n);
        exit(1);
    }
}

void otraFunc() {
    if (next_atomo == 'h' || next_atomo == 'g' || next_atomo == 'n' || next_atomo == 'd' || next_atomo == 'v') {
        Func();
        otraFunc();
    } else {
        // Nada que hacer, producción vacía
    }
}

void Func() {
    printf("Func: next_atomo %c\n", next_atomo);
    if (next_atomo == 'h' || next_atomo == 'g' || next_atomo == 'n' || next_atomo == 'd' || next_atomo == 'v') {
        Tipo();
        if (next_atomo == 'i') {
            n++;
            next_atomo = tokens[n].atomo;
            if (next_atomo == '(') {
                n++;
                next_atomo = tokens[n].atomo;
                Param();
                if (next_atomo == ')') {
                    n++;
                    next_atomo = tokens[n].atomo;
                    if (next_atomo == '{') {
                        n++;
                        next_atomo = tokens[n].atomo;
                        Cuerpo();
                        if (next_atomo == '}') {
                            n++;
                            if (n < numTokens) {
                                next_atomo = tokens[n].atomo;
                            }
                            // Función correctamente analizada
                        } else {
                            printf("Error de sintaxis en el atomo %c en la posición %d. Se esperaba '}'\n", next_atomo, n);
                            exit(1);
                        }
                    } else {
                        printf("Error de sintaxis en el atomo %c en la posición %d. Se esperaba '{'\n", next_atomo, n);
                        exit(1);
                    }
                } else {
                    printf("Error de sintaxis en el atomo %c en la posición %d. Se esperaba ')'\n", next_atomo, n);
                    exit(1);
                }
            } else {
                printf("Error de sintaxis en el atomo %c en la posición %d. Se esperaba '('\n", next_atomo, n);
                exit(1);
            }
        } else {
            printf("Error de sintaxis en el atomo %c en la posición %d. Se esperaba un identificador\n", next_atomo, n);
            exit(1);
        }
    } else {
        printf("Error en Func\n");
        exit(1);
    }
}

void Tipo() {
    if (next_atomo == 'h' || next_atomo == 'g' || next_atomo == 'n' || next_atomo == 'd' || next_atomo == 'v') {
        n++;
        next_atomo = tokens[n].atomo;
    } else {
        printf("Error de sintaxis en el atomo %c en la posición %d. Se esperaba un tipo\n", next_atomo, n);
        exit(1);
    }
}

void Param() {
    if (next_atomo == 'h' || next_atomo == 'g' || next_atomo == 'n' || next_atomo == 'd') {
        Tipo();
        if (next_atomo == 'i') {
            n++;
            next_atomo = tokens[n].atomo;
            otroArg();
        } else {
            printf("Error de sintaxis en Param. Se esperaba un identificador\n");
            exit(1);
        }
    } else {
        // Producción vacía, no hay parámetros
    }
}

void otroArg() {
    if (next_atomo == ',') {
        n++;
        next_atomo = tokens[n].atomo;
        Param();
    } else {
        // Producción vacía
    }
}

void Cuerpo() {
    if (next_atomo == 'h' || next_atomo == 'g' || next_atomo == 'n' || next_atomo == 'd') {
        Decl();
        listaP();
    } else if (next_atomo == 'i' || next_atomo == 'f' || next_atomo == 'w' || next_atomo == 'j' || next_atomo == 'b') {
        listaP();
    } else {
        // Producción vacía
    }
}

void Decl() {
    if (next_atomo == 'h' || next_atomo == 'g' || next_atomo == 'n' || next_atomo == 'd') {
        D();
        Decl();
    } else {
        // Producción vacía
    }
}

void D() {
    Tipo();
    if (next_atomo == 'i') {
        n++;
        next_atomo = tokens[n].atomo;
        K();
        if (next_atomo == ';') {
            n++;
            next_atomo = tokens[n].atomo;
        } else {
            printf("Error de sintaxis en D. Se esperaba ';'\n");
            exit(1);
        }
    } else {
        printf("Error de sintaxis en D. Se esperaba un identificador\n");
        exit(1);
    }
}

void K() {
    if (next_atomo == ',') {
        n++;
        next_atomo = tokens[n].atomo;
        if (next_atomo == 'i') {
            n++;
            next_atomo = tokens[n].atomo;
            K();
        } else {
            printf("Error de sintaxis en K. Se esperaba un identificador\n");
            exit(1);
        }
    } else if (next_atomo == '=') {
        n++;
        next_atomo = tokens[n].atomo;
        N();
        C();
    } else {
        // Producción vacía
    }
}

void N() {
    if (next_atomo == 'z' || next_atomo == 'r' || next_atomo == 's' || next_atomo == 'c') {
        n++;
        next_atomo = tokens[n].atomo;
    } else {
        printf("Error de sintaxis en N. Se esperaba una constante\n");
        exit(1);
    }
}

void C() {
    if (next_atomo == ',') {
        n++;
        next_atomo = tokens[n].atomo;
        if (next_atomo == 'i') {
            n++;
            next_atomo = tokens[n].atomo;
            K();
        } else {
            printf("Error de sintaxis en C. Se esperaba un identificador\n");
            exit(1);
        }
    } else {
        // Producción vacía
    }
}

void listaP() {
    if (next_atomo == 'i' || next_atomo == 'f' || next_atomo == 'w' || next_atomo == 'j' || next_atomo == 'b') {
        P();
        listaP();
    } else {
        // Producción vacía
    }
}

void P() {
    if (next_atomo == 'i') {
        // Asignación o llamada a función
        n++;
        next_atomo = tokens[n].atomo;
        if (next_atomo == '=') {
            n++;
            next_atomo = tokens[n].atomo;
            E();
            if (next_atomo == ';') {
                n++;
                next_atomo = tokens[n].atomo;
            } else {
                printf("Error de sintaxis en P. Se esperaba ';'\n");
                exit(1);
            }
        } else if (next_atomo == '(') {
            n++;
            next_atomo = tokens[n].atomo;
            arg();
            if (next_atomo == ')') {
                n++;
                next_atomo = tokens[n].atomo;
                if (next_atomo == ';') {
                    n++;
                    next_atomo = tokens[n].atomo;
                } else {
                    printf("Error de sintaxis en P. Se esperaba ';'\n");
                    exit(1);
                }
            } else {
                printf("Error de sintaxis en P. Se esperaba ')'\n");
                exit(1);
            }
        } else {
            printf("Error de sintaxis en P. Se esperaba '=' o '('\n");
            exit(1);
        }
    } else if (next_atomo == 'f') {
        I();
    } else if (next_atomo == 'j') {
        J();
    } else if (next_atomo == 'w') {
        W();
    } else if (next_atomo == 'b') {
        Devuelve();
    } else {
        printf("Error de sintaxis en P. Instrucción no válida\n");
        exit(1);
    }
}

void I() {
    if (next_atomo == 'f') {
        n++;
        next_atomo = tokens[n].atomo;
        if (next_atomo == '(') {
            n++;
            next_atomo = tokens[n].atomo;
            R();
            if (next_atomo == ')') {
                n++;
                next_atomo = tokens[n].atomo;
                if (next_atomo == '{') {
                    n++;
                    next_atomo = tokens[n].atomo;
                    listaP();
                    if (next_atomo == '}') {
                        n++;
                        next_atomo = tokens[n].atomo;
                        // Verificar si hay else
                        if (next_atomo == 'e') {
                            n++;
                            next_atomo = tokens[n].atomo;
                            if (next_atomo == '{') {
                                n++;
                                next_atomo = tokens[n].atomo;
                                listaP();
                                if (next_atomo == '}') {
                                    n++;
                                    next_atomo = tokens[n].atomo;
                                } else {
                                    printf("Error de sintaxis en I. Se esperaba '}'\n");
                                    exit(1);
                                }
                            } else {
                                printf("Error de sintaxis en I. Se esperaba '{'\n");
                                exit(1);
                            }
                        }
                    } else {
                        printf("Error de sintaxis en I. Se esperaba '}'\n");
                        exit(1);
                    }
                } else {
                    printf("Error de sintaxis en I. Se esperaba '{'\n");
                    exit(1);
                }
            } else {
                printf("Error de sintaxis en I. Se esperaba ')'\n");
                exit(1);
            }
        } else {
            printf("Error de sintaxis en I. Se esperaba '('\n");
            exit(1);
        }
    } else {
        printf("Error de sintaxis en I. Se esperaba 'if'\n");
        exit(1);
    }
}

void J() {
    if (next_atomo == 'j') {
        n++;
        next_atomo = tokens[n].atomo;
        if (next_atomo == '(') {
            n++;
            next_atomo = tokens[n].atomo;
            Y();
            if (next_atomo == ';') {
                n++;
                next_atomo = tokens[n].atomo;
                X();
                if (next_atomo == ';') {
                    n++;
                    next_atomo = tokens[n].atomo;
                    Z();
                    if (next_atomo == ')') {
                        n++;
                        next_atomo = tokens[n].atomo;
                        if (next_atomo == '{') {
                            n++;
                            next_atomo = tokens[n].atomo;
                            listaP();
                            if (next_atomo == '}') {
                                n++;
                                next_atomo = tokens[n].atomo;
                            } else {
                                printf("Error de sintaxis en J. Se esperaba '}'\n");
                                exit(1);
                            }
                        } else {
                            printf("Error de sintaxis en J. Se esperaba '{'\n");
                            exit(1);
                        }
                    } else {
                        printf("Error de sintaxis en J. Se esperaba ')'\n");
                        exit(1);
                    }
                } else {
                    printf("Error de sintaxis en J. Se esperaba ';'\n");
                    exit(1);
                }
            } else {
                printf("Error de sintaxis en J. Se esperaba ';'\n");
                exit(1);
            }
        } else {
            printf("Error de sintaxis en J. Se esperaba '('\n");
            exit(1);
        }
    } else {
        printf("Error de sintaxis en J. Se esperaba 'for'\n");
        exit(1);
    }
}

void W() {
    if (next_atomo == 'w') {
        n++;
        next_atomo = tokens[n].atomo;
        if (next_atomo == '(') {
            n++;
            next_atomo = tokens[n].atomo;
            R();
            if (next_atomo == ')') {
                n++;
                next_atomo = tokens[n].atomo;
                if (next_atomo == '{') {
                    n++;
                    next_atomo = tokens[n].atomo;
                    listaP();
                    if (next_atomo == '}') {
                        n++;
                        next_atomo = tokens[n].atomo;
                    } else {
                        printf("Error de sintaxis en W. Se esperaba '}'\n");
                        exit(1);
                    }
                } else {
                    printf("Error de sintaxis en W. Se esperaba '{'\n");
                    exit(1);
                }
            } else {
                printf("Error de sintaxis en W. Se esperaba ')'\n");
                exit(1);
            }
        } else {
            printf("Error de sintaxis en W. Se esperaba '('\n");
            exit(1);
        }
    } else {
        printf("Error de sintaxis en W. Se esperaba 'while'\n");
        exit(1);
    }
}

void Devuelve() {
    if (next_atomo == 'b') {
        n++;
        next_atomo = tokens[n].atomo;
        if (next_atomo == ';') {
            n++;
            next_atomo = tokens[n].atomo;
        } else {
            V();
            if (next_atomo == ';') {
                n++;
                next_atomo = tokens[n].atomo;
            } else {
                printf("Error de sintaxis en Devuelve. Se esperaba ';'\n");
                exit(1);
            }
        }
    } else {
        printf("Error de sintaxis en Devuelve. Se esperaba 'return'\n");
        exit(1);
    }
}

void arg() {
    if (next_atomo == 'i' || next_atomo == 'z' || next_atomo == 'r' || next_atomo == 's' || next_atomo == 'c') {
        V();
        otroArg();
    } else {
        // Producción vacía
    }
}

void V() {
    if (next_atomo == 'i' || next_atomo == 'z' || next_atomo == 'r' || next_atomo == 's' || next_atomo == 'c') {
        n++;
        next_atomo = tokens[n].atomo;
    } else {
        printf("Error de sintaxis en V. Se esperaba un valor o identificador\n");
        exit(1);
    }
}

void R() {
    V();
    RP();
    V();
}

void RP() {
    if (next_atomo == '>' || next_atomo == '<' || next_atomo == 'l' || next_atomo == 'y' || next_atomo == '?' || next_atomo == 'x') {
        n++;
        next_atomo = tokens[n].atomo;
    } else {
        printf("Error de sintaxis en RP. Se esperaba un operador relacional\n");
        exit(1);
    }
}

void Y() {
    if (next_atomo == 'i') {
        n++;
        next_atomo = tokens[n].atomo;
        if (next_atomo == '=') {
            n++;
            next_atomo = tokens[n].atomo;
            E();
        } else {
            printf("Error de sintaxis en Y. Se esperaba '='\n");
            exit(1);
        }
    } else {
        // Producción vacía
    }
}

void X() {
    R();
}

void Z() {
    if (next_atomo == 'i') {
        n++;
        next_atomo = tokens[n].atomo;
        if (next_atomo == '=') {
            n++;
            next_atomo = tokens[n].atomo;
            E();
        } else {
            printf("Error de sintaxis en Z. Se esperaba '='\n");
            exit(1);
        }
    } else {
        // Producción vacía
    }
}

void E() {
    V();
    if (next_atomo == '+' || next_atomo == '-' || next_atomo == '*' || next_atomo == '/' || next_atomo == '$') {
        n++;
        next_atomo = tokens[n].atomo;
        V();
    }
}

int main(int argc, char** argv) {
    printf("\n<--> BIENVENIDO AL PROGRAMA ANALIZADOR LÉXICO Y SINTÁCTICO <-->\n");
    printf("  <-->                      DESCENDENTE RECURSIVO            <-->\n\n");
    printf("A continuación se empezará a analizar el archivo que ha introducido al arrancar el programa\n");
    printf("empezando con la definición de las clases de cada sentencia del programa que se está evaluando\n\n");

    if (argc != 2) {
        fprintf(stderr, "Uso: %s <archivo_de_entrada>\n", argv[0]);
        return 1;
    }

    FILE* archivo = fopen(argv[1], "r");
    if (archivo == NULL) {
        fprintf(stderr, "Error al abrir el archivo: %s\n", argv[1]);
        return 1;
    }

    yyin = archivo;
    yylex();

    printf("Ya definidas las clases de cada una de las sentencias, se empezarán a mostrar en sus\n");
    printf("respectivas tablas, para una mejor organización\n\n");

    // Muestra la tabla de símbolos
    printf("\n\nTabla de símbolos:\n");
    printf("Posición | Nombre         | Tipo\n");
    printf("-----------------------------\n");
    for (int i = 0; i < numSimbolos; i++) {
        printf("%8d | %-14s | %d\n", tablaSimbolos[i].posicion, tablaSimbolos[i].nombre, tablaSimbolos[i].tipo);
    }

    // Muestra la tabla de literales de cadenas
    printf("\n\nTabla de literales de cadenas:\n");
    printf("Posición | Dato\n");
    printf("------------------\n");
    for (int i = 0; i < numLitCad; i++) {
        printf("%8d | %-s\n", tablaLiteralesCadenas[i].posicion, tablaLiteralesCadenas[i].dato);
    }

    // Muestra la tabla de literales numéricas
    printf("\n\nTabla de literales numéricas:\n");
    printf("Posición | Dato\n");
    printf("------------------\n");
    for (int i = 0; i < numLitNum; i++) {
        printf("%8d | %-s\n", tablaLiteralesNumericas[i].posicion, tablaLiteralesNumericas[i].dato);
    }

    // Mostrar los tokens generados
    printf("\n\nTokens generados:\n");
    printf("Clase | Valor | Info   \t| Átomo\n");
    printf("----------------------\n");
    for (int i = 0; i < numTokens; i++) {
        printf("%5d | %-4s | %-s  \t| %-c \n", tokens[i].clase, tokens[i].valor, tokens[i].info, tokens[i].atomo);
    }

    // Mostrar la cadena de átomos generados
    printf("\n\nCadena de átomos encontrados: %s\n", cadenaAtomos);

    if (numTokens > 0) {
        next_atomo = tokens[n].atomo;
        Program();
        printf("ANÁLISIS SINTÁCTICO REALIZADO CON ÉXITO\n");
    } else {
        printf("No se encontraron tokens para analizar.\n");
    }

    fclose(archivo);

    return 0;
}

