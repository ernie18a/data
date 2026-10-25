//+------------------------------------------------------------------+
//|                                     Boa_ZigZag_Arrows_Duplex.mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                                mandorr@gmail.com |
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
//---- ссылка на сайт автора
#property link      "mandorr@gmail.com"
//---- номер версии индикатора
#property version   "1.00"
#property description "Дв разнопериодных казахских удава" 
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type1 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color1 clrDodgerBlue
//---- толщина линии индикатора равна 5
#property indicator_width1 5
//---- отображение метки сигнальной линии
#property indicator_label1  "Slow Boa_ZigZag Dn"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type2 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color2 clrDeepPink
//---- толщина линии индикатора равна 5
#property indicator_width2 5
//---- отображение метки сигнальной линии
#property indicator_label2  "Slow Boa_ZigZag Up"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован
#property indicator_color3  clrAqua
//---- толщина линии индикатора 3 равна 5
#property indicator_width3  5
//---- отображение бычьей метки индикатора
#property indicator_label3  "Fast Boa_ZigZag Dn"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде значка
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован
#property indicator_color4  clrOrange
//---- толщина линии индикатора 2 равна 5
#property indicator_width4  5
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Fast Boa_ZigZag Up"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint SlowLength=42; // период медленного зигзага
input uint FastLength=6; // период быстрого зигзага
                         //input int Shift=0;      // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double ZigzagLawnBuffer1[],ZigzagPeakBuffer1[];
double ZigzagLawnBuffer2[],ZigzagPeakBuffer2[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(MathMax(SlowLength,FastLength))+1;

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Boa_ZigZag_Arrows_Duplex(",string(SlowLength),", ",string(FastLength),")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ZigzagLawnBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
//PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ZigzagLawnBuffer1,true);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,162);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ZigzagPeakBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
//PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ZigzagPeakBuffer1,true);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,162);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,ZigzagLawnBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
//PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ZigzagLawnBuffer2,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,159);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,ZigzagPeakBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
//PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ZigzagPeakBuffer2,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   int limit,climit,bar;
   double HH,LL,BH,BL;
   int zu,zd,Swing,Swing_n;
//----

   limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
   climit=limit; // стартовый номер для раскраски индикатора

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//----   
   Swing=0;
   Swing_n=0;
   zu=limit;
   zd=limit;
   BH=high[limit];
   BL=low[limit];
//---- Цикл расчёта медленного зигзага
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ZigzagLawnBuffer1[bar]=NULL;
      ZigzagPeakBuffer1[bar]=NULL;

      HH=high[ArrayMaximum(high,bar+1,SlowLength)];
      LL=low[ArrayMinimum(low,bar+1,SlowLength)];
      if(low[bar]<LL && high[bar]>HH)
        {
         Swing=2;
         if(Swing_n== 1) zu=bar+1;
         if(Swing_n==-1) zd=bar+1;
        }
      else
        {
         if(low [bar]<LL) Swing=-1;
         if(high[bar]>HH) Swing= 1;
        }
      if(Swing!=Swing_n && Swing_n!=0)
        {
         if(Swing==2) {Swing=-Swing_n; BH=high[bar]; BL=low[bar];}
         if(Swing== 1)
           {            
            if(BL==low[zd]) ZigzagLawnBuffer1[zd]=BL;
            else ZigzagLawnBuffer1[zd-1]=BL;
           }
         if(Swing==-1)
           {
            if(BH==high[zu]) ZigzagPeakBuffer1[zu]=BH;
            else ZigzagPeakBuffer1[zu-1]=BH;
           }
         BH=high[bar];
         BL=low [bar];
        }
      if(Swing== 1) {if(high[bar]>=BH) {BH=high[bar]; zu=bar;}}
      if(Swing==-1) {if(low [bar]<=BL) {BL=low [bar]; zd=bar;}}
      Swing_n=Swing;
     }
//----   
   Swing=0;
   Swing_n=0;
   zu=limit;
   zd=limit;
   BH=high[limit];
   BL=low[limit];
//---- Цикл расчёта быстрого зигзага
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ZigzagLawnBuffer2[bar]=NULL;
      ZigzagPeakBuffer2[bar]=NULL;

      HH=high[ArrayMaximum(high,bar+1,FastLength)];
      LL=low[ArrayMinimum(low,bar+1,FastLength)];
      if(low[bar]<LL && high[bar]>HH)
        {
         Swing=2;
         if(Swing_n== 1) zu=bar+1;
         if(Swing_n==-1) zd=bar+1;
        }
      else
        {
         if(low [bar]<LL) Swing=-1;
         if(high[bar]>HH) Swing= 1;
        }
      if(Swing!=Swing_n && Swing_n!=0)
        {
         if(Swing==2) {Swing=-Swing_n; BH=high[bar]; BL=low[bar];}
         if(Swing== 1)
           {            
            if(BL==low[zd]) ZigzagLawnBuffer2[zd]=BL;
            else ZigzagLawnBuffer2[zd-1]=BL;
           }
         if(Swing==-1)
           {
            if(BH==high[zu]) ZigzagPeakBuffer2[zu]=BH;
            else ZigzagPeakBuffer2[zu-1]=BH;
           }
         BH=high[bar];
         BL=low [bar];
        }
      if(Swing== 1) {if(high[bar]>=BH) {BH=high[bar]; zu=bar;}}
      if(Swing==-1) {if(low [bar]<=BL) {BL=low [bar]; zd=bar;}}
      Swing_n=Swing;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
