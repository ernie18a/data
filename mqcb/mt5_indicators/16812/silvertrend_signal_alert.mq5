//+------------------------------------------------------------------+
//|                                     SilverTrend_Signal_Alert.mq5 |
//|                                        Ramdass - Conversion only |
//+------------------------------------------------------------------+
#property copyright "SilverTrend  rewritten by CrazyChart"
#property link      "http://viac.ru/"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован цвет Red
#property indicator_color1  clrRed
//---- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//---- отображение метки медвежьей линии индикатора
#property indicator_label1  "Silver Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета бычьей линии индикатора использован цвет Lime
#property indicator_color2  clrLime
//---- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//---- отображение метки бычьей линии индикатора
#property indicator_label2 "Silver Buy"

//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int SSP=9;
input int RISK=3;           //степень риска
input uint NumberofBar=1;//Номер бара для подачи сигнала
input bool SoundON=true; //Разрешение алерта
input uint NumberofAlerts=2;//Количество алертов
input bool EMailON=false; //Разрешение почтовой отправки сигнала
input bool PushON=false; //Разрешение отправки сигнала на мобильный
//+----------------------------------------------+

//---- объявление динамических массивов, которые в дальнейшем
//---- будут использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//----
int K;
bool old,uptrend_;
//---- объявление целых переменных начала отсчета данных
int StartBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   StartBars=SSP+1;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Silver Sell");
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,108);
//---- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(SellBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Silver Buy");
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,108);
//---- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и метка для подокон 
   string short_name="SilverTrend_Signal";
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<StartBars) return(0);

//---- объявления локальных переменных 
   int limit;
   double Range,AvgRange,smin,smax,SsMax,SsMin,price;
   bool uptrend;

//---- расчеты необходимого количества копируемых данных
//---- и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      K=33-RISK;
      limit=rates_total-StartBars;       // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- восстанавливаем значения переменных
   uptrend=uptrend_;

//---- основной цикл расчета индикатора
   for(int bar=limit; bar>=0; bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
        {
         uptrend_=uptrend;
        }

      Range=0;
      AvgRange=0;
      for(int iii=bar; iii<=bar+SSP; iii++) AvgRange=AvgRange+MathAbs(high[iii]-low[iii]);
      Range=AvgRange/(SSP+1);
      //----
      SsMax=low[bar];
      SsMin=close[bar];

      for(int kkk=bar; kkk<=bar+SSP-1; kkk++)
        {
         price=high[kkk];
         if(SsMax<price) SsMax=price;
         price=low[kkk];
         if(SsMin>=price) SsMin=price;
        }

      smin=SsMin+(SsMax-SsMin)*K/100;
      smax=SsMax-(SsMax-SsMin)*K/100;

      SellBuffer[bar]=0;
      BuyBuffer[bar]=0;

      if(close[bar]<smin) uptrend=false;
      if(close[bar]>smax) uptrend=true;

      if(uptrend!=old && uptrend==true) BuyBuffer[bar]=low[bar]-Range*0.5;
      if(uptrend!=old && uptrend==false) SellBuffer[bar]=high[bar]+Range*0.5;

      if(bar) old=uptrend;
     }
//---     
   BuySignal("BykovTrendAlert",BuyBuffer,rates_total,prev_calculated,close,spread);
   SellSignal("BykovTrendAlert",SellBuffer,rates_total,prev_calculated,close,spread);
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
      Bid+=_Point*Spread[index];
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
      Bid+=_Point*Spread[index];
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
