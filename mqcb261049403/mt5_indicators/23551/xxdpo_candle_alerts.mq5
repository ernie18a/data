//+---------------------------------------------------------------------+
//|                                             XXDPO_Candle_Alerts.mq5 | 
//|                                  Copyright © 2018, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
//---- в качестве цветов индикатора использованы
#property indicator_color1   clrMagenta,clrBrown,clrGray,clrBlue,clrDodgerBlue
//---- отображение метки индикатора
#property indicator_label1  "XXDPO Open;XXDPO High;XXDPO Low;XXDPO Close"
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1[4],XMA2[4];
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
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_T3;                // метод усреднения DPO
input int Length1=21;                                  // глубина  усреднения DPO                  
input int Phase1=15;                                   // параметр усреднения DPO,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MA_Method2=MODE_JJMA;              // метод сглаживания индикатора
input int Length2=13;                                  // глубина сглаживания индикатора
input int Phase2=100;                                  // параметр сглаживания индикатора
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0;                                     // сдвигиндикатора по горизонтали в барах
input uint Gap=10;                                     // размер неучитываемого гэпа в пунктах
input double HighLevel=+0.6;                      // уровень перекупленности
input double LowLevel=-0.6;                       // уровень перепроданности
input uint NumberofBar=1;          // Номер бара для подачи сигнала
input bool SoundON=true;           // Разрешение алерта
input uint NumberofAlerts=2;       // Количество алертов
input bool EMailON=false;          // Разрешение почтовой отправки сигнала
input bool PushON=false;           // Разрешение отправки сигнала на мобильный
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int StartBars,StartBars1,StartBars2;
//+------------------------------------------------------------------+   
//| XXDPO_Candle indicator initialization function                   | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   StartBars1=GetStartBars(MA_Method1, Length1, Phase1);
   StartBars2=GetStartBars(MA_Method2, Length2, Phase2);
   StartBars=StartBars1+StartBars2;
//---- установка алертов на недопустимые значения внешних переменных
   XMA1[0].XMALengthCheck("Length1", Length1);
   XMA2[0].XMALengthCheck("Length2", Length2);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1[0].XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2[0].XMAPhaseCheck("Phase2", Phase2, MA_Method2);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора на StartBars
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1[0].GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1[0].GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"XXDPO_Candle_Alerts(",Length1,", ",Length2,", ",Smooth1,", ",Smooth2,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,0.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrLimeGreen);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrMagenta);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_SOLID);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| XXDPO_Candle iteration function                                  | 
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
   if(rates_total<StartBars) return(0);
//---- Объявление переменных с плавающей точкой  
   double XO,XH,XL,XC,XXO,XXH,XXL,XXC,Max,Min;
   double xodpo,xhdpo,xldpo,xcdpo;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;
//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=0; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      XO=XMA1[0].XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,open[bar],bar,false);
      xodpo=open[bar]-XO;
      XXO=XMA2[0].XMASeries(StartBars1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,xodpo,bar,false);
      //----  
      XH=XMA1[1].XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,high[bar],bar,false);
      xhdpo=high[bar]-XH;
      XXH=XMA2[1].XMASeries(StartBars1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,xhdpo,bar,false);
      //----
      XL=XMA1[2].XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,low[bar],bar,false);
      xldpo=low[bar]-XL;
      XXL=XMA2[2].XMASeries(StartBars1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,xldpo,bar,false);
      //----
      XC=XMA1[3].XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,close[bar],bar,false);
      xcdpo=close[bar]-XC;
      XXC=XMA2[3].XMASeries(StartBars1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,xcdpo,bar,false);
      //---- исправляем значения полученных свечек
      Max=MathMax(XXO,XXC);
      Max=MathMax(Max,XXL);
      Max=MathMax(Max,XXH);
      Min=MathMin(XXO,XXC);
      Min=MathMin(Min,XXL);
      Min=MathMin(Min,XXH);
      ExtOpenBuffer[bar]=XXO;
      ExtHighBuffer[bar]=Max;
      ExtLowBuffer[bar]=Min;
      ExtCloseBuffer[bar]=XXC;
      //---- удаляем несуществующие гепы
      if(MathAbs(open[bar]-close[bar])<=Gap) ExtOpenBuffer[bar]=ExtCloseBuffer[MathMax(bar-1,0)];
      //---- красим индикатор
      int clr=2;
      double trend=ExtCloseBuffer[bar]-ExtOpenBuffer[bar];

      if(ExtCloseBuffer[bar]>HighLevel  || ExtCloseBuffer[bar]<LowLevel)
        {
         if(trend>0) clr=4.0;
         else if(trend<0) clr=0.0;
        }       
      else
        {
         if(trend>0) clr=3.0;
         else if(trend<0) clr=1.0;
        }
      ExtColorBuffer[bar]=clr;
     }
//---     
   BuySignal("XXDPO_Candle_Alerts",rates_total,prev_calculated,close,spread);
   SellSignal("XXDPO_Candle_Alerts",rates_total,prev_calculated,close,spread);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Buy signal function                                              |
//+------------------------------------------------------------------+
void BuySignal(string SignalSirname,      // текст имени индикатора для почтовых и пуш-сигналов
               const int Rates_total,     // текущее количество баров
               const int Prev_calculated, // количество баров на предыдущем тике
               const double &Close[],     // цена закрытия
               const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   string SignalText="";
   bool BuySignal=false;
   int index=int(Rates_total-1-NumberofBar);
   int index1=int(Rates_total-1-NumberofBar)-1;
   //--- 
   if(ExtCloseBuffer[index1]<=0 && ExtCloseBuffer[index]>0)  
     {
      BuySignal=true;
      SignalText=SignalText+"Пробой нуля! ";
     } 
    //--- 
    if(ExtColorBuffer[index1]<3 && ExtColorBuffer[index]>2)
     {
      BuySignal=true;
      SignalText=SignalText+"Изменение направления движения свечи! ";
     } 
    //--- 
    if(ExtCloseBuffer[index1]<=HighLevel && ExtCloseBuffer[index]>HighLevel)
     {
      BuySignal=true;
      SignalText=SignalText+"Пробой уровня перекупленности! ";
     }  
    //--- 
    if(ExtCloseBuffer[index1]<LowLevel && ExtCloseBuffer[index]>=LowLevel)
     {
      BuySignal=true;
      SignalText=SignalText+"Выход из зоны перепроданности! ";
     }
        
   //---              
   if(BuySignal && counter<=NumberofAlerts)
     {
      counter++;
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);
      string text=TimeToString(TimeCurrent(),TIME_DATE)+" "+string(tm.hour)+":"+string(tm.min);
      double Ask=Close[index];
      double Bid=Close[index];
      Bid+=Spread[index]*_Point;
      string sAsk=DoubleToString(Ask,_Digits);
      string sBid=DoubleToString(Bid,_Digits);
      string sPeriod=GetStringTimeframe(ChartPeriod());
      if(SoundON) Alert("BUY signal "+SignalText+"\n Ask=",Ask,"\n Bid=",Bid,"\n currtime=",text,"\n Symbol=",Symbol()," Period=",sPeriod);
      if(EMailON) SendMail(SignalSirname+": BUY signal "+SignalText," at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
      if(PushON) SendNotification(SignalSirname+": BUY signal "+SignalText+" at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
     }

//---
  }
//+------------------------------------------------------------------+
//| Sell signal function                                             |
//+------------------------------------------------------------------+
void SellSignal(string SignalSirname,      // текст имени индикатора для почтовых и пуш-сигналов
                const int Rates_total,     // текущее количество баров
                const int Prev_calculated, // количество баров на предыдущем тике
                const double &Close[],     // цена закрытия
                const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;
   string SignalText="";
   bool SellSignal=false;
   int index=int(Rates_total-1-NumberofBar);
   int index1=int(Rates_total-1-NumberofBar)-1;
   //---   
   if(ExtCloseBuffer[index1]>=0 && ExtCloseBuffer[index]<0)
     {
      SellSignal=true;
      SignalText=SignalText+"Пробой нуля! ";
     } 
    //--- 
    if(ExtColorBuffer[index1]>1 && ExtColorBuffer[index]<2)
     {
      SellSignal=true;
      SignalText=SignalText+"Изменение направления движения свечи! ";
     } 
    //--- 
    if(ExtCloseBuffer[index1]>=LowLevel && ExtCloseBuffer[index]<LowLevel)
     {
      SellSignal=true;
      SignalText=SignalText+"Пробой уровня пепроданности! ";
     } 
    //--- 
    if(ExtCloseBuffer[index1]>HighLevel && ExtCloseBuffer[index]<=HighLevel)
     {
      SellSignal=true;
      SignalText=SignalText+"Выход из зоны перекупленности! ";
     }
   //--- 
   if(SellSignal && counter<=NumberofAlerts)
     {
      counter++;
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);
      string text=TimeToString(TimeCurrent(),TIME_DATE)+" "+string(tm.hour)+":"+string(tm.min);
      double Ask=Close[index];
      double Bid=Close[index];
      Bid+=Spread[index]*_Point;
      string sAsk=DoubleToString(Ask,_Digits);
      string sBid=DoubleToString(Bid,_Digits);
      string sPeriod=GetStringTimeframe(ChartPeriod());
      if(SoundON) Alert("SELL signal "+SignalText+"\n Ask=",Ask,"\n Bid=",Bid,"\n currtime=",text,"\n Symbol=",Symbol()," Period=",sPeriod);
      if(EMailON) SendMail(SignalSirname+": SELL signal "+SignalText," at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
      if(PushON) SendNotification(SignalSirname+": SELL signal "+SignalText+" at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
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
