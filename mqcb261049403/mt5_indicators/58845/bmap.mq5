//+------------------------------------------------------------------+ 
//|                                                         bmap.mq5 |
//|                      Copyright 2023, MetaQuotes Ltd.             |
//|                      https://www.mql5.com/es/users/popar         |
//+------------------------------------------------------------------+

// Declaración de metainformación del indicador
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/es/users/popar"
#property version   "1.00"
#property description "========================================================"
#property description "DESARROLLADO POR OSCAR MANTILLA"
#property description "========================================================"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrNONE

double emptyBuffer[];

// Definición del nombre del objeto bitmap que se usará para mostrar la imagen
#define BITMAP_OBJECT_NAME_CENTER "centerImage"

// Tamaño de la imagen que se mostrará centrada
int width_center = -240;   // Ancho de la imagen (negativo para tomar dimensiones reales del archivo BMP)
int height_center = 450;   // Alto de la imagen

//+------------------------------------------------------------------+
//| Función de inicialización del indicador                          |
//+------------------------------------------------------------------+
int OnInit()
{
    // Crear un objeto gráfico de tipo imagen en el gráfico (bitmap label)
    if (!ObjectCreate(0, BITMAP_OBJECT_NAME_CENTER, OBJ_BITMAP_LABEL, 0, 0, 0))
    {
        // Mostrar mensaje de error si no se pudo crear el objeto
        Print("Failed to create center image object. Error code = ", GetLastError());
        return INIT_FAILED;  // Fallo en la inicialización
    }

    // Establecer el archivo de imagen que se mostrará (debe estar en la carpeta MQL5\Images\)
    ObjectSetString(0, BITMAP_OBJECT_NAME_CENTER, OBJPROP_BMPFILE, "\\Images\\2.bmp");

    // Establecer propiedades del objeto:
    ObjectSetInteger(0, BITMAP_OBJECT_NAME_CENTER, OBJPROP_BACK, true);    // Mostrar detrás del gráfico
    ObjectSetInteger(0, BITMAP_OBJECT_NAME_CENTER, OBJPROP_CORNER, 3);     // Esquina inferior derecha como referencia

    // Llamar a la función para calcular y aplicar la posición centrada de la imagen
    UpdateBitmapPosition();

    return INIT_SUCCEEDED;  // Inicialización exitosa
}

//+------------------------------------------------------------------+
//| Función principal de cálculo del indicador (se ejecuta en cada tick) |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,       // Total de barras disponibles
                const int prev_calculated,   // Número de barras calculadas previamente
                const datetime &time[],      // Array de tiempos de las barras
                const double &open[],        // Array de precios de apertura
                const double &high[],        // Array de máximos
                const double &low[],         // Array de mínimos
                const double &close[],       // Array de cierres
                const long &tick_volume[],   // Volumen por tick
                const long &volume[],        // Volumen real
                const int &spread[])         // Spread en puntos
{
    // Actualizar la posición de la imagen cada vez que se recalcula el indicador
    UpdateBitmapPosition();
    return(rates_total); // Devolver el número total de barras procesadas
}

//+------------------------------------------------------------------+
//| Función para actualizar la posición de la imagen en el gráfico  |
//+------------------------------------------------------------------+
void UpdateBitmapPosition()
{
    // Variables para almacenar el ancho y alto del gráfico en píxeles
    long x_distance, y_distance;

    // Obtener el ancho del gráfico en píxeles
    if (!ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0, x_distance))
    {
        Print("Failed to get the chart width! Error code = ", GetLastError());
        return;
    }

    // Obtener el alto del gráfico en píxeles
    if (!ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0, y_distance))
    {
        Print("Failed to get the chart height! Error code = ", GetLastError());
        return;
    }

    // Calcular la posición X e Y para centrar la imagen en el gráfico
    int x_center = (int)(x_distance - width_center) / 2;  // Posición X centrada
    int y_center = (int)(y_distance - height_center) / 2; // Posición Y centrada

    // Establecer la distancia desde la esquina (corner) hacia el centro
    ObjectSetInteger(0, BITMAP_OBJECT_NAME_CENTER, OBJPROP_XDISTANCE, x_center); // Posición horizontal
    ObjectSetInteger(0, BITMAP_OBJECT_NAME_CENTER, OBJPROP_YDISTANCE, y_center); // Posición vertical
}
