//+---------------------------------------------------------------------+
//|                                               ColorXdinMA_Alert.mq5 | 
//|                                          Copyright © 2011,   dimeon | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, dimeon"
#property link ""
//---- номер версии индикатора
#property version   "1.04"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------------+
//|  Параметры отрисовки индикатора                    |
//+----------------------------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов трёхцветной линии использованы
#property indicator_color1  clrYellow,clrBlue,clrRed
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "XdinMA"

//+----------------------------------------------------+
//|  Описание класса CXMA                              |
//+----------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+----------------------------------------------------+
//|  объявление перечислений                           |
//+----------------------------------------------------+
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
input Smooth_Method MA_Method1=MODE_SMA_; //метод усреднения
input int Length_main=10; //глубина main усреднения
input int Length_plus=20; //глубина plus усреднения                  
input int PhaseX=15; //параметр усреднения,
  //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
  // Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE_;//ценовая константа
input int Shift=0; // сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // cдвиг индикатора по вертикали в пунктах
//---- Входные переменные для алертов
input ENUM_SIGNAL_MODE SignMode=MODE_SIGNAL; //Вариант подачи сигнала 
input uint NumberofBar=1;                    //Номер бара для подачи сигнала
input bool SoundON=true;                     //Разрешение алерта
input uint NumberofAlerts=2;                 //Количество алертов
input bool EMailON=false;                    //Разрешение почтовой отправки сигнала
input bool PushON=false;                     //Разрешение отправки сигнала на мобильный
//+----------------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double XdinMA[];
double ColorXdinMA[];

//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
//+------------------------------------------------------------------+   
//| XdinMA indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   int StartBars1=XMA1.GetStartBars(MA_Method1, Length_main, PhaseX);
   int StartBars2=XMA2.GetStartBars(MA_Method1, Length_plus, PhaseX);
   min_rates_total=MathMax(StartBars1,StartBars2)+1;
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("Length_main", Length_main);
   XMA2.XMALengthCheck("Length_plus", Length_plus);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("PhaseX", PhaseX, MA_Method1);
   
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,XdinMA,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorXdinMA,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(MA_Method1);
   StringConcatenate(shortname,"XdinMA(",Length_main,", ",Length_plus,", ",Smooth,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
   
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| XdinMA iteration function                                        | 
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
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных с плавающей точкой  
   double price_,ma_main,ma_plus;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first1,first2,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
    {
      first1=0; // стартовый номер для расчёта всех баров
      first2=min_rates_total;
    }
   else
    {
     first1=prev_calculated-1; // стартовый номер для расчёта новых баров
     first2=first1;
    }

//---- Основной цикл расчёта индикатора
   for(bar=first1; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Вызов функции PriceSeries для получения входной цены price_
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- Два вызова функции XMASeries.   
      ma_main = XMA1.XMASeries(0, prev_calculated, rates_total, MA_Method1, PhaseX, Length_main, price_, bar, false);
      ma_plus = XMA2.XMASeries(0, prev_calculated, rates_total, MA_Method1, PhaseX, Length_plus, price_, bar, false);
      //----       
      XdinMA[bar]=ma_main*2-ma_plus+dPriceShift;
     }
           
//---- Основной цикл раскраски индикатора
   for(bar=first2; bar<rates_total; bar++)
     {
      ColorXdinMA[bar]=0;
      if(XdinMA[bar-1]<XdinMA[bar]) ColorXdinMA[bar]=1;
      if(XdinMA[bar-1]>XdinMA[bar]) ColorXdinMA[bar]=2;
     }
//---     
   BuySignal("ColorXdinMA_Alert",ColorXdinMA,1,rates_total,prev_calculated,close,spread);
   SellSignal("ColorXdinMA_Alert",ColorXdinMA,2,rates_total,prev_calculated,close,spread);
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
