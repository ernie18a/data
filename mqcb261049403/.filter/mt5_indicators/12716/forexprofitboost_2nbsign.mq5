//+------------------------------------------------------------------+ 
//|                                     ForexProfitBoost_2nbSign.mq5 | 
//|                               Copyright © 2015, TradeLikeaPro.ru | 
//|                                         http://tradelikeapro.ru/ | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2015, TradeLikeaPro.ru"
#property link "http://tradelikeapro.ru/"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован Gold цвет
#property indicator_color1  clrGold
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "ForexProfitBoost_2nb Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован SpringGreen цвет
#property indicator_color2  clrSpringGreen
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2 "ForexProfitBoost_2nb Buy"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0    // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
//--- параметры скользящего среднего 1
input uint   MAPeriod1=7;
input  ENUM_MA_METHOD   MAType1=MODE_EMA;
input ENUM_APPLIED_PRICE   MAPrice1=PRICE_CLOSE;
//--- параметры скользящего среднего 2
input uint   MAPeriod2=21;
input  ENUM_MA_METHOD   MAType2=MODE_SMA;
input ENUM_APPLIED_PRICE   MAPrice2=PRICE_CLOSE;
input int Shift=0;                              // Сдвиг индикатора по горизонтали в барах 
//+-----------------------------------+
//--- объявление целочисленных переменных начала отсчета данных
int  min_rates_total;
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int MA1_Handle,MA2_Handle,BB_Handle,ATR_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   int ATR_Period=10;
   min_rates_total=int(MathMax(MAPeriod1,MAPeriod2))+1;
   min_rates_total=int(MathMax(min_rates_total,ATR_Period));
//--- получение хендла индикатора iMA 1
   MA1_Handle=iMA(NULL,0,MAPeriod1,0,MAType1,MAPrice1);
   if(MA1_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA 1");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора iMA 2
   MA2_Handle=iMA(NULL,0,MAPeriod2,0,MAType2,MAPrice2);
   if(MA2_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA 2");
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
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,172);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,172);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//--- инициализации переменной для короткого имени индикатора
   string shortname="ForexProfitBoost_2nbSign";
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
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(MA1_Handle)<rates_total
      || BarsCalculated(MA2_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//--- объявление переменных с плавающей точкой  
   double MA1[],MA2[],ATR[1];
//--- объявление целочисленных переменных
   int limit,to_copy;
//--- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=rates_total-min_rates_total-1;  // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated;  // стартовый номер для расчета только новых баров
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(MA1,true);
   ArraySetAsSeries(MA2,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
//---
   to_copy=limit+2;
//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(MA1_Handle,0,0,to_copy,MA1)<=0) return(RESET);
   if(CopyBuffer(MA2_Handle,0,0,to_copy,MA2)<=0) return(RESET);
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      if(MA1[bar]>MA2[bar])
        {
         if(MA1[bar+1]<=MA2[bar+1])
           {
            //--- копируем вновь появившиеся данные в массив
            if(CopyBuffer(ATR_Handle,0,bar,1,ATR)<=0) return(RESET);
            BuyBuffer[bar]=Low[bar]-ATR[0]*3/8;
           }
        }
      else
        {
         if(MA1[bar+1]>=MA2[bar+1])
           {
            //--- копируем вновь появившиеся данные в массив
            if(CopyBuffer(ATR_Handle,0,bar,1,ATR)<=0) return(RESET);
            SellBuffer[bar]=High[bar]+ATR[0]*3/8;
           }
        }
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
