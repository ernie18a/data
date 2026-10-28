//+------------------------------------------------------------------+ 
//|                            PercentageCrossoverChannel_System.mq5 | 
//|                                        Copyright © 2009, Vic2008 | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2009, Vic2008"
#property link ""
#property description "Пробойная система с использованием индикатора PercentageCrossoverChannel"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано девять буферов
#property indicator_buffers 9
//---- использовано четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 1            |
//+----------------------------------------------+
//---- отрисовка индикатора в виде одноцветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета индикатора использован WhiteSmoke цвет
#property indicator_color1  clrWhiteSmoke
//---- отображение метки индикатора
#property indicator_label1  "PercentageCrossoverChannel"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 2            |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован MediumSeaGreen цвет
#property indicator_color2  clrMediumSeaGreen
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение бычей метки индикатора
#property indicator_label2  "Upper PercentageCrossoverChannel"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 3            |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован Magenta цвет
#property indicator_color3  clrMagenta
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение медвежьей метки индикатора
#property indicator_label3  "Lower PercentageCrossoverChannel"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 4            |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветных свеч
#property indicator_type4 DRAW_COLOR_CANDLES
//---- в качестве цветов индикатора использованы
#property indicator_color4 clrDeepPink,clrPurple,clrGray,clrMediumBlue,clrDodgerBlue
//---- линия индикатора - сплошная
#property indicator_style4 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width4 2
//---- отображение метки индикатора
#property indicator_label4 "PercentageCrossoverChannel_BARS"
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input double percent=1.0; //процентное отклонение цены от предыдущего значения индикатора
input int Shift=1; // сдвиг канала по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double Up1Buffer[],Dn1Buffer[];
double Up2Buffer[],Dn2Buffer[];
double ExtOpenBuffer[],ExtHighBuffer[],ExtLowBuffer[],ExtCloseBuffer[],ExtColorBuffer[];
//---- объявление глобальных переменных
double plusvar,minusvar;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator indicator initialization function               | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация констант
   min_rates_total=2;
   double var1=percent/100;
   plusvar=1+var1;
   minusvar=1-var1;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,Up1Buffer,INDICATOR_DATA);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,Dn1Buffer,INDICATOR_DATA);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,Up2Buffer,INDICATOR_DATA);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,Dn2Buffer,INDICATOR_DATA);

//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(4,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,ExtCloseBuffer,INDICATOR_DATA);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(8,ExtColorBuffer,INDICATOR_COLOR_INDEX);


//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

//---- осуществление сдвига индикатора 3 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);

//---- осуществление сдвига индикатора 3 по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,0);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 4 на min_rates_total
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Percentage Crossover Channel(percent = ",percent,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
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
   if(rates_total<min_rates_total) return(0);

//---- Объявление целых переменных
   int first,bar;
   double Middle;
   static double Middle_prev;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated==0) // проверка на первый старт расчёта индикатора
     {
      first=1; // стартовый номер для расчёта всех баров
      Middle_prev=close[first-1];
     }
   else // стартовый номер для расчёта новых баров
     {
      first=prev_calculated-1;
     }

//---- Основной цикл расчёта средней линии канала
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if((close[bar]*minusvar)>Middle_prev) Middle=close[bar]*minusvar;
      else
        {
         if(close[bar]*plusvar<Middle_prev) Middle=close[bar]*plusvar;
         else Middle=Middle_prev;
        }

      Up1Buffer[bar]=Up2Buffer[bar]=Middle+(Middle/100) * percent;
      Dn1Buffer[bar]=Dn2Buffer[bar]=Middle-(Middle/100) * percent;

      if(bar<rates_total-1) Middle_prev=Middle;
     }
//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) first+=int(Shift);
//---- Основной цикл раскраски баров индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int clr=2;
      ExtOpenBuffer[bar]=NULL;
      ExtCloseBuffer[bar]=NULL;
      ExtHighBuffer[bar]=NULL;
      ExtLowBuffer[bar]=NULL;

      if(close[bar]>Up1Buffer[bar-Shift])
        {
         if(open[bar]<=close[bar]) clr=4;
         else clr=3;
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
        }

      if(close[bar]<Dn1Buffer[bar-Shift])
        {
         if(open[bar]>close[bar]) clr=0;
         else clr=1;
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
        }

      ExtColorBuffer[bar]=clr;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
