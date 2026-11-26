//+------------------------------------------------------------------+
//|                                              ChandelExitSign.mq5 |
//|                                                       MQLService |
//|                                           scripts@mqlservice.com |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "MQLService"
#property link      "scripts@mqlservice.com"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован Red цвет
#property indicator_color1  clrRed
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "BullsBears Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован Lime цвет
#property indicator_color2  clrLime
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2 "BullsBears Buy"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint RangePeriod=15;
input uint Shift=1;
input uint ATRPeriod=14;
input uint MultipleATR=4;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//---- Объявление целых переменных для хендлов индикаторов
int ATR1_Handle,ATR2_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   int ATR2Period=12;
   min_rates_total=int(MathMax(MathMax(ATRPeriod,RangePeriod+Shift)+1,ATR2Period));

//---- получение хендла индикатора ATR1
   ATR1_Handle=iATR(NULL,0,ATRPeriod);
   if(ATR1_Handle==INVALID_HANDLE)
     {
      Print("Не удалось получить хендл индикатора ATR1");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора ATR2
   ATR2_Handle=iATR(NULL,0,ATR2Period);
   if(ATR2_Handle==INVALID_HANDLE)
     {
      Print("Не удалось получить хендл индикатора ATR2");
      return(INIT_FAILED);
     }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,163);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,163);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ChandelExit(",RangePeriod,", ",ATRPeriod,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(ATR1_Handle)<rates_total
      || BarsCalculated(ATR2_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   static int direction;
   int to_copy,limit,bar;
   double ATR1[],ATR2[],HH0,LL0,Up=0.0,Dn=0.0;
   static double Up1,Dn1;

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчёта всех баров
      direction=0;
      Up=Up1=0.0;
      Dn=Dn1=0.0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

//---- расчёт необходимого количества копируемых данных
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ATR1_Handle,0,0,to_copy,ATR1)<=0) return(RESET);
   if(CopyBuffer(ATR2_Handle,0,0,to_copy,ATR2)<=0) return(RESET);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR1,true);
   ArraySetAsSeries(ATR2,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ATR1[bar]*=MultipleATR;
      HH0=high[ArrayMaximum(high,bar+Shift,RangePeriod)]-ATR1[bar];
      LL0=low[ArrayMinimum(low,bar+Shift,RangePeriod)]+ATR1[bar];

      if(direction>=0)
        {
         if(close[bar]<HH0)
           {
            if(bar) direction=-1;
            Up=LL0;
            Dn=HH0;
           }
         else
           {
            Up=HH0;
            Dn=LL0;
           }
        }
      else
      if(direction<=0)
        {
         if(close[bar]>LL0)
           {
            if(bar) direction=+1;
            Dn=LL0;
            Up=HH0;
           }
         else
           {
            Up=LL0;
            Dn=HH0;
           }
        }

      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      if(Dn1<=Up1 && Dn>Up) BuyBuffer[bar]=low[bar]-ATR1[bar]*3/8;
      if(Dn1>=Up1 && Dn<Up) SellBuffer[bar]=high[bar]+ATR1[bar]*3/8;

      if(bar)
        {
         Up1=Up;
         Dn1=Dn;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
