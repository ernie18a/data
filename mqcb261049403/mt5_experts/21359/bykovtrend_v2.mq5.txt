//+------------------------------------------------------------------+
//|                                                BykovTrend_V2.mq5 |
//|                                        Ramdass - Conversion only |
//|                                                                  |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Ramdass - Conversion only"
//--- ссылка на сайт автора
#property link      ""
//--- номер версии индикатора
#property version   "1.10"
//--- отрисовка индикатора в главном окне
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
#property indicator_color1  clrLimeGreen,clrTeal,clrGray,clrChocolate,clrGold
//---- отображение метки индикатора
#property indicator_label1  "BykovTrendOpen;BykovTrendHigh;BykovTrendLow;BykovTrendClose"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int RISK=3;
input int SSP=9;
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double ExtOpenBuffer[],ExtHighBuffer[],ExtLowBuffer[],ExtCloseBuffer[],ExtColorsBuffer[];
//---
int K,WPR_Handle,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   K=33-RISK;
   min_rates_total=int(SSP)+1;
//--- получение хендла индикатора iWPR
   WPR_Handle=iWPR(NULL,0,SSP);
   if(WPR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iWPR");
      return(INIT_FAILED);
     }

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorsBuffer,true);

//--- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="BykovTrend_V2";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- завершение инициализации
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(WPR_Handle)<rates_total || rates_total<min_rates_total)
      return(RESET);

//--- объявления локальных переменных 
   int to_copy,limit,bar,trend;
   double WPR[];
   static int oldtrend;

//--- расчеты необходимого количества копируемых данных и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчета всех баров
      oldtrend=0;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=limit+1; // расчетное количество копируемых баров

//--- копируем вновь появившиеся данные в массив WPR[]
   if(CopyBuffer(WPR_Handle,0,0,to_copy,WPR)<=0) return(RESET);

//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(WPR,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtOpenBuffer[bar]=open[bar];
      ExtHighBuffer[bar]=high[bar];
      ExtLowBuffer[bar]=low[bar];
      ExtCloseBuffer[bar]=close[bar];
      ExtColorsBuffer[bar]=2;
      //----
      trend=oldtrend;
      if(WPR[bar]<-100+K) trend=-1;
      if(WPR[bar]>-K) trend=+1;
      //-----
      if(trend>0)
        {
         if(open[bar]<=close[bar]) ExtColorsBuffer[bar]=0;
         else ExtColorsBuffer[bar]=1;
        }
      //-----
      if(trend<0)
        {
         if(open[bar]>=close[bar]) ExtColorsBuffer[bar]=4;
         else ExtColorsBuffer[bar]=3;
        }
      //---
      if(bar) oldtrend=trend;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
