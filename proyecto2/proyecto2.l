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


        #include<stdio.h> // Librerias a utilizar a lo largo del código
        #include<stdlib.h>
        #include<string.h>
        #include<stdbool.h>

        // FUNCIONES GLOBALES
        char cadenaAtomos[99999] = ""; // <-- Cadena encargada de guardar los átmos
        char asignarAtomoSimEspe(const char* yytext);
        char asignarAtomoOpArit(const char* yytext);
        char *asignarAtomoOpRel(const char* yytext);
	char *asignarAtomoOpAsig(const char* yytext);

        void Program();
        void otraFunc();
        void Func();
        void Tipo();
        void Param();
        void otroParam();
        void Cuerpo();
        void Decl();
        void D();
        void K();
        void Q();
        void N();
        void C();
        void listaP();
        void P();
        void A();
        void AP();
        void E();
        void EP();
        void T();
        void F();
        void Llama();
        void arg();
        void otroArg();
        void V();
        void TP();
        void I();
        void R();
        void RP();
        void IP();
        void H();
        void CP();
        void U();
        void OP();
        void W();
        void J();
        void Y();
        void X();
        void Z();
        void Devuelve();



        char next_atomo;
        int n=0;

        typedef struct { // Se define la estructura del catalogo de palabras reservadas
            int valor; // Valor del catalogo
            char palabra[100]; //palabra
        } PalRes;

        typedef struct { // Se define la estructura del catalogo de operadores
            int valor; // Valor del catalogo
            char op[100]; //Operador en la tabla
        } Operadores;

        // Estructura del arreglo de simbolos
        typedef struct { // Se define la estructura de la tabla de simbolos
            int posicion; // Posición del simbolo
            char nombre[100]; // Nombre del simbolo, con longitud máxima de 100
            int tipo; // Tipo de dato del simbolo
        } TablaSimbolos;

        // Estructura para el arreglo de literales
        typedef struct { // Se define la estructura de la tabla de literales
            int posicion; // Posición que tendrá el dato cadena o literal 
            char dato[100]; // Longitud del valor dato, maximo 100
        } TablaLiterales;

        // Estructura para la información de un token
        typedef struct { // Se define la estructura del Token
            int clase; // Clase entera que es el simbolo
            char valor[100]; // Longitud del valor del token, maximo 100
            char info[100]; // Cadena que tiene guardada cada token
            char atomo; // RESPONSABLE DE GUARDAR EL ATOMO DE CADA UNO DE LAS CLASES UNA VEZ IDENTIFICADOS
        } TokenInfo;

        // Creacion de arreglos
        TablaSimbolos tablaSimbolos[99999]; // Se crea el arreglo "tablaSimbolos"
        TablaLiterales tablaLiteralesCadenas[99999]; // Se crea el arreglo "tablaLitCad"
        TablaLiterales tablaLiteralesNumericas[99999]; // Se crea el arreglo "tablaLitNum"
        TokenInfo tokens[99999]; // Se crea el arreglo "tokens"
        PalRes catalogoRes[17]; // Se crea el catalogo de palabras reservadas
        Operadores catalogoOp[13]; // Se crea el catalogo de operadores

        // Se crean variables para las funciones de busqueda
        int numSimbolos, numLitCad, numLitNum, numTokens;

        // Funcion para obtener el valor en el catalogo de palabras reservadas
        int Palabras_res(char* pal)
        {
            // Asignamos el valor con un ciclo for
            for (int i = 0; i < 17; i++) {
                catalogoRes[i].valor = i;
                }
            
            // Agregamos las palabras reservadas al catalogo
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
            
            // Con busqueda lineal revisamos si la palabra coincide con la palabra reservada
            for (int i = 0; i < 17; i++) { //EN CASO DE QUE EXISTA LA PALABRA RESERVADA Y LA COMPARAMOS CON PAL, ENTONCES VAMOS A RETORNAR EL VALOR DEL CATALOGO DE ARRIBA.
                if (strcmp(pal, catalogoRes[i].palabra) == 0) {
                    // Si coincide regresamos el valor en la tabla de palabras reservadas
                    return catalogoRes[i].valor;
                    }
                }
            // Si no encontramos la palabra
            return -1;
        }
        
        // Funcion para obtener el valor en el catalogo de OPERADORES RELACIONALES
        int Operadores_rel(char* Op)
        {
            // Asignamos el valor con un ciclo for
            for (int i = 0; i < 7; i++) {
                catalogoOp[i].valor=i;
            }
            
            // Agregamos los operadores al catalogo
            strcpy(catalogoOp[0].op, "^^");
  	    strcpy(catalogoOp[1].op, "^\"");
 	    strcpy(catalogoOp[2].op, "==");
 	    strcpy(catalogoOp[3].op, "^^=");
	    strcpy(catalogoOp[4].op, "^\"=");
 	    strcpy(catalogoOp[5].op, "<>");

            // Con busqueda lineal revisamos si el op coincide con el operador
            for (int i = 0; i < 32; i++) {
                if (strcmp(Op, catalogoOp[i].op) == 0) {
                    // Si coincide regresamos el valor en la tabla de operadores
                    return catalogoOp[i].valor;
                }
            }
            
            // Si no encontramos el operador
            return -1;
        }

	// Funcion para obtener el valor en el catalogo de OPERADORES DE ASIGNACIÓN

	int Operadores_asig(char* Op)
        {
            // Asignamos el valor con un ciclo for
            for (int i = 7; i < 13; i++) {
                catalogoOp[i].valor=i;
            }
            
            // Agregamos los operadores al catalogo
            strcpy(catalogoOp[7].op, "~");
  	    strcpy(catalogoOp[8].op, "+~");
 	    strcpy(catalogoOp[9].op, "-~");
 	    strcpy(catalogoOp[10].op, "*~");
	    strcpy(catalogoOp[11].op, "/~");
 	    strcpy(catalogoOp[12].op, "$~");

	    // Con busqueda lineal revisamos si el op coincide con el operador
            for (int i = 0; i < 32; i++) {
                if (strcmp(Op, catalogoOp[i].op) == 0) {
                    // Si coincide regresamos el valor en la tabla de operadores
                    return catalogoOp[i].valor;
                }
            }
            
            // Si no encontramos el operador
            return -1;
        }



	//Funcion para obetenr el catalogo de 

        // Funcion para busqueda lineal de la posicion en la tabla de simbolos
        int posTabSimb(char* nombre) {
            for (int i = 0; i < numSimbolos; i++) {
                // Si encontramos una coincidencia devolvemos la posicion
                if (strcmp(tablaSimbolos[i].nombre, nombre) == 0) {
                    return tablaSimbolos[i].posicion;
                }
            }
            return -1;  
        }


        // Funcion para busqueda linela de la posicion en la tabla de literales de cadena
        int posTabLitCads(char* dato) {
            for (int i = 0; i < numLitCad; i++) {
                // Si encontramos una coincidencia devolvemos la posicion
                if (strcmp(tablaLiteralesCadenas[i].dato, dato) == 0) {
                    return tablaLiteralesCadenas[i].posicion;
                }
            }
            return -1; 
        }

        // Funcion para busqueda lineal de la posicion en la tabla de literales numericas
        int posTabLitNum(char* dato) {
            for (int i = 0; i < numLitNum; i++) {
                // Si encontramos una coincidencia devolvemos la posicion
                if (strcmp(tablaLiteralesNumericas[i].dato, dato) == 0) {
                    return tablaLiteralesNumericas[i].posicion;
                }
            }
            return -1;  // No encontrado
        }

        // Función que busca un id en el arreglo de simbolos
        int buscaTabSimb(char* nombre) {
            for (int i = 0; i < numSimbolos; i++) {
                if (strcmp(tablaSimbolos[i].nombre, nombre) == 0) {
                    return i;
                }
            }
            return -1;  
        }

        // Función que busca un id en el arreglo de literales cadena
        int buscaTabLitCads(char* dato) {
            for (int i = 0; i < numLitCad; i++) {
                if (strcmp(tablaLiteralesCadenas[i].dato, dato) == 0) {
                    return i;
                }
            }
            return -1; 
        }

        // Función que busca un id en el arreglo de literales numericas
        int buscaTabLitNum(char* dato) {
            for (int i = 0; i < numLitNum; i++) {
                if (strcmp(tablaLiteralesNumericas[i].dato, dato) == 0) {
                    return i;
                }
            }
            return -1;  // No encontrado
        }


        // asignar átomos de palabras reservadas según la tabla del PDF
	// REVISAR SI LAS PALABRAS RESERVADAS LAS METEMOS DIRECTO EN ESTA PARTE
    char asignarAtomoPalRes(char *palabra) {
        if (strcmp(palabra, "cadena") == 0) return 'h';
        if (strcmp(palabra, "caracter") == 0) return 'g';
        if (strcmp(palabra, "else") == 0) return 'e';
        if (strcmp(palabra, "entero") == 0) return 'n';
        if (strcmp(palabra, "for") == 0) return 'f';
        if (strcmp(palabra, "if") == 0) return 'i';
        if (strcmp(palabra, "real") == 0) return 'd';
        if (strcmp(palabra, "return") == 0) return 'b';
        if (strcmp(palabra, "void") == 0) return 'v';
        if (strcmp(palabra, "while") == 0) return 'w';
        return 'N'; // No encontrado
    }


    char asignarAtomoSimEspe(const char* palabra){
        if (strcmp(palabra, "(") == 0) {
            return '(';
        } else if (strcmp(palabra, ")") == 0) {
            return ')';
        } else if (strcmp(palabra, "(") == 0) {
            return '(';
        } else if (strcmp(palabra, "{") == 0) {
            return '{';
        } else if (strcmp(palabra, "}") == 0) {
            return '}';
        }  else if (strcmp(palabra, "[") == 0) {
            return '[';
        } else if (strcmp(palabra, "]") == 0) {
            return ']';
        }else if (strcmp(palabra, "&") == 0) {
            return '&';
        } else if (strcmp(palabra, ",") == 0) {
            return ',';
        } else if (strcmp(palabra, ":") == 0) {
            return ':';
        } else {
            return 'N'; // Valor por defecto si no se encuentra la palabra
        }
    }


    char asignarAtomoOpArit(const char* palabra) {
        if (strcmp(palabra, "+") == 0) {
            return '+';
        } else if (strcmp(palabra, "-") == 0) {
            return '-';
        } else if (strcmp(palabra, "*") == 0) {
            return '*';
        } else if (strcmp(palabra, "/") == 0) {
            return '/';
        } else if (strcmp(palabra, "$") == 0) { 
            return '$';
        } else {
            return 'N'; // Valor por defecto si no se encuentra la palabra
        }
    }

    //Operadores relacionales según los valores de la tabla
    char asignarAtomoOpRel(const char* op) {
        if (strcmp(op, "^^") == 0) return '>';
        if (strcmp(op, "^\"") == 0) return '<';
        if (strcmp(op, "==") == 0) return '?';
        if (strcmp(op, "^^=") == 0) return 'y';
        if (strcmp(op, "^\"=") == 0) return 'l';
        if (strcmp(op, "<>") == 0) return '¿';
        return 'N'; // No encontrado
    }

    // REVISAR AL CREACION DE LA TABLA DE OP.ASIGNACION
    char asignarAtomoOpAsig(const char* op) {
        if (strcmp(op, "~") == 0) return '=';
        if (strcmp(op, "+~") == 0) return 'm';
        if (strcmp(op, "-~") == 0) return 'k';
        if (strcmp(op, "*~") == 0) return 'p';
        if (strcmp(op, "/~") == 0) return 't';
        if (strcmp(op, "$~") == 0) return 'u';
        return 'N'; // No encontrado
    }


    // AQUI SE DEFINIRAN LAS EXPRESIONES REGULARES PARA LOS COMPONENTES LEXICOS

    %}

%option noyywrap

%%

// PARA PALABRAS RESERVADAS CLASE 0, LOS ATOMOS DE ESTA PARTE SE ENCUENTRA EN 


"cadena"|"caracter"|"else"|"entero"|"for"|"if"|"real"|"return"|"void"|"while" {
    printf("[Clase 0] Palabra reservada: %s\n", yytext);
    int val = Palabras_res(yytext);
    char cadena[20];
    tokens[numTokens].clase = 0;
    sprintf(cadena, "%d", val);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = asignarAtomoPalRes(yytext); // ASIGNA EL ATOMO
    strcat(cadenaAtomos, &tokens[numTokens].atomo); // Agrega el atomo a la cadena de atomos
    numTokens++;
}


// PARA CLASE 1, REFERENTE A LOS OPERADORES ARITMETICOS 


"+"|"-"|"*"|"/"|"$" {
    printf("[Clase 1] Operador aritmético: %s\n", yytext);
    tokens[numTokens].clase = 1;
    strcpy(tokens[numTokens].valor, yytext);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = asignarAtomoOpArit(yytext); // ASIGNA EL ATOMO
    strcat(cadenaAtomos, &tokens[numTokens].atomo); // Agrega el atomo a la cadena de atomos
    numTokens++;
}

// PARA CLASE 2, REFERENTE A LA TABLA DE OPERADORES DE ASIGNACION

"~"|"+~""|"-~"|"*~"|"/~"|"$~" { 

	printf("[Clase 2] Operador de asignacion: %s\n", yytext);
	int val = Operadores_asig(yytext);
	char cadena[20];
	// Almacena la información del token
	tokens[numTokens].clase = 2;
	sprintf(cadena, "%d", val);
	strcpy(tokens[numTokens].valor, cadena);
	strcpy(tokens[numTokens].info, yytext);
	tokens[numTokens].atomo = *asignarAtomoOpAsig(yytext); // ASIGNA EL ATOMO
	strcat(cadenaAtomos, &tokens[numTokens].atomo); // Agrega el atomo a la cadena de atomos
        numTokens++;
}


// PARA CLASE 3, REFERENTE A LOS SIMBOLOS ESPECIALES


")"|"("|"{"|"}"|"["|"]"|"&"|","|":" { 

	printf("[Clase 3] Simbolo especial: %s\n", yytext);      
	// Almacena la información del token
        tokens[numTokens].clase = 3;
        strcpy(tokens[numTokens].valor, yytext);
        strcpy(tokens[numTokens].info, yytext);
        tokens[numTokens].atomo = asignarAtomoSimEspe(yytext); // ASIGNA EL ATOMO
        strcat(cadenaAtomos, &tokens[numTokens].atomo); // Agrega el atomo a la cadena de atomos
        numTokens++; 
}

// PARA CLASE 4, REFERENTE A LA TABLA DE OPERADORES RELACIONALES

"^^"|"^\""|"=="|"^^=""|"^\"="|"<>" { 

	printf("[Clase 7] Operador relacional: %s\n", yytext);
	int val = Operadores_rel(yytext);
	char cadena[20];
	// Almacena la información del token
	tokens[numTokens].clase = 4;
	sprintf(cadena, "%d", val);
	strcpy(tokens[numTokens].valor, cadena);
	strcpy(tokens[numTokens].info, yytext);
	tokens[numTokens].atomo = *asignarAtomoOpRel(yytext); // ASIGNA EL ATOMO
	strcat(cadenaAtomos, &tokens[numTokens].atomo); // Agrega el atomo a la cadena de atomos
        numTokens++;
}

// PARA CLASE 5, LEER LAS ESPECIFICACIONES EN LA TABLA DEL PDF

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
    tokens[numTokens].clase = 5;
    sprintf(cadena, "%d", tablaSimbolos[pos].posicion);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = 'a'; // ASIGNANDO EL ATOMO
     strcat(cadenaAtomos, &tokens[numTokens].atomo); // Agrega el atomo a la cadena de atomos
    numTokens++;
}


// PARA CLASE 6, LEER LAS ESPECIFICACIONES EN LA TABLA DEL PDF

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
    tokens[numTokens].clase = 6;
    val = posTabLitNum(yytext);
    sprintf(cadena, "%d", val);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = 'z'; // ASIGNANDO EL ATOMO
    strcat(cadenaAtomos, &tokens[numTokens].atomo); // Agrega el atomo a la cadena de atomos
    numTokens++;
}

// PARA CLASE 7, LEER LAS ESPECIFICACIONES EN LA TABLA DEL PDF

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
    tokens[numTokens].clase = 7;
    val = posTabLitNum(yytext);
    sprintf(cadena, "%d", val);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = 'r'; // ASIGNANDO EL ATOMO
    strcat(cadenaAtomos, &tokens[numTokens].atomo); // Agrega el atomo a la cadena de atomos
    numTokens++;
}

// PARA CLASE 8, LEER LAS ESPECIFICACIONES EN LA TABLA DEL PDF

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
    tokens[numTokens].clase = 8;
    val = posTabLitCads(yytext);
    sprintf(cadena, "%d", val);
    strcpy(tokens[numTokens].valor, cadena);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = 's'; // ASIGNANDO EL ATOMO 
    strcat(cadenaAtomos, &tokens[numTokens].atomo); // Agrega el atomo a la cadena de atomos       
    numTokens++;
}


// PARA CLASE 9, LEER LAS ESPECIFICACIONES EN LA TABLA DEL PDF


\'[^\']\' {
    printf("[Clase 5] Carácter válido: %s\n", yytext);
    tokens[numTokens].clase = 9;
    strcpy(tokens[numTokens].valor, yytext);
    strcpy(tokens[numTokens].info, yytext);
    tokens[numTokens].atomo = 'c'; // ASIGNANDO EL ATOMO 
    strcat(cadenaAtomos, &tokens[numTokens].atomo); // Agrega el atomo a la cadena de atomos  
    numTokens++;
}

[ \t\n]+            ;  // Ignora espacios, tabuladores y saltos de línea

.                   {
                        fprintf(stderr, "No se reconoce el caracter (%s)\n", yytext); // No reconoce el caracter
                    }



%%

int main(int argc, char** argv) {

    
    printf("\n<--> BIENVENIDO AL PROGRAMA ANALIZADOR LEXICO Y SINTACTICO <-->\n");
    printf("  <-->                      DESCENDENTE RECURSIVO            <-->\n\n");
    printf("A continuacion se empezara a analizar el archivo que ha introducido al arrancar el programa\n");
    printf("empezando con la definicion de las clases de cada sentencia del programa que se esta evaluando\n\n");
    system("pause");



    if (argc != 2) {
        fprintf(stderr, "Uso: %s <archivo_de_entrada>\n", argv[0]);
        return 1;
    }

    FILE* archivo = fopen(argv[1], "r"); // Abre el archivo que se va a analizar
    if (archivo == NULL) {
        fprintf(stderr, "Error al abrir el archivo :c: %s\n", argv[1]); 
        return 1; // Si hay algun error en abrir el archivo, devuelve un error
    }

    yyin = archivo;
    yylex();

    printf("Ya definidas las clases de cada una de las sentencias, se empezaran a mostrar en sus\n");
    printf("respectivas tablas, para una mejor organizacion\n\n");
    system("pause");

    // Muestra la tabla de símbolos
    printf("\n\nTabla de simbolos:\n");
    printf("Posicion | Nombre         | Tipo\n");
    printf("-----------------------------\n");
    for (int i = 0; i < numSimbolos; i++) { // Se leen los arreglos y se generan sus tablas
        printf("%8d | %-14s | %d\n", tablaSimbolos[i].posicion, tablaSimbolos[i].nombre, tablaSimbolos[i].tipo);
    }

    // Muestra la tabla de literales de cadenas
    printf("\n\nTabla de literales de cadenas:\n");
    printf("Posicion | Dato\n");
    printf("------------------\n");
    for (int i = 0; i < numLitCad; i++) { // Se leen los arreglos y se generan sus tablas
        printf("%8d | %-s\n", tablaLiteralesCadenas[i].posicion, tablaLiteralesCadenas[i].dato);
    }

    // Muestra la tabla de literales numericas
    printf("\n\nTabla de literales numericas:\n");
    printf("Posicion | Dato\n");
    printf("------------------\n");
    for (int i = 0; i < numLitNum; i++) { // Se leen los arreglos y se generan sus tablas
        printf("%8d | %-s\n", tablaLiteralesNumericas[i].posicion, tablaLiteralesNumericas[i].dato);
    }

    // Mostrar los tokens generados
    printf("\n\nTokens generados:\n");
    printf("Clase | Valor | Info   \t| Atomo\n");
    printf("----------------------\n");
    for (int i = 0; i < numTokens; i++) { // Se leen los arreglos y se generan sus tablas
        printf("%5d | %-4s | %-s  \t| %-c \n", tokens[i].clase, tokens[i].valor, tokens[i].info, tokens[i].atomo);
    }

    // Mostrar la cadena de atomos generados
    printf("\n\nCadena de atomos encontrados: %s\n", cadenaAtomos); // Imprime la cadena de atomos encontrados

    next_atomo = tokens[n].atomo;
    Program();
    printf("ANALISIS SINTACTICO REALIZADO CON EXITO\n");

    fclose(archivo);

    return 0;
}

//Función para analisis del terminal Program de la gramatica del lenguaje
void Program(){
    printf("Program\n");
    if(next_atomo=='#' || next_atomo=='b' || next_atomo=='g' || next_atomo=='x' || next_atomo=='y'){
        Func();
        if(next_atomo=='}'&&(tokens[n+1].atomo=='#'||tokens[n+1].atomo=='b'||tokens[n+1].atomo=='g'||tokens[n+1].atomo=='x'||tokens[n+1].atomo=='y')){
            n++;
            next_atomo= tokens[n].atomo;
            otraFunc();
        }else if(next_atomo=='}'&& (n==numTokens-1)){

        }else{
            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba otra funcion \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la funcion correspondiente
            exit(0);
        }
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un tipo de dato \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar un tipo de dato correspondiente
        exit(0);
    }
}

//Función para analisis de terminal otraFunc de la gramatica del lenguaje
void otraFunc(){
    //strcmp(palabra, ">") == 0
    if(next_atomo=='#' || next_atomo=='b' || next_atomo=='g' || next_atomo=='x' || next_atomo=='y'){
        Func();
    }
}

//Función para analisis de terminal Func de la gramatica del lenguaje
void Func(){
    printf("Func:  next_atomo %c",next_atomo);
    if(next_atomo=='#' || next_atomo=='b' || next_atomo=='g' || next_atomo=='x' || next_atomo=='y'){
        Tipo();
        if(next_atomo=='i'){
            n++;
            next_atomo= tokens[n].atomo;
            if(next_atomo=='('){
                n++;
                next_atomo= tokens[n].atomo;
                if(next_atomo=='#' || next_atomo=='b' || next_atomo=='g' || next_atomo=='x' || next_atomo=='y'){
                    Param();
                    if(next_atomo==')'){
                        n++;
                        next_atomo= tokens[n].atomo;
                        if(next_atomo=='{'){
                            n++;
                            next_atomo= tokens[n].atomo;
                            if(next_atomo=='#' || next_atomo=='b' || next_atomo=='g' || next_atomo=='x' || next_atomo=='y'){
                                Cuerpo();
                            }else if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){
                                Cuerpo();
                            }else{
                                printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una declaracion o una lista de parametros\n",next_atomo,n);
                                exit(0);
                            }
                        }else{
                            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un { \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la { correspondiente
                            exit(0);
                        }
                    }else{
                        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un ) \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el ) correspondiente
                        exit(0);
                    }
                }else if(next_atomo==')'){
                    n++;
                    next_atomo= tokens[n].atomo;
                    if(next_atomo=='{'){
                        n++;
                        next_atomo= tokens[n].atomo;
                        if(next_atomo=='#' || next_atomo=='b' || next_atomo=='g' || next_atomo=='x' || next_atomo=='y'){
                            Cuerpo();
                        }else if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){
                            Cuerpo();
                        }else{
                            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una declaracion o una lista de parametros\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar una declaracion o lista de parametros correspondiente 
                            exit(0);
                        }
                    }else{
                        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un { \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la { correspondiente
                        exit(0);
                    }
                }else{
                    printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un tipo de dato \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar un tipo de dato correspondiente
                    exit(0);
                }
            }else{
                printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un ( \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar un ( correspondiente
                exit(0);
            }
        }else{
            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un identificador \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el identificador correspondiente
            exit(0);
        }
    }
}

//Función para analisis del terminal Tipo de la gramatica del lenguaje
void Tipo(){
    if(next_atomo=='#' || next_atomo=='b' || next_atomo=='g' || next_atomo=='x' || next_atomo=='y'){
        n++; 
        next_atomo= tokens[n].atomo;
    }
}

//Función para analisis del terminal Param de la gramatica del lenguaje
void Param(){
    if(next_atomo=='#' || next_atomo=='b' || next_atomo=='g' || next_atomo=='x' || next_atomo=='y'){
        Tipo();
        if(next_atomo=='i'){
            n++;
            next_atomo= tokens[n].atomo;
            if(next_atomo==',' ){
                otroParam();
            }else if(next_atomo==')'){

            }
        }
    }
}

//Función para analisis del terminal otroParam de la gramatica del lenguaje
void otroParam(){
    if(next_atomo==','){
        n++;
        next_atomo= tokens[n].atomo;
        Param();
    }
}

//Función para analisis del terminal Cuerpo de la gramatica del lenguaje
void Cuerpo(){
    printf("Cuerpo:  next_atomo %c\n",next_atomo);
    if(next_atomo=='#' || next_atomo=='b' || next_atomo=='g' || next_atomo=='x' || next_atomo=='y'){
        Decl();
        if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){
            listaP();
        }
    }else if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){
        listaP();
    }else if(next_atomo=='}'){

    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una declaracion de variables o una lista de parametros \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar una declaracion de variablesmo lista de parametros correspondiente
        exit(0);
    }
}

//Función para analisis del terminal Decl de la gramatica del lenguaje
void Decl(){
    if(next_atomo=='#' || next_atomo=='b' || next_atomo=='g' || next_atomo=='x' || next_atomo=='y'){
        D();
        if(next_atomo=='#' || next_atomo=='b' || next_atomo=='g' || next_atomo=='x' || next_atomo=='y'){
            Decl();
        }
    }
}

//Función para analisis del terminal D de la gramatica del lenguaje
void D(){
    if(next_atomo=='#' || next_atomo=='b' || next_atomo=='g' || next_atomo=='x' || next_atomo=='y'){
        printf("D_antTipo:  next_atomo %c\n",next_atomo);
        Tipo();
        if(next_atomo=='i'){
            printf("D_desTipo:  next_atomo %c\n",next_atomo);
            K();
            if(next_atomo==';'){
                n++;
                next_atomo= tokens[n].atomo;
            }
        }else{
            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un identificador \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el identificador correspondiente
            exit(0);
        }
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un tipo de dato \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el tipo de dato correspondiente
        exit(0);
    }
}

//Función para analisis del terminal K de la gramatica del lenguaje 
void K(){
    if(next_atomo=='i'){
        n++;
        next_atomo= tokens[n].atomo;
        printf("K:  next_atomo %c\n",next_atomo);
        if(next_atomo=='='||next_atomo==','){
            Q();
        }else if(next_atomo==';'){

        }
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un identificador \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el identificador correspondiente
        exit(0);
    }
}

//Función para analisis del terminal Q de la gramatica del lenguaje
void Q(){
    printf("Q:  next_atomo %c\n",next_atomo);
    if(next_atomo=='='){
        n++;
        next_atomo= tokens[n].atomo;
        printf("Q_if1:  next_atomo %c\n",next_atomo);
        if(next_atomo=='n' || next_atomo=='r'|| next_atomo=='s'){
            N();
            if(next_atomo==','){
                C();
            }else if(next_atomo==';'){

            }
        }else{
            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una constante cadena, entera o real \n",next_atomo,n); //Muestra un letrero de error en caso de no encontar una constante correspondiente
            exit(0);
        }
    }else if(next_atomo==';'){

    }
}

//Función para analisis del terminal N de la gramatica del lenguaje
void N(){
    if(next_atomo=='n' || next_atomo=='r'|| next_atomo=='s'){
        n++;
        next_atomo= tokens[n].atomo;
        printf("N_if:  next_atomo %c\n",next_atomo);
    }
}

//Función para analisis del terminal C de la gramtaica del lenguaje
void C(){
    if(next_atomo==','){
        n++;
        next_atomo= tokens[n].atomo;
        K();
    }else if(next_atomo==';'){

    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una , \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la , correspondiente
        exit(0);
    }
}

//Función para analisis del terminal listaP de la gramatica del lenguaje
void listaP(){
    printf("listaP:  next_atomo %c\n",next_atomo);
    //if(next_atomo==';' && tokens[n+1].atomo=='i'){
    if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){
        P();
        if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){
            listaP();
        }else if(next_atomo=='}'){

        }
    }else if(next_atomo=='}'){

    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una palabra reservada o un identificador \n",next_atomo,n); //Muestra un letrero de error en caso de no encontra la palabra reservada o identificador correspondiente
        exit(0);
    }
}

//Función para analisis del terminal P de la gramatica del lenguaje
void P(){
    printf("P:  next_atomo %c\n",next_atomo);
    if(next_atomo=='i'){
        A();
        if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){
            P();
        }
    }else if(next_atomo=='f'){
        I();
        if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){
            P();
        }
    }else if(next_atomo=='h'){
        H();
        if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){
            P();
        }
    }else if(next_atomo=='w'){
        W();
        if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){
            P();
        }
    }else if(next_atomo=='j'){
        J();
        if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){
            P();
        }
    }else if(next_atomo=='['){
        Llama();
        if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){
            P();
        }
    }else if(next_atomo=='z'){
        Devuelve();
        printf("P()_dDevuelve: %c\n",next_atomo);
        if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){
            P();
        }
    }else if(next_atomo=='c'){
        n++;
        next_atomo= tokens[n].atomo;
        if(next_atomo==';'){
            n++;
            next_atomo= tokens[n].atomo;
            if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){
                P();
            }
        }
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una palabra reservada o un identificador \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la palabra reservada o identificador correspondiente
        exit(0);
    }
}

//Función para analisis del terminal A de la gramatica del lenguaje
void A(){
    printf("A:  next_atomo %c\n",next_atomo);
    if(next_atomo=='i'){
        n++;
        next_atomo= tokens[n].atomo;
        if(next_atomo=='='){
            n++;
            next_atomo= tokens[n].atomo;
            printf("A_if2:  next_atomo %c\n",next_atomo);
            if(next_atomo=='s'||next_atomo=='('||next_atomo=='i'||next_atomo=='n'||next_atomo=='r'||next_atomo=='['){
                AP();
                if(next_atomo==';'){
                    n++;
                    next_atomo= tokens[n].atomo;
                }else{
                    printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un ;\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el ; correspondiente                    
						  exit(0);
                }
            }else{
                printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una constante cadena o (\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la constante cadena correspondiente
                exit(0);
            }
        }else{
            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un =\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el = ci=orrespondiente
				exit(0);
        }
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un identificador \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el identificador correspondiente
        exit(0);
    }
}

//Función para analisis del terminal AP de la gramatica del lenguaje
void AP(){
    printf("AP_aif1:  next_atomo %c\n",next_atomo);
    if(next_atomo=='s'){
        n++;
        next_atomo= tokens[n].atomo;
    }else if(next_atomo=='('||next_atomo=='i'||next_atomo=='n'||next_atomo=='r'){
        E();
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una constante cadena, numerica, real o un identificador \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la constante correspondiente
        exit(0);
    }
}

//Función para analisis del terminal E de la gramatica del lenguaje
void E(){
    if(next_atomo=='('||next_atomo=='i'||next_atomo=='n'||next_atomo=='r'||next_atomo=='['){
        T();
        if(next_atomo=='+'||next_atomo=='-'){
            EP();
        }
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una constante numerica, real, un identificador o un ( \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la constante correspondiente
        exit(0);
    }
}

//Función para analisis del terminal EP de la gramatica del lenguaje
void EP(){
    if(next_atomo=='+' ||next_atomo=='-'){
        n++;
        next_atomo= tokens[n].atomo;
        T();
        if(next_atomo=='+'||next_atomo=='-'){
            EP();
        }
    }
}

//Función para analisis del terminal T de la gramatica del lenguaje
void T(){
    if(next_atomo=='('||next_atomo=='i'||next_atomo=='n'||next_atomo=='r'||next_atomo=='['){
        F();
        printf("T()_dF(): next_atomo %c\n",next_atomo);
        if(next_atomo=='*' || next_atomo=='/'||next_atomo=='\\'||next_atomo=='%'||next_atomo=='^'){
            printf("T()_aTP(): next_atomo %c\n",next_atomo);
            TP();
        }else if(next_atomo==';'){
            
        }else if(next_atomo=='+'||next_atomo=='-'){
            
        }
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una constante numerica, real, un identificador un ( o un [ \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la constante correspondiente
        exit(0);
    }
}

//Función para analisis del terminal F de la gramatica del lenguaje
void F(){
    if(next_atomo=='('){
        n++;
        next_atomo= tokens[n].atomo;
        if(next_atomo=='('||next_atomo=='i'||next_atomo=='n'||next_atomo=='r'){
            E();
            if(next_atomo==')'){
                n++;
                next_atomo= tokens[n].atomo;
            }else{
                printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una ) \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el ) correspondiente
					 exit(0);
            }
        }else{
            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una constante numerica, real, un identificador o un ( \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la constante correspondiente
            exit(0);
        }
    }else if(next_atomo=='i'||next_atomo=='n'||next_atomo=='r'){
        n++;
        next_atomo= tokens[n].atomo;
        printf("F_if2:  next_atomo %c\n",next_atomo);
    }else if(next_atomo=='['){
        Llama();
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una constante numerica, real, un identificador, un ( o [ \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la constante correspondiente
        exit(0);
    }
}

//Función para analisis del terminal Llama de la gramatica del lenguaje
void Llama(){
    if(next_atomo=='['){
        n++;
        next_atomo= tokens[n].atomo;
        if(next_atomo=='i'){
            n++;
            next_atomo= tokens[n].atomo;
            if(next_atomo=='('){
                n++;
                next_atomo= tokens[n].atomo;
                if(next_atomo=='i'||next_atomo=='n'||next_atomo=='r'||next_atomo=='s'){
                    arg();
                    if(next_atomo==')'){
                        n++;
                        next_atomo=tokens[n].atomo;
                        if(next_atomo==']'){
                            n++;
                            next_atomo=tokens[n].atomo;
                        }
                    }
                }else if(next_atomo==')'){
                    n++;
                    next_atomo=tokens[n].atomo;
                    if(next_atomo==']'){
                        n++;
                        next_atomo=tokens[n].atomo;
                    }else{
                        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un ]\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el ] correspondiente
                        exit(0);
                    }
                }else{
                    printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una constante cadena, entera, real o un identificador\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la constante correspondiente
                    exit(0);
                }
            }else{
                printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una (\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el ( correspondiente
                exit(0);
            }
        }else{
            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un identificador\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el identificador correspondiente
            exit(0);
        }
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una [\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la  [ correspondiente
        exit(0);
    }
}

//Función para analisis del terminal arg de la gramatica del lenguaje
void arg(){
    if(next_atomo=='i'||next_atomo=='n'||next_atomo=='r'||next_atomo=='s'){
        V();
        if(next_atomo==','){
            otroArg();
        }else{
            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una ,\n",next_atomo,n);
            exit(0);
        }
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una constante cadena, entera, real o un identificador\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la constante correspondiente
        exit(0);
    }
}

//Función para analisis del terminal otroArg de la gramatica del lenguaje
void otroArg(){
    if(next_atomo==','){
        n++;
        next_atomo=tokens[n].atomo;
        if(next_atomo=='i'||next_atomo=='n'||next_atomo=='r'||next_atomo=='s'){
            V();
            if(next_atomo==','){
                otroArg();
            }
        }else{
            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una constante cadena, entera, real o un identificador\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la constante correspondiente
            exit(0);
        }
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una ,\n",next_atomo,n); //Muestra un letrero de error en caso de no encontar la , correspondiente
        exit(0);
    }
}

//Función para analisis del terminal V de la gramatica del lenguaje
void V(){
    if(tokens[n].atomo=='i'||tokens[n].atomo=='n'||tokens[n].atomo=='r'||tokens[n].atomo=='s'){
        n++;
        next_atomo=tokens[n].atomo;
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una constante cadena, entera, real o un identificador\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la constante correspondiente
        exit(0);
    }
}

//Función para analisis del terminal TP de la gramatica del lenguaje
void TP(){
    if(next_atomo=='*' || next_atomo=='/'||next_atomo=='\\'||next_atomo=='%'||next_atomo=='^'||next_atomo=='+'||next_atomo=='-'){
        n++;
        next_atomo= tokens[n].atomo;
        printf("TP()_aF(): next_atomo %c\n",next_atomo);
        F();
        printf("TP()_aTP(): next_atomo %c\n",next_atomo);
        if(next_atomo=='*' || next_atomo=='/'||next_atomo=='\\'||next_atomo=='%'||next_atomo=='^'||next_atomo=='+'||next_atomo=='-'){
            TP();
            printf("T()_dTP(): next_atomo %c\n",next_atomo);
        }else if(next_atomo==';'){

        }else{
            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un operador aritmetico o ; \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el operador correspondiente
            exit(0);
        }
    }else if(next_atomo==';'){

    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un operador aritmetico o ; \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el operador correspondiente
        exit(0);
    }
}

//Función para analisis del terminal I de la gramatica del lenguaje
void I(){
    if(next_atomo=='f'){
        n++;
        next_atomo= tokens[n].atomo;
        if(next_atomo=='('){
            n++;
            next_atomo= tokens[n].atomo;
            R();
            if(next_atomo==')'){
                n++;
                next_atomo= tokens[n].atomo;
                if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){ //Falta agregar hasta que termine P()
                    listaP();
                    if(next_atomo=='t'){
                        IP();
                        if(next_atomo==':'){
                            n++;
                            next_atomo= tokens[n].atomo;
                        }else{
                            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba :\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el : correspondiente
                            exit(0);
                        }
                    }else{
                        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un else \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el else correspondiente
                        exit(0);
                    }
                }else if(next_atomo==':'){
                    
                }else{
                    printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba la declaracion de un parametro\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la declaracion correspondinente
                    exit(0);
                }
            }else{
                printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un )\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el ) correspondiente
                exit(0);
            }
        }else{
            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un (\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el ( correspondiente
            exit(0);
        }
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un if \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el if correspondiente
        exit(0);
    }
}

//Función para analisis del terminal R de la gramatica del lenguaje
void R(){
    if(next_atomo=='i'||next_atomo=='n'||next_atomo=='r'||next_atomo=='s'){
        n++;
        next_atomo= tokens[n].atomo;
        if(next_atomo=='>'||next_atomo=='<'||next_atomo=='l'||next_atomo=='e'||next_atomo=='d'||next_atomo=='u'){
            RP();
            if(tokens[n].atomo=='i'||tokens[n].atomo=='n'||tokens[n].atomo=='r'||tokens[n].atomo=='s'){
                V();
            }else{
                printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una constante cadena, entera, real o un identificador\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la constante correspondiente
                exit(0);
            }
        }else{
            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un operador relacional\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el operador correspondiente
            exit(0);
        }
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una constante cadena, entera, real o un identificador\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la constante correspondiente
        exit(0);
    }
}

//Función para analisis del terminal RP de la gramatica del lenguaje
void RP(){
    if(next_atomo=='>'||next_atomo=='<'||next_atomo=='l'||next_atomo=='e'||next_atomo=='d'||next_atomo=='u'){
        n++;
        next_atomo= tokens[n].atomo;
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un operador relacional\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el operador correspondiente
        exit(0);
    }
}

//Función para analisis del terminal IP de la gramatica del lenguaje
void IP(){
    if(next_atomo=='t'){
        n++;
        next_atomo= tokens[n].atomo;
        listaP();
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un else\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el else correspondiente
		  exit(0);
    }
}

//Función para analisis del terminal H de la gramatica del lenguaje
void H(){
    if(next_atomo=='h'){
        n++;
        next_atomo= tokens[n].atomo;
        if(next_atomo=='('){
            n++;
            next_atomo= tokens[n].atomo;
            if(next_atomo=='i'){
                n++;
                next_atomo= tokens[n].atomo;
                if(next_atomo==')'){
                    n++;
                    next_atomo= tokens[n].atomo;
                    if(next_atomo=='{'){
                        n++;
                        next_atomo= tokens[n].atomo;
                        if(next_atomo=='a'){
                            CP();
                            if(next_atomo=='o'){
                                OP();
                            }
                        }else if(next_atomo=='o'){
                            OP();
                        }else if(next_atomo=='}'){
                            n++;
                            next_atomo= tokens[n].atomo;
                        }else{
                            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un case o default\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el case o default correspondiente
                            exit(0);
                        }
                    }else{
                        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un {\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la { correspondiente
                        exit(0);
                    }
                }else{
                    printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un ) \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el ) correspondiente
                    exit(0);
                }
            }else{
                printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un identificador \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el identificador correspondiente
                exit(0);
            }
        }else{
            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un ( \n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el ( correspondiente
            exit(0);
        }
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un switch\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el switch correspondiente
        exit(0);
    }
}

//Función para analisis del terminal CP de la gramatica del lenguaje
void CP(){
    if(next_atomo=='a'){
        n++;
        next_atomo= tokens[n].atomo;
        if(next_atomo=='n'){
            n++;
            next_atomo= tokens[n].atomo;
            if(next_atomo==':'){
                n++;
                next_atomo= tokens[n].atomo;
                if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){//Actualizar cuando termine P()
                    listaP();
                    if(next_atomo=='q'){
                        U();
                        if(next_atomo=='a'){
                            CP();
                        }
                    }else if(next_atomo=='a'){
                        CP();
                    }else{
                        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un break o un case\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el break o case correspondiente
                        exit(0);
                    }
                }else{
                    printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un nuevo parametro\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el nuevo parametro correspondiente
                    exit(0);
                }
            }else{
                printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un :\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el : correspondiente
                exit(0);
            }
        }else{
            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una constante numerica\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la contante correspondiente
            exit(0);
        }
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un case\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el case correspondiente
        exit(0);
    }
}

//Función para analisis del terminal U de la gramatica del lenguaje
void U(){
    if(next_atomo=='q'){
        n++;
        next_atomo= tokens[n].atomo;
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un break\n",next_atomo,n); //Muestra un letrero de error en caso de no encontra el break correspondiente
        exit(0);
    }
}

//Función para analisis del terminal OP de la gramatica del lenguaje
void OP(){
    if(next_atomo=='o'){
        n++;
        next_atomo= tokens[n].atomo;
        if(next_atomo==':'){
            n++;
            next_atomo= tokens[n].atomo;
            if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){//Actualizar cuando termine P()
                listaP();
            }else{
                printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba una declaracion de parametros\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar la declaracion de parametros correspondiente
                exit(0);
            }
        }else{
            printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un :\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el : correspondiente
            exit(0);
        }
    }else{
        printf("Error de sintaxis en el atomo %c en la posicion %d. Se esperaba un default\n",next_atomo,n); //Muestra un letrero de error en caso de no encontrar el atomo correspondiente
        exit(0);
    }
}

//Función para analisis del terminal W de la gramatica del lenguaje
void W(){
    if(next_atomo=='w'){
        n++;
        next_atomo= tokens[n].atomo;
        if(next_atomo=='('){
            n++;
            next_atomo= tokens[n].atomo;
            if(next_atomo=='i'||next_atomo=='n'||next_atomo=='r'||next_atomo=='s'){
                R();
                if(next_atomo==')'){
                    n++;
                    next_atomo= tokens[n].atomo;
                    if(next_atomo=='m'){
                        n++;
                        next_atomo= tokens[n].atomo;
                        if(next_atomo=='{'){
                            n++;
                            next_atomo= tokens[n].atomo;
                            if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){//Actualizar cuando termine P()
                                listaP();
                                if(next_atomo=='}'){
                                    n++;
                                    next_atomo= tokens[n].atomo;
                                }
                            }else if(next_atomo=='}'){
                                n++;
                                next_atomo= tokens[n].atomo;
                            }
                        }
                    }
                }
            }
        }
    }
}

//Función para analisis del terminal J de la gramatica del lenguaje
void J(){
    if(next_atomo=='j'){
        n++;
        next_atomo= tokens[n].atomo;
        if(next_atomo=='('){
            n++;
            next_atomo= tokens[n].atomo;
            if(next_atomo=='i'||next_atomo==';'){
                Y();
                if(next_atomo=='i'||next_atomo=='n'||next_atomo=='r'||next_atomo=='s'||next_atomo==';'){
                    X();
                    if(next_atomo=='i'||next_atomo==')'){
                        Z();
                        if(next_atomo=='{'){
                            n++;
                            next_atomo= tokens[n].atomo;
                            if(next_atomo=='i'||next_atomo=='f'||next_atomo=='h'||next_atomo=='w'||next_atomo=='j'||next_atomo=='['||next_atomo=='z'||next_atomo=='c'){//Actualizar cuando termine P()
                                listaP();
                                if(next_atomo=='}'){
                                    n++;
                                    next_atomo= tokens[n].atomo;
                                }
                            }else if(next_atomo=='}'){
                                n++;
                                next_atomo= tokens[n].atomo;
                            }
                        }
                    }
                }
            }
        }
    }
}

//Función para analisis del terminal Y de la gramatica del lenguaje
void Y(){
    if(next_atomo=='i'){
        n++;
        next_atomo= tokens[n].atomo;
        if(next_atomo=='='){
            n++;
            next_atomo= tokens[n].atomo;
            if(next_atomo=='('||next_atomo=='i'||next_atomo=='n'||next_atomo=='r'){
                E();
                if(next_atomo==';'){
                    n++;
                    next_atomo= tokens[n].atomo;
                }
            }
        }
    }else if(next_atomo==';'){
        n++;
        next_atomo= tokens[n].atomo;
    }
}

//Función para analisis del terminal X de la gramatica del lenguaje
void X(){
    if(next_atomo=='i'||next_atomo=='n'||next_atomo=='r'||next_atomo=='s'){
        R();
        if(next_atomo==';'){
            n++;
            next_atomo= tokens[n].atomo;
        }
    }else if(next_atomo==';'){
        n++;
        next_atomo= tokens[n].atomo;
    }
}

//Función para analisis del terminal Z de la gramatica del lenguaje
void Z(){
    if(next_atomo=='i'){
        n++;
        next_atomo= tokens[n].atomo;
        if(next_atomo=='='){
            n++;
            next_atomo= tokens[n].atomo;
            if(next_atomo=='('||next_atomo=='i'||next_atomo=='n'||next_atomo=='r'){
                E();
                if(next_atomo==')'){
                    n++;
                    next_atomo= tokens[n].atomo;
                }
            }
        }
    }else if(next_atomo==')'){
        n++;
        next_atomo= tokens[n].atomo;
    }
}

//Función para analisis del terminal Devuelve de la gramatica del lenguaje
void Devuelve(){
    if(next_atomo=='z'){
        n++;
        next_atomo= tokens[n].atomo;
        if(next_atomo=='('){
            n++;
            next_atomo= tokens[n].atomo;
            if(tokens[n].atomo=='i'||tokens[n].atomo=='n'||tokens[n].atomo=='r'||tokens[n].atomo=='s'){
                V();
                if(next_atomo==')'){
                    n++;
                    next_atomo= tokens[n].atomo;
                    if(next_atomo==';'){
                        n++;
                        next_atomo= tokens[n].atomo;
                    }
                }
            }else if(next_atomo==')'){
                n++;
                next_atomo= tokens[n].atomo;
                if(next_atomo==';'){
                    n++;
                    next_atomo= tokens[n].atomo;
                }
            }
        }
    }
}

