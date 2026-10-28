//+------------------------------------------------------------------+ 
//|                                               FractalChannel.mq5 | 
//|                           Copyright © 2005, TrendLaboratory Ltd. |
//|                                       E-mail: igorad2004@list.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, TrendLaboratory Ltd."
#property link      "E-mail: igorad2004@list.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 3 
//---- использовано три графических построения
#property indicator_plots   3
//+-----------------------------------+
//| Параметры отрисовки индикатора 1  |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован зеленый цвет
#property indicator_color1 clrSeaGreen
//---- линия индикатора - штрих-пунктир
#property indicator_style1  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Upper FractalChannel"
//+-----------------------------------+
//| Параметры отрисовки индикатора 2  |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован серый цвет
#property indicator_color2 clrGray
//---- линия индикатора  - штрих-пунктир
#property indicator_style2  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "Middle FractalChannel"
//+-----------------------------------+
//| Параметры отрисовки индикатора 3  |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован красный цвет
#property indicator_color3 clrRed
//---- линия индикатора  - штрих-пунктир
#property indicator_style3  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width3  1
//---- отображение метки индикатора
#property indicator_label3  "Lower FractalChannel"
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum Type //тип константы
  {
   Type_1 = 1,     //Type_1
   Type_2,         //Type_2
   Type_3         //Type_3
  };
//+-----------------------------------+
enum PriceType //тип константы
  {
   OpenClose,//OpenClose
   LowHigh   //LowHigh
  };
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input Type       ChannelType=Type_1;
input double     Margins=0;
input double     Advance=0;
input PriceType  Prices=OpenClose;
input int        Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- индикаторные буферы
double UpperBuffer[];
double MiddleBuffer[];
double LowerBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total=7;
//+------------------------------------------------------------------+    
//| FractalChannel initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на AroonShift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Upper FractalChannel");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpperBuffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,MiddleBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Middle FractalChannel");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(MiddleBuffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,LowerBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Lower FractalChannel");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(LowerBuffer,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"FractalChannel( ChannelType = ",ChannelType,
                     ", Prices = ",Prices,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| FractalChannel iteration function                                | 
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
   if(rates_total<min_rates_total) return(0);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//---- объявление переменных с плавающей точкой  
   double smax,smin,Low0,Low1,Low2,Low3,Low4,Low5,Low6;
   double High0,High1,High2,High3,High4,High5,High6,v1,v2;
//---- объявление целочисленных переменных
   int limit,bar;
//---- объявление статических переменных  
   static double smax_,smin_;
//---- расчеты стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчета всех баров
      smax_ = 0;
      smin_ = 1000000000000;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
//---- восстанавливаем значения переменных
   smax = smax_;
   smin = smin_;
//---- основной цикл расчета индикатора    
   for(bar=limit; bar>=0; bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==rates_total-1)
        {
         smax_ = smax;
         smin_ = smin;
        }
      //----
      v1=-1;
      v2=-1;
      //----
      switch(Prices)
        {
         case  OpenClose:
            High0=high[bar+0];
            High1=high[bar+1];
            High2=high[bar+2];
            High3=high[bar+3];
            High4=high[bar+4];
            High5=high[bar+5];
            High6=high[bar+6];

            Low0=low[bar+0];
            Low1=low[bar+1];
            Low2=low[bar+2];
            Low3=low[bar+3];
            Low4=low[bar+4];
            Low5=low[bar+5];
            Low6=low[bar+6];
            break;
            //----
         case  LowHigh:
            High0=MathMax(close[bar+0],open[bar+1]);
            High1=MathMax(close[bar+1],open[bar+1]);
            High2=MathMax(close[bar+2],open[bar+2]);
            High3=MathMax(close[bar+3],open[bar+3]);
            High4=MathMax(close[bar+4],open[bar+4]);
            High5=MathMax(close[bar+5],open[bar+5]);
            High6=MathMax(close[bar+6],open[bar+6]);
            //----
            Low0=MathMin(close[bar+0],open[bar+1]);
            Low1=MathMin(close[bar+1],open[bar+1]);
            Low2=MathMin(close[bar+2],open[bar+2]);
            Low3=MathMin(close[bar+3],open[bar+3]);
            Low4=MathMin(close[bar+4],open[bar+4]);
            Low5=MathMin(close[bar+5],open[bar+5]);
            Low6=MathMin(close[bar+6],open[bar+6]);
            break;
            //----
         default:
            High0=high[bar+0];
            High1=high[bar+1];
            High2=high[bar+2];
            High3=high[bar+3];
            High4=high[bar+4];
            High5=high[bar+5];
            High6=high[bar+6];
            //----
            Low0=low[bar+0];
            Low1=low[bar+1];
            Low2=low[bar+2];
            Low3=low[bar+3];
            Low4=low[bar+4];
            Low5=low[bar+5];
            Low6=low[bar+6];
        }
      //----
      switch(ChannelType)
        {
         case  Type_1:
           {
            if(High2<=High1 && High0<High1) v1=High1;
            if(Low2 >= Low1 && Low0 > Low1) v2=Low1;
           }
         break;
         //----
         case  Type_2:
           {
            if(High4<=High2 && High3<=High2 && High0<High2 && High1<High2) v1=High2;
            if(Low4 >= Low2 && Low3 >= Low2 && Low0 > Low2 && Low1 > Low2) v2=Low2;
           }
         break;
         //----
         case  Type_3:
           {
            if(High6<=High3 && High5<=High3 && High4<=High3 && High0<High3 && High1<High3 && High2<High3) v1=High3;
            if(Low6 >= Low3 && Low5 >= Low3 && Low4 >= Low3 && Low0 > Low3 && Low1 > Low3 && Low2 > Low3) v2=Low3;
           }
         break;
         //----
         default:
           {
            if(High2<=High1 && High0<High1) v1=High1;
            if(Low2 >= Low1 && Low0 > Low1) v2=Low1;
           }
        }
      //----
      if(v1>0) smax=v1;
      if(High0>smax) smax=High0;
      //----
      if(v2>0) smin=v2;
      if(Low0<smin) smin=Low0;
      //----
      UpperBuffer[bar]=smax-(smax-smin)*Margins;
      LowerBuffer[bar]=smin+(smax-smin)*Margins;
      MiddleBuffer[bar]=(UpperBuffer[bar]+LowerBuffer[bar])/2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
