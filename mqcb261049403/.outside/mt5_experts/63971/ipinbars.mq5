//+------------------------------------------------------------------+
//|                                                     iPinBars.mq5 |
//|                                Copyright 2025, Artem A. Trishkin |
//|                         https://www.mql5.com/ru/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Artem A. Trishkin, Skype artmedia70"
#property link      "https://www.mql5.com/ru/users/artmedia70"
#property version   "1.00"
#property description         "This indicator looks for pattern"
#property description         "PriceActions \"Pin-Bars\""
#property description         "and puts signal pointers"

#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot PinUP
#property indicator_label1  "PinBar to Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDeepSkyBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot PinDN
#property indicator_label2  "PinBar to Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot ArrowUP
#property indicator_label3  "Signal Buy"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDeepSkyBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot ArrowDN
#property indicator_label4  "Signal Sell"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

//--- input parameters
input int      MinCandleSizePT      = 10;    // Minimum size of a candle from low to high
input double   MaxCandleBodySize    = 0.33;  // Maximum size of the candle body relative to its shadows
input double   RelativeToPrevCandle = 0.33;  // Position of the body relative to the previous candle
input double   AspectRatioShadows   = 2.0;   // Aspect ratio of the shadows

//--- global variables
int            min_candle_size;
double         max_candle_body_size;
double         relative_to_prev_candle;
double         aspect_ratio_shadows;

//--- indicator buffers
double         BufferPinUP[];
double         BufferPinDN[];
double         BufferArrowUP[];
double         BufferArrowDN[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- корректируем введённые значения input-переменных
   min_candle_size = (MinCandleSizePT < 1 ? 1 : MinCandleSizePT);
   max_candle_body_size = (MaxCandleBodySize <= 0 ? 0.01 : MaxCandleBodySize > 1 ? 1.0 : MaxCandleBodySize);
   relative_to_prev_candle = (RelativeToPrevCandle < 0 ? 0 : RelativeToPrevCandle > 1 ? 1.0 : RelativeToPrevCandle);
   aspect_ratio_shadows = (AspectRatioShadows <= 0 ? 0.1 : AspectRatioShadows);
   
//--- индексы буферов индикатора
   SetIndexBuffer(0, BufferPinUP);
   SetIndexBuffer(1, BufferPinDN);
   SetIndexBuffer(2, BufferArrowUP);
   SetIndexBuffer(3, BufferArrowDN);
   
//--- устанавливаем коды стрелок для рисуемых буферов из набора Wingdings
   PlotIndexSetInteger(0, PLOT_ARROW, 171);
   PlotIndexSetInteger(1, PLOT_ARROW, 171);
   PlotIndexSetInteger(2, PLOT_ARROW, 159);
   PlotIndexSetInteger(3, PLOT_ARROW, 159);
   
//--- для рисуемых буферов устанавливаем не рисуемое значение как EMPTY_VALUE
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   
//--- устанавливаем индексацию всех используемых буферов как у таймсерии
   ArraySetAsSeries(BufferPinUP, true);
   ArraySetAsSeries(BufferPinDN, true);
   ArraySetAsSeries(BufferArrowUP, true);
   ArraySetAsSeries(BufferArrowDN, true);
   
//--- короткое имя
   IndicatorSetString(INDICATOR_SHORTNAME, "PinBars_" + Symbol());
   
//--- успешно
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- проверяем количество доступной истории
   if(rates_total < 4)
      return(0);
      
//--- устанавливаем индексацию всех используемых массивов как у таймсерии
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
//--- проверка количества посчитанных баров
   int limit = rates_total - prev_calculated;
//--- если это первый запуск или изменение в исторических данных
   if(limit > 1)
     {
      limit = rates_total - 4;   // расчёт начинаем с начала истории
      //--- инициализируем все рисуемые буферы пустым значением
      ArrayInitialize(BufferPinUP, EMPTY_VALUE);
      ArrayInitialize(BufferPinDN, EMPTY_VALUE);
      ArrayInitialize(BufferArrowUP, EMPTY_VALUE);
      ArrayInitialize(BufferArrowDN, EMPTY_VALUE);
     }
     
//--- в цикле от значения limit до текущего бара ищем пин-бары
   for(int i = limit; i >= 0; i--)
     {
      //--- удаляем мусор в буферах
      BufferPinUP[i] = EMPTY_VALUE;
      BufferPinDN[i] = EMPTY_VALUE;
      BufferArrowUP[i] = EMPTY_VALUE;
      BufferArrowDN[i] = EMPTY_VALUE;
      
      //--- параметры искомой свечи
      double up_body = fmax(open[i + 1], close[i + 1]);                                // верх тела свечи
      double dn_body = fmin(open[i + 1], close[i + 1]);                                // низ тела свечи
      double candle_size = high[i + 1] - low[i + 1];                                   // размер всей свечи
      double body_size = fabs(open[i + 1] - close[i + 1]);                             // размер тела свечи
      double req_candle = candle_size * max_candle_body_size;                          // искомый размер тела свечи
      double prev_candle_shift = (high[i + 2] - low[i + 2]) * relative_to_prev_candle; // смещение относительно предыдущей свечи
      double avg_body_price = (dn_body + up_body) * 0.5;                               // средняя цена тела свечи
      
      //--- если размер свечи меньше минимального - дальше
      if(candle_size < min_candle_size * Point())
         continue;
      
      //--- если тело свечи больше искомого - дальше
      if(body_size > req_candle)
         continue;
      
      //--- пин-бар должен находиться в пределах предыдущей свечи
      //--- если верх тела выше high предыдущей - дальше
      if(up_body > high[i + 2])
         continue;
      //--- если низ тела ниже low предыдущей - дальше
      if(dn_body < low[i + 2])
         continue;
      
      //--- Верхние тени
      if(high[i + 1] > high[i + 2] && high[i + 1] >= high[i + 3])    // если high свечи выше двух предыдущих
        {
         if(avg_body_price >= high[i + 2] - prev_candle_shift)       // если середина тела выше границы предыдущей свечи
           {
            //--- если длина верхней тени значительно больше длины нижней тени (соотношение aspect_ratio_shadows)
            if((dn_body - low[i + 1])*aspect_ratio_shadows <= high[i + 1] - up_body)
              {
               BufferPinDN[i + 1] = high[i + 1];
               BufferArrowDN[i] = open[i];
              }
           }
        }
      //--- Нижние тени
      if(low[i + 1] < low[i + 2] && low[i + 1] <= low[i + 3])        // если low свечи ниже двух предыдущих
        {
         if(avg_body_price <= low[i + 2] + prev_candle_shift)        // если середина тела ниже границы предыдущей свечи
           {
            //--- если длина нижней тени значительно больше длины верхней тени (соотношение aspect_ratio_shadows)
            if((high[i + 1] - up_body)*aspect_ratio_shadows <= dn_body - low[i + 1])
              {
               BufferPinUP[i + 1] = low[i + 1];
               BufferArrowUP[i] = open[i];
              }
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
