%{
    /* 
    * OBJETIVO: Este programa es un analizador léxico que procesa un archivo fuente, identifica
    *           palabras reservadas, operadores, identificadores, literales, y genera una
    *           representación en forma de tokens, además de detectar errores léxicos.
    * INTEGRANTES:
    * - Soto Huerta Gustavo Isaac
    * - Peña Rodríguez Eduardo
    * - Guerrero Gutiérrez Héctor
    * FECHA: 2024
    */

    #include<stdio.h> 
    #include<stdlib.h>
    #include<string.h>

    // Estructura del catálogo de palabras reservadas
    typedef struct { 
        int valor; 
        char palabra[100]; 
    } PalRes;

    // Estructura del catálogo de operadores
    typedef struct { 
        int valor; 
        char op[100]; 
    } Operadores;

    // Estructura del arreglo de símbolos
    typedef struct { 
        int posicion; 
        char nombre[100]; 
        int tipo; 
    } TablaSimbolos;

    // Estructura para el arreglo de literales
    typedef struct { 
        int posicion; 
        char dato[100]; 
    } TablaLiterales;

    // Estructura para la información de un token
    typedef struct { 
        int clase; 
        char valor[100]; 
        char info[100]; 
    } TokenInfo;

    // Estructura para manejar los errores léxicos
    typedef struct {
    int posicion; 
    char mensaje[100]; 
    } ErrorLexico;



    // Arreglos para almacenar símbolos, literales, tokens y errores léxicos
    TablaSimbolos tablaSimbolos[100]; 
    TablaLiterales tablaLiteralesCadenas[100]; 
    TablaLiterales tablaLiteralesNumericas[100]; 
    TokenInfo tokens[100]; 
    PalRes catalogoRes[17]; 
    Operadores catalogoOp[7]; 
    ErrorLexico erroresLexicos[100]; 

    // Variables para el conteo de elementos en las tablas
    int numSimbolos, numLitCad, numLitNum, numTokens,numErroresLexicos;

    // Función para obtener el valor de una palabra reservada
    // Busca en el catálogo de palabras reservadas si existe una coincidencia
    int Palabras_res(char* pal) {
        for (int i = 0; i < 17; i++) {
            catalogoRes[i].valor = i;
        }

        // Se asignan las palabras reservadas al catálogo
        strcpy(catalogoRes[0].palabra, "case");
        strcpy(catalogoRes[1].palabra, "long");
        strcpy(catalogoRes[2].palabra, "if");
        strcpy(catalogoRes[3].palabra, "else");
        strcpy(catalogoRes[4].palabra, "double");
        strcpy(catalogoRes[5].palabra, "while");
        strcpy(catalogoRes[6].palabra, "do");
        strcpy(catalogoRes[7].palabra, "int");
        strcpy(catalogoRes[8].palabra, "default");
        strcpy(catalogoRes[9].palabra, "float");
        strcpy(catalogoRes[10].palabra, "for");
        strcpy(catalogoRes[11].palabra, "switch");
        strcpy(catalogoRes[12].palabra, "short");
        strcpy(catalogoRes[13].palabra, "continue");
        strcpy(catalogoRes[14].palabra, "break");
        strcpy(catalogoRes[15].palabra, "char");
        strcpy(catalogoRes[16].palabra, "return");
        
        for (int i = 0; i < 17; i++) {
            if (strcmp(pal, catalogoRes[i].palabra) == 0) {
                return catalogoRes[i].valor;
            }
        }
        return -1;
    }
    
    // Función para obtener el valor de un operador relacional
    // Busca en el catálogo de operadores relacionales
    int Operadores_rel(char* Op) {
        for (int i = 0; i < 7; i++) {
            catalogoOp[i].valor = i;
        }
        
        strcpy(catalogoOp[0].op, "<");
        strcpy(catalogoOp[1].op, ">");
        strcpy(catalogoOp[2].op, "<=");
        strcpy(catalogoOp[3].op, ">=");
        strcpy(catalogoOp[4].op, "==");
        strcpy(catalogoOp[5].op, "!=");

        for (int i = 0; i < 7; i++) {
            if (strcmp(Op, catalogoOp[i].op) == 0) {
                return catalogoOp[i].valor;
            }
        }
        return -1;
    }

    // Funciones para buscar la posición de un símbolo o literal en las tablas
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
%}

%option noyywrap

%%

"case"|"long"|"if"|"else"|"double"|"while"|"do"|"int"|"default"|"float"|"for"|"switch"|"short"|"continue"|"break"|"char"|"return" {
    printf("[Clase 0] Palabra reservada: %s\n", yytext);
    int val = Palabras_res(yytext);
    char cadena[20];
    tokens[numTokens].clase = 0;
    sprintf(cadena, "%d", val);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    numTokens++;
}

[A-Za-z][A-Za-z0-9]{0,5}_ {
    printf("[Clase 1] Identificador válido: %s\n", yytext);
    int pos = buscaTabSimb(yytext);
    char cadena[20];
    if (pos == -1) {
        tablaSimbolos[numSimbolos].posicion = numSimbolos + 1;
        strcpy(tablaSimbolos[numSimbolos].nombre, yytext);
        tablaSimbolos[numSimbolos].tipo = -1;
        pos = numSimbolos; // Se asigna la nueva posición
        numSimbolos++;
    }
    tokens[numTokens].clase = 1;
    sprintf(cadena, "%d", tablaSimbolos[pos].posicion);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    numTokens++;
}

[+-]?\s?[0-9]{1,6} {
    printf("[Clase 2] Constante numérica válida: %s\n", yytext);
    int pos = buscaTabLitNum(yytext);
    char cadena[20];
    int val;
    if (pos == -1) {
        tablaLiteralesNumericas[numLitNum].posicion = numLitNum + 1;
        strcpy(tablaLiteralesNumericas[numLitNum].dato, yytext);
        numLitNum++;
    }
    tokens[numTokens].clase = 2;
    val = posTabLitNum(yytext);
    sprintf(cadena, "%d", val);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    numTokens++;
}

([0-9]+\.[0-9]+|\.[0-9]+|[0-9]+\.) {
    printf("[Clase 3] Constante decimal válida: %s\n", yytext);
    int pos = buscaTabLitNum(yytext);
    char cadena[20];
    int val;
    if (pos == -1) {
        tablaLiteralesNumericas[numLitNum].posicion = numLitNum + 1;
        strcpy(tablaLiteralesNumericas[numLitNum].dato, yytext);
        numLitNum++;
    }
    tokens[numTokens].clase = 3;
    val = posTabLitNum(yytext);
    sprintf(cadena, "%d", val);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    numTokens++;
}

\"[^\"]{1,38}\" {
    printf("[Clase 4] Cadena válida: %s\n", yytext);
    int pos = buscaTabLitCads(yytext);
    char cadena[20];
    int val;
    if (pos == -1) {
        tablaLiteralesCadenas[numLitCad].posicion = numLitCad + 1;
        strcpy(tablaLiteralesCadenas[numLitCad].dato, yytext);
        numLitCad++;
    }
    tokens[numTokens].clase = 4;
    val = posTabLitCads(yytext);
    sprintf(cadena, "%d", val);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    numTokens++;
}

\'[^\']\' {
    printf("[Clase 5] Carácter válido: %s\n", yytext);
    tokens[numTokens].clase = 5;
    strcpy(tokens[numTokens].valor, yytext);
    strcpy(tokens[numTokens].info, yytext);
    numTokens++;
}

"+"|"-"|"*"|"/"|"%"|"\\"|"^" {
    printf("[Clase 6] Operador aritmético: %s\n", yytext);
    tokens[numTokens].clase = 6;
    strcpy(tokens[numTokens].valor, yytext);
    strcpy(tokens[numTokens].info, yytext);
    numTokens++;
}

"<"|">"|"<="|">="|"=="|"!=" {
    printf("[Clase 7] Operador relacional: %s\n", yytext);
    int val = Operadores_rel(yytext);
    char cadena[20];
    tokens[numTokens].clase = 7;
    sprintf(cadena, "%d", val);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    numTokens++;
}

"=" {
    printf("[Clase 8] Operador de asignación: %s\n", yytext);
    tokens[numTokens].clase = 8;
    strcpy(tokens[numTokens].valor, yytext);
    strcpy(tokens[numTokens].info, yytext);
    numTokens++;
}

[ \t\n]+ ;  // Ignora espacios, tabuladores y saltos de línea

. {
    fprintf(stderr, "No se reconoce el carácter (%s)\n", yytext);
    
    // Almacenar el error en la tabla de errores léxicos
    if (numErroresLexicos < 100) { 
        erroresLexicos[numErroresLexicos].posicion = numErroresLexicos + 1;
        sprintf(erroresLexicos[numErroresLexicos].mensaje, "Carácter no reconocido: %s", yytext);
        numErroresLexicos++;
    }
}


%%

int main(int argc, char** argv) {
    printf("\n<--> BIENVENIDO AL PROGRAMA ANALIZADOR LÉXICO <-->\n\n");
    printf("A continuación, se analizará el archivo introducido al arrancar el programa\n");
    system("pause");

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

    printf("Resultados del análisis léxico:\n\n");
    system("pause");

    printf("\n\nTabla de símbolos:\n");
    printf("Posición | Nombre         | Tipo\n");
    printf("-----------------------------\n");
    for (int i = 0; i < numSimbolos; i++) {
        printf("%8d | %-14s | %d\n", tablaSimbolos[i].posicion, tablaSimbolos[i].nombre, tablaSimbolos[i].tipo);
    }

    printf("\n\nTabla de literales de cadenas:\n");
    printf("Posición | Dato\n");
    printf("------------------\n");
    for (int i = 0; i < numLitCad; i++) {
        printf("%8d | %-s\n", tablaLiteralesCadenas[i].posicion, tablaLiteralesCadenas[i].dato);
    }

    printf("\n\nTabla de literales numéricas:\n");
    printf("Posición | Dato\n");
    printf("------------------\n");
    for (int i = 0; i < numLitNum; i++) {
        printf("%8d | %-s\n", tablaLiteralesNumericas[i].posicion, tablaLiteralesNumericas[i].dato);
    }

    printf("\n\nTokens generados:\n");
    printf("Clase | Valor | Info\n");
    printf("----------------------\n");
    for (int i = 0; i < numTokens; i++) {
        printf("%5d | %-4s | %-s \n", tokens[i].clase, tokens[i].valor, tokens[i].info);
    }

     // Finalmente, imprimir la tabla de errores léxicos
    printf("\n\nTabla de errores léxicos:\n");
    printf("Posición | Mensaje\n");
    printf("-------------------\n");
    for (int i = 0; i < numErroresLexicos; i++) {
        printf("%8d | %-s\n", erroresLexicos[i].posicion, erroresLexicos[i].mensaje);
    }


    fclose(archivo);
    return 0;
}