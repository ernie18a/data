//+---------------------------------------------------------------------+
//|                                                      BinaryWave.mq5 | 
//|                                             Copyright © 2009, LeMan |
//|                                                    b-market@mail.ru |
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2009, LeMan"
#property link      "b-market@mail.ru"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------------------+
//| Параметры отрисовки индикатора                |
//+-----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован DodgerBlue цвет
#property indicator_color1 clrDodgerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "BinaryWave"
//+-----------------------------------------------+
//| Параметры отображения горизонтальных уровней  |
//+-----------------------------------------------+
#property indicator_level1  0
#property indicator_levelcolor clrRed
#property indicator_levelstyle STYLE_SOLID
//+-----------------------------------------------+
//| Объявление констант                           |
//+-----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------------------+
//| Описание класса CXMA                          |
//+-----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+-----------------------------------------------+
//| Объявление перечислений                       |
//+-----------------------------------------------+
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
//+-----------------------------------------------+
//| Входные параметры индикатора                  |
//+-----------------------------------------------+
//--- Вес индикаторов. Если ноль, индикатор не участвует в расчете волны
input double WeightMA    = 1.0;
input double WeightMACD  = 1.0;
input double WeightOsMA  = 1.0;
input double WeightCCI   = 1.0;
input double WeightMOM   = 1.0;
input double WeightRSI   = 1.0;
input double WeightADX   = 1.0;
//---- Параметры скользящего среднего
input int   MAPeriod=13;
input  ENUM_MA_METHOD   MAType=MODE_EMA;
input ENUM_APPLIED_PRICE   MAPrice=PRICE_CLOSE;
//---- Параметры MACD
input int   FastMACD     = 12;
input int   SlowMACD     = 26;
input int   SignalMACD   = 9;
input ENUM_APPLIED_PRICE   PriceMACD=PRICE_CLOSE;
//---- Параметры OsMA
input int   FastPeriod   = 12;
input int   SlowPeriod   = 26;
input int   SignalPeriod = 9;
input ENUM_APPLIED_PRICE   OsMAPrice=PRICE_CLOSE;
//---- Параметры CCI
input int   CCIPeriod=14;
input ENUM_APPLIED_PRICE   CCIPrice=PRICE_MEDIAN;
//---- Параметры Момента
input int   MOMPeriod=14;
input ENUM_APPLIED_PRICE   MOMPrice=PRICE_CLOSE;
//---- Параметры RSI
input int   RSIPeriod=14;
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE;
//---- Параметры ADX
input int   ADXPeriod=14;
//---- Включение сглаживания волны
input Smooth_Method bMA_Method=MODE_JJMA; // Метод усреднения
input int bLength=5;  // Глубина сглаживания                    
input int bPhase=100; // Параметр сглаживания
                      // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
                      // для VIDIA это период CMO, для AMA это период медленной скользящей
//+-----------------------------------------------+
//---- объявление динамического массива, который будет в 
//---- дальнейшем использован в качестве индикаторного буфера
double IndBuffer[];
//---- объявление целочисленных переменных начала отсчёта данных
int min_rates_total,min_rates_total_1;
//---- объявление целочисленных переменных для хендлов индикаторов
int MA_Handle,MACD_Handle,OsMA_Handle,CCI_Handle,MOM_Handle,RSI_Handle,ADX_Handle;
//+------------------------------------------------------------------+
//| Определяем положение цены закрытия относительно среднего         |
//+------------------------------------------------------------------+    
double MAClose(int bar,double &MaArray[],const double &Close[])
  {
   if(WeightMA>0)
     {
      if(Close[bar]-MaArray[bar]>0) return(+WeightMA);
      if(Close[bar]-MaArray[bar]<0) return(-WeightMA);
      //if(Close[bar]-MaArray[bar]==0) return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Определяем наклон MACD                                           |
//+------------------------------------------------------------------+    
double MACD(int bar,double &MacdArray[])
  {
   if(WeightMACD>0)
     {
      if(MacdArray[bar]-MacdArray[bar+1]>0) return(+WeightMACD);
      if(MacdArray[bar]-MacdArray[bar+1]<0) return(-WeightMACD);
      //if(MacdArray[bar]-MacdArray[bar+1]==0) return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Определяем положение OsMa относительно нуля                      |
//+------------------------------------------------------------------+    
double OsMA(int bar,double &OsMAArray[])
  {
   if(WeightOsMA>0)
     {
      if(OsMAArray[bar]>0) return(+WeightOsMA);
      if(OsMAArray[bar]<0) return(-WeightOsMA);
      //if(OsMAArray[bar]==0) return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Определяем положение CCI относительно нуля                       |
//+------------------------------------------------------------------+    
double CCI(int bar,double &CCIArray[])
  {
   if(WeightCCI>0)
     {
      if(CCIArray[bar]>0) return(+WeightCCI);
      if(CCIArray[bar]<0) return(-WeightCCI);
      //if(CCIArray[bar]==0) return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Определяем положение Momentum относительно 100                   |
//+------------------------------------------------------------------+    
double MOM(int bar,double &MOMArray[])
  {
   if(WeightMOM>0)
     {
      if(MOMArray[bar]>100) return(+WeightMOM);
      if(MOMArray[bar]<100) return(-WeightMOM);
      //if(MOMArray[bar]==100) return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Определяем положение RSI относительно 50                         |
//+------------------------------------------------------------------+    
double RSI(int bar,double &RSIArray[])
  {
   if(WeightRSI>0)
     {
      if(RSIArray[bar]>50) return(+WeightRSI);
      if(RSIArray[bar]<50) return(-WeightRSI);
      //if(RSIArray[bar]==100) return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Определяем положение DMI                                         |
//+------------------------------------------------------------------+    
double ADX(int bar,double &DMIPArray[],double &DMIMArray[])
  {
   if(WeightADX>0)
     {
      if(DMIPArray[bar]>DMIMArray[bar]) return(+WeightADX);
      if(DMIPArray[bar]<DMIMArray[bar]) return(-WeightADX);
      //if(DMIPArray[bar]==DMIMArray[bar]) return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+   
//| BinaryWave indicator initialization function                     | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- инициализация переменных начала отсчёта данных
   min_rates_total_1=MathMax(MAPeriod,MathMax(SlowPeriod,MathMax(CCIPeriod,MathMax(SlowMACD,MOMPeriod))))+1;
   min_rates_total=min_rates_total_1+XMA1.GetStartBars(bMA_Method,bLength,bPhase);

//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("bLength", bLength);
   XMA1.XMAPhaseCheck("bPhase", bPhase, bMA_Method);

//---- получение хендла индикатора iMA
   MA_Handle=iMA(NULL,0,MAPeriod,0,MAType,MAPrice);
   if(MA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iMACD
   MACD_Handle=iMACD(NULL,0,FastMACD,SlowMACD,SignalMACD,PriceMACD);
   if(MACD_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMACD");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iOsMA
   OsMA_Handle=iOsMA(NULL,0,FastPeriod,SlowPeriod,SignalPeriod,OsMAPrice);
   if(OsMA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iOsMA");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iCCI
   CCI_Handle=iCCI(NULL,0,CCIPeriod,CCIPrice);
   if(CCI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iCCI");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iMomentum
   MOM_Handle=iMomentum(NULL,0,MOMPeriod,MOMPrice);
   if(MOM_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMomentum");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iRSI
   RSI_Handle=iRSI(NULL,0,RSIPeriod,RSIPrice);
   if(RSI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iADX
   ADX_Handle=iADX(NULL,0,ADXPeriod);
   if(ADX_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iADX");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(bMA_Method);
   StringConcatenate(shortname,"BinaryWave(",bLength,", ",Smooth1,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| BinaryWave iteration function                                    | 
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
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(MA_Handle)<rates_total
      || BarsCalculated(MACD_Handle)<rates_total
      || BarsCalculated(OsMA_Handle)<rates_total
      || BarsCalculated(CCI_Handle)<rates_total
      || BarsCalculated(MOM_Handle)<rates_total
      || BarsCalculated(RSI_Handle)<rates_total
      || BarsCalculated(ADX_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//---- объявления локальных переменных 
   int to_copy,limit,bar,maxbar;
   double tmp,MA_[],MACD_[],OsMA_[],CCI_[],MOM_[],RSI_[],DMIP_[],DMIM_[];
//---- расчёты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      to_copy=rates_total; // расчётное количество всех баров
      limit=rates_total-2; // стартовый номер для расчёта всех баров
     }
   else
     {
      to_copy=rates_total-prev_calculated+1; // расчётное количество только новых баров
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA_)<=0) return(RESET);
   if(CopyBuffer(MACD_Handle,0,0,to_copy+1,MACD_)<=0) return(RESET);
   if(CopyBuffer(OsMA_Handle,0,0,to_copy,OsMA_)<=0) return(RESET);
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI_)<=0) return(RESET);
   if(CopyBuffer(MOM_Handle,0,0,to_copy,MOM_)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI_)<=0) return(RESET);
   if(CopyBuffer(ADX_Handle,1,0,to_copy,DMIP_)<=0) return(RESET);
   if(CopyBuffer(ADX_Handle,2,0,to_copy,DMIM_)<=0) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(MA_,true);
   ArraySetAsSeries(MACD_,true);
   ArraySetAsSeries(OsMA_,true);
   ArraySetAsSeries(CCI_,true);
   ArraySetAsSeries(MOM_,true);
   ArraySetAsSeries(RSI_,true);
   ArraySetAsSeries(DMIP_,true);
   ArraySetAsSeries(DMIM_,true);
   ArraySetAsSeries(close,true);
//----   
   maxbar=rates_total-min_rates_total_1-1;
//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      tmp=MAClose(bar,MA_,close)+MACD(bar,MACD_)+OsMA(bar,OsMA_)+CCI(bar,CCI_)+MOM(bar,MOM_)+RSI(bar,RSI_)+ADX(bar,DMIP_,DMIM_);
      IndBuffer[bar]=XMA1.XMASeries(maxbar,prev_calculated,rates_total,bMA_Method,bPhase,bLength,tmp,bar,true);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
