//+------------------------------------------------------------------+
//|                         Rj_SlidingRangeRj_Digit_System_Alert.mq5 |
//|                            Copyright © 2011,RJ Rjabkov Alexander |
//|                                                     rj-a@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011,RJ Rjabkov Alexander"
#property link      "rj-a@mail.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 9
#property indicator_buffers 9 
//---- использовано 4 графических построения
#property indicator_plots   4
//+--------------------------------------------+
//| Параметры отрисовки облака                 |
//+--------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет Lavender
#property indicator_color1 clrLavender
//---- отображение метки индикатора
#property indicator_label1  "Rj_SlidingRangeRj_Digit Channel"
//+--------------------------------------------+
//| Параметры отрисовки уровней                |
//+--------------------------------------------+
//---- отрисовка уровней в виде линий
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- ввыбор цветов уровней
#property indicator_color2  clrLimeGreen
#property indicator_color3  clrRed
//---- уровни - штрихпунктирные кривые
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- толщина уровней равна 3
#property indicator_width2  3
#property indicator_width3  3
//---- отображение меток уровней
#property indicator_label2  "Rj_SlidingRangeRj_Digit Up Line"
#property indicator_label3  "Rj_SlidingRangeRj_Digit Down Line"
//+--------------------------------------------+
//| Параметры отрисовки свечей                 |
//+--------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type4   DRAW_COLOR_CANDLES
#property indicator_color4   clrDeepPink,clrPurple,clrTeal,clrDarkTurquoise
//---- отображение метки индикатора
#property indicator_label4  "Rj_SlidingRangeRj_Digit_Open;Rj_SlidingRangeRj_Digit_High;Rj_SlidingRangeRj_Digit_Low;Rj_SlidingRangeRj_Digit_Close"
//+--------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА              |
//+--------------------------------------------+
input uint UpCalcPeriodRange=5; //Период поиска для хая
input uint UpCalcPeriodShift=0; //Период сдвига для хая  
input uint UpDigit=2;           //количество разрядов округления для хая
//----                       
input uint DnCalcPeriodRange=5; //Период поиска для лоу
input uint DnCalcPeriodShift=0; //Период сдвига для лоу      
input uint DnDigit=2;           //количество разрядов округления для лоу
//----
input int Shift=0;              //Сдвиг индикатора по горизонтали в барах
input uint NumberofBar=1;       //Номер бара для подачи сигнала
input bool SoundON=true;        //Разрешение алерта
input uint NumberofAlerts=2;    //Количество алертов
input bool EMailON=false;       //Разрешение почтовой отправки сигнала
input bool PushON=false;        //Разрешение отправки сигнала на мобильный
//+--------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[],ExtHighBuffer[],ExtLowBuffer[],ExtCloseBuffer[],ExtColorBuffer[];
double UpIndBuffer[],DnIndBuffer[],UpLineBuffer[],DnLineBuffer[];
double UpPointPow10,DnPointPow10;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+    
//| Rj_SlidingRange Channel indicator initialization function        | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация констант
   min_rates_total=int(MathMax(UpCalcPeriodRange+UpCalcPeriodShift,DnCalcPeriodRange+DnCalcPeriodShift))+1;
   UpPointPow10=_Point*MathPow(10,UpDigit);
   DnPointPow10=_Point*MathPow(10,DnDigit);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,UpIndBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DnIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(2,UpLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,DnLineBuffer,INDICATOR_DATA);
//---- установка позиции, с которой начинается линий канала
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(4,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(8,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- установка позиции, с которой начинается линий канала
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига индикатора по горизонтали
   //PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);
   ArraySetAsSeries(UpIndBuffer,true);
   ArraySetAsSeries(DnIndBuffer,true);
   ArraySetAsSeries(UpLineBuffer,true);
   ArraySetAsSeries(DnLineBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Rj_SlidingRangeRj_Digit_System_Alert(",UpCalcPeriodRange,",",UpCalcPeriodShift,",",DnCalcPeriodRange,",",DnCalcPeriodShift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Rj_SlidingRange Channel iteration function                       | 
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

//---- Объявление целых переменных
   int limit,bar,iii,end;
   double b;

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated;  // стартовый номер для расчёта только новых баров

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      iii=bar+int(UpCalcPeriodRange+UpCalcPeriodShift)-1;
      b=0.0;
      end=bar+int(UpCalcPeriodShift);
      while(iii>=end)
        {
         b+=high[ArrayMaximum(high,iii,UpCalcPeriodRange)];
         iii--;
        }
      b/=UpCalcPeriodRange;
      UpLineBuffer[bar]=UpIndBuffer[bar]=UpPointPow10*MathRound(b/UpPointPow10);
        
      iii=bar+int(DnCalcPeriodRange+DnCalcPeriodShift)-1;
      b=0.0;
      end=bar+int(DnCalcPeriodShift);
      while(iii>=end)
        {
         b+=low[ArrayMinimum(low,iii,DnCalcPeriodRange)];
         iii--;
        }
      b/=DnCalcPeriodRange;       
      DnLineBuffer[bar]=DnIndBuffer[bar]=DnPointPow10*MathRound(b/DnPointPow10);
      //----
      ExtOpenBuffer[bar]=ExtCloseBuffer[bar]=ExtHighBuffer[bar]=ExtLowBuffer[bar]=NULL;
      ExtColorBuffer[bar]=4;
      //----
      if(close[bar]>UpLineBuffer[bar])
        {
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         if(close[bar]>=open[bar]) ExtColorBuffer[bar]=3;
         else ExtColorBuffer[bar]=2;
        }
      //----
      if(close[bar]<DnLineBuffer[bar])
        {
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         if(close[bar]<=open[bar]) ExtColorBuffer[bar]=0;
         else ExtColorBuffer[bar]=1;
        }
     }
//---     
   BuySignal("Rj_SlidingRangeRj_Digit_System_Alert",ExtColorBuffer,rates_total,prev_calculated,close,spread);
   SellSignal("Rj_SlidingRangeRj_Digit_System_Alert",ExtColorBuffer,rates_total,prev_calculated,close,spread);
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
   if((ColorArrow[index]==3 || ColorArrow[index]==2) && (ColorArrow[index1]!=3 && ColorArrow[index1]!=2)) BuySignal=true;
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
   if((ColorArrow[index]==0 || ColorArrow[index]==1) && (ColorArrow[index1]!=0 && ColorArrow[index1]!=1)) SellSignal=true;
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
