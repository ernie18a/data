//+------------------------------------------------------------------+
//|                                         BBands_Stop_v1_Alert.mq5 |
//|                           Copyright © 2006, TrendLaboratory Ltd. |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                       E-mail: igorad2004@list.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, TrendLaboratory Ltd." 
//---- ссылка на сайт автора
#property link "http://finance.groups.yahoo.com/group/TrendLaboratory"
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 6
//---- использовано всего шесть графических построений
#property indicator_plots   6
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета символа входа использован Orange цвет
#property indicator_color1  clrOrange
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение медвежьей метки индикатора 1
#property indicator_label1  "Sell Signal"

//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета символов стоплоссов использован Orange цвет
#property indicator_color2  clrOrange
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение медвежьей метки индикатора 2
#property indicator_label2 "Sell Stop Signal"

//---- отрисовка индикатора 3 в виде символа
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии стоплоссов использован Orange цвет
#property indicator_color3 clrOrange
//---- толщина линии индикатора 3 равна 1
#property indicator_width3  1
//---- отображение медвежьей метки индикатора 3
#property indicator_label3 "Sell Stop Line"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета символа входа использован Chartreuse цвет
#property indicator_color4  clrChartreuse
//---- толщина линии индикатора 4 равна 1
#property indicator_width4  1
//---- отображение бычей метки индикатора 4
#property indicator_label4  "Buy Signal"

//---- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета символов стоплоссов использован Chartreuse цвет
#property indicator_color5  clrChartreuse
//---- толщина линии индикатора 5 равна 1
#property indicator_width5  1
//---- отображение бычей метки индикатора 5
#property indicator_label5 "Buy Stop Signal"

//---- отрисовка индикатора 6 в виде символа
#property indicator_type6   DRAW_LINE
//---- в качестве цвета линии стоплоссов использован Chartreuse цвет
#property indicator_color6  clrChartreuse
//---- толщина линии индикатора 6 равна 1
#property indicator_width6  1
//---- отображение бычей метки индикатора 6
#property indicator_label6 "Buy Stop Line"
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum DISPLAY_SIGNALS_MODE //Тип константы
  {
   OnlyStops= 0,//Only Stops
   SignalsStops,//Signals & Stops
   OnlySignals  //Only Signals
  };

//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int Length=20;                              //Период Боллинджера
input double Deviation=2;                         //Девиация
input double MoneyRisk=1.00;                      //Offset Factor
input DISPLAY_SIGNALS_MODE Signal=SignalsStops;
input bool Line=true;
input uint NumberofBar=1;                         //Номер бара для подачи сигнала
input bool SoundON=true;                          //Разрешение алерта
input uint NumberofAlerts=2;                      //Количество алертов
input bool EMailON=false;                         //Разрешение почтовой отправки сигнала
input bool PushON=false;                          //Разрешение отправки сигнала на мобильный
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double UpTrendBuffer[];
double DownTrendBuffer[];
double UpTrendSignal[];
double DownTrendSignal[];
double UpTrendLine[];
double DownTrendLine[];
//---- Объявление целых переменных для хендлов индикаторов
int BB_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление глобальных переменных
double MRisk;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- инициализация глобальных переменных 
   min_rates_total=Length+1;
   MRisk=0.5*(MoneyRisk-1);
//----
   BB_Handle=iBands(NULL,0,Length,0,Deviation,PRICE_CLOSE);
   if(BB_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iBands");

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,DownTrendSignal,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,108);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DownTrendSignal,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DownTrendBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DownTrendBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,DownTrendLine,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DownTrendLine,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,UpTrendSignal,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,108);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpTrendSignal,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,UpTrendBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 5
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(4,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpTrendBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,UpTrendLine,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 6
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpTrendLine,true);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name;
   StringConcatenate(short_name,"BBands_Stop(",Length,", ",
                     DoubleToString(Deviation,2),", ",DoubleToString(MoneyRisk,2),")");
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Bollinger Bands_Stop_v1                                          |
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
   if(BarsCalculated(BB_Handle)<rates_total || rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   int limit,bar,trend,to_copy,maxbar;
   double smax0,smin0,bsmax0,bsmin0;
   double UpBB[],DnBB[],dsize;

//---- объявления переменных памяти  
   static int trend_;
   static double smax1,smin1,bsmax1,bsmin1;

//---- расчёты стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров

      smax1=-999999999;
      smin1=+999999999;
      bsmax1=-999999999;
      bsmin1=+999999999;
      trend_=0;

      for(bar=rates_total-1; bar>limit; bar--)
        {
         UpTrendBuffer[bar]=0;
         DownTrendBuffer[bar]=0;
         UpTrendSignal[bar]=0;
         DownTrendSignal[bar]=0;
         UpTrendLine[bar]=0;
         DownTrendLine[bar]=0;
        }
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }

//---- индексация элементов в массивах как в таймсериях
   ArraySetAsSeries(UpBB,true);
   ArraySetAsSeries(DnBB,true);
   ArraySetAsSeries(close,true);
   to_copy=limit+1;
   maxbar=rates_total-min_rates_total-1;

//---- копируем вновь появившиеся данные в массив
   if(CopyBuffer(BB_Handle,1,0,to_copy,UpBB)<=0) return(0);
   if(CopyBuffer(BB_Handle,2,0,to_copy,DnBB)<=0) return(0);

//---- восстанавливаем значения переменных
   trend=trend_;

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
        {
         trend_=trend;
        }

      smax0=UpBB[bar];
      smin0=DnBB[bar];
      UpTrendBuffer[bar]=NULL;
      DownTrendBuffer[bar]=NULL;
      UpTrendSignal[bar]=NULL;
      DownTrendSignal[bar]=NULL;
      UpTrendLine[bar]=NULL;
      DownTrendLine[bar]=NULL;

      if(bar>maxbar)
        {
         smin1=smin0;
         smax1=smax0;
         bsmax1=smax1+MRisk*(smax1-smin1);
         bsmin1=smin1-MRisk*(smax1-smin1);
         continue;
        }

      if(close[bar]>smax1) trend=1;
      if(close[bar]<smin1) trend=-1;

      if(trend>0 && smin0<smin1) smin0=smin1;
      if(trend<0 && smax0>smax1) smax0=smax1;

      dsize=MRisk*(smax0-smin0);
      bsmax0=smax0+dsize;
      bsmin0=smin0-dsize;

      if(trend>0 && bsmin0<bsmin1) bsmin0=bsmin1;
      if(trend<0 && bsmax0>bsmax1) bsmax0=bsmax1;

      if(trend>0)
        {
         if(Signal && !UpTrendBuffer[bar+1])
           {
            UpTrendSignal[bar]=bsmin0;
            UpTrendBuffer[bar]=bsmin0;
            if(Line) UpTrendLine[bar]=bsmin0;
           }
         else
           {
            UpTrendBuffer[bar]=bsmin0;
            if(Line) UpTrendLine[bar]=bsmin0;
            UpTrendSignal[bar]=NULL;
           }

         if(Signal==OnlySignals) UpTrendBuffer[bar]=NULL;
         DownTrendSignal[bar]=NULL;
         DownTrendBuffer[bar]=NULL;
         DownTrendLine[bar]=NULL;
        }

      if(trend<0)
        {
         if(Signal && !DownTrendBuffer[bar+1])
           {
            DownTrendSignal[bar]=bsmax0;
            DownTrendBuffer[bar]=bsmax0;
            if(Line) DownTrendLine[bar]=bsmax0;
           }
         else
           {
            DownTrendBuffer[bar]=bsmax0;
            if(Line) DownTrendLine[bar]=bsmax0;
            DownTrendSignal[bar]=NULL;
           }
         if(Signal==OnlySignals) DownTrendBuffer[bar]=NULL;
         UpTrendSignal[bar]=NULL;
         UpTrendBuffer[bar]=NULL;
         UpTrendLine[bar]=NULL;
        }

      if(bar>0)
        {
         smax1=smax0;
         smin1=smin0;
         bsmax1=bsmax0;
         bsmin1=bsmin0;
        }

     }
//---     
   switch(Signal)
     {
      case OnlyStops: //Only Stops
        {
         BuySignal("BBands_Stop_v1_Alert",UpTrendBuffer,rates_total,prev_calculated,close,spread);
         SellSignal("BBands_Stop_v1_Alert",DownTrendBuffer,rates_total,prev_calculated,close,spread);
         break;
        }
      case SignalsStops: //Signals & Stops
        {
         BuySignal("BBands_Stop_v1_Alert",UpTrendBuffer,rates_total,prev_calculated,close,spread);
         SellSignal("BBands_Stop_v1_Alert",DownTrendBuffer,rates_total,prev_calculated,close,spread);
         break;
        }
      case OnlySignals: //Only Signals
        {
         BuySignal("BBands_Stop_v1_Alert",UpTrendSignal,rates_total,prev_calculated,close,spread);
         SellSignal("BBands_Stop_v1_Alert",DownTrendSignal,rates_total,prev_calculated,close,spread);
         break;
        }
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Buy signal function                                              |
//+------------------------------------------------------------------+
void BuySignal(string SignalSirname,      // текст имени индикатора для почтовых и пуш-сигналов
               double &UpArrow[],         // индикаторный  буфер с сигналами для покупки
               const int Rates_total,     // текущее количество баров
               const int Prev_calculated, // количество баров на предыдущем тике
               const double &Close[],     // цена закрытия
               const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool BuySignal=false;
   bool SeriesTest=ArrayGetAsSeries(UpArrow);
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
   if(UpArrow[index] && !UpArrow[index1]) BuySignal=true;
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
                double &DnArrow[],        // индикаторный  буфер с сигналами для продажи
                const int Rates_total,     // текущее количество баров
                const int Prev_calculated, // количество баров на предыдущем тике
                const double &Close[],     // цена закрытия
                const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool SellSignal=false;
   bool SeriesTest=ArrayGetAsSeries(DnArrow);
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
   if(DnArrow[index] && !DnArrow[index1]) SellSignal=true;
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
