//+------------------------------------------------------------------+
//|                                              BykovTrend_NRTR.mq5 |
//|                                        Ramdass - Conversion only |
//|                                                                  |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Ramdass - Conversion only"
//--- ссылка на сайт автора
#property link      ""
//--- номер версии индикатора
#property version   "1.10"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 6
#property indicator_buffers 6 
//---- использовано всего шесть графических построений
#property indicator_plots   6
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1 DRAW_LINE
//---- в качестве окраски индикатора использован
#property indicator_color1 clrLime
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки сигнальной линии
#property indicator_label1  "NRTR Line Up"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2 DRAW_LINE
//---- в качестве окраски индикатора использован
#property indicator_color2 clrMagenta
//---- линия индикатора - сплошная
#property indicator_style2 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2 2
//---- отображение метки сигнальной линии
#property indicator_label2  "NRTR Line Down"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type3 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color3 clrLimeGreen
//---- линия индикатора - сплошная
#property indicator_style3 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3 2
//---- отображение метки сигнальной линии
#property indicator_label3  "NRTR Up"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type4 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color4 clrDarkViolet
//---- линия индикатора - сплошная
#property indicator_style4 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width4 2
//---- отображение метки сигнальной линии
#property indicator_label4  "NRTR Down"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде значка
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован цвет голубой
#property indicator_color5  clrDodgerBlue
//---- линия индикатора 5 - непрерывная кривая
#property indicator_style5  STYLE_SOLID
//---- толщина линии индикатора 5 равна 5
#property indicator_width5  5
//---- отображение бычьей метки индикатора
#property indicator_label5  "Buy BykovTrend signal"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 6 в виде значка
#property indicator_type6   DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован цвет глубоко-розовый
#property indicator_color6  clrDeepPink
//---- линия индикатора 6 - непрерывная кривая
#property indicator_style6  STYLE_SOLID
//---- толщина линии индикатора 6 равна 5
#property indicator_width6  5
//---- отображение медвежьей метки индикатора
#property indicator_label6 "Sell BykovTrend signal"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int RISK=3;
input int SSP=9;
input double AtrRatio=0.375;
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double UpBuffer1[],DnBuffer1[];
double UpBuffer2[],DnBuffer2[];
double SellBuffer[],BuyBuffer[];
//---
int K,WPR_Handle,ATR_Handle,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   K=33-RISK;
   int ATR_Period=15;
   min_rates_total=int(MathMax(SSP,ATR_Period))+1;
//--- получение хендла индикатора ATR
   WPR_Handle=iWPR(NULL,0,SSP);
   if(WPR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iWPR");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer1,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer1,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer1,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer1,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,UpBuffer2,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer2,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,DnBuffer2,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer2,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 5
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(4,PLOT_ARROW,175);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 6
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(5,PLOT_ARROW,175);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);

//--- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="BykovTrend";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(WPR_Handle)<rates_total || BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total)
      return(RESET);

//--- объявления локальных переменных 
   int to_copy,limit,bar,trend;
   double WPR[],ATR[],range,stop;
   static int oldtrend;

//--- расчеты необходимого количества копируемых данных и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчета всех баров
      oldtrend=0;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=limit+1; // расчетное количество копируемых баров

//--- копируем вновь появившиеся данные в массивы WPR[] и ATR[]
   if(CopyBuffer(WPR_Handle,0,0,to_copy,WPR)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(WPR,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=SellBuffer[bar]=UpBuffer1[bar]=DnBuffer1[bar]=UpBuffer2[bar]=DnBuffer2[bar]=NULL;
      //---
      trend=oldtrend;
      if(WPR[bar]<-100+K) trend=-1;
      if(WPR[bar]>-K) trend=+1;
      range=AtrRatio*ATR[bar];
      //---
      if(oldtrend<0 && trend>0) BuyBuffer[bar]=low[bar]-range;
      if(oldtrend>0 && trend<0) SellBuffer[bar]=high[bar]+range;

      if(trend>0)
        {
         if(BuyBuffer[bar])
           {
            UpBuffer1[bar]=UpBuffer2[bar]=BuyBuffer[bar];
            DnBuffer1[bar]=DnBuffer1[bar+1];
           }
         else
           {
            stop=low[bar]-range;
            if(stop<UpBuffer1[bar+1]) stop=UpBuffer1[bar+1];
            UpBuffer1[bar]=UpBuffer2[bar]=stop;
           }
        }

      if(trend<0)
        {
         if(SellBuffer[bar])
           {
            DnBuffer1[bar]=DnBuffer2[bar]=SellBuffer[bar];
            UpBuffer1[bar]=UpBuffer1[bar+1];
           }
         else
           {
            stop=high[bar]+range;
            if(stop>DnBuffer1[bar+1]) stop=DnBuffer1[bar+1];
            DnBuffer1[bar]=DnBuffer2[bar]=stop;
           }
        }
      //---
      if(bar) oldtrend=trend;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
