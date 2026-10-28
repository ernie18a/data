//+------------------------------------------------------------------+
//|                                           Boa_ZigZag_channel.mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                                mandorr@gmail.com |
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
//---- ссылка на сайт автора
#property link      "mandorr@gmail.com"
//---- номер версии индикатора
#property version   "1.00"
#property description "Казахский удав в виде канала" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано восемь буферов
#property indicator_buffers 8
//---- использовано всего пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//|  Параметры отрисовки индикатора облака       |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrLavender
//---- отображение метки индикатора
#property indicator_label1  "Boa_ZigZag_channel Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки верхнего индикатора     |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде многоцветной линии
#property indicator_type2   DRAW_COLOR_LINE
//---- в качестве цвета индикатора использованы
#property indicator_color2  clrLimeGreen,clrMediumOrchid
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение бычей метки индикатора
#property indicator_label2  "Up Boa_ZigZag_channel"
//+----------------------------------------------+
//|  Параметры отрисовки нижнего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде многоцветной линии
#property indicator_type3   DRAW_COLOR_LINE
//---- в качестве цвета индикатора использованы
#property indicator_color3  clrLimeGreen,clrMediumOrchid
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение медвежьей метки индикатора
#property indicator_label3 "Down Boa_ZigZag_channel"
//+----------------------------------------------+
//|  Параметры отрисовки верхнего индикатора     |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета индикатора использован Blue
#property indicator_color4  clrBlue
//---- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//---- отображение бычей метки индикатора
#property indicator_label4  "Up Boa_ZigZag_Arrows"
//+----------------------------------------------+
//|  Параметры отрисовки нижнего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета индикатора использован Magenta
#property indicator_color5  clrMagenta
//---- толщина линии индикатора 5 равна 2
#property indicator_width5  2
//---- отображение медвежьей метки индикатора
#property indicator_label5 "Down Boa_ZigZag_Arrows"
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input uint Length=6;
input uint  UpLable=159;//лейба верхнего фрактала
input uint  DnLable=159;//лейба нижнего фрактала
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[],DnBuffer[];
double UpperBuffer[],LowerBuffer[];
double ColorUpperBuffer[],ColorLowerBuffer[];
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
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,UpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ColorUpperBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,LowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ColorLowerBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,ZigzagPeakBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,ZigzagLawnBuffer,INDICATOR_DATA);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(UpBuffer,true);
   ArraySetAsSeries(DnBuffer,true);
   ArraySetAsSeries(UpperBuffer,true);
   ArraySetAsSeries(LowerBuffer,true);
   ArraySetAsSeries(ColorUpperBuffer,true);
   ArraySetAsSeries(ColorLowerBuffer,true);
   ArraySetAsSeries(ZigzagLawnBuffer,true);
   ArraySetAsSeries(ZigzagPeakBuffer,true);
//---- установка позиции, с которой начинается отрисовка
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- символы для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,DnLable);
   PlotIndexSetInteger(4,PLOT_ARROW,UpLable);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string shortname;
   StringConcatenate(shortname,"Boa_ZigZag_channel(Length=",Length,")");
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
   double LastLawn_prev,LastLawn,LastPeak_prev,LastPeak;
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

   LastPeak_prev=LastPeak=high[ArrayMaximum(high,limit,Length)];
   LastLawn_prev=LastLawn=low[ArrayMinimum(low,limit,Length)];

//---- Первый большой цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ZigzagLawnBuffer[bar]=NULL;
      ZigzagPeakBuffer[bar]=NULL;

      HH=high[ArrayMaximum(high,bar+1,Length)];
      LL=low[ArrayMinimum(low,bar+1,Length)];
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
         if(Swing==+1)
           {
            ZigzagLawnBuffer[zd]=BL;
            LastLawn_prev=LastLawn;
            LastLawn=BL;
            DnBuffer[zd]=LowerBuffer[zd]=BL;
            if(LastLawn_prev>LastLawn) ColorLowerBuffer[zd]=1;
            else if(LastLawn_prev<LastLawn) ColorLowerBuffer[zd]=0;
            else ColorLowerBuffer[zd]=ColorLowerBuffer[zd+1];
           }
         if(Swing==-1)
           {
            ZigzagPeakBuffer[zu]=BH;
            LastPeak_prev=LastPeak;
            LastPeak=BH;
            UpBuffer[zu]=UpperBuffer[zu]=BH;
            if(LastPeak_prev>LastPeak) ColorUpperBuffer[zu]=1;
            else if(LastPeak_prev<LastPeak) ColorUpperBuffer[zu]=0;
            else ColorUpperBuffer[zu]=ColorUpperBuffer[zu+1];
           }
         BH=high[bar];
         BL=low [bar];
        }

      if(ZigzagPeakBuffer[zu])
         for(int index=zu-1; index>=bar && !IsStopped(); index--)
           {
            UpBuffer[index]=UpBuffer[index+1];
            UpperBuffer[index]=UpperBuffer[index+1];
            ColorUpperBuffer[index]=ColorUpperBuffer[index+1];
           }
      else
        {
         UpBuffer[bar]=UpperBuffer[bar]=LastPeak;
         ColorUpperBuffer[bar]=ColorUpperBuffer[bar+1];
        }
      if(ZigzagLawnBuffer[zd])
         for(int index=zd-1; index>=bar && !IsStopped(); index--)
           {
            DnBuffer[index]=DnBuffer[index+1];
            LowerBuffer[index]=LowerBuffer[index+1];
            ColorLowerBuffer[index]=ColorLowerBuffer[index+1];
           }
      else
        {
         DnBuffer[bar]=LowerBuffer[bar]=LowerBuffer[bar+1];
         ColorLowerBuffer[bar]=ColorLowerBuffer[bar+1];
        }

      if(!ZigzagPeakBuffer[zu] && !ZigzagLawnBuffer[zd])
        {
         DnBuffer[bar]=LowerBuffer[bar]=LastLawn;
         ColorLowerBuffer[bar]=ColorLowerBuffer[bar+1];
         //----
         UpBuffer[bar]=UpperBuffer[bar]=LastPeak;
         ColorUpperBuffer[bar]=ColorUpperBuffer[bar+1];
        }

      if(Swing== 1) {if(high[bar]>=BH) {BH=high[bar]; zu=bar;}}
      if(Swing==-1) {if(low [bar]<=BL) {BL=low [bar]; zd=bar;}}
      Swing_n=Swing;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
