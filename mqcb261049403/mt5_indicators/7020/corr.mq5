//+------------------------------------------------------------------+
//|                                                         Corr.mq5 | 
//|                                           Copyright © 2006, Nike | 
//|                                              http://www.mql4.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2006, Nike"
#property link "http://www.mql4.com"
//---- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован DodgerBlue цвет
#property indicator_color1 clrDodgerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Corr"
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint CorrLen=7;  // период
input int Shift=0;     // сдвиг индикатора по горизонтали в барах
//+-----------------------------------+

//---- объявление динамического массива, который будет в 
// дальнейшем использован в качестве индикаторного буфера
double IndBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(CorrLen);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Corr(",CorrLen,", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
   
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
   
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=min_rates_total-1; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++) 
     {
      IndBuffer[bar]=(close[bar]-open[bar])/_Point;
      IndBuffer[bar]=corr(IndBuffer,bar,CorrLen);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  corr()                                                          |
//+------------------------------------------------------------------+
double corr(double &a[],int index,int len)
  {
//----
   double m1 = 0;
   double m2 = 0;
   double m1_2 = 0;
   double m2_2 = 0;
   double m12=0;
//----
   for(int i=0; i<len; i++)
     {
      m1+=a[i];
      m2+=a[index-i];
      m1_2+=a[i]*a[i];
      m2_2+=a[index-i]*a[index-i];
      m12+=a[i]*a[index-i];
     }
//----
   m1 = m1/len;
   m2 = m2/len;
   m1_2/=len;
   m2_2/=len;
   m12/=len;
   double res=(m1_2-m1*m1)*(m2_2-m2*m2);
   if(!res) return(0);
//----
   return((m12 - m1*m2)/MathSqrt(MathAbs(res)));
  }
//+------------------------------------------------------------------+
