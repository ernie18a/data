//+------------------------------------------------------------------+ 
//|                                               Aggressiveness.mq5 | 
//|                   Copyright © 2009, Trofimov Evgeniy Vitalyevich | 
//|                                     http://TrofimovVBA.narod.ru/ | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2009, Trofimov Evgeniy Vitalyevich"
#property link      "http://TrofimovVBA.narod.ru/"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован BlueViolet цвет
#property indicator_color1 clrBlueViolet
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Aggressiveness"
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint MyPeriod=22;
input double Lot=0; // Lot (0 - в пунктах, >0 - в валюте депозита)
input int Shift=0;  // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- индикаторный буфер
double IndBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+    
//| Aggressiveness indicator initialization function                 | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(MyPeriod+1);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   if(!Lot) shortname="Aggressiveness("+string(MyPeriod)+"), (pips) = ";
   else shortname="Aggressiveness("+string(MyPeriod)+"), ("+AccountInfoString(ACCOUNT_CURRENCY)+"·"+DoubleToString(Lot,2)+") = ";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Aggressiveness iteration function                                | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total)return(0);
//---- объявление целочисленных переменных
   int first,bar;
//---- объявление переменных с плавающей точкой  
   double Sum;
//----
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=min_rates_total; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      Sum=0;
      for(int x=0; x<int(MyPeriod); x++)
        {
         int barx=bar-x;
         if(close[barx]>open[barx]) Sum+=close[barx]-close[barx-1]; //белая свеча
         else Sum+=close[barx-1]-close[barx]; //черная свеча
        }
      //----
      IndBuffer[bar]=Sum/(_Point*MyPeriod);
      //----
      if(Lot)
        {
         double TICKVALUE=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE);
         if(!TICKVALUE) return(prev_calculated);
         IndBuffer[bar]*=TICKVALUE*Lot;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
