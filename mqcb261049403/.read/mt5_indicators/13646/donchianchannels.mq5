//+------------------------------------------------------------------+
//|                      Donchian Channels - Generalized version.mq4 |
//|                         Copyright © 2005, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 3 
//---- использовано три графических построения
#property indicator_plots   3
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован оливковый цвет
#property indicator_color1 OliveDrab
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Upper Donchian"
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован серый цвет
#property indicator_color2 Gray
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "Middle Donchian"
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован какао цвет
#property indicator_color3 PaleVioletRed
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width3  1
//---- отображение метки индикатора
#property indicator_label3  "Lower Donchian"
//+-----------------------------------+
//| Объявление перечисления           |
//+-----------------------------------+
enum Applied_Extrem //тип экстремумов
  {
   HIGH_LOW,
   HIGH_LOW_OPEN,
   HIGH_LOW_CLOSE,
   OPEN_HIGH_LOW,
   CLOSE_HIGH_LOW
  };
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input int DonchianPeriod=20; // Период усреднения
input Applied_Extrem Extremes=HIGH_LOW; // Тип экстремумов
input int Margins=-2;
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- индикаторные буферы
double UpperBuffer[];
double MiddleBuffer[];
double LowerBuffer[];
//+------------------------------------------------------------------+
//| Searching index of the highest bar                               |
//+------------------------------------------------------------------+
int iHighest(const double &array[],// массив для поиска индекса максимального элемента
             int count,            // число элементов массива (в направлении от текущего бара в сторону убывания индекса), 
                                   // среди которых должен быть произведен поиск
             int startPos)         // индекс (смещение относительно текущего бара) начального бара, 
                                   // с которого начинается поиск наибольшего значения

  {
//----
   int index=startPos;
//---- проверка стартового индекса на корректность
   if(startPos<0)
     {
      Print("Неверное значение в функции iHighest, startPos = ",startPos);
      return(0);
     }
//---- проверка значения startPos на корректность
   if(startPos-count<0)
      count=startPos;
//----
   double max=array[startPos];
//---- поиск индекса
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]>max)
        {
         index=i;
         max=array[i];
        }
     }
//---- возврат индекса наибольшего бара
   return(index);
  }
//+------------------------------------------------------------------+
//| Searching index of the lowest bar                                |
//+------------------------------------------------------------------+
int iLowest(const double &array[],// массив для поиска индекса минимального элемента
            int count,            // число элементов массива (в направлении от текущего бара в сторону убывания индекса), 
                                  // среди которых должен быть произведен поиск
            int startPos) // индекс (смещение относительно текущего бара) начального бара, 
                          // с которого начинается поиск наименьшего значения
  {
//----
   int index=startPos;
//---- проверка стартового индекса на корректность
   if(startPos<0)
     {
      Print("Неверное значение в функции iLowest, startPos = ",startPos);
      return(0);
     }
//---- проверка значения startPos на корректность
   if(startPos-count<0)
      count=startPos;
//----
   double min=array[startPos];
//---- поиск индекса
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]<min)
        {
         index=i;
         min=array[i];
        }
     }
//---- возврат индекса наименьшего бара
   return(index);
  }
//+------------------------------------------------------------------+    
//| Donchian Channel indicator initialization function               | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на AroonShift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,DonchianPeriod-1);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Upper Donchian");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,MiddleBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,DonchianPeriod-1);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Middle Donchian");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,LowerBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,DonchianPeriod-1);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Lower Donchian");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Donchian( DonchianPeriod = ",DonchianPeriod,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Donchian Channel iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<DonchianPeriod+1) return(0);
//---- объявление переменных с плавающей точкой  
   double smin,smax,SsMax=0,SsMin=0;
//---- объявление целочисленных переменных
   int first,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated==0) // проверка на первый старт расчета индикатора
     {
      first=DonchianPeriod; // стартовый номер для расчета всех баров
     }
   else
     {
      first=prev_calculated-1;// стартовый номер для расчета новых баров
     }
//---- основной цикл расчета канала
   for(bar=first; bar<rates_total; bar++)
     {
      switch(Extremes)
        {
         case HIGH_LOW:
            SsMax=high[iHighest(high,DonchianPeriod,bar)];
            SsMin=low[iLowest(low,DonchianPeriod,bar)];
            break;
            //----
         case HIGH_LOW_OPEN:
            SsMax=(open[iHighest(open,DonchianPeriod,bar)]+high[iHighest(high,DonchianPeriod,bar)])/2;
            SsMin=(open[iLowest(open,DonchianPeriod,bar)]+low[iLowest(high,DonchianPeriod,bar)])/2;
            break;
            //----
         case HIGH_LOW_CLOSE:
            SsMax=(close[iHighest(close,DonchianPeriod,bar)]+high[iHighest(high,DonchianPeriod,bar)])/2;
            SsMin=(close[iLowest(close,DonchianPeriod,bar)]+low[iLowest(high,DonchianPeriod,bar)])/2;
            break;
            //----
         case OPEN_HIGH_LOW:
            SsMax=open[iHighest(open,DonchianPeriod,bar)];
            SsMin=open[iLowest(open,DonchianPeriod,bar)];
            break;
            //----
         case CLOSE_HIGH_LOW:
            SsMax=close[iHighest(close,DonchianPeriod,bar)];
            SsMin=close[iLowest(close,DonchianPeriod,bar)];
            break;
        }
      //----
      smin=SsMin+(SsMax-SsMin)*Margins/100;
      smax=SsMax-(SsMax-SsMin)*Margins/100;
      UpperBuffer[bar]=smax;
      LowerBuffer[bar]=smin;
      MiddleBuffer[bar]=(smax+smin)/2.0;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
