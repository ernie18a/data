//+------------------------------------------------------------------+
//|                                                  2pbIdeal1MA.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2011, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- для расчёта и отрисовки индикатора использован один буфер
#property indicator_buffers 1
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован синий цвет
#property indicator_color1  clrBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "2pbIdealMA"
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input uint Period1 = 10; //грубое усреднение
input uint Period2 = 10; //уточняющее усреднение
input int MAShift=0; //сдвиг мувинга по горизонтали в барах 
//+----------------------------------------------+ 
//---- объявление динамического массива, который будет в 
// дальнейшем использован в качестве индикаторного буфера
double ExtLineBuffer[];
//---- объявления переменных для сглаживающих констант
double w1,w2;
//+------------------------------------------------------------------+
//|  Усреднение от Neutron                                           |
//+------------------------------------------------------------------+
double GetIdealMASmooth
(
 double W1_,//первая сглаживающая константа
 double W2_,//вторая сглаживающая константа
 double Series1,//значение тамсерии с текущего бара 
 double Series0,//значение тамсерии с предыдущего бара 
 double Resalt1 //значение мувинга с предыдущего бара
 )
  {
//----
   double Resalt0,dSeries,dSeries2;
   dSeries=Series0-Series1;
   dSeries2=dSeries*dSeries-1.0;

   Resalt0=(W1_ *(Series0-Resalt1)+
            Resalt1+W2_*Resalt1*dSeries2)
   /(1.0+W2_*dSeries2);
//----
   return(Resalt0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализации переменных
   w1=1.0/Period1;
   w2=1.0/Period2;
//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали наMAShift
   PlotIndexSetInteger(0,PLOT_SHIFT,MAShift);
//---- установка позиции, с которой начинается отрисовка индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,1);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"2pbIdealMA(",w1,",",w2,")");
//---- создание метки для отображения в Окне данных
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,     // количество истории в барах на текущем тике
                const int prev_calculated, // количество истории в барах на предыдущем тике
                const int begin,           // номер начала достоверного отсчёта баров
                const double &price[]      // ценовой массив для расчёта индикатора
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<1+begin) return(0);

//---- объявления локальных переменных 
   int first,bar;
   
//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=1+begin;  // стартовый номер для расчёта всех баров
      //---- увеличим позицию начала данных на begin баров, вследствие расчетов на данных другого индикатора
      if(begin>0) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin+1);
         
      ExtLineBuffer[begin]=price[begin];
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total; bar++)
      ExtLineBuffer[bar]=GetIdealMASmooth(w1,w2,price[bar-1],price[bar],ExtLineBuffer[bar-1]);
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
