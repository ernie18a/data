//+---------------------------------------------------------------------+
//|                                          WeightOscillator_Alert.mq5 | 
//|                                  Copyright © 2016, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description  "Осциллятор, представляющий взвешенную сглаженную сумму четырёх индикаторов - RSI, MFI, WPR и DeMarker."
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 3
#property indicator_buffers 3 
//---- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------------+
//|  Параметры отрисовки индикатора                    |
//+----------------------------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---- в качестве цветов индикатора использованы
#property indicator_color1  clrDodgerBlue,clrPaleTurquoise,clrGray,clrGold,clrOrange
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1  "WeightOscillator_Alert"
//+----------------------------------------------------+
//| Параметры отображения горизонтальных уровней       |
//+----------------------------------------------------+
#property indicator_level1  0
#property indicator_levelcolor clrRed
#property indicator_levelstyle STYLE_SOLID
//+----------------------------------------------------+
//|  объявление констант                               |
//+----------------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------------+
//|  Описание класса CXMA                              |
//+----------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+----------------------------------------------------+
//|  объявление перечислений                           |
//+----------------------------------------------------+
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
//+----------------------------------------------------+
//| перечисление для вариантов транслируемых сигналов  |
//+----------------------------------------------------+
enum ENUM_SIGNAL_MODE
  {
   MODE_SIGNAL,  //Сигналы пробоя
   MODE_TREND    //Сигналы пробоя и тренда
  };
//+----------------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                      |
//+----------------------------------------------------+
//---- Параметры RSI
input double RSIWeight=1.0;
input uint   RSIPeriod=14;
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE;
//---- Параметры MFI
input double MFIWeight=1.0;
input uint   MFIPeriod=14;
input ENUM_APPLIED_VOLUME MFIVolumeType=VOLUME_TICK;
//---- Параметры WPR
input double WPRWeight=1.0;
input uint   WPRPeriod=14;
//---- Параметры DeMarker
input double DeMarkerWeight=1.0;
input uint   DeMarkerPeriod=14;
//---- Включение сглаживания волны
input Smooth_Method bMA_Method=MODE_JJMA; //метод усреднения
input uint bLength=5; //глубина сглаживания                    
input int bPhase=100; //параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint HighLevel=70;         // уровень перезакупа
input uint LowLevel=30;          // уровень перепроданности
//---- Входные переменные для алертов
input ENUM_SIGNAL_MODE SignMode=MODE_SIGNAL; //Вариант подачи сигнала 
input uint NumberofBar=1;                    //Номер бара для подачи сигнала
input bool SoundON=true;                     //Разрешение алерта
input uint NumberofAlerts=2;                 //Количество алертов
input bool EMailON=false;                    //Разрешение почтовой отправки сигнала
input bool PushON=false;                     //Разрешение отправки сигнала на мобильный
//+----------------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[],DnBuffer[],ColorBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_total_1;
//---- Объявление переменной для суммарного весового коэффициента
double SumWeight;
//---- Объявление целых переменных для хендлов индикаторов
int RSI_Handle,MFI_Handle,WPR_Handle,DeMarker_Handle;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- Проверка значения уровня перекупленности корректность
   if(HighLevel<50)
     {
      Print(" Значение уровня перекупленности должно быть не меньше 50");
      return(INIT_FAILED);
     }
//---- Проверка значения уровня перепроданности на корректность
   if(LowLevel>50)
     {
      Print(" Значение уровня перепроданности должно быть не больше 50");
      return(INIT_FAILED);
     }

//---- Инициализация переменных начала отсчёта данных
   min_rates_total_1=int(MathMax(RSIPeriod,MathMax(MFIPeriod,MathMax(WPRPeriod,DeMarkerPeriod))))+1;
   min_rates_total=min_rates_total_1+GetStartBars(bMA_Method,bLength,bPhase);
   SumWeight=RSIWeight+MFIWeight+WPRWeight+DeMarkerWeight;

//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("bLength",bLength);
   XMA1.XMAPhaseCheck("bPhase",bPhase,bMA_Method);

//---- получение хендла индикатора iRSI
   RSI_Handle=iRSI(NULL,0,RSIPeriod,RSIPrice);
   if(RSI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iMFI
   MFI_Handle=iMFI(NULL,0,MFIPeriod,MFIVolumeType);
   if(MFI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMFI");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iWPR
   WPR_Handle=iWPR(NULL,0,WPRPeriod);
   if(WPR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iWPR");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iDeMarker
   DeMarker_Handle=iDeMarker(NULL,0,DeMarkerPeriod);
   if(DeMarker_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iDeMarker");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   ArraySetAsSeries(UpBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(bMA_Method);
   StringConcatenate(shortname,"WeightOscillator_Alert(",bLength,", ",Smooth1,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы 
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrLimeGreen);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrRed);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- завершение инициализации
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
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(RSI_Handle)<rates_total
      || BarsCalculated(MFI_Handle)<rates_total
      || BarsCalculated(WPR_Handle)<rates_total
      || BarsCalculated(DeMarker_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar,maxbar;
   double RSI[],MFI[],WPR[],DeMarker[],WeightOscillator;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI)<=0) return(RESET);
   if(CopyBuffer(MFI_Handle,0,0,to_copy,MFI)<=0) return(RESET);
   if(CopyBuffer(WPR_Handle,0,0,to_copy,WPR)<=0) return(RESET);
   if(CopyBuffer(DeMarker_Handle,0,0,to_copy,DeMarker)<=0) return(RESET);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(RSI,true);
   ArraySetAsSeries(MFI,true);
   ArraySetAsSeries(WPR,true);
   ArraySetAsSeries(DeMarker,true);
//----   
   maxbar=rates_total-min_rates_total_1-1;

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      WeightOscillator=(RSIWeight*RSI[bar]+MFIWeight*MFI[bar]+WPRWeight*(WPR[bar]+100)+DeMarkerWeight*100*DeMarker[bar])/SumWeight;
      UpBuffer[bar]=XMA1.XMASeries(maxbar,prev_calculated,rates_total,bMA_Method,bPhase,bLength,WeightOscillator,bar,true);
      DnBuffer[bar]=50.0;
      int clr=2.0;
      if(UpBuffer[bar]>HighLevel) clr=0.0;
      else if(UpBuffer[bar]>50) clr=1.0;
      else if(UpBuffer[bar]<LowLevel) clr=4.0;
      else if(UpBuffer[bar]<50) clr=3.0;
      ColorBuffer[bar]=clr;
     }
//---     
   BuySignal("WeightOscillator_Alert",ColorBuffer,0,rates_total,prev_calculated,close,spread);
   SellSignal("WeightOscillator_Alert",ColorBuffer,4,rates_total,prev_calculated,close,spread);
//---      
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Buy signal function                                              |
//+------------------------------------------------------------------+
void BuySignal(string SignalSirname,// текст имени индикатора для почтовых и пуш-сигналов
               double &ColorArray[],// цветовой индексный буфер
               int ColorIndex,// индекс цвета в цветовом индескном буфере для подачи сигнала 
               const int Rates_total,     // текущее количество баров
               const int Prev_calculated, // количество баров на предыдущем тике
               const double &Close[],     // цена закрытия
               const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool BuySignal=false;
   bool SeriesTest=ArrayGetAsSeries(ColorArray);
   int index,index1;
   if(SeriesTest)
     {
      index=int(NumberofBar);
      index1=index+1;
     }
   else
     {
      index=Rates_total-int(NumberofBar)-1;
      index1=index-1;
     }
   if(SignMode==MODE_SIGNAL)
     {
      if(ColorArray[index1]!=ColorIndex && ColorArray[index]==ColorIndex) BuySignal=true;
     }
   else
     {
      if(ColorArray[index]==ColorIndex) BuySignal=true;
     }
   if(BuySignal && counter<=NumberofAlerts)
     {
      counter++;
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);
      string text=TimeToString(TimeCurrent(),TIME_DATE)+" "+string(tm.hour)+":"+string(tm.min);
      SeriesTest=ArrayGetAsSeries(Close);
      if(SeriesTest) index=int(NumberofBar);
      else index=Rates_total-int(NumberofBar)-1;
      double Ask=Close[index];
      double Bid=Close[index];
      SeriesTest=ArrayGetAsSeries(Spread);
      if(SeriesTest) index=int(NumberofBar);
      else index=Rates_total-int(NumberofBar)-1;
      Bid+=_Point*Spread[index];
      string sAsk=DoubleToString(Ask,_Digits);
      string sBid=DoubleToString(Bid,_Digits);
      string sPeriod=GetStringTimeframe(ChartPeriod());
      if(SignMode==MODE_SIGNAL || (SignMode==MODE_TREND && ColorArray[index1]!=ColorIndex))
        {
         if(SoundON) Alert("BUY signal \n Ask=",Ask,"\n Bid=",Bid,"\n currtime=",text,"\n Symbol=",Symbol()," Period=",sPeriod);
         if(EMailON) SendMail(SignalSirname+": BUY signal alert","BUY signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
         if(PushON) SendNotification(SignalSirname+": BUY signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
        }
      else
        {
         if(SoundON) Alert("Up Trend signal \n Ask=",Ask,"\n Bid=",Bid,"\n currtime=",text,"\n Symbol=",Symbol()," Period=",sPeriod);
         if(EMailON) SendMail(SignalSirname+": Up Trend signal alert","BUY signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
         if(PushON) SendNotification(SignalSirname+": Up Trend signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
        }
     }

//---
  }
//+------------------------------------------------------------------+
//| Sell signal function                                             |
//+------------------------------------------------------------------+
void SellSignal(string SignalSirname,// текст имени индикатора для почтовых и пуш-сигналов
                double &ColorArray[],       // цветовой индексный буфер
                int ColorIndex,             // индекс цвета в цветовом индескном буфере для подачи сигнала 
                const int Rates_total,     // текущее количество баров
                const int Prev_calculated, // количество баров на предыдущем тике
                const double &Close[],     // цена закрытия
                const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool SellSignal=false;
   bool SeriesTest=ArrayGetAsSeries(ColorArray);
   int index,index1;
   if(SeriesTest)
     {
      index=int(NumberofBar);
      index1=index+1;
     }
   else
     {
      index=Rates_total-int(NumberofBar)-1;
      index1=index-1;
     }

   if(SignMode==MODE_SIGNAL)
     {
      if(ColorArray[index1]!=ColorIndex && ColorArray[index]==ColorIndex) SellSignal=true;
     }
   else
     {
      if(ColorArray[index]==ColorIndex) SellSignal=true;
     }
   if(SellSignal && counter<=NumberofAlerts)
     {
      counter++;
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);
      string text=TimeToString(TimeCurrent(),TIME_DATE)+" "+string(tm.hour)+":"+string(tm.min);
      SeriesTest=ArrayGetAsSeries(Close);
      if(SeriesTest) index=int(NumberofBar);
      else index=Rates_total-int(NumberofBar)-1;
      double Ask=Close[index];
      double Bid=Close[index];
      SeriesTest=ArrayGetAsSeries(Spread);
      if(SeriesTest) index=int(NumberofBar);
      else index=Rates_total-int(NumberofBar)-1;
      Bid+=_Point*Spread[index];
      string sAsk=DoubleToString(Ask,_Digits);
      string sBid=DoubleToString(Bid,_Digits);
      string sPeriod=GetStringTimeframe(ChartPeriod());
      if(SignMode==MODE_SIGNAL || (SignMode==MODE_TREND && ColorArray[index1]!=ColorIndex))
        {
         if(SoundON) Alert("SELL signal \n Ask=",Ask,"\n Bid=",Bid,"\n currtime=",text,"\n Symbol=",Symbol()," Period=",sPeriod);
         if(EMailON) SendMail(SignalSirname+": SELL signal alert","SELL signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
         if(PushON) SendNotification(SignalSirname+": SELL signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
        }
      else
        {
         if(SoundON) Alert("Down trend signal \n Ask=",Ask,"\n Bid=",Bid,"\n currtime=",text,"\n Symbol=",Symbol()," Period=",sPeriod);
         if(EMailON) SendMail(SignalSirname+": Down trend signal alert","SELL signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
         if(PushON) SendNotification(SignalSirname+": Down trend signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
        }
     }
//---
  }
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+
//|  RightPrice creation                                             |
//+------------------------------------------------------------------+
void CreateRightPrice(long chart_id,// chart ID
                      string   name,              // object name
                      int      nwin,              // window index
                      datetime time,              // price level time
                      double   price,             // price level
                      color    Color              // Text color
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,2);
//----
  }
//+------------------------------------------------------------------+
//|  RightPrice reinstallation                                       |
//+------------------------------------------------------------------+
void SetRightPrice(long chart_id,// chart ID
                   string   name,              // object name
                   int      nwin,              // window index
                   datetime time,              // price level time
                   double   price,             // price level
                   color    Color              // Text color
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color);
   else ObjectMove(chart_id,name,0,time,price);
//----
  }
//+------------------------------------------------------------------+
