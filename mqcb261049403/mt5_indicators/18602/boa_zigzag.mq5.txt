//+------------------------------------------------------------------+
//|                                                   Boa_ZigZag.mq5 |
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
#property indicator_plots   1
//+----------------------------------------------+ 
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использован зигзаг секциями
#property indicator_type1   DRAW_COLOR_SECTION
//---- отображение метки индикатора
#property indicator_label1  "Boa_ZigZag"
//---- в качестве цвета линии индикатора использованы
#property indicator_color1 clrMediumOrchid,clrLimeGreen
//---- линия индикатора - длинный пунктир
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input uint Length=6;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
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
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(IndBuffer,true);
   ArraySetAsSeries(ColorIndBuffer,true);
//---- установка позиции, с которой начинается отрисовка уровней Боллинджера
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
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
      IndBuffer[bar]=NULL;
     
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
         if (Swing== 1) IndBuffer[zd]=BL;
         if (Swing==-1) IndBuffer[zu]=BH;
         BH=high[bar];
         BL=low [bar];
        }
      if (Swing== 1) {if (high[bar]>=BH) {BH=high[bar]; zu=bar;}}
      if (Swing==-1) {if (low [bar]<=BL) {BL=low [bar]; zd=bar;}}
      Swing_n=Swing;
     }

//---- Второй большой цикл раскраски индикатора
   for(bar=climit; bar>=0 && !IsStopped(); bar--)
     {
      if(!IndBuffer[bar]) ColorIndBuffer[bar]=ColorIndBuffer[bar+1];

      if(IndBuffer[bar] && IndBuffer[bar]>high[bar+1]) ColorIndBuffer[bar]=1;
      if(IndBuffer[bar] && IndBuffer[bar]<low[bar+1]) ColorIndBuffer[bar]=0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
