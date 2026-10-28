//+------------------------------------------------------------------+
//|                                    XPeriodCandleSystem_Alert.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2018, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчёта и отрисовки индикатора использовано восемь буферов
#property indicator_buffers 8
//---- использовано всего четыре графических построения
#property indicator_plots   4
//+--------------------------------------------+
//|  Параметры отрисовки индикатора            |
//+--------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color1 clrBlueViolet
//---- линия индикатора - сплошная
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "XMA"
//+--------------------------------------------+
//|  Параметры отрисовки индикатора BB уровней |
//+--------------------------------------------+
//---- отрисовка уровней Боллинджера в виде линий
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- ввыбор цветов уровней Боллинджера
#property indicator_color2  clrLime
#property indicator_color3  clrRed
//---- уровни Боллинджера - сплошные
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- толщина уровней Боллинджера равна 2
#property indicator_width2  2
#property indicator_width3  2
//---- отображение меток уровней Боллинджера
#property indicator_label2  "+2Sigma"
#property indicator_label3  "-2Sigma"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+ 
//---- в качестве индикатора использованы цветные свечи
#property indicator_type4   DRAW_COLOR_CANDLES
#property indicator_color4  clrDodgerBlue,clrLightSkyBlue,clrGray,clrPink,clrMagenta
//---- отображение метки индикатора
#property indicator_label4  "Open;High;Low;Close"
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh>
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMAO,XMAL,XMAH,XMAC;
//---- объявление переменных классов CXMA и CStdDeviation из файла SmoothAlgorithms.mqh
CXMA XMA1;
CStdDeviation STD;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price 
  };
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA    // AMA
  }; */
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint period=5;                       // Период расчёта свечей
input Smooth_Method MA_SMethod=MODE_JJMA;  // Метод усреднения
input int MA_Length=3;                     // глубина сглаживания                    
input int MA_Phase=100; //параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
//----
input Smooth_Method BB_Method=MODE_SMA_; //метод усреднения полос Боллинджера
input uint BBLength=20; //глубина  усреднения полос Боллинджера                    
input int BBPhase=15; //параметр усреднения полос Боллинджера,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input double BandsDeviation=1.001; //девиация
input Applied_price_ IPC=PRICE_CLOSE_;//ценовая константа
input uint Shift=0; // сдвиг свеч индикатора по горизонтали в барах влево
input uint NumberofBar=1;//Номер бара для подачи сигнала
input bool SoundON=true; //Разрешение алерта
input uint NumberofAlerts=2;//Количество алертов
input bool EMailON=false; //Разрешение почтовой отправки сигнала
input bool PushON=false; //Разрешение отправки сигнала на мобильный
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в  дальнейшем использованы в качестве индикаторных буферов свеч
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorsBuffer[];
//---- объявление динамического массива, который будет в дальнейшем использован в качестве индикаторного буфера линии
double ExtLineBuffer0[];
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов уровней Боллинджера
double ExtLineBuffer1[],ExtLineBuffer2[];
//---
int min_rates_total,min_rates_1,min_rates_2,min_rates_3;
//---- объявление глобальных переменных
int Count[];
double iopen[],ihigh[],ilow[];
//+------------------------------------------------------------------+
//|  Пересчет позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация глобальных переменных 
   min_rates_1=GetStartBars(MA_SMethod,MA_Length,MA_Phase);
   min_rates_2=min_rates_1+int(period)+1;   
   min_rates_3=GetStartBars(BB_Method,BBLength,BBPhase)+1;
   min_rates_total=min_rates_3+int(BBLength);
   
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,period);
   ArrayResize(iopen,period);
   ArrayResize(ihigh,period);
   ArrayResize(ilow,period);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer0,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);   

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);   
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);   
//---- установка позиции, с которой начинается отрисовка уровней Боллинджера
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(3,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(7,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);   
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,-int(Shift));
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorsBuffer,true);
   ArraySetAsSeries(ExtLineBuffer0,true);
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="XPeriodCandleSystem_Alert";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---- завершение инициализации
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
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных    
   int bar,limit,maxbar1,maxbar2,maxbar3;
   double HH,LL,iclose;
   double price,xma,stdev;
   //----
   maxbar1=rates_total-2;
   maxbar2=maxbar1-min_rates_2;
   maxbar3=maxbar2-min_rates_3;
//---- расчёт стартового номера limit для цикла пересчёта баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=maxbar1; // стартовый номер для расчёта всех баров
      ArrayInitialize(Count,0);
      ArrayInitialize(iopen,open[maxbar1]);
      ArrayInitialize(ihigh,high[maxbar1]);
      ArrayInitialize(ilow,low[maxbar1]);
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(iopen,true);
   ArraySetAsSeries(ihigh,true);
   ArraySetAsSeries(ilow,true);

//---- основной цикл расчёта индикатора свечек
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      iopen[Count[0]]=XMAO.XMASeries(maxbar1,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,open[bar],bar,true);
      ihigh[Count[0]]=XMAH.XMASeries(maxbar1,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,high[bar],bar,true);
      ilow[Count[0]]=XMAL.XMASeries(maxbar1,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,low[bar],bar,true);
      iclose=XMAC.XMASeries(maxbar1,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,close[bar],bar,true);
      //----
      HH=ihigh[ArrayMaximum(ihigh,0,period)];
      LL=ilow[ArrayMinimum(ilow,0,period)];
      //---- 
      ExtOpenBuffer[bar]=iopen[Count[period-1]];
      ExtHighBuffer[bar]=HH;
      ExtLowBuffer[bar]=LL;
      ExtCloseBuffer[bar]=iclose;
      ExtColorsBuffer[bar]=2;
      //---- исправление неправильных свечей     
      double Max=MathMax(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      double Min=MathMin(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      ExtHighBuffer[bar]=MathMax(Max,ExtHighBuffer[bar]);
      ExtLowBuffer[bar]=MathMin(Min,ExtLowBuffer[bar]);
      //---- окрашивание свечей
      if(ExtOpenBuffer[bar]<=ExtCloseBuffer[bar]) ExtColorsBuffer[bar]=1;
      else ExtColorsBuffer[bar]=3;
      //---- пересчёт баров в кольцевом буфере
      if(bar) Recount_ArrayZeroPos(Count,period);
     }
     
//---- Основной цикл расчёта индикатора полос Боллинджера и определение пробойных свечек
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      price=PriceSeries(IPC,bar,ExtOpenBuffer,ExtLineBuffer0,ExtHighBuffer,ExtCloseBuffer);
      xma=XMA1.XMASeries(maxbar2,prev_calculated,rates_total,BB_Method,BBPhase,BBLength,price,bar,true);
      ExtLineBuffer0[bar]=xma;
      stdev=STD.StdDevSeries(maxbar3,prev_calculated,rates_total,BBLength,BandsDeviation,price,xma,bar,true);
      ExtLineBuffer1[bar]=xma+stdev;
      ExtLineBuffer2[bar]=xma-stdev;
      
      //---- окрашивание пробойных свечек
      if(ExtOpenBuffer[bar]<=ExtCloseBuffer[bar] && ExtCloseBuffer[bar]>ExtLineBuffer1[bar+Shift])  ExtColorsBuffer[bar]=0;
      if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar] && ExtCloseBuffer[bar]<ExtLineBuffer2[bar+Shift])  ExtColorsBuffer[bar]=4;
     }
//---     
   BuySignal("XPeriodCandleSystem_Alert",ExtColorsBuffer,rates_total,prev_calculated,close,spread);
   SellSignal("XPeriodCandleSystem_Alert",ExtColorsBuffer,rates_total,prev_calculated,close,spread);
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Buy signal function                                              |
//+------------------------------------------------------------------+
void BuySignal(string SignalSirname,      // текст имени индикатора для почтовых и пуш-сигналов
               double &ColorArrow[],      // цветовой индикаторный  буфер с сигналами для покупки
               const int Rates_total,     // текущее количество баров
               const int Prev_calculated, // количество баров на предыдущем тике
               const double &Close[],     // цена закрытия
               const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool BuySignal=false;
   bool SeriesTest=ArrayGetAsSeries(ColorArrow);
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
   if(ColorArrow[index]==0 && ColorArrow[index1]!=0) BuySignal=true;
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
      Bid+=Spread[index]*_Point;
      string sAsk=DoubleToString(Ask,_Digits);
      string sBid=DoubleToString(Bid,_Digits);
      string sPeriod=GetStringTimeframe(ChartPeriod());
      if(SoundON) Alert("BUY signal \n Ask=",Ask,"\n Bid=",Bid,"\n currtime=",text,"\n Symbol=",Symbol()," Period=",sPeriod);
      if(EMailON) SendMail(SignalSirname+": BUY signal alert","BUY signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
      if(PushON) SendNotification(SignalSirname+": BUY signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
     }

//---
  }
//+------------------------------------------------------------------+
//| Sell signal function                                             |
//+------------------------------------------------------------------+
void SellSignal(string SignalSirname,      // текст имени индикатора для почтовых и пуш-сигналов
                double &ColorArrow[],      // цветовой индикаторный  буфер с сигналами для продажи
                const int Rates_total,     // текущее количество баров
                const int Prev_calculated, // количество баров на предыдущем тике
                const double &Close[],     // цена закрытия
                const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool SellSignal=false;
   bool SeriesTest=ArrayGetAsSeries(ColorArrow);
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
   if(ColorArrow[index]==4 && ColorArrow[index1]!=4) SellSignal=true;
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
      Bid+=Spread[index]*_Point;
      string sAsk=DoubleToString(Ask,_Digits);
      string sBid=DoubleToString(Bid,_Digits);
      string sPeriod=GetStringTimeframe(ChartPeriod());
      if(SoundON) Alert("SELL signal \n Ask=",Ask,"\n Bid=",Bid,"\n currtime=",text,"\n Symbol=",Symbol()," Period=",sPeriod);
      if(EMailON) SendMail(SignalSirname+": SELL signal alert","SELL signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
      if(PushON) SendNotification(SignalSirname+": SELL signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
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
