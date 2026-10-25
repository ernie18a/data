//+------------------------------------------------------------------+ 
//|                                           ColorZerolagStochs.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2011, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
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
//---- в качестве цвета линии индикатора использован ярко-зеленый цвет
#property indicator_color1 SpringGreen
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1 "FastTrendLine"
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color2 BlueViolet
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
//---- в качестве цветов заливки индикатора использованы синий цвет и красный цвета
#property indicator_color3  Blue, Red
//---- отображение метки индикатора
#property indicator_label3 "ZerolagStochs"
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input int    Slowing=3;
input int    smoothing=15;
input ENUM_MA_METHOD MA_Method=MODE_SMA;
input ENUM_STO_PRICE Price_field=STO_LOWHIGH;
//----
input double Factor1=0.05;
input int    Kperiod1 = 8;
input int    Dperiod1 = 3;
//----
input double Factor2=0.10;
input int    Kperiod2 = 21;
input int    Dperiod2 = 5;
//----
input double Factor3=0.16;
input int    Kperiod3 = 34;
input int    Dperiod3 = 8;
//----
input double Factor4=0.26;
input int    Kperiod4 = 55;
input int    Dperiod4 = 13;
//----
input double Factor5=0.43;
input int    Kperiod5 = 89;
input int    Dperiod5 = 21;
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
int STO1_Handle,STO2_Handle,STO3_Handle,STO4_Handle,STO5_Handle;
//+------------------------------------------------------------------+    
//| ZerolagStochs indicator initialization function                  | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация констант
   smoothConst=(smoothing-1.0)/smoothing;
//---- 
   int PeriodBuffer[5];
//---- расчет стартового бара
   PeriodBuffer[0] = Kperiod1 + Dperiod1;
   PeriodBuffer[1] = Kperiod2 + Dperiod2;
   PeriodBuffer[2] = Kperiod3 + Dperiod3;
   PeriodBuffer[3] = Kperiod4 + Dperiod4;
   PeriodBuffer[4] = Kperiod5 + Dperiod5;
//----
   StartBar=PeriodBuffer[ArrayMaximum(PeriodBuffer,0,WHOLE_ARRAY)]+1;
//---- получение хендла индикатора iStochastic1
   STO1_Handle=iStochastic(NULL,0,Kperiod1,Dperiod1,Slowing,MA_Method,Price_field);
   if(STO1_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора iStochastic1");
//---- получение хендла индикатора iStochastic2
   STO2_Handle=iStochastic(NULL,0,Kperiod2,Dperiod2,Slowing,MA_Method,Price_field);
   if(STO2_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора iStochastic2");
//---- получение хендла индикатора iStochastic3
   STO3_Handle=iStochastic(NULL,0,Kperiod3,Dperiod3,Slowing,MA_Method,Price_field);
   if(STO3_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора iStochastic3");
//---- получение хендла индикатора iStochastic4
   STO4_Handle=iStochastic(NULL,0,Kperiod4,Dperiod4,Slowing,MA_Method,Price_field);
   if(STO4_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора iStochastic4");
//---- получение хендла индикатора iStochastic5
   STO5_Handle=iStochastic(NULL,0,Kperiod5,Dperiod5,Slowing,MA_Method,Price_field);
   if(STO5_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора iStochastic5");
//----
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
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBar);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"FastTrendLine");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(FastBuffer_,true);
//----
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,SlowBuffer_,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBar);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(3,PLOT_LABEL,"SlowTrendLine");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SlowBuffer_,true);
//----
//---- инициализации переменной для короткого имени индикатора
   string shortname="ZerolagStochs";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| ZerolagStochs iteration function                                 | 
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
   if(BarsCalculated(STO1_Handle)<rates_total
      || BarsCalculated(STO2_Handle)<rates_total
      || BarsCalculated(STO3_Handle)<rates_total
      || BarsCalculated(STO4_Handle)<rates_total
      || BarsCalculated(STO5_Handle)<rates_total
      || rates_total<StartBar)
      return(0);
//---- объявление переменных с плавающей точкой  
   double Sto1,Sto2,Sto3,Sto4,Sto5,FastTrend,SlowTrend;
   double Stoch1[],Stoch2[],Stoch3[],Stoch4[],Stoch5[];
//---- объявление целочисленных переменных
   int limit,to_copy,bar;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-StartBar-2; // стартовый номер для расчета всех баров
      to_copy=rates_total; // расчетное количество всех баров
     }
   else // стартовый номер для расчета новых баров
     {
      limit=rates_total-prev_calculated;  // стартовый номер для расчета только новых баров
      to_copy=rates_total-prev_calculated+1;
     }
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Stoch1,true);
   ArraySetAsSeries(Stoch2,true);
   ArraySetAsSeries(Stoch3,true);
   ArraySetAsSeries(Stoch4,true);
   ArraySetAsSeries(Stoch5,true);
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(STO1_Handle,0,0,to_copy,Stoch1)<=0) return(0);
   if(CopyBuffer(STO2_Handle,0,0,to_copy,Stoch2)<=0) return(0);
   if(CopyBuffer(STO3_Handle,0,0,to_copy,Stoch3)<=0) return(0);
   if(CopyBuffer(STO4_Handle,0,0,to_copy,Stoch4)<=0) return(0);
   if(CopyBuffer(STO5_Handle,0,0,to_copy,Stoch5)<=0) return(0);
//---- расчеты необходимого количества копируемых данных,
//---- стартового номера limit для цикла пересчета баров
//---- и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      Sto1 = Factor1 * Stoch1[limit+1];
      Sto2 = Factor2 * Stoch2[limit+1];
      Sto3 = Factor2 * Stoch3[limit+1];
      Sto4 = Factor4 * Stoch4[limit+1];
      Sto5 = Factor5 * Stoch5[limit+1];
      //----
      FastTrend=Sto1+Sto2+Sto3+Sto4+Sto5;
      FastBuffer[limit+1]=FastTrend;
      FastBuffer_[limit+1]=FastTrend;
      SlowBuffer[limit+1]=FastTrend/smoothing;
      SlowBuffer_[limit+1]=SlowBuffer[limit+1];
     }
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0; bar--)
     {
      Sto1 = Factor1 * Stoch1[bar];
      Sto2 = Factor2 * Stoch2[bar];
      Sto3 = Factor2 * Stoch3[bar];
      Sto4 = Factor4 * Stoch4[bar];
      Sto5 = Factor5 * Stoch5[bar];
      //----
      FastTrend = Sto1 + Sto2 + Sto3 + Sto4 + Sto5;
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
