//+------------------------------------------------------------------+
//|                                                    QQECandle.mq5 |
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "QQECandle"
//--- номер версии индикатора
#property version   "1.00"
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//--- использовано всего одно графическое построение
#property indicator_plots   1
//--- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1   clrDeepPink,clrGray,clrBlueViolet
//--- отображение метки индикатора
#property indicator_label1  "QQECandle Open;QQECandle High;QQECandle Low;QQECandle Close"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//| объявление перечислений                      |
//+----------------------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+----------------------------------------------+
//| объявление перечислений                      |
//+----------------------------------------------+
enum mode
  {
   MODE_MAIN,  //расчет по основной линии
   MODE_SIGN,  //расчет по сигнальной линии
   MODE_DIFF   //расчет по разности линий
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input mode Mode=MODE_DIFF;                // Вариант алгоритма
input uint RSI_Period=123;
input uint SF=41;
input double DARFACTOR=4.236;
input Smooth_Method XMA_Method=MODE_SMA;  // Метод усреднения
input int XPhase=15; // Параметр сглаживания
//--- XPhase: для JJMA изменяется в пределах -100 ... +100, влияет на качество переходного процесса;
//--- XPhase: для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0;                        // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle[4];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   int Wilders_Period=int(RSI_Period*2-1);
   min_rates_total=int(RSI_Period+1);
   min_rates_total+=GetStartBars(XMA_Method,SF,XPhase)+1;
   min_rates_total+=GetStartBars(XMA_Method,Wilders_Period,XPhase);
   min_rates_total+=GetStartBars(XMA_Method,Wilders_Period,XPhase);
//--- получение хендлов индикатора iQQE
   Ind_Handle[0]=iCustom(NULL,0,"QQECloudX",RSI_Period,SF,DARFACTOR,XMA_Method,XPhase,PRICE_OPEN,0);
   if(Ind_Handle[0]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iQQE["+string(0)+"]!");
      return(INIT_FAILED);
     }
//---   
   Ind_Handle[1]=iCustom(NULL,0,"QQECloudX",RSI_Period,SF,DARFACTOR,XMA_Method,XPhase,PRICE_HIGH,0);
   if(Ind_Handle[1]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iQQE["+string(1)+"]!");
      return(INIT_FAILED);
     }
//---
   Ind_Handle[2]=iCustom(NULL,0,"QQECloudX",RSI_Period,SF,DARFACTOR,XMA_Method,XPhase,PRICE_LOW,0);
   if(Ind_Handle[2]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iQQE["+string(2)+"]!");
      return(INIT_FAILED);
     }
//---
   Ind_Handle[3]=iCustom(NULL,0,"QQECloudX",RSI_Period,SF,DARFACTOR,XMA_Method,XPhase,PRICE_CLOSE,0);
   if(Ind_Handle[3]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iQQE["+string(3)+"]!");
      return(INIT_FAILED);
     }
//--- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//--- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//--- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- имя для окон данных и метка для субъокон 
   string short_name="QQECandle";
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
   if(BarsCalculated(Ind_Handle[0])<rates_total
      || BarsCalculated(Ind_Handle[1])<rates_total
      || BarsCalculated(Ind_Handle[2])<rates_total
      || BarsCalculated(Ind_Handle[3])<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//--- объявления локальных переменных 
   int to_copy,limit,bar;
//--- расчеты необходимого количества копируемых данных и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
//---
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы
   switch(Mode)
     {
      case  MODE_MAIN:
         if(CopyBuffer(Ind_Handle[0],MAIN_LINE,0,to_copy,ExtOpenBuffer)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle[1],MAIN_LINE,0,to_copy,ExtHighBuffer)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle[2],MAIN_LINE,0,to_copy,ExtLowBuffer)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle[3],MAIN_LINE,0,to_copy,ExtCloseBuffer)<=0) return(RESET);
         break;
         //---
      case  MODE_SIGN:
         if(CopyBuffer(Ind_Handle[0],SIGNAL_LINE,0,to_copy,ExtOpenBuffer)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle[1],SIGNAL_LINE,0,to_copy,ExtHighBuffer)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle[2],SIGNAL_LINE,0,to_copy,ExtLowBuffer)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle[3],SIGNAL_LINE,0,to_copy,ExtCloseBuffer)<=0) return(RESET);
         break;
         //---
      case  MODE_DIFF:
        {
         double MOpen[],MHigh[],MLow[],MClose[],SOpen[],SHigh[],SLow[],SClose[];
         //--- индексация элементов в массивах, как в таймсериях  
         ArraySetAsSeries(MOpen,true);
         ArraySetAsSeries(MHigh,true);
         ArraySetAsSeries(MLow,true);
         ArraySetAsSeries(MClose,true);
         ArraySetAsSeries(SOpen,true);
         ArraySetAsSeries(SHigh,true);
         ArraySetAsSeries(SLow,true);
         ArraySetAsSeries(SClose,true);
         //--- индексация
         if(CopyBuffer(Ind_Handle[0],MAIN_LINE,0,to_copy,MOpen)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle[1],MAIN_LINE,0,to_copy,MHigh)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle[2],MAIN_LINE,0,to_copy,MLow)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle[3],MAIN_LINE,0,to_copy,MClose)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle[0],SIGNAL_LINE,0,to_copy,SOpen)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle[1],SIGNAL_LINE,0,to_copy,SHigh)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle[2],SIGNAL_LINE,0,to_copy,SLow)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle[3],SIGNAL_LINE,0,to_copy,SClose)<=0) return(RESET);
         //---
         for(bar=limit; bar>=0 && !IsStopped(); bar--)
           {
            ExtOpenBuffer[bar]=MOpen[bar]-SOpen[bar];
            ExtCloseBuffer[bar]=MClose[bar]-SClose[bar];
            ExtLowBuffer[bar]=MLow[bar]-SLow[bar];
            ExtHighBuffer[bar]=MHigh[bar]-SHigh[bar];
           }
        }
     }
//--- основной цикл исправления и окрашивания свечей
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- исправление порубленных свеч
      double max=MathMax(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      if(ExtHighBuffer[bar]<max) ExtHighBuffer[bar]=max;
      double min=MathMin(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      if(ExtLowBuffer[bar]>min) ExtLowBuffer[bar]=min;
      //---
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=2.0;
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else ExtColorBuffer[bar]=1.0;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
