//+------------------------------------------------------------------+
//|                                               HistVolatility.mq5 | 
//|                              Copyright © 2008, Victor Umnyashkin |
//|                                                   v354@hotbox.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Victor Umnyashkin"
#property link      "v354@hotbox.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде трехцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов  использованы
#property indicator_color1 clrGray,clrPurple,clrDarkTurquoise
//---- линия индикатора - непрерывная кривая
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 4
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "HistVolatility"
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum Scale_ //Тип константы
  {
   S1_ = 1,     //1
   S2_,         //2
   S3_          //3
  };
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input int Per=21;
input Scale_ Scale=S3_;
input int Trading_Day_In_Year=365;
input int Percent=100;
input double Coeff=1;
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- индикаторные буферы
double LineBuffer[],ColorLineBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int YearBase,min_rates_total;
//+------------------------------------------------------------------+   
//| HistVolatility initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=Per+1;
//---- инициализация переменных
   YearBase=Trading_Day_In_Year*PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(LineBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorLineBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorLineBuffer,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"HistVolatility(",Per,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| HistVolatility iteration function                                | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const int begin,          // номер начала достоверного отсчета баров
                const double &price[])    // ценовой массив для расчета индикатора
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total+begin) return(0);
//---- объявление переменных с плавающей точкой  
   double Volatility;
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int limit,bar;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1-min_rates_total-begin; // стартовый номер для расчета всех баров
      //---- осуществление сдвига начала отсчета отрисовки индикатора
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+1+begin);
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(price,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Volatility=WVHiVol(Per,price,bar,Scale);
      LineBuffer[bar]=Volatility*MathSqrt(1.0*YearBase/Per)*Percent*Coeff;
     }
//----
   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
//---- основной цикл раскраски индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorLineBuffer[bar]=0;
      if(LineBuffer[bar]>LineBuffer[bar+1]) ColorLineBuffer[bar]=2;
      if(LineBuffer[bar]<LineBuffer[bar+1]) ColorLineBuffer[bar]=1;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+
double WVHiVol(int N,const double &Price[],int index,Scale_ IsLog)
  {
//----
   double Mid,MidLog,MidIncr,delta,Vol,VolLog,VolIncr;
//----
   Mid=0;
   MidIncr=0;
   MidLog=0;
//----
   for(int i=0; i<N; i++)
     {
      delta=Price[index+i]-Price[index+i+1];
      Mid+=delta;
      delta/=Price[index+i];
      MidIncr+=delta;
      delta=Price[index+i]/Price[index+i+1];
      MidLog+=MathLog(delta);
     }
//----
   Vol=0;
   VolLog=0;
   VolIncr=0;
//----
   for(int i=0; i<N; i++)
     {
      delta=Price[index+i]-Price[index+i+1];
      Vol+=(delta-Mid)*(delta-Mid);
      delta/=Price[i];
      VolIncr+=(delta-MidIncr)*(delta-MidIncr);
      delta=MathLog(Price[index+i]/Price[index+i+1]);
      VolLog+=(delta-MidLog)*(delta-MidLog);
     }
//----
   if(IsLog == S2_) return(MathSqrt(Vol/(N-1.0)));
   if(IsLog == S1_) return(MathSqrt(VolIncr/(N-1.0)));
//----
   return(MathSqrt(VolLog/(N-1.0)));
  }
//+------------------------------------------------------------------+
