//+------------------------------------------------------------------+
//|                                                  EMABands_v1.mq5 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"
//---- номер версии индикатора
#property version   "1.00"
#property description "MACD_Cloud"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано два графических построений
#property indicator_plots   2
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов индикатора использованы
#property indicator_color1  clrPaleGreen
//---- отображение метки индикатора
#property indicator_label1  "Upper Cloud"
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цветов индикатора использованы
#property indicator_color2  clrPink
//---- отображение метки индикатора
#property indicator_label2  "Lower Cloud"
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input int   MAPeriod=13;
input  ENUM_MA_METHOD   MAType=MODE_EMA;
input uint Delta=150;
//+-----------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int  min_rates_total;
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double ExtHHBuffer[];
double ExtHLBuffer[];
double ExtLHBuffer[];
double ExtLLBuffer[];
//----
double dDelta;
//---- объявление целочисленных переменных для хендлов индикаторов
int MAh_Handle,MAl_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(MAPeriod);
   dDelta=Delta*_Point;
//---- получение хендла индикатора iMA h
   MAh_Handle=iMA(NULL,0,MAPeriod,0,MAType,PRICE_HIGH);
   if(MAh_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA h");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iMA l
   MAl_Handle=iMA(NULL,0,MAPeriod,0,MAType,PRICE_LOW);
   if(MAl_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA l");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtHHBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtHHBuffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ExtHLBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtHLBuffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,ExtLHBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLHBuffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,ExtLLBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLLBuffer,true);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"EMABands_v1");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(MAh_Handle)<rates_total
      || BarsCalculated(MAl_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);
//---- объявления локальных переменных 
   int to_copy,limit;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated;  // стартовый номер для расчета только новых баров
//----
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(MAh_Handle,MAIN_LINE,0,to_copy,ExtHLBuffer)<=0) return(RESET);
   if(CopyBuffer(MAl_Handle,MAIN_LINE,0,to_copy,ExtLHBuffer)<=0) return(RESET);
//---- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtHHBuffer[bar]=ExtHLBuffer[bar]+dDelta;
      ExtLLBuffer[bar]=ExtLHBuffer[bar]-dDelta;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
