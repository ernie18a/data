//+------------------------------------------------------------------+
//|                                               Mapear Símbolo.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/envex"
#property version   "1.00"


//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
// Declaración de un parámetro de entrada para especificar el símbolo base

string inputSymbol = "EURUSD"; // Símbolo base ingresado por el usuario

// La función principal del script
void OnStart()
  {
// Obtener todos los símbolos visibles en la ventana Market Watch
   string marketWatchSymbols[];
   int totalSymbols = SymbolsTotal(true); // Número total de símbolos visibles en Market Watch
   ArrayResize(marketWatchSymbols, totalSymbols); // Redimensionar el array para almacenar los símbolos

// Llenar el array con los nombres de los símbolos
   for(int i = 0; i < totalSymbols; i++)
      marketWatchSymbols[i] = SymbolName(i, true);

// Encontrar el símbolo más similar al especificado por el usuario
   string mappedSymbol = FindMostSimilarSymbol(inputSymbol, marketWatchSymbols);

// Mostrar el resultado como comentario en el gráfico
   Comment("El símbolo ingresado es: ", inputSymbol, "\n",
           "El símbolo más similar encontrado es: ", mappedSymbol);
  }

//+------------------------------------------------------------------+
//| Función para calcular la distancia de Levenshtein entre cadenas  |
//+------------------------------------------------------------------+
// Esta función implementa el algoritmo de Levenshtein para calcular la diferencia mínima
// (inserciones, eliminaciones, sustituciones) entre dos cadenas.
int LevenshteinDistance(string s, string t)
  {
   int len_s = StringLen(s); // Longitud de la primera cadena
   int len_t = StringLen(t); // Longitud de la segunda cadena

// Manejo de cadenas vacías: si alguna es vacía, la distancia es igual a la longitud de la otra
   if(len_s == 0)
      return len_t;
   if(len_t == 0)
      return len_s;

// Declaración y redimensionamiento de un array dinámico para almacenar la matriz de distancias
   int total_size = (len_s + 1) * (len_t + 1);
   int dist_matrix[];
   ArrayResize(dist_matrix, total_size);

// Inicializar la primera columna de la matriz
   for(int i = 0; i <= len_s; i++)
      dist_matrix[i * (len_t + 1)] = i;

// Inicializar la primera fila de la matriz
   for(int j = 0; j <= len_t; j++)
      dist_matrix[j] = j;

// Rellenar la matriz calculando las distancias mínimas
   for(int i = 1; i <= len_s; i++)
     {
      for(int j = 1; j <= len_t; j++)
        {
         // Calcular el costo de sustitución
         int cost = (StringGetCharacter(s, i - 1) == StringGetCharacter(t, j - 1)) ? 0 : 1;

         // Calcular los costos de eliminación, inserción y sustitución
         int deletion = dist_matrix[(i - 1) * (len_t + 1) + j] + 1;
         int insertion = dist_matrix[i * (len_t + 1) + (j - 1)] + 1;
         int substitution = dist_matrix[(i - 1) * (len_t + 1) + (j - 1)] + cost;

         // Elegir el menor costo y asignarlo a la celda actual
         dist_matrix[i * (len_t + 1) + j] = MathMin(deletion, MathMin(insertion, substitution));
        }
     }

// Devolver el valor en la última celda de la matriz como la distancia total
   return dist_matrix[len_s * (len_t + 1) + len_t];
  }

//+------------------------------------------------------------------+
//| Función para encontrar el símbolo más similar                    |
//+------------------------------------------------------------------+
// Compara un símbolo base con una lista de símbolos y retorna el más similar
string FindMostSimilarSymbol(string baseSymbol, string &symbolList[])
  {
   int minDistance = INT_MAX; // Distancia mínima inicializada al máximo valor entero
   string closestSymbol = ""; // Variable para almacenar el símbolo más cercano

// Iterar sobre la lista de símbolos y calcular la distancia con cada uno
   for(int i = 0; i < ArraySize(symbolList); i++)
     {
      int distance = LevenshteinDistance(baseSymbol, symbolList[i]); // Calcular la distancia

      // Si encontramos una distancia menor, actualizar los valores
      if(distance < minDistance)
        {
         minDistance = distance;
         closestSymbol = symbolList[i];
        }
     }

// Retornar el símbolo más cercano encontrado
   return closestSymbol;
  }
//+------------------------------------------------------------------+
