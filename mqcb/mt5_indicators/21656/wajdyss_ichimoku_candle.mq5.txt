//+------------------------------------------------------------------+
//|                                      wajdyss_Ichimoku_Candle.mq5 |
//|                                        Copyright © 2009, Wajdyss |
//|                                                wajdyss@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Wajdyss"
#property link "wajdyss@yahoo.com"
#property description ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+--------------------------------------------+
//|  Параметры отрисовки индикатора            |
//+--------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrMagenta,clrBrown,clrBlue,clrAqua
//---- отображение метки индикатора
#property indicator_label1  "wajdyss_Ichimoku Open;wajdyss_Ichimoku High;wajdyss_Ichimoku Low;wajdyss_Ichimoku Close"
//+--------------------------------------------+
//|  объявление констант                       |
//+--------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+--------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА              |
//+--------------------------------------------+
input uint Kijun=26;
//+--------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| CandleStop initialization function                               | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(Kijun);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);

//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);

//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"wajdyss_Ichimoku_Candle");

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| CandleStop iteration function                                    | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);

//---- Объявление переменных с плавающей точкой  
   double kijun,price,High,Low;
//---- Объявление целых переменных и получение
   int limit,bar,to_copy;
  
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1;               // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated;                 // стартовый номер для расчета новых баров
     }
   to_copy=limit+1;
   
//---- индексация элементов в массивах, как в таймсериях 
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true); 
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);

//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      High=high[bar];
      Low=low[bar];
      int index=bar+int(Kijun)-1;
      while(index>bar)
        {
         price=high[index];
         if(High<price) High=price;
         price=low[index];
         if(Low>price) Low=price;
         index--;
        }
      //----  
      kijun=(High+Low)/2;
      
      ExtOpenBuffer[bar]=open[bar];
      ExtHighBuffer[bar]=high[bar];
      ExtLowBuffer[bar]=low[bar];
      ExtCloseBuffer[bar]=close[bar];
      
      //----
      if(close[bar]>kijun)
        {
         if(close[bar]>=open[bar]) ExtColorBuffer[bar]=3;
         else ExtColorBuffer[bar]=2;
        }
      //----
      if(close[bar]<kijun)
        {
         if(close[bar]<=open[bar]) ExtColorBuffer[bar]=0;
         else ExtColorBuffer[bar]=1;
        }
     }
//----  
   return(rates_total);
  }
//+------------------------------------------------------------------+
