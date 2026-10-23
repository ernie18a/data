//+------------------------------------------------------------------+
//|                                                 Harami_Alert.mq5 |
//|                                  Copyright © 2009, Paul Stringer |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property description "Harami"
//---- авторство индикатора
#property copyright "Copyright © 2009, Paul Stringer"
//---- ссылка на сайт автора
#property link      "https://www.metaquotes.net"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки верхнего индикатора     |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета индикатора использован розовый цвет
#property indicator_color1  clrMagenta
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение бычей метки индикатора
#property indicator_label1  "Up Harami"
//+----------------------------------------------+
//|  Параметры отрисовки нижнего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета индикатора использован синий цвет
#property indicator_color2  clrBlue
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение медвежьей метки индикатора
#property indicator_label2 "Down Harami"

//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint MinMasterSize = 40;
input uint MaxMasterSize = 500;
input uint MinHaramiSize = 20;
input uint MaxHaramiSize = 300;
input double   MaxRatioHaramiToMaster = 0.75;
input double   MinRatioHaramiToMaster = 0.5;
input uint ArrowOffSet=35;
input int  UpLable=218;//лейба верхнего фрактала
input int  DnLable=217;//лейба нижнего фрактала
//---- 
input uint NumberofBar=1;//Номер бара для подачи сигнала
input bool SoundON=true; //Разрешение алерта
input uint NumberofAlerts=2;//Количество алертов
input bool EMailON=false; //Разрешение почтовой отправки сигнала
input bool PushON=false; //Разрешение отправки сигнала на мобильный
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
double dMinMasterSize,dMaxMasterSize,dMinHaramiSize,dMaxHaramiSize,dArrowOffSet;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- инициализация глобальных переменных 
   min_rates_total=6;
   dMinMasterSize=MinMasterSize*_Point;
   dMaxMasterSize=MaxMasterSize*_Point;
   dMinHaramiSize=MinHaramiSize*_Point;
   dMaxHaramiSize=MaxHaramiSize*_Point;
   dArrowOffSet=ArrowOffSet*_Point;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,UpLable);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,DnLable);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="Harami";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
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
   int limit;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);

//---- основной цикл расчёта индикатора
   for(int bar=limit; bar>=1 && !IsStopped(); bar--)
     {
      BuyBuffer[bar-1]=SellBuffer[bar-1]=NULL;
      double _MasterBarSize=MathAbs(open[bar+1]-close[bar+1]);
      double _HaramiBarSize=MathAbs(open[bar]-close[bar]);
      double MaxM=_MasterBarSize-dMaxMasterSize;
      double MinM=_MasterBarSize-dMinMasterSize;
      double MaxH=_HaramiBarSize-dMaxHaramiSize;
      double MinH=_HaramiBarSize-dMinHaramiSize;
      if(!_MasterBarSize) _MasterBarSize=_Point;
      double res=_HaramiBarSize/_MasterBarSize;

      if(MaxM && MinM && MaxH && MinH && res<=MaxRatioHaramiToMaster && res>=MinRatioHaramiToMaster)
        {
         // Is it reversal in favour of a BEAR reversal...
         if(
            (open[bar+1]>close[bar+1]) && 
            (open[bar]<close[bar]) && 
            (close[bar+1]<open[bar]) && 
            (open[bar+1]>close[bar])
            )
           {
            // Reversal favouring a bull coming...
            BuyBuffer[bar-1]=low[bar-1]-dArrowOffSet;
           }

         // Is it reversal in favour of a BULL reversal...
         if(
            (open[bar+1]<close[bar+1]) && 
            (open[bar]>close[bar]) && 
            (close[bar+1]>open[bar]) && 
            (open[bar+1]<close[bar])
            )
           {
            // Reversal favouring a bull coming...
            SellBuffer[bar-1]=high[bar-1]+dArrowOffSet;
           }
        }
     }
//---     
   BuySignal("Harami_Alert",BuyBuffer,rates_total,prev_calculated,close,spread);
   SellSignal("Harami_Alert",SellBuffer,rates_total,prev_calculated,close,spread);
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
   int index;
   if(SeriesTest) index=int(NumberofBar);
   else index=Rates_total-int(NumberofBar)-1;
   if(NormalizeDouble(BuyArrow[index],_Digits) && BuyArrow[index]!=EMPTY_VALUE) BuySignal=true;
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
   int index;
   if(SeriesTest) index=int(NumberofBar);
   else index=Rates_total-int(NumberofBar)-1;
   if(NormalizeDouble(SellArrow[index],_Digits) && SellArrow[index]!=EMPTY_VALUE) SellSignal=true;
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
