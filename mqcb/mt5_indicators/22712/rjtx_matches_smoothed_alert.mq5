//+------------------------------------------------------------------+
//|                                  RJTX_Matches_Smoothed_Alert.mq5 |
//|                            Copyright 2015, Rafael Jimenez Tocino |
//|               http://www.tradingrafa.com/indicadores/rjt_matches |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright 2015, Rafael Jimenez Tocino"
//--- ссылка на сайт автора
#property link      "http://www.tradingrafa.com/indicadores/rjt_matches"
#property description "We recommend adjust the body and head size of the matches for better visualization."
//--- номер версии индикатора
#property version   "4.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 5
//--- использовано всего два графических построения
#property indicator_plots   5
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован фиолетовый цвет
#property indicator_color1  clrDarkViolet
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "match 1"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован фиолетовый цвет
#property indicator_color2  clrDarkViolet
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  "match 2"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 3             |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован фиолетовый цвет
#property indicator_color3  clrDarkViolet
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение медвежьей метки индикатора
#property indicator_label3  "match 3"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//--- в качестве цвета медвежьего индикатора использован розовый цвет
#property indicator_color4  clrDeepPink
//--- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//--- отображение медвежьей метки индикатора
#property indicator_label4  "RJTX_Matches_Smoothed Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//--- в качестве цвета бычьего индикатора использован голубой цвет
#property indicator_color5  clrDodgerBlue
//--- толщина линии индикатора 5 равна 2
#property indicator_width5  2
//--- отображение бычьей метки индикатора
#property indicator_label5 "RJTX_Matches_Smoothed Buy"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMAO,XMAC;
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
/*enum SmoothMethod - перечисление объявлено в файле SmoothAlgorithms.mqh
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
   MODE_AMA    //AMA
  }; */
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint iPeriod=10;                    // Период индикатора свечек
input Smooth_Method XMA_Method=MODE_SMA_; // Метод усреднения
input uint XLength=12;                    // Глубина сглаживания
input int XPhase=15;                      // Параметр сглаживания
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
input uint NumberofBar=1;                 // Номер бара для подачи сигнала
input bool SoundON=true;                  // Разрешение алерта
input uint NumberofAlerts=2;              // Количество алертов
input bool EMailON=false;                 // Разрешение почтовой отправки сигнала
input bool PushON=false;                  // Разрешение отправки сигнала на мобильный
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double LineBuffer0[];
double LineBuffer1[];
double LineBuffer2[];
double SellBuffer[];
double BuyBuffer[];
//---
int min_rates_total;
//---- объявление глобальных переменных
int Count[];
double xOpen[];
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;
//----
   Max2=Size;
   Max1=Max2-1;
//----
   count--;
   if(count<0) count=Max1;
//----
   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=GetStartBars(XMA_Method,XLength,XPhase);
   min_rates_total=int(MathMax(iPeriod,min_rates_total));
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,iPeriod+1);
   ArrayResize(xOpen,iPeriod+1);
//---- инициализация индикаторного буферов
   IndInit(0,LineBuffer0,0,min_rates_total,0);
   IndInit(1,LineBuffer1,0,min_rates_total,0);
   IndInit(2,LineBuffer2,0,min_rates_total,0);
   IndInit(3,SellBuffer,0,min_rates_total,0);
   IndInit(4,BuyBuffer,0,min_rates_total,0);
//--- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,174);
   PlotIndexSetInteger(4,PLOT_ARROW,174);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="RJTX_Matches_Smoothed";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(Number,PLOT_SHOW_DATA,false);
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
   if(rates_total<min_rates_total) return(RESET);
//--- объявление локальных переменных 
   int first,bar;
   static uint p=0;
   double xclose;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=0; // стартовый номер для расчета всех баров
      ArrayInitialize(Count,0);
      ArrayInitialize(xOpen,open[first]);
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      xOpen[Count[0]]=XMAO.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,open[bar],bar,false);
      xclose=XMAC.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,close[bar],bar,false);
      //--- the color of matchstick heads
      if(xclose>xOpen[Count[iPeriod]])
        {
         SellBuffer[bar]=NULL;
         BuyBuffer[bar]=xclose;
        }
      else
        {
         SellBuffer[bar]=xclose;
         BuyBuffer[bar]=NULL;
        }
      //---
      switch(p)
        {
         case 0:
           {
            LineBuffer0[bar]=xOpen[Count[iPeriod-1]];
            LineBuffer1[bar]=NULL;
            LineBuffer2[bar]=xclose;
            break;
           }
         case 1:
           {
            LineBuffer0[bar]=xclose;
            LineBuffer1[bar]=xOpen[Count[iPeriod-1]];
            LineBuffer2[bar]=NULL;
            break;
           }
         case 2:
           {
            LineBuffer0[bar]=NULL;
            LineBuffer1[bar]=xclose;
            LineBuffer2[bar]=xOpen[Count[iPeriod-1]];
           }
        }
      if(bar<rates_total-1)
        {
         Recount_ArrayZeroPos(Count,iPeriod+1);
         p++;
        }
      if(p>2) p=0;
     }
//---     
   BuySignal("RJTX_Matches_Smoothed_Alert",BuyBuffer,rates_total,prev_calculated,close,spread);
   SellSignal("RJTX_Matches_Smoothed_Alert",SellBuffer,rates_total,prev_calculated,close,spread);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Buy signal function                                              |
//+------------------------------------------------------------------+
void BuySignal(string SignalSirname,      // текст имени индикатора для почтовых и пуш-сигналов
               double &BuyArrow[],        // индикаторный буфер с сигналами для покупки
               const int Rates_total,     // текущее количество баров
               const int Prev_calculated, // количество баров на предыдущем тике
               const double &Close[],     // цена закрытия
               const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool BuySignal=false;
   bool SeriesTest=ArrayGetAsSeries(BuyArrow);
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
   if(!BuyArrow[index1] && BuyArrow[index]) BuySignal=true;
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
                double &SellArrow[],       // индикаторный буфер с сигналами для покупки
                const int Rates_total,     // текущее количество баров
                const int Prev_calculated, // количество баров на предыдущем тике
                const double &Close[],     // цена закрытия
                const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool SellSignal=false;
   bool SeriesTest=ArrayGetAsSeries(SellArrow);
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
   if(!SellArrow[index1] && SellArrow[index]) SellSignal=true;
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
