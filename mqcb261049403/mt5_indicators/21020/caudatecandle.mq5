//+------------------------------------------------------------------+
//|                                                CaudateCandle.mq5 |
//|                                      Copyright © 2018, Scriptong |
//|                                          http://advancetools.net |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2018, Scriptong"
//---- ссылка на сайт автора
#property link      "http://advancetools.net"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- для расчёта и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrDeepSkyBlue,clrBlue,clrGray,clrMaroon,clrOrchid
//---- отображение метки индикатора
#property indicator_label1  "CaudateOpen;CaudateHigh;CaudateLow;CaudateClose"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                    // Константа для возврата терминалу команды на пересчет индикатора
#define TYPE_NO_TAIL     0                         // Свеча без хвоста
#define TYPE_HIGHER_TAIL 1                         // Свеча с верхним хвостом         
#define TYPE_LOWER_TAIL  2                         // Свеча с нижним хвостом
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int    Shift=0; // сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorsBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator function Определение типа свечи                 |
//+------------------------------------------------------------------+
int GetCandleType(int index,const double &Open[],const double &High[],const double &Low[],const double &Close[])
  {
//----
   double candleHalf=(High[index]+Low[index])/2;            // Середина высоты свечи

   if(Open[index]<candleHalf && Close[index]<candleHalf) // Тело свечи находится в нижней половине свечи                        
      return(TYPE_HIGHER_TAIL);                             // Верхний хвост

   if(Open[index]>candleHalf && Close[index]>candleHalf) // Тело свечи находится в верхней половине свечи                        
      return(TYPE_LOWER_TAIL);                              // Нижний хвост
//----   
   return(TYPE_NO_TAIL);                                    // У свечи нет хвоста
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=1;
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorsBuffer,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Caudate_Candles");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int limit,bar;
   double;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      switch(GetCandleType(bar,open,high,low,close)) // Получение типа свечи
        {
         case TYPE_NO_TAIL: // Свеча без хвоста не интересует
            ExtOpenBuffer[bar]=NULL;
            ExtHighBuffer[bar]=NULL;
            ExtLowBuffer[bar]=NULL;
            ExtCloseBuffer[bar]=NULL;
            ExtColorsBuffer[bar]=2;
            break;

         case TYPE_LOWER_TAIL: // Свеча с нижним хвостом
            ExtOpenBuffer[bar]=open[bar];
            ExtHighBuffer[bar]=high[bar];
            ExtLowBuffer[bar]=low[bar];
            ExtCloseBuffer[bar]=close[bar];
            if(open[bar]<=close[bar]) ExtColorsBuffer[bar]=0;
            else ExtColorsBuffer[bar]=1;
            break;

         case TYPE_HIGHER_TAIL: // Свеча с верхним хвостом
            ExtOpenBuffer[bar]=open[bar];
            ExtHighBuffer[bar]=high[bar];
            ExtLowBuffer[bar]=low[bar];
            ExtCloseBuffer[bar]=close[bar];
            if(open[bar]>=close[bar]) ExtColorsBuffer[bar]=4;
            else ExtColorsBuffer[bar]=3;
            break;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
