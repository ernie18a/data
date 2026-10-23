//+------------------------------------------------------------------+ 
//|                                                 DecEMA_StDev.mq5 | 
//|                                         Developed by Coders Guru |
//|                                            http://www.xpworx.com |                      
//|                         Revised by IgorAD,igorad2003@yahoo.co.uk |   
//|                                        http://www.forex-tsd.com/ |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Guru"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 6
//---- использовано всего пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов трехцветной линии использованы
#property indicator_color1  clrHotPink,clrGray,clrCornflowerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "DecEMA"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета медвежьего индикатора использован розовый цвет
#property indicator_color2  clrMagenta
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение медвежьей метки индикатора
#property indicator_label2  "Dn_Signal 1"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде символа
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета бычьего индикатора использован салатовый цвет
#property indicator_color3  clrSpringGreen
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение бычьей метки индикатора
#property indicator_label3  "Up_Signal 1"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета медвежьего индикатора использован розовый цвет
#property indicator_color4  clrMagenta
//---- толщина линии индикатора 4 равна 4
#property indicator_width4  4
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Dn_Signal 2"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора        |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета бычьего индикатора использован салатовый цвет
#property indicator_color5  clrSpringGreen
//---- толщина линии индикатора 5 равна 4
#property indicator_width5  4
//---- отображение бычьей метки индикатора
#property indicator_label5  "Up_Signal 2"
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Applied_price_ //тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint EMA_Period=3; // Период EMA 
input int ELength=15;    // Глубина сглаживания                   
input Applied_price_ IPC=PRICE_CLOSE; // Ценовая константа
input int PriceShift=0; // Сдвиг Фатла по вертикали в пунктах
input double dK1=1.5;   // Коэффициент 1 для квадратичного фильтра
input double dK2=2.5;   // Коэффициент 2 для квадратичного фильтра
input uint std_period=9; // Период квадратичного фильтра
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double ExtLineBuffer[],ColorExtLineBuffer[];
double BearsBuffer1[],BullsBuffer1[];
double BearsBuffer2[],BullsBuffer2[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление глобальных переменных
double alfa,dPriceShift,dDecEMA[];
//+------------------------------------------------------------------+    
//| DecEMA indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных 
   min_rates_total=2+int(std_period);
   alfa=2.0/(1.0+ELength);
//---- инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- распределение памяти под массивы переменных  
   ArrayResize(dDecEMA,std_period);
//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"DecEMA");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorExtLineBuffer,INDICATOR_COLOR_INDEX);
//---- превращение динамического массива BearsBuffer в индикаторный буфер
   SetIndexBuffer(2,BearsBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива BullsBuffer в индикаторный буфер
   SetIndexBuffer(3,BullsBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива BearsBuffer в индикаторный буфер
   SetIndexBuffer(4,BearsBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива BullsBuffer в индикаторный буфер
   SetIndexBuffer(5,BullsBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(4,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE); 
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"DecEMA(",EMA_Period,",",ELength,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| DecEMA iteration function                                        | 
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
//---- объявление локальных переменных
   int first,bar,maxbar;
//----
   double price,EMA0,EMA1,EMA2,EMA3,EMA4,EMA5,EMA6,EMA7,EMA8,EMA9,EMA10;
   static double sdEMA1,sdEMA2,sdEMA3,sdEMA4,sdEMA5,sdEMA6,sdEMA7,sdEMA8,sdEMA9,sdEMA10;
   double decema,SMAdif,Sum,StDev,dstd,BEARS1,BULLS1,BEARS2,BULLS2,Filter1,Filter2;
//----
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=1; // стартовый номер для расчета всех баров
      //---- инициализация коэффициентов
      sdEMA1=PriceSeries(IPC,first-1,open,low,high,close);
      sdEMA2=sdEMA1;
      sdEMA3=sdEMA1;
      sdEMA4=sdEMA1;
      sdEMA5=sdEMA1;
      sdEMA6=sdEMA1;
      sdEMA7=sdEMA1;
      sdEMA8=sdEMA1;
      sdEMA9=sdEMA1;
      sdEMA10=sdEMA1;
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- восстановление переменных
   EMA1=sdEMA1;
   EMA2=sdEMA2;
   EMA3=sdEMA3;
   EMA4=sdEMA4;
   EMA5=sdEMA5;
   EMA6=sdEMA6;
   EMA7=sdEMA7;
   EMA8=sdEMA8;
   EMA9=sdEMA9;
   EMA10=sdEMA10;
   maxbar=rates_total-1;
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      EMA0=XMA1.XMASeries(1,prev_calculated,rates_total,1,0,EMA_Period,price,bar,false);
      EMA1=alfa*EMA0 + (1-alfa)*EMA1;
      EMA2=alfa*EMA1 + (1-alfa)*EMA2;
      EMA3=alfa*EMA2 + (1-alfa)*EMA3;
      EMA4=alfa*EMA3 + (1-alfa)*EMA4;
      EMA5=alfa*EMA4 + (1-alfa)*EMA5;
      EMA6=alfa*EMA5 + (1-alfa)*EMA6;
      EMA7=alfa*EMA6 + (1-alfa)*EMA7;
      EMA8=alfa*EMA7 + (1-alfa)*EMA8;
      EMA9=alfa*EMA8 + (1-alfa)*EMA9;
      EMA10=alfa*EMA9+(1-alfa)*EMA10;
      ExtLineBuffer[bar]=10*EMA1-45*EMA2+120*EMA3-210*EMA4+252*EMA5-210*EMA6+120*EMA7-45*EMA8+10*EMA9-EMA10;
      ExtLineBuffer[bar]+=dPriceShift;
      //---- сохранение переменных 
      if(bar<maxbar)
        {
         sdEMA1=EMA1;
         sdEMA2=EMA2;
         sdEMA3=EMA3;
         sdEMA4=EMA4;
         sdEMA5=EMA5;
         sdEMA6=EMA6;
         sdEMA7=EMA7;
         sdEMA8=EMA8;
         sdEMA9=EMA9;
         sdEMA10=EMA10;
        }
     }
//---- пересчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first++;
//---- основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int clr=1;
      if(ExtLineBuffer[bar-1]<ExtLineBuffer[bar]) clr=2;
      if(ExtLineBuffer[bar-1]>ExtLineBuffer[bar]) clr=0;
      ColorExtLineBuffer[bar]=clr;
     }
//---- пересчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=min_rates_total;
//---- основной цикл расчета индикатора стандартных отклонений
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- загружаем приращения индикатора в массив для промежуточных вычислений
      for(int iii=0; iii<int(std_period); iii++) dDecEMA[iii]=ExtLineBuffer[bar-iii]-ExtLineBuffer[bar-iii-1];
      //---- находим простое среднее приращений индикатора
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=dDecEMA[iii];
      SMAdif=Sum/std_period;
      //---- находим сумму квадратов разностей приращений и среднего
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=MathPow(dDecEMA[iii]-SMAdif,2);
      //---- определяем итоговое значение среднеквадратичного отклонения StDev от приращения индикатора
      StDev=MathSqrt(Sum/std_period);
      //---- инициализация переменных
      dstd=NormalizeDouble(dDecEMA[0],_Digits+2);
      Filter1=NormalizeDouble(dK1*StDev,_Digits+2);
      Filter2=NormalizeDouble(dK2*StDev,_Digits+2);
      BEARS1=EMPTY_VALUE;
      BULLS1=EMPTY_VALUE;
      BEARS2=EMPTY_VALUE;
      BULLS2=EMPTY_VALUE;
      decema=ExtLineBuffer[bar];
      //---- вычисление индикаторных значений
      if(dstd<-Filter1 && dstd>=-Filter2) BEARS1=decema; //есть нисходящий тренд
      if(dstd<-Filter2) BEARS2=decema; //есть нисходящий тренд
      if(dstd>+Filter1 && dstd<=+Filter2) BULLS1=decema; //есть восходящий тренд
      if(dstd>+Filter2) BULLS2=decema; //есть восходящий тренд
      //---- инициализация ячеек индикаторных буферов полученными значениями 
      BullsBuffer1[bar]=BULLS1;
      BearsBuffer1[bar]=BEARS1;
      BullsBuffer2[bar]=BULLS2;
      BearsBuffer2[bar]=BEARS2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
