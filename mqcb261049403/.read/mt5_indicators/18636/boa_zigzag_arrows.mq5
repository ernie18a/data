//+------------------------------------------------------------------+
//|                                            Boa_ZigZag_Arrows.mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                                mandorr@gmail.com |
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
//---- ссылка на сайт автора
#property link      "mandorr@gmail.com"
//---- номер версии индикатора
#property version   "1.00"
#property description "Казахский удав" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано всего 2 графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки верхнего индикатора     |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета индикатора использован MediumOrchid
#property indicator_color1  clrMediumOrchid
//---- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//---- отображение бычей метки индикатора
#property indicator_label1  "Up Boa_ZigZag_Arrows"
//+----------------------------------------------+
//|  Параметры отрисовки нижнего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета индикатора использован LimeGreen
#property indicator_color2  clrLimeGreen
//---- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//---- отображение медвежьей метки индикатора
#property indicator_label2 "Down Boa_ZigZag_Arrows"
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input uint Length=6;
input uint  UpLable=217;//лейба верхнего фрактала
input uint  DnLable=218;//лейба нижнего фрактала
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ZigzagPeakBuffer[],ZigzagLawnBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(Length)+1;
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ZigzagLawnBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ZigzagPeakBuffer,INDICATOR_DATA);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ZigzagLawnBuffer,true);
   ArraySetAsSeries(ZigzagPeakBuffer,true);
//---- установка позиции, с которой начинается отрисовка
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символы для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,DnLable);
   PlotIndexSetInteger(1,PLOT_ARROW,UpLable);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string shortname;
   StringConcatenate(shortname,"Boa_ZigZag(Length=",Length,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//----   
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   int limit,climit,bar;
   double HH,LL,BH,BL;   
   int zu,zd,Swing,Swing_n;
//----

   limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
   climit=limit; // стартовый номер для раскраски индикатора
   
   Swing=0;
   Swing_n=0;
   zu=limit;
   zd=limit;
   BH=high[limit];
   BL=low[limit];

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- Первый большой цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ZigzagLawnBuffer[bar]=NULL;
      ZigzagPeakBuffer[bar]=NULL;
     
      HH=high[ArrayMaximum(high,bar+1,Length)];
      LL=low[ArrayMinimum(low,bar+1,Length)];
      if (low[bar]<LL && high[bar]>HH)
        {
         Swing=2;
         if (Swing_n== 1) zu=bar+1;
         if (Swing_n==-1) zd=bar+1;
        }
      else
        {
         if (low [bar]<LL) Swing=-1;
         if (high[bar]>HH) Swing= 1;
        }
      if (Swing!=Swing_n && Swing_n!=0)
        {
         if (Swing== 2) {Swing=-Swing_n; BH=high[bar]; BL=low[bar];}
         if (Swing== 1) ZigzagLawnBuffer[zd]=BL;
         if (Swing==-1) ZigzagPeakBuffer[zu]=BH;
         BH=high[bar];
         BL=low [bar];
        }
      if (Swing== 1) {if (high[bar]>=BH) {BH=high[bar]; zu=bar;}}
      if (Swing==-1) {if (low [bar]<=BL) {BL=low [bar]; zd=bar;}}
      Swing_n=Swing;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
