//+------------------------------------------------------------------+ 
//|                                              ColorZerolagRSI.mq5 | 
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2015, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 2
#property indicator_buffers 4 
//---- использовано три графических построения
#property indicator_plots   3
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color1 clrBlueViolet
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1 "FastTrendLine"
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color2 clrBlueViolet
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2 "SlowTrendLine"
//+-----------------------------------+
//| Параметры отрисовки заливки       |
//+-----------------------------------+
//---- отрисовка индикатора в виде заливки между двумя линиями
#property indicator_type3   DRAW_FILLING
//---- в качестве цветов заливки индикатора использованы Aqua и Tomato цвета
#property indicator_color3  clrAqua,clrTomato
//---- отображение метки индикатора
#property indicator_label3 "ZerolagRSI"
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint    smoothing=15;
input ENUM_APPLIED_PRICE IPC=PRICE_CLOSE; // Ценовая константа
//----
input double Factor1=0.05;
input uint    RSI_period1=8;
//----
input double Factor2=0.10;
input uint    RSI_period2=21;
//----
input double Factor3=0.16;
input uint    RSI_period3=34;
//----
input double Factor4=0.26;
input int    RSI_period4=55;
//----
input double Factor5=0.43;
input uint    RSI_period5=89;
//+-----------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int StartBar;
//---- объявление переменных с плавающей точкой
double smoothConst;
//---- индикаторные буферы
double FastBuffer[];
double SlowBuffer[];
double FastBuffer_[];
double SlowBuffer_[];
//---- объявление переменных для хранения хендлов индикаторов
int RSI1_Handle,RSI2_Handle,RSI3_Handle,RSI4_Handle,RSI5_Handle;
//+------------------------------------------------------------------+    
//| ZerolagRSI indicator initialization function                     | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация констант
   smoothConst=(smoothing-1.0)/smoothing;
//---- 
   uint PeriodBuffer[5];
//---- расчет стартового бара
   PeriodBuffer[0] = RSI_period1;
   PeriodBuffer[1] = RSI_period2;
   PeriodBuffer[2] = RSI_period3;
   PeriodBuffer[3] = RSI_period4;
   PeriodBuffer[4] = RSI_period5;
//----
   StartBar=int(3*PeriodBuffer[ArrayMaximum(PeriodBuffer,0,WHOLE_ARRAY)])+2;
//---- получение хендла индикатора iRSI1
   RSI1_Handle=iRSI(NULL,0,RSI_period1,IPC);
   if(RSI1_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI1");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iRSI2
   RSI2_Handle=iRSI(NULL,0,RSI_period2,IPC);
   if(RSI2_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI2");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iRSI3
   RSI3_Handle=iRSI(NULL,0,RSI_period3,IPC);
   if(RSI3_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI3");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iRSI4
   RSI4_Handle=iRSI(NULL,0,RSI_period4,IPC);
   if(RSI4_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI4");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iRSI5
   RSI5_Handle=iRSI(NULL,0,RSI_period5,IPC);
   if(RSI5_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI5");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,FastBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBar);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"FastTrendLine");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(FastBuffer,true);
//----
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,SlowBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBar);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"SlowTrendLine");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SlowBuffer,true);
//----
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,FastBuffer_,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(FastBuffer_,true);
//----
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,SlowBuffer_,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SlowBuffer_,true);
//----
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBar);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"FastTrendLine");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//----
//---- инициализация переменной для короткого имени индикатора
   string shortname="ZerolagRSI";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| ZerolagRSI iteration function                                    | 
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
   if(BarsCalculated(RSI1_Handle)<rates_total
      || BarsCalculated(RSI2_Handle)<rates_total
      || BarsCalculated(RSI3_Handle)<rates_total
      || BarsCalculated(RSI4_Handle)<rates_total
      || BarsCalculated(RSI5_Handle)<rates_total
      || rates_total<StartBar)
      return(0);
//---- объявление переменных с плавающей точкой  
   double Osc1,Osc2,Osc3,Osc4,Osc5,FastTrend,SlowTrend;
   double RSI1[],RSI2[],RSI3[],RSI4[],RSI5[];
//---- объявление целочисленных переменных
   int limit,to_copy,bar;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-StartBar-2; // стартовый номер для расчета всех баров
      to_copy=limit+2;
     }
   else // стартовый номер для расчета новых баров
     {
      limit=rates_total-prev_calculated;  // стартовый номер для расчета только новых баров
      to_copy=limit+1;
     }
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(RSI1,true);
   ArraySetAsSeries(RSI2,true);
   ArraySetAsSeries(RSI3,true);
   ArraySetAsSeries(RSI4,true);
   ArraySetAsSeries(RSI5,true);
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(RSI1_Handle,0,0,to_copy,RSI1)<=0) return(0);
   if(CopyBuffer(RSI2_Handle,0,0,to_copy,RSI2)<=0) return(0);
   if(CopyBuffer(RSI3_Handle,0,0,to_copy,RSI3)<=0) return(0);
   if(CopyBuffer(RSI4_Handle,0,0,to_copy,RSI4)<=0) return(0);
   if(CopyBuffer(RSI5_Handle,0,0,to_copy,RSI5)<=0) return(0);
//---- расчет стартового номера limit для цикла пересчета баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      bar=limit+1;
      Osc1 = Factor1 * RSI1[bar];
      Osc2 = Factor2 * RSI2[bar];
      Osc3 = Factor2 * RSI3[bar];
      Osc4 = Factor4 * RSI4[bar];
      Osc5 = Factor5 * RSI5[bar];
      //----
      FastTrend=Osc1+Osc2+Osc3+Osc4+Osc5;
      FastBuffer[bar]=FastBuffer_[bar]=FastTrend;
      SlowBuffer[bar]=SlowBuffer_[bar]=FastTrend/smoothing;
     }
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Osc1 = Factor1 * RSI1[bar];
      Osc2 = Factor2 * RSI2[bar];
      Osc3 = Factor2 * RSI3[bar];
      Osc4 = Factor4 * RSI4[bar];
      Osc5 = Factor5 * RSI5[bar];
      //----
      FastTrend = Osc1 + Osc2 + Osc3 + Osc4 + Osc5;
      SlowTrend = FastTrend / smoothing + SlowBuffer[bar + 1] * smoothConst;
      //----
      SlowBuffer[bar]=SlowTrend;
      FastBuffer[bar]=FastTrend;
      //----
      SlowBuffer_[bar]=SlowTrend;
      FastBuffer_[bar]=FastTrend;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
