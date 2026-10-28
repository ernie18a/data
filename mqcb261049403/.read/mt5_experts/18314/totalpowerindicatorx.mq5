//+------------------------------------------------------------------+
//|Based on totel_power_indicator.mq4 by Daniel Fernandez            |
//|Asirikuy.com 2011                                                 |
//|                                         TotalPowerIndicatorX.mq5 |
//|                                  Copyright © 2011, EarnForex.com |
//|                                         http://www.earnforex.com |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2011, www.EarnForex.com"
//---- ссылка на сайт автора
#property link      "http://www.earnforex.com/"
//---- номер версии индикатора
#property version   "1.0"

#property description "Displays the concentration of bull PowerBuffer periods, bear power periods"
#property description " and total periods when either bulls or bears had prevailance."

//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчёта и отрисовки индикатора использовано три буфера
#property indicator_buffers 3
//---- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов облака индикатора использованы
#property indicator_color1  clrDodgerBlue,clrMagenta
//---- отображение метки индикатора
#property indicator_label1  "BullsBears Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора мощности     |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован DarkOrchid цвет
#property indicator_color2  clrDarkOrchid
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  "Power"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 100.0
#property indicator_level2  50.0
#property indicator_level3   0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Параметры фиксации границ окна               |
//+----------------------------------------------+
#property indicator_minimum  -5
#property indicator_maximum 105
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint PowerPeriod=10;//период индикатора
input uint LookbackPeriod=45;// период сглаживания
input int Shift=0; // сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double BullsBuffer[];
double BearsBuffer[];
double PowerBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int Bulls_Handle,Bears_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(LookbackPeriod+PowerPeriod);

//---- получение хендла индикатора Bulls
   Bulls_Handle=iBullsPower(NULL,0,PowerPeriod);
   if(Bulls_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Bulls");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора Bears
   Bears_Handle=iBearsPower(NULL,0,PowerPeriod);
   if(Bears_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Bears");
      return(INIT_FAILED);
     }

//---- превращение динамического массива BullsBuffer в индикаторный буфер
   SetIndexBuffer(0,BullsBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на Period
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- превращение динамического массива BearsBuffer в индикаторный буфер
   SetIndexBuffer(1,BearsBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2 на Period
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

//---- превращение динамического массива PowerBuffer в индикаторный буфер
   SetIndexBuffer(2,PowerBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3 на Period
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);

//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(BullsBuffer,true);
   ArraySetAsSeries(BearsBuffer,true);
   ArraySetAsSeries(PowerBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Total Power Indicator(",PowerPeriod,", ",LookbackPeriod,", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
//---- проверка количества баров на достаточность для расчёта
   if
   (
    BarsCalculated(Bulls_Handle)<rates_total
    || BarsCalculated(Bears_Handle)<rates_total
    || rates_total<min_rates_total
    )
      return(RESET);

//---- объявления локальных переменных 
   int limit,to_copy,bar,bearscount,bullscount;
   double BULLS[],BEARS[];

//---- индексация элементов в массивах как в таймсериях 
   ArraySetAsSeries(BULLS,true);
   ArraySetAsSeries(BEARS,true);

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

//---- расчёт количества копируемых данных   
   to_copy=limit+min_rates_total+1;

//---- копируем вновь появившиеся данные в массивы переменных
   if(CopyBuffer(Bulls_Handle,0,0,to_copy,BULLS)<=0) return(RESET);
   if(CopyBuffer(Bears_Handle,0,0,to_copy,BEARS)<=0) return(RESET);


//---- Первый большой цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      bearscount=NULL;
      bullscount=NULL;

      for(int kkk=int(LookbackPeriod)-1; kkk>=0; kkk--)
        {
         if(BULLS[bar+kkk]>0) bullscount++;
         if(BEARS[bar+kkk]<0) bearscount++;
        }

      PowerBuffer[bar]=MathMax(0,MathMin(100,2*MathAbs(bullscount-bearscount)*100/LookbackPeriod));
      BullsBuffer[bar]=MathMax(0,MathMin(100,((bullscount*100/LookbackPeriod)-50)*2));
      BearsBuffer[bar]=MathMax(0,MathMin(100,((bearscount*100/LookbackPeriod)-50)*2));
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
