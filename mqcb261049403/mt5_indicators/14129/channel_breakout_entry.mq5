//+------------------------------------------------------------------+
//|                                       channel_breakout_entry.mq5 | 
//|                                       Copyright © 2009, darmasdt | 
//|                                          http://indotraders.org/ | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, darmasdt"
#property link "http://indotraders.org/"
#property description ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 8
#property indicator_buffers 8 
//---- использовано всего 8 графических построений
#property indicator_plots   8
//+--------------------------------------------+
//| Параметры отрисовки индикатора             |
//+--------------------------------------------+
//---- отрисовка уровней в виде линий
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE
//---- выбор цветов уровней
#property indicator_color1 clrDarkGray
#property indicator_color2 clrDarkGray
#property indicator_color3 clrDodgerBlue
#property indicator_color4 clrDodgerBlue
#property indicator_color5 clrTomato
#property indicator_color6 clrTomato
#property indicator_color7 clrLightSkyBlue
#property indicator_color8 clrPlum
//---- уровни - сплошные кривые
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
#property indicator_style6 STYLE_SOLID
#property indicator_style7 STYLE_SOLID
#property indicator_style8 STYLE_SOLID
//---- толщина уровней равна 1
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  1
//---- отображение меток уровней
#property indicator_label1  "trailing_Up"
#property indicator_label2  "trailing_Dn"
#property indicator_label3  "sys1_Up"
#property indicator_label4  "sys1_Dn"
#property indicator_label5  "failsafe_Up"
#property indicator_label6  "failsafe_Dn"
#property indicator_label7  "Sys 1 Stp"
#property indicator_label8  "Sys 2 Stp"
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint Range1=10;
input uint Range2=20;
input uint Range3=55;
input double atr_factor=2;
input int atr_range=14;
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов уровней channel_breakout_entry
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[];
double ExtLineBuffer5[],ExtLineBuffer6[],ExtLineBuffer7[],ExtLineBuffer8[];
//---- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| channel_breakout_entry indicator initialization function         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(MathMax(MathMax(MathMax(Range1,atr_factor),Range2),Range3));
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,atr_range);
   if(ATR_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора ATR");
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer6,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer7,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer8,INDICATOR_DATA);
//---- установка позиции, с которой начинается отрисовка уровней
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
   ArraySetAsSeries(ExtLineBuffer3,true);
   ArraySetAsSeries(ExtLineBuffer4,true);
   ArraySetAsSeries(ExtLineBuffer5,true);
   ArraySetAsSeries(ExtLineBuffer6,true);
   ArraySetAsSeries(ExtLineBuffer7,true);
   ArraySetAsSeries(ExtLineBuffer8,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"channel_breakout_entry(",Range1,",",Range2,",",Range3,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| channel_breakout_entry iteration function                        | 
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявление переменных с плавающей точкой  
   double ATR[];
//---- объявления локальных переменных 
   int limit,to_copy,bar;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=rates_total-min_rates_total-2; // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров 
   to_copy=limit+2;
//---- копируем вновь появившиеся данные в массив SAR
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtLineBuffer1[bar]=high[ArrayMaximum(high,bar,Range1)];
      ExtLineBuffer2[bar]=low[ArrayMinimum(low,bar,Range1)];
      ExtLineBuffer3[bar]=high[ArrayMaximum(high,bar,Range2)];
      ExtLineBuffer4[bar]=low[ArrayMinimum(low,bar,Range2)];
      ExtLineBuffer5[bar]=high[ArrayMaximum(high,bar,Range3)];
      ExtLineBuffer6[bar]=low[ArrayMinimum(low,bar,Range3)];
      //----
      if(high[bar+1]<=ExtLineBuffer3[bar+1] && high[bar]>ExtLineBuffer3[bar])
        {
         ExtLineBuffer7[bar]=ExtLineBuffer3[bar]-(ATR[bar+1]*atr_factor);
        }
      if(high[bar+1]<=ExtLineBuffer5[bar+1] && high[bar]>ExtLineBuffer5[bar])
        {
         ExtLineBuffer8[bar]=ExtLineBuffer5[bar]-(ATR[bar+1]*atr_factor);
        }
      if(low[bar+1]>=ExtLineBuffer4[bar+1] && low[bar]<ExtLineBuffer4[bar])
        {
         ExtLineBuffer7[bar]=ExtLineBuffer4[bar]+(ATR[bar+1]*atr_factor);
        }
      if(low[bar+1]>=ExtLineBuffer6[bar+1] && ExtLineBuffer6[bar])
        {
         ExtLineBuffer8[bar]=ExtLineBuffer6[bar]+(ATR[bar+1]*atr_factor);
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
