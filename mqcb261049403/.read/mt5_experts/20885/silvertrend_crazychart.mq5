//+------------------------------------------------------------------+
//|                                       SilverTrend_CrazyChart.mq5 |
//|                                     Copyright © 2006, CrazyChart |
//|                                                  http://viac.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, CrazyChart"
#property link "http://viac.ru/"
//---- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в основном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов индикатора использованы
#property indicator_color1  clrDodgerBlue,clrOrchid
//---- отображение метки индикатора
#property indicator_label1  "SilverTrend_CrazyChart"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input uint SSP=7;
input double Kmin = 1.6;
input double Kmax = 50.6;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtABuffer[],ExtBBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(2*SSP);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtABuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtABuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ExtBBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtBBuffer,true);

//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"SilverTrend_CrazyChart");
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
                const double &high[],
                const double &low[],
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
   double SsMax,SsMin,smin,smax;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      for(bar=rates_total-1; bar>=limit && !IsStopped(); bar--)
        {
         ExtBBuffer[bar]=0.0;
         ExtABuffer[bar]=0.0;
        }
     }
   else limit=rates_total-prev_calculated+int(SSP); // стартовый номер для расчёта новых баров

//---- первый цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      SsMax=high[ArrayMaximum(high,bar,SSP)];
      SsMin=low[ArrayMinimum(low,bar,SSP)];
      smin=NormalizeDouble((SsMin-(SsMax-SsMin)*Kmin/100),_Digits);
      smax=NormalizeDouble((SsMax-(SsMax-SsMin)*Kmax/100),_Digits);
      int barx=bar-int(SSP)-1;
      if(barx>=0) ExtBBuffer[barx]=smax;
      ExtABuffer[bar]=smax;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
