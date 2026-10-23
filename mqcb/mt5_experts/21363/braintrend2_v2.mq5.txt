//+------------------------------------------------------------------+
//|                                               BrainTrend2_V2.mq5 |
//|                               Copyright © 2005, BrainTrading Inc |
//|                                      http://www.braintrading.com |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2005, BrainTrading Inc."
//---- ссылка на сайт автора
#property link      "http://www.braintrading.com/"
//---- номер версии индикатора
#property version   "1.00"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrLime,clrTeal,clrGray,clrMaroon,clrMagenta
//---- отображение метки индикатора
#property indicator_label1  "BrainTrend2Open;BrainTrend2High;BrainTrend2Low;BrainTrend2Close"

//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint ATR_Period=7;
input uint NumberofBar=1;//Номер бара для подачи сигнала
input bool SoundON=true; //Разрешение алерта
input uint NumberofAlerts=2;//Количество алертов
input bool EMailON=false; //Разрешение почтовой отправки сигнала
input bool PushON=false; //Разрешение отправки сигнала на мобильный
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorsBuffer[];
//---
bool   river=true,river_;
int    glava,glava_,min_rates_total;
double dartp,cecf,Emaxtra,Emaxtra_,Values_[],Values[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация глобальных переменных 
   dartp=7.0;
   cecf=0.7;
   min_rates_total=int(ATR_Period)+2;

//---- распределение памяти под массивы переменных   
   if(ArrayResize(Values,ATR_Period)<int(ATR_Period))
     {
      Print("Не удалось распределить память под массив Values");
      return(INIT_FAILED);
     }
   if(ArrayResize(Values_,ATR_Period)<int(ATR_Period))
     {
      Print("Не удалось распределить память под массив Values_");
      return(INIT_FAILED);
     }

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorsBuffer,true);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="BrainTrend1_V2";
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
   int bar,J,limit,Curr;
   double ATR,widcha,TR,Spread;
   double Weight,Series1,High,Low;

//---- расчёт стартового номера limit для цикла пересчёта баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
      Emaxtra=close[limit+1];
      glava=0;
      double T_Series2=close[limit+2];
      double T_Series1=close[limit+1];
      if(T_Series2>T_Series1) river=true;
      else river=false;

      TR=spread[limit]+high[limit]-low[limit];

      if(MathAbs(spread[limit]+high[limit]-T_Series1)>TR)
         TR=MathAbs(spread[limit]+high[limit]-T_Series1);

      if(MathAbs(low[limit]-T_Series1)>TR)
         TR=MathAbs(low[limit]-T_Series1);

      ArrayInitialize(Values,TR);
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
   ArraySetAsSeries(spread,true);
   ArraySetAsSeries(Values,true);
   ArraySetAsSeries(Values_,true);

//---- восстанавливаем значения переменных
   glava=glava_;
   Emaxtra=Emaxtra_;
   river=river_;
   ArrayCopy(Values,Values_,0,WHOLE_ARRAY);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0; bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
        {
         glava_=glava;
         Emaxtra_=Emaxtra;
         river_=river;
         ArrayCopy(Values_,Values,0,WHOLE_ARRAY);
        }

      ExtOpenBuffer[bar]=NULL;
      ExtHighBuffer[bar]=NULL;
      ExtLowBuffer[bar]=NULL;
      ExtCloseBuffer[bar]=NULL;
      ExtColorsBuffer[bar]=2;

      Spread=spread[bar]*_Point;

      High=high[bar];
      Low=low[bar];
      Series1=close[bar+1];
      TR=Spread+High-Low;

      if(MathAbs(Spread+High-Series1)>TR) TR=MathAbs(Spread+High-Series1);

      if(MathAbs(Low-Series1)>TR) TR=MathAbs(Low-Series1);

      Values[glava]=TR;

      ATR=0;
      Weight=ATR_Period;
      Curr=glava;

      for(J=0; J<=int(ATR_Period)-1; J++)
        {
         ATR+=Values[Curr]*Weight;
         Weight-=1.0;
         Curr--;
         if(Curr==-1) Curr=int(ATR_Period)-1;
        }

      ATR=2.0*ATR/(dartp *(dartp+1.0));
      glava++;

      if(glava==ATR_Period) glava=0;

      widcha=cecf*ATR;

      if(river && Low<Emaxtra-widcha)
        {
         river=false;
         Emaxtra=Spread+High;
        }

      if(!river && Spread+High>Emaxtra+widcha)
        {
         river=true;
         Emaxtra=Low;
        }

      if(river && Low>Emaxtra)
        {
         Emaxtra=Low;
        }

      if(!river && Spread+High<Emaxtra)
        {
         Emaxtra=Spread+High;
        }

      if(river)
        {
         ExtOpenBuffer[bar]=open[bar];
         ExtHighBuffer[bar]=High;
         ExtLowBuffer[bar]=Low;
         ExtCloseBuffer[bar]=close[bar];

         if(open[bar]<=close[bar]) ExtColorsBuffer[bar]=0;
         else ExtColorsBuffer[bar]=1;
        }
      else
        {
         ExtOpenBuffer[bar]=open[bar];
         ExtHighBuffer[bar]=High;
         ExtLowBuffer[bar]=Low;
         ExtCloseBuffer[bar]=close[bar];

         if(open[bar]>=close[bar]) ExtColorsBuffer[bar]=4;
         else ExtColorsBuffer[bar]=3;
        }
     }
//---     
   BuySignal("BrainTrend2_V2",ExtColorsBuffer,rates_total,prev_calculated,close,spread);
   SellSignal("BrainTrend2_V2",ExtColorsBuffer,rates_total,prev_calculated,close,spread);
//---       
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) //Период графика индикатора (таймфрейм)
  {
//--- проверка периодов графиков на корректность
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора "+IndName+" не может быть меньше периода текущего графика!");
      Print("Следует изменить входные параметры индикатора!");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Buy signal function                                              |
//+------------------------------------------------------------------+
void BuySignal(string SignalSirname,// текст имени индикатора для почтовых и пуш-сигналов
               double &ColorBuff[],// индикаторный буфер с сигналами для покупки
               const int Rates_total,     // текущее количество баров
               const int Prev_calculated, // количество баров на предыдущем тике
               const double &Close[],     // цена закрытия
               const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool BuySignal=false;
   bool SeriesTest=ArrayGetAsSeries(ColorBuff);
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

   if(ColorBuff[index1]>1 && ColorBuff[index]<2) BuySignal=true;
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
                double &ColorBuff[],       // индикаторный буфер с сигналами для покупки
                const int Rates_total,     // текущее количество баров
                const int Prev_calculated, // количество баров на предыдущем тике
                const double &Close[],     // цена закрытия
                const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool SellSignal=false;
   bool SeriesTest=ArrayGetAsSeries(ColorBuff);
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

   if(ColorBuff[index1]<3 && ColorBuff[index]>2) SellSignal=true;
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
