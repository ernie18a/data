//+------------------------------------------------------------------+
//|                                                      velas.mq5   |
//|           Indicador personalizado que dibuja velas y mechas      |
//|        con colores personalizados y se actualiza en tiempo real  |
//+------------------------------------------------------------------+

// Estas líneas establecen los metadatos del indicador
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

// Este indicador se dibuja directamente sobre la ventana del gráfico
#property indicator_chart_window

// Cantidad de buffers usados (espacios en memoria para los datos visuales)
#property indicator_buffers 10

// Cantidad de elementos gráficos (3: mechas, velas alcistas, velas bajistas)
#property indicator_plots   3

// Enumeración para encender o apagar una opción (como un interruptor)
enum APAGAR
{
   ENCIENDE = 0, // Valor 0 = No se apaga (activa)
   APAGA = 1     // Valor 1 = Se apaga (desactiva)
};

// ----------- BUFFERS (Almacenan la información para dibujar en pantalla) ------------

// Mechas (parte superior e inferior de la vela)
double BUFFER_WICK_TOP[];       // Puntero a la mecha superior
double BUFFER_WICK_BOTTOM[];    // Puntero a la mecha inferior

// Velas alcistas (verde): se componen de 4 partes
double BUFFER_ALCISTA_OPEN[];   // Precio de apertura
double BUFFER_ALCISTA_HIGH[];   // Precio máximo
double BUFFER_ALCISTA_LOW[];    // Precio mínimo
double BUFFER_ALCISTA_CLOSE[];  // Precio de cierre

// Velas bajistas (rojas): se componen también de 4 partes
double BUFFER_BAJISTA_OPEN[];
double BUFFER_BAJISTA_HIGH[];
double BUFFER_BAJISTA_LOW[];
double BUFFER_BAJISTA_CLOSE[];

// --------------------- PARÁMETROS PERSONALIZABLES ------------------------
input string  ____________CONFIGURACIÓN___________________ = "========= CAMBIAR COLOR DE VELAS Y MECHA =========";
input APAGAR  APAGAR_MECHA_DE_LA_VELA = ENCIENDE;  // Encender/apagar la mecha
input int     ANCHO_DE_LA_MECHA = 1;               // Grosor de la línea de la mecha
input color   COLOR_DEL_CUERPO_DE_LA_VELA_ALCISTA = clrGreen;  // Color vela alcista
input color   COLOR_DEL_CUERPO_DE_LA_VELA_BAJISTA = clrRed;    // Color vela bajista
input color   COLOR_DE_LA_MECHA = clrWhite;         // Color de la mecha (wick)
input color   FONDO_DE_COLOR_EN_EL_PRIMER_PLANO_DEL_GRAFICO = clrRed;   // Color texto
input color   FONDO_DE_COLOR_EN_EL_GRAFICO = clrBlack;         // Fondo del gráfico

//+------------------------------------------------------------------+
//| Función que se ejecuta al iniciar el indicador                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // ---------------- Configuración de buffers y colores --------------------

   // Mechas (wick superior e inferior)
   SetIndexBuffer(0, BUFFER_WICK_TOP, INDICATOR_DATA);
   SetIndexBuffer(1, BUFFER_WICK_BOTTOM, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM2); // Dibuja línea vertical
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, COLOR_DE_LA_MECHA);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, ANCHO_DE_LA_MECHA);
   PlotIndexSetString(0, PLOT_LABEL, "Wicks");

   // Velas alcistas (verdes)
   SetIndexBuffer(2, BUFFER_ALCISTA_OPEN, INDICATOR_DATA);
   SetIndexBuffer(3, BUFFER_ALCISTA_HIGH, INDICATOR_DATA);
   SetIndexBuffer(4, BUFFER_ALCISTA_LOW, INDICATOR_DATA);
   SetIndexBuffer(5, BUFFER_ALCISTA_CLOSE, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_CANDLES); // Dibuja velas
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, COLOR_DEL_CUERPO_DE_LA_VELA_ALCISTA);
   PlotIndexSetString(1, PLOT_LABEL, "Bullish Candles");

   // Velas bajistas (rojas)
   SetIndexBuffer(6, BUFFER_BAJISTA_OPEN, INDICATOR_DATA);
   SetIndexBuffer(7, BUFFER_BAJISTA_HIGH, INDICATOR_DATA);
   SetIndexBuffer(8, BUFFER_BAJISTA_LOW, INDICATOR_DATA);
   SetIndexBuffer(9, BUFFER_BAJISTA_CLOSE, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_CANDLES);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, COLOR_DEL_CUERPO_DE_LA_VELA_BAJISTA);
   PlotIndexSetString(2, PLOT_LABEL, "Bearish Candles");

   // ---------------- Configuración visual del gráfico --------------------

   ChartSetInteger(ChartID(), CHART_MODE, CHART_CANDLES);                      // Mostrar gráfico en modo velas
   ChartSetInteger(ChartID(), CHART_FOREGROUND, APAGAR_MECHA_DE_LA_VELA);      // Mostrar/ocultar elementos en primer plano
   ChartSetInteger(ChartID(), CHART_COLOR_BACKGROUND, FONDO_DE_COLOR_EN_EL_GRAFICO);        // Color de fondo
   ChartSetInteger(ChartID(), CHART_COLOR_FOREGROUND, FONDO_DE_COLOR_EN_EL_PRIMER_PLANO_DEL_GRAFICO); // Color de ejes/etiquetas
   ChartSetInteger(ChartID(), CHART_COLOR_CANDLE_BULL, COLOR_DEL_CUERPO_DE_LA_VELA_ALCISTA); // Color vela alcista nativa
   ChartSetInteger(ChartID(), CHART_COLOR_CANDLE_BEAR, COLOR_DEL_CUERPO_DE_LA_VELA_BAJISTA); // Color vela bajista nativa

   return INIT_SUCCEEDED; // Todo está bien
}

//+------------------------------------------------------------------+
//| Esta función se ejecuta automáticamente con cada nuevo tick     |
//| o cuando el gráfico cambia (por ejemplo, al hacer zoom o scroll)|
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,      // Total de barras disponibles
                const int prev_calculated,  // Barras ya calculadas antes
                const datetime &time[],
                const double &open[],       // Array de precios de apertura
                const double &high[],       // Array de precios altos
                const double &low[],        // Array de precios bajos
                const double &close[],      // Array de precios de cierre
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   // Si hay menos de 10 velas, salimos (no hay suficiente información)
   if(rates_total < 10) return 0;

   // Comenzamos a calcular desde la vela anterior si ya se había calculado antes
   int start = prev_calculated > 0 ? prev_calculated - 1 : 0;

   // Recorremos todas las velas desde el punto de inicio hasta la más reciente
   for(int i = start; i < rates_total; i++)
   {
      double o = open[i];   // Apertura
      double h = high[i];   // Alto
      double l = low[i];    // Bajo
      double c = close[i];  // Cierre

      // Limpiar los buffers (evita que se dibujen cosas antiguas)
      BUFFER_WICK_TOP[i] = EMPTY_VALUE;
      BUFFER_WICK_BOTTOM[i] = EMPTY_VALUE;
      BUFFER_ALCISTA_OPEN[i] = EMPTY_VALUE;
      BUFFER_ALCISTA_HIGH[i] = EMPTY_VALUE;
      BUFFER_ALCISTA_LOW[i] = EMPTY_VALUE;
      BUFFER_ALCISTA_CLOSE[i] = EMPTY_VALUE;
      BUFFER_BAJISTA_OPEN[i] = EMPTY_VALUE;
      BUFFER_BAJISTA_HIGH[i] = EMPTY_VALUE;
      BUFFER_BAJISTA_LOW[i] = EMPTY_VALUE;
      BUFFER_BAJISTA_CLOSE[i] = EMPTY_VALUE;

      // Determinamos cuál es el cuerpo de la vela
      double cuerpo_alto = MathMax(o, c);
      double cuerpo_bajo = MathMin(o, c);

      // Guardamos las mechas
      BUFFER_WICK_TOP[i] = h;
      BUFFER_WICK_BOTTOM[i] = l;

      // Vela alcista: cierre > apertura
      if(c > o)
      {
         BUFFER_ALCISTA_OPEN[i] = o;
         BUFFER_ALCISTA_HIGH[i] = cuerpo_alto;
         BUFFER_ALCISTA_LOW[i] = cuerpo_bajo;
         BUFFER_ALCISTA_CLOSE[i] = c;
      }
      // Vela bajista: cierre < apertura
      else if(c < o)
      {
         BUFFER_BAJISTA_OPEN[i] = o;
         BUFFER_BAJISTA_HIGH[i] = cuerpo_alto;
         BUFFER_BAJISTA_LOW[i] = cuerpo_bajo;
         BUFFER_BAJISTA_CLOSE[i] = c;
      }
      // Vela doji: cierre == apertura
      else
      {
         BUFFER_ALCISTA_OPEN[i] = o;
         BUFFER_ALCISTA_HIGH[i] = o;
         BUFFER_ALCISTA_LOW[i] = o;
         BUFFER_ALCISTA_CLOSE[i] = o;
      }
   }

   // Devuelve la cantidad de velas procesadas
   return rates_total;
}
