%{
/* 
* OBJETIVO: Construir un analizador Sintáctico Descendente Recursivo    
*
* INTEGRANTES:
* - Soto Huerta Gustavo Isaac
* - Peña Rodríguez Eduardo
* - Guerrero Gutiérrez Héctor
* - Flores Chavez Marcos Gabriel
* FECHA: 2024
*/

// Incluimos las librerías necesarias
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>

// Declaración de variables globales y estructuras
int error_count = 0;  // Variable global para contar errores
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
void GlobalDeclarations();
void FuncList();
void Declaration();
void IdentList();
void MoreIdents();
void OptionalAssignment();  // Declaración añadida
void Expression();          // Declaración añadida
void Func();
void Tipo();
void Param();
void otroParam();
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
void arg();
void otroArg();
void V();
void R();
void RP();
void Y();
void X();
void Z();
void E();
void avanzar_atomo();
void synchronize(const char* sync_tokens);
bool is_function_declaration();

void report_error(const char* message, int position);

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

"~"|"\\+="|"\\-="|"\\*="|"/="|"\\$=" {
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

"("|")"|"{"|"}"|"["|"]"|"&"|","|":"|";" {
    printf("[Clase 3] Símbolo especial: %s\n", yytext);
    tokens[numTokens].clase = 3;
    strcpy(tokens[numTokens].valor, yytext);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = asignarAtomoSimEspe(yytext);
    char atomo_str[2] = { tokens[numTokens].atomo, '\0' };
    strcat(cadenaAtomos, atomo_str);
    numTokens++;
}

"=="|"!="|"<="|">="|"<"|">" {
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

[A-Za-z][A-Za-z0-9_]{0,31} {
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

[0-9]+(\.[0-9]+)? {
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
    if (strchr(yytext, '.'))
        tokens[numTokens].atomo = 'r'; // Real
    else
        tokens[numTokens].atomo = 'z'; // Entero
    char atomo_str[2] = { tokens[numTokens].atomo, '\0' };
    strcat(cadenaAtomos, atomo_str);
    numTokens++;
}

\"[^\"]*\" {
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

[ \t\n]+ ; // Ignora espacios, tabuladores y saltos de línea

. {
    printf("No se reconoce el carácter (%s)\n", yytext);
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
        const char* ops[] = { ">", "<", ">=", "<=", "==", "!=" };
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
        const char* ops[] = { "~", "+=", "-=", "*=", "/=", "$=" };
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

// Implementación de las funciones de búsqueda en tablas

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

// Asignación de átomos

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
    if (strcmp(palabra, ";") == 0) return ';';
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
    if (strcmp(op, ">") == 0) return '>';
    if (strcmp(op, "<") == 0) return '<';
    if (strcmp(op, ">=") == 0) return 'y';
    if (strcmp(op, "<=") == 0) return 'l';
    if (strcmp(op, "==") == 0) return '?';
    if (strcmp(op, "!=") == 0) return 'x';
    return 'N';
}

char asignarAtomoOpAsig(const char* op) {
    if (strcmp(op, "~") == 0) return '=';
    if (strcmp(op, "+=") == 0) return 'm';
    if (strcmp(op, "-=") == 0) return 'k';
    if (strcmp(op, "*=") == 0) return 'p';
    if (strcmp(op, "/=") == 0) return 't';
    if (strcmp(op, "$=") == 0) return 'u';
    return 'N';
}

// Implementación del analizador sintáctico

void report_error(const char* message, int position) {
    extern int error_count;
    error_count++;
    printf("Error en la posición %d: %s\n", position, message);
}

void avanzar_atomo() {
    extern int n, numTokens;
    if (n < numTokens - 1) {
        n++;
        next_atomo = tokens[n].atomo;
        printf("Avanzar_atomo: posición %d, next_atomo '%c'\n", n, next_atomo);
    } else {
        printf("Fin de tokens alcanzado en avanzar_atomo.\n");
        next_atomo = '\0'; // Indicar fin de entrada
    }
}

void synchronize(const char* sync_tokens) {
    while (next_atomo != '\0' && strchr(sync_tokens, next_atomo) == NULL) {
        avanzar_atomo();
    }
    if (next_atomo != '\0') {
        avanzar_atomo();
    }
}

bool is_function_declaration() {
    int save_n = n;
    char save_next_atomo = next_atomo;

    avanzar_atomo();  // Avanzamos al identificador
    if (next_atomo == 'i') {
        avanzar_atomo();
        if (next_atomo == '(') {
            // Es una función
            n = save_n;
            next_atomo = save_next_atomo;
            return true;
        }
    }

    n = save_n;
    next_atomo = save_next_atomo;
    return false;
}

void Program() {
    printf("Program\n");
    while (next_atomo != '\0') {
        if (strchr("hgnvd", next_atomo)) {
            if (is_function_declaration()) {
                Func();
            } else {
                GlobalDeclarations();
            }
        } else {
            report_error("Símbolo inesperado en el nivel superior", n);
            avanzar_atomo();
        }
    }
}

void GlobalDeclarations() {
    while (strchr("hgnvd", next_atomo)) {
        if (is_function_declaration()) {
            break;
        } else {
            Declaration();
        }
    }
}

void FuncList() {
    while (strchr("hgnvd", next_atomo)) {
        Func();
    }
}

void Declaration() {
    Tipo();
    IdentList();
    if (next_atomo == ';' || next_atomo == ':') {
        avanzar_atomo();
    } else {
        report_error("Se esperaba ';' o ':' al final de la declaración", n);
        synchronize(";:}");
    }
}

void IdentList() {
    if (next_atomo == 'i') {
        avanzar_atomo();
        OptionalAssignment();
        MoreIdents();
    } else {
        report_error("Se esperaba un identificador en la lista de declaraciones", n);
        synchronize(";:}");
    }
}

void MoreIdents() {
    if (next_atomo == ',') {
        avanzar_atomo();
        IdentList();
    }
    // else vacío
}

void OptionalAssignment() {
    if (next_atomo == '=') {
        avanzar_atomo();
        Expression();
    }
    // else vacío
}

void Expression() {
    E();
}

void Func() {
    printf("Func: next_atomo %c\n", next_atomo);
    if (strchr("hgnvd", next_atomo)) {
        Tipo();
        if (next_atomo == 'i') {
            avanzar_atomo();
            if (next_atomo == '(') {
                avanzar_atomo();
                Param();
                if (next_atomo == ')') {
                    avanzar_atomo();
                    if (next_atomo == '{') {
                        avanzar_atomo();
                        Cuerpo();
                        if (next_atomo == '}') {
                            avanzar_atomo();
                        } else {
                            report_error("Se esperaba '}'", n);
                            synchronize(";:}");
                        }
                    } else {
                        report_error("Se esperaba '{'", n);
                        synchronize(";:}");
                    }
                } else {
                    report_error("Se esperaba ')'", n);
                    synchronize(";:}");
                }
            } else {
                report_error("Se esperaba '('", n);
                synchronize(";:}");
            }
        } else {
            report_error("Se esperaba un identificador", n);
            synchronize(";:}");
        }
    } else {
        report_error("Tipo no reconocido en Func", n);
        synchronize(";:}");
    }
}

void Tipo() {
    if (strchr("hgnvd", next_atomo)) {
        avanzar_atomo();
    } else {
        report_error("Se esperaba un tipo", n);
        synchronize(";:}");
    }
}

void Param() {
    if (strchr("hgnvd", next_atomo)) {
        Tipo();
        if (next_atomo == 'i') {
            avanzar_atomo();
            otroParam();
        } else {
            report_error("Se esperaba un identificador en Param", n);
            synchronize(";:}");
        }
    }
    // else vacío
}

void otroParam() {
    if (next_atomo == ',') {
        avanzar_atomo();
        Param();
    }
    // else vacío
}

void Cuerpo() {
    if (strchr("hgnvd", next_atomo)) {
        Decl();
        listaP();
    } else if (strchr("ifwbj", next_atomo) || next_atomo == 'i' || next_atomo == 'b') {
        listaP();
    } else {
        // Cuerpo puede ser vacío, pero es poco probable
    }
}

void Decl() {
    while (strchr("hgnvd", next_atomo)) {
        D();
    }
}

void D() {
    Tipo();
    if (next_atomo == 'i') {
        avanzar_atomo();
        K();
        if (next_atomo == ';' || next_atomo == ':') {
            avanzar_atomo();
        } else {
            report_error("Se esperaba ';' o ':' en D", n);
            synchronize(";:}");
        }
    } else {
        report_error("Se esperaba un identificador en D", n);
        synchronize(";:}");
    }
}

void K() {
    if (next_atomo == ',') {
        avanzar_atomo();
        if (next_atomo == 'i') {
            avanzar_atomo();
            K();
        } else {
            report_error("Se esperaba un identificador después de ','", n);
            synchronize(";:}");
        }
    } else if (next_atomo == '=') {
        avanzar_atomo();
        N();
        C();
    }
    // else vacío
}

void N() {
    if (strchr("zrcs", next_atomo)) {
        avanzar_atomo();
    } else {
        report_error("Se esperaba una constante en N", n);
        synchronize(";:}");
    }
}

void C() {
    if (next_atomo == ',') {
        avanzar_atomo();
        if (next_atomo == 'i') {
            avanzar_atomo();
            K();
        } else {
            report_error("Se esperaba un identificador después de ','", n);
            synchronize(";:}");
        }
    }
    // else vacío
}

void listaP() {
    while (next_atomo == 'i' || strchr("ifwbj", next_atomo) || next_atomo == 'b') {
        P();
    }
    // else vacío
}

void P() {
    if (next_atomo == 'i') {
        avanzar_atomo();
        if (next_atomo == '=') {
            avanzar_atomo();
            E();
            if (next_atomo == ';' || next_atomo == ':') {
                avanzar_atomo();
            } else {
                report_error("Se esperaba ';' o ':' en P", n);
                synchronize(";:}");
            }
        } else if (next_atomo == '(') {
            avanzar_atomo();
            arg();
            if (next_atomo == ')') {
                avanzar_atomo();
                if (next_atomo == ';' || next_atomo == ':') {
                    avanzar_atomo();
                } else {
                    report_error("Se esperaba ';' o ':' después de ')'", n);
                    synchronize(";:}");
                }
            } else {
                report_error("Se esperaba ')' en P", n);
                synchronize(";:)}");
            }
        } else {
            report_error("Se esperaba '=' o '(' en P", n);
            synchronize(";:}");
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
        report_error("Instrucción no válida en P", n);
        avanzar_atomo();
    }
}

void I() {
    if (next_atomo == 'f') {
        avanzar_atomo();
        if (next_atomo == '[') {
            avanzar_atomo();
            R();
            if (next_atomo == ']') {
                avanzar_atomo();
                if (next_atomo == '{') {
                    avanzar_atomo();
                    listaP();
                    if (next_atomo == '}') {
                        avanzar_atomo();
                        // Manejo opcional del 'else'
                        if (next_atomo == 'e') {
                            avanzar_atomo();
                            if (next_atomo == '{') {
                                avanzar_atomo();
                                listaP();
                                if (next_atomo == '}') {
                                    avanzar_atomo();
                                } else {
                                    report_error("Se esperaba '}' después del bloque 'else'", n);
                                    synchronize(";:}");
                                }
                            } else {
                                report_error("Se esperaba '{' después de 'else'", n);
                                synchronize(";:}");
                            }
                        }
                    } else {
                        report_error("Se esperaba '}' al final del bloque 'if'", n);
                        synchronize(";:}");
                    }
                } else {
                    report_error("Se esperaba '{' después de ']'", n);
                    synchronize(";:}");
                }
            } else {
                report_error("Se esperaba ']' después de la condición del 'if'", n);
                synchronize(";:}");
            }
        } else {
            report_error("Se esperaba '[' después de 'if'", n);
            synchronize(";:}");
        }
    } else {
        report_error("Se esperaba 'if'", n);
        avanzar_atomo();
    }
}

void J() {
    if (next_atomo == 'j') {
        avanzar_atomo();
        if (next_atomo == '[') {
            avanzar_atomo();
            Y();
            if (next_atomo == ';' || next_atomo == ':') {
                avanzar_atomo();
                X();
                if (next_atomo == ';' || next_atomo == ':') {
                    avanzar_atomo();
                    Z();
                    if (next_atomo == ']') {
                        avanzar_atomo();
                        if (next_atomo == '{') {
                            avanzar_atomo();
                            listaP();
                            if (next_atomo == '}') {
                                avanzar_atomo();
                            } else {
                                report_error("Se esperaba '}' en J", n);
                                synchronize(";:}");
                            }
                        } else {
                            report_error("Se esperaba '{' en J", n);
                            synchronize(";:}");
                        }
                    } else {
                        report_error("Se esperaba ']' en J", n);
                        synchronize(";:}");
                    }
                } else {
                    report_error("Se esperaba ';' o ':' en J", n);
                    synchronize(";:}");
                }
            } else {
                report_error("Se esperaba ';' o ':' en J", n);
                synchronize(";:}");
            }
        } else {
            report_error("Se esperaba '[' en J", n);
            synchronize(";:}");
        }
    } else {
        report_error("Se esperaba 'for' en J", n);
        avanzar_atomo();
    }
}

void W() {
    if (next_atomo == 'w') {
        avanzar_atomo();
        if (next_atomo == '[') {
            avanzar_atomo();
            R();
            if (next_atomo == ']') {
                avanzar_atomo();
                if (next_atomo == '{') {
                    avanzar_atomo();
                    listaP();
                    if (next_atomo == '}') {
                        avanzar_atomo();
                    } else {
                        report_error("Se esperaba '}' en W", n);
                        synchronize(";:}");
                    }
                } else {
                    report_error("Se esperaba '{' en W", n);
                    synchronize(";:}");
                }
            } else {
                report_error("Se esperaba ']' en W", n);
                synchronize(";:}");
            }
        } else {
            report_error("Se esperaba '[' en W'", n);
            synchronize(";:}");
        }
    } else {
        report_error("Se esperaba 'while' en W", n);
        avanzar_atomo();
    }
}

void Devuelve() {
    if (next_atomo == 'b') {
        avanzar_atomo();
        if (next_atomo == ';' || next_atomo == ':') {
            avanzar_atomo();
        } else {
            V();
            if (next_atomo == ';' || next_atomo == ':') {
                avanzar_atomo();
            } else {
                report_error("Se esperaba ';' o ':' en Devuelve", n);
                synchronize(";:}");
            }
        }
    } else {
        report_error("Se esperaba 'return' en Devuelve", n);
        avanzar_atomo();
    }
}

void arg() {
    if (strchr("izrcs", next_atomo)) {
        V();
        otroArg();
    }
    // else vacío
}

void otroArg() {
    if (next_atomo == ',') {
        avanzar_atomo();
        arg();
    }
    // else vacío
}

void V() {
    if (strchr("izrcs", next_atomo)) {
        avanzar_atomo();
    } else {
        report_error("Se esperaba un valor o identificador en V", n);
        synchronize(";:}");
    }
}

void R() {
    V();
    RP();
    V();
}

void RP() {
    if (strchr("><yl?x", next_atomo)) {
        avanzar_atomo();
    } else {
        report_error("Se esperaba un operador relacional en RP", n);
        synchronize(";:}");
    }
}

void Y() {
    if (next_atomo == 'i') {
        avanzar_atomo();
        if (next_atomo == '=') {
            avanzar_atomo();
            E();
        } else {
            report_error("Se esperaba '=' en Y", n);
            synchronize(";:}");
        }
    } else {
        report_error("Se esperaba un identificador en Y", n);
        synchronize(";:}");
    }
}

void X() {
    R();
}

void Z() {
    if (next_atomo == 'i') {
        avanzar_atomo();
        if (next_atomo == '=') {
            avanzar_atomo();
            E();
        } else {
            report_error("Se esperaba '=' en Z", n);
            synchronize(";:}");
        }
    } else {
        report_error("Se esperaba un identificador en Z", n);
        synchronize(";:}");
    }
}

void E() {
    V();
    if (strchr("+-*/$", next_atomo)) {
        avanzar_atomo();
        V();
    }
    // else vacío
}

int main(int argc, char** argv) {
    extern int error_count;
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

        printf("Debug: error_count antes de la verificación final es %d\n", error_count);
        // Mensaje de salida basado en el conteo de errores
        if (error_count == 0) {
            printf("ANÁLISIS SINTÁCTICO REALIZADO CON ÉXITO\n");
        } else {
            printf("Se encontraron %d errores en el análisis sintáctico.\n", error_count);
        }
    } else {
        printf("No se encontraron tokens para analizar.\n");
    }

    fclose(archivo);
    return 0;
}


