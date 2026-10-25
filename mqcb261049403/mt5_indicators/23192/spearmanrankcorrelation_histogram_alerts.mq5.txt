//+------------------------------------------------------------------+
//|                     SpearmanRankCorrelation_Histogram_Alerts.mq5 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
// http://www.infamed.com/stat/s05.html
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде четырёхцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов четырёхцветной гистограммы использованы
#property indicator_color1 clrMagenta,clrPurple,clrGray,clrBlue,clrDodgerBlue
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//+----------------------------------------------+
//---- параметры минимального и максимального значений индикатора
#property indicator_minimum -1.0
#property indicator_maximum +1.0
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_APPLIED_PRICE_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price 
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int  rangeN=14;
input int  CalculatedBars=0;
input int  Maxrange=30;
input bool direction=true;
input ENUM_APPLIED_PRICE_ IPC=PRICE_CLOSE_;  // ценовая константа
input double inHighLevel=+0.5;
input double inLowLevel=-0.5;
input uint NumberofBar=1;          // Номер бара для подачи сигнала
input bool SoundON=true;           // Разрешение алерта
input uint NumberofAlerts=2;       // Количество алертов
input bool EMailON=false;          // Разрешение почтовой отправки сигнала
input bool PushON=false;           // Разрешение отправки сигнала на мобильный
//+----------------------------------------------+
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
double multiply;
double R2[],TrueRanks[];
int    PriceInt[],SortInt[],Maxrange_;
//+------------------------------------------------------------------+
//| calculate  RSP  function                                         |
//+------------------------------------------------------------------+
double SpearmanRankCorrelation(double &Ranks[],int N)
  {
//----
   double res,z2=0.0;

   for(int iii=0; iii<N; iii++) z2+=MathPow(Ranks[iii]-iii-1,2);
   res=1-6*z2/(MathPow(N,3)-N);
//----
   return(res);
  }
//+------------------------------------------------------------------+
//| Ranking array of prices function                                 |
//+------------------------------------------------------------------+
void RankPrices(double &TrueRanks_[],int &InitialArray[])
  {
//----
   int i,k,m,dublicat,counter,etalon;
   double dcounter,averageRank;

   ArrayCopy(SortInt,InitialArray,0,0,WHOLE_ARRAY);

   for(i=0; i<rangeN; i++) TrueRanks_[i]=i+1;
   
   ArraySort(SortInt);
   
   for(i=0; i<rangeN-1; i++)
     {
      if(SortInt[i]!=SortInt[i+1]) continue;

      dublicat=SortInt[i];
      k=i+1;
      counter=1;
      averageRank=i+1;

      while(k<rangeN)
        {
         if(SortInt[k]==dublicat)
           {
            counter++;
            averageRank+=k+1;
            k++;
           }
         else
            break;
        }
      dcounter=counter;
      averageRank=averageRank/dcounter;

      for(m=i; m<k; m++)
         TrueRanks_[m]=averageRank;
      i=k;
     }
   for(i=0; i<rangeN; i++)
     {
      etalon=InitialArray[i];
      k=0;
      while(k<rangeN)
        {
         if(etalon==SortInt[k])
           {
            R2[i]=TrueRanks_[k];
            break;
           }
         k++;
        }
     }
//----
   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- распределение памяти под массивы переменных   
   ArrayResize(R2,rangeN);
   ArrayResize(PriceInt,rangeN);
   ArrayResize(SortInt,rangeN);
//---- изменение индексации элементов в массиве переменных
   if(direction) ArraySetAsSeries(SortInt,true);
   ArrayResize(TrueRanks,rangeN);
//---- инициализация переменных
   if(Maxrange<=0) Maxrange_=10;
   else Maxrange_=Maxrange;
   multiply=MathPow(10,_Digits);
//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rangeN);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   if(rangeN>Maxrange_) shortname="Decrease rangeN input!";
   else StringConcatenate(shortname,"SpearmanRankCorrelation_Histogram_Alerts(",rangeN,")");
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//---- количество  горизонтальных уровней индикатора    
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,inHighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,inLowLevel);
//---- в качестве цветов линий горизонтальных уровней использован розовый и синий цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrBlue);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASH);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<rangeN) return(0);
   if(rangeN>Maxrange_) return(0);

//---- объявления локальных переменных 
   int limit;

//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-2-rangeN; // стартовый номер для расчета всех баров
     }
   else
     {
      if(!CalculatedBars) limit = rates_total - prev_calculated;
      else limit = CalculatedBars;
     }

//---- индексация элементов в массивах как в таймсериях 
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(Open,true); 
   ArraySetAsSeries(High,true); 
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Spread,true); 

//---- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      for(int k=0; k<rangeN; k++) PriceInt[k]=int(PriceSeries(IPC,bar+k,Open,Low,High,Close)*multiply);

      RankPrices(TrueRanks,PriceInt);
      IndBuffer[bar]=SpearmanRankCorrelation(R2,rangeN);
      
      int clr=2;
      double res=IndBuffer[bar];

      if(res>0)
        {
         if(res>inHighLevel) clr=4;
         else clr=3;
        }        
      if(res<0)
        {
         if(res<inLowLevel) clr=0;
         else clr=1;
        }        
      ColorIndBuffer[bar]=clr;
     }
//---     
   BuySignal("SpearmanRankCorrelation_Histogram_Alerts",rates_total,prev_calculated,Close,Spread);
   SellSignal("SpearmanRankCorrelation_Histogram_Alerts",rates_total,prev_calculated,Close,Spread);
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
   int index=int(NumberofBar);
   int index1=int(NumberofBar)+1;
   //--- 
   if(IndBuffer[index1]<=0 && IndBuffer[index]>0)  
     {
      BuySignal=true;
      SignalText=SignalText+"Пробой нуля! ";
     }  
    //--- 
    if(ColorIndBuffer[index1]<4 && ColorIndBuffer[index]==4)
     {
      BuySignal=true;
      SignalText=SignalText+"Пробой уровня перекупленности! ";
     } 
    //--- 
    if(ColorIndBuffer[index1]==1 && ColorIndBuffer[index]>2)
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
   int index=int(NumberofBar);
   int index1=int(NumberofBar)+1;
   //---   
   if(IndBuffer[index1]>=0 && IndBuffer[index]<0)
     {
      SellSignal=true;
      SignalText=SignalText+"Пробой нуля! ";
     }  
    //--- 
    if(ColorIndBuffer[index1]>0 && ColorIndBuffer[index]==0)
     {
      SellSignal=true;
      SignalText=SignalText+"Пробой уровня пепроданности! ";
     }  
    //--- 
    if(ColorIndBuffer[index1]==4 && ColorIndBuffer[index]<4)
     {
      SellSignal=true;
      SignalText=SignalText+"Выход из зоны перекупленности! ";
     }       
   //--
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
//| Получение значения ценовой таймсерии                             |
//+------------------------------------------------------------------+ 
double PriceSeries
(
 uint applied_price,// Ценовая константа
 uint   bar,// Индекс сдвига относительно текущего бара на указанное количество периодов назад или вперёд).
 const double &Open[],
 const double &Low[],
 const double &High[],
 const double &Close[]
 )
//PriceSeries(applied_price, bar, open, low, high, close)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   switch(applied_price)
     {
      //---- Ценовые константы из перечисления ENUM_APPLIED_PRICE
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);

      //----                            
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      //----                                
      case 10:
        {
         if(Close[bar]>Open[bar])return(High[bar]);
         else
           {
            if(Close[bar]<Open[bar])
               return(Low[bar]);
            else return(Close[bar]);
           }
        }
      //----         
      case 11:
        {
         if(Close[bar]>Open[bar])return((High[bar]+Close[bar])/2.0);
         else
           {
            if(Close[bar]<Open[bar])
               return((Low[bar]+Close[bar])/2.0);
            else return(Close[bar]);
           }
         break;
        }
      //----         
      case 12:
        {
         double res=High[bar]+Low[bar]+Close[bar];
         if(Close[bar]<Open[bar]) res=(res+Low[bar])/2;
         if(Close[bar]>Open[bar]) res=(res+High[bar])/2;
         if(Close[bar]==Open[bar]) res=(res+Close[bar])/2;
         return(((res-Low[bar])+(res-High[bar]))/2);
        }
      //----
      default: return(Close[bar]);
     }
//----
//return(0);
  }
//+------------------------------------------------------------------+