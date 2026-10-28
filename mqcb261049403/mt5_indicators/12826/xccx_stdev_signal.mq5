//+---------------------------------------------------------------------+ 
//|                                               XCCX_StDev_Signal.mq5 | 
//|                                          Copyright © 2015, olegok83 | 
//|                              https://www.mql5.com/ru/users/olegok83 | 
//+---------------------------------------------------------------------+ 
//| Для работы индикатора следует положить файл SmoothAlgorithms.mqh    |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2015, olegok83"
//--- ссылка на сайт автора
#property link      "https://www.mql5.com/ru/users/olegok83"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color1  clrMagenta
//--- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//--- отображение бычей метки индикатора
#property indicator_label1  "XCCX_StDev Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован зеленый цвет
#property indicator_color2  clrLime
//--- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//--- отображение медвежьей метки индикатора
#property indicator_label2 "XCCX_StDev Buy"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                 // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//| объявление перечислений                      |
//+----------------------------------------------+
enum Applied_price //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//| объявление перечислений                      |
//+----------------------------------------------+
/*enum Smooth_Method - объявлено в файле SmoothAlgorithms.mqh
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
enum Applied_Mode //Тип константы
  {
   Mode_OnlyLevels = 1,     //Только уровни
   Mode_OnlyStDev,          //Только девиация
   Mode_LevelsStDev,        //Уровни плюс отклонение
   Mode_LevelsStDev_On,     //Уровни плюс отклонение по тренду
   Mode_LevelsStDev_Out     //Уровни плюс отклонение против тренда
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Applied_Mode Mode=Mode_LevelsStDev_On;  // Вариант алгоритма
input Smooth_Method DSmoothMethod=MODE_JJMA;  // Метод усреднения цены
input uint DPeriod=15;                        // Период средней
input int DPhase=15;                          // Параметр усреднения
//--- DPhase: для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- DPhase: для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MSmoothMethod=MODE_T3;    // Метод усреднения отклонения
input uint MPeriod=15;                        // Период среднего отклонения
input int MPhase=15;                          // Параметр среднего отклонения
//--- MPhase: для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- MPhase: для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price IPC=PRICE_TYPICAL;        // Ценовая константа
input double dK=2.0;                          // Коэффициент для квадратичного фильтра
input uint std_period=9;                      // Период квадратичного фильтра
input int UpLevel=+50;                        // Уровень перезакупа
input int DnLevel=-50;                        // Уровень перепроданности
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle,Ind_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   int min_rates_D=GetStartBars(DSmoothMethod,DPeriod,DPhase);
   int min_rates_M=GetStartBars(MSmoothMethod,MPeriod,MPhase);
   min_rates_total=min_rates_D+min_rates_M+1+int(std_period);
   int ATR_Period=15;
   min_rates_total=int(MathMax(ATR_Period,min_rates_total));
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(Symbol(),PERIOD_CURRENT,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора XCCX_StDev
   Ind_Handle=iCustom(Symbol(),PERIOD_CURRENT,"XCCX_StDev",DSmoothMethod,DPeriod,DPhase,MSmoothMethod,MPeriod,MPhase,IPC,dK,std_period,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XCCX_StDev");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,159);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="XCCX_StDev_Signal";
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
   if(BarsCalculated(Ind_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//--- объявления локальных переменных 
   int to_copy,limit,bar;
   double Ind[],Up[],Dn[],ATR[];
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы Ind[] и ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//---
   switch(Mode)
     {
      case  Mode_OnlyLevels://только уровни
        {
         if(CopyBuffer(Ind_Handle,0,0,to_copy,Ind)<=0) return(RESET);
         ArraySetAsSeries(Ind,true);
        }
      break;
      case  Mode_OnlyStDev://только отклонение
        {
         if(CopyBuffer(Ind_Handle,3,0,to_copy,Up)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,2,0,to_copy,Dn)<=0) return(RESET);
         ArraySetAsSeries(Up,true);
         ArraySetAsSeries(Dn,true);
        }
      break;
      case  Mode_LevelsStDev://уровни плюс отклонение
        {
         if(CopyBuffer(Ind_Handle,0,0,to_copy,Ind)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,3,0,to_copy,Up)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,2,0,to_copy,Dn)<=0) return(RESET);
         ArraySetAsSeries(Ind,true);
         ArraySetAsSeries(Up,true);
         ArraySetAsSeries(Dn,true);
        }
      break;
      case  Mode_LevelsStDev_On://уровни плюс отклонение по тренду
        {
         if(CopyBuffer(Ind_Handle,0,0,to_copy,Ind)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,3,0,to_copy,Up)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,2,0,to_copy,Dn)<=0) return(RESET);
         ArraySetAsSeries(Ind,true);
         ArraySetAsSeries(Up,true);
         ArraySetAsSeries(Dn,true);
        }
      break;
      case  Mode_LevelsStDev_Out://уровни плюс отклонение против тренда
        {
         if(CopyBuffer(Ind_Handle,0,0,to_copy,Ind)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,3,0,to_copy,Up)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,2,0,to_copy,Dn)<=0) return(RESET);
         ArraySetAsSeries(Ind,true);
         ArraySetAsSeries(Up,true);
         ArraySetAsSeries(Dn,true);
        }
      break;
     }
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      switch(Mode)
        {
         case  Mode_OnlyLevels://только уровни
           {
            if(Ind[bar]>UpLevel) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
            if(Ind[bar]<DnLevel) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
           }
         break;
         case  Mode_OnlyStDev://только отклонение
           {
            if(Up[bar]) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
            if(Dn[bar]) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
           }
         break;
         case  Mode_LevelsStDev://уровни плюс отклонение
           {
            if(Ind[bar]>UpLevel && Up[bar]) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
            if(Ind[bar]<DnLevel && Up[bar]) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
            if(Ind[bar]>UpLevel && Dn[bar]) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
            if(Ind[bar]<DnLevel && Dn[bar]) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
           }
         break;
         case  Mode_LevelsStDev_On://уровни плюс отклонение по тренду
           {
            if(Ind[bar]>UpLevel && Up[bar]) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
            if(Ind[bar]<DnLevel && Dn[bar]) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
           }
         break;
         case  Mode_LevelsStDev_Out://уровни плюс отклонение против тренда
           {
            if(Ind[bar]>UpLevel && Dn[bar]) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
            if(Ind[bar]<DnLevel && Up[bar]) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
           }
         break;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
