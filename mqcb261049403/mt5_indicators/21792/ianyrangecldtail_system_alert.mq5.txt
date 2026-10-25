//+----------------------------------------------------------------------------+
//|                                        i-AnyRangeCldTail_System_Alert.mq5  |
//|                                  Copyright © 2006, Ким Игорь В. aka KimIV  |
//|                                                       http://www.kimiv.ru  |
//+----------------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2006, Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"
//---- номер версии индикатора
#property version   "1.10"
//---- описание индикатора
#property description "Индикатор диапазонов произвольных временных интервалов"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано тринадцать буферов
#property indicator_buffers 13
//---- использовано семь графических построений
#property indicator_plots   7
//+----------------------------------------------+
//| Параметры отрисовки облака 1                 |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет Lavender
#property indicator_color1 clrLavender
//---- отображение метки индикатора
#property indicator_label1  "i-AnyRange"
//+----------------------------------------------+
//| Параметры отрисовки верхней линии            |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован синий цвет
#property indicator_color2  clrBlue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 2 равна 3
#property indicator_width2  3
//---- отображение бычей метки индикатора
#property indicator_label2  "Upper Zone"
//+----------------------------------------------+
//| Параметры отрисовки нижней линии             |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color3  clrRed
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 3
#property indicator_width3  3
//---- отображение медвежьей метки индикатора
#property indicator_label3  "Lower Zone"
//+----------------------------------------------+
//| Параметры отрисовки облака 2                 |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type4   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет LavenderBlush
#property indicator_color4 clrLavenderBlush
//---- отображение метки индикатора
#property indicator_label4  "i-AnyRange tail"
//+----------------------------------------------+
//| Параметры отрисовки верхней линии            |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде линии
#property indicator_type5   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован синий цвет
#property indicator_color5  clrBlue
//---- линия индикатора 5 - штрих-пунктир
#property indicator_style5  STYLE_DASHDOTDOT
//---- толщина линии индикатора 5 равна 1
#property indicator_width5  1
//---- отображение бычей метки индикатора
#property indicator_label5  "Upper Zone  tail"
//+----------------------------------------------+
//| Параметры отрисовки нижней линии             |
//+----------------------------------------------+
//---- отрисовка индикатора 6 в виде линии
#property indicator_type6   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color6  clrRed
//---- линия индикатора 6 - штрих-пунктир
#property indicator_style6  STYLE_DASHDOTDOT
//---- толщина линии индикатора 6 равна 1
#property indicator_width6  1
//---- отображение медвежьей метки индикатора
#property indicator_label6  "Lower Zone  tail"
//+--------------------------------------------+
//| Параметры отрисовки свечей                 |
//+--------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type7   DRAW_COLOR_CANDLES
#property indicator_color7   clrDeepPink,clrPurple,clrTeal,clrDarkTurquoise
//---- отображение метки индикатора
#property indicator_label7  "i-AnyRange_Open;i-AnyRange_High;i-AnyRange_Low;i-AnyRange_Close"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input string Time1 = "02:00";   // Временная точка 1
input string Time2 = "07:00";   // Временная точка 2
input uint   nDays = 8;         // Количество дней обсчёта (0-все)
input int    Shift=0;           // сдвиг индикатора по горизонтали в барах
input uint NumberofBar=1;       // Номер бара для подачи сигнала
input bool SoundON=true;        // Разрешение алерта
input uint NumberofAlerts=2;    // Количество алертов
input bool EMailON=false;       // Разрешение почтовой отправки сигнала
input bool PushON=false;        // Разрешение отправки сигнала на мобильный
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double Up0Buffer[],Dn0Buffer[],Up1Buffer[],Dn1Buffer[];
double Up2Buffer[],Dn2Buffer[],Up3Buffer[],Dn3Buffer[];
double ExtOpenBuffer[],ExtHighBuffer[],ExtLowBuffer[],ExtCloseBuffer[],ExtColorBuffer[];

//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,Max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(24*60*60*nDays/PeriodSeconds()+1);
   Max=int(nDays*1440*60/PeriodSeconds());

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,Up0Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
//PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Up0Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,Dn0Buffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Dn0Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,Up1Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Up1Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,Dn1Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Dn1Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,Up2Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
//PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Up2Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,Dn2Buffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Dn2Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(6,Up3Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Up3Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(7,Dn3Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(5,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Dn3Buffer,true);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(8,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(9,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(10,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(11,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(12,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- установка позиции, с которой начинается линий канала
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,NULL);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(6,PLOT_SHIFT,Shift);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(6,PLOT_SHIFT,Shift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"i-AnyRangeCldTail_System(",Time1,", ",Time2,", ",nDays,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----   
  }
//+------------------------------------------------------------------+
//| iBarShift() function                                             |
//+------------------------------------------------------------------+
int iBarShift(string symbol,ENUM_TIMEFRAMES timeframe,datetime time)

// iBarShift(symbol, timeframe, time)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----+
   if(time<0) return(-1);

   datetime Arr[],time1;

   time1=(datetime) SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE);
   if(time>=time1) return(0);

   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
     {
      int size=ArraySize(Arr);
      return(size-1);
     }
   else return(-1);
//----+
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка периода графика
   if(Period()>PERIOD_H1)
     {
      Comment("Индикатору i-AnyRange нужен ТФ младше H4!");
      return(RESET);
     }
   else Comment("");

//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   double up=NULL,dn=NULL;
   int    bar,limit,kd=0,nb1=0,nb2=0,nd=0,rates_10;
   string sdt;

   rates_10=rates_total-10;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(nDays==0) limit=rates_10;
   else limit=Max;
   limit=MathMin(rates_10,limit);

//---- осуществление сдвига начала отсчёта отрисовки индикаторов
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-limit);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,rates_total-limit);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,rates_total-limit);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,rates_total-limit);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,rates_total-limit);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,rates_total-limit);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,rates_total-limit);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

//---- основной цикл обнуления индикаторов 1, 2, 3
   for(bar=0; bar<limit && !IsStopped(); bar++)
     {
      Up0Buffer[bar]=NULL;
      Dn0Buffer[bar]=NULL;
      Up1Buffer[bar]=EMPTY_VALUE;
      Dn1Buffer[bar]=EMPTY_VALUE;
     }

//---- основной цикл расчёта индикаторов 1, 2, 3
   for(bar=0; bar<limit && !IsStopped(); bar++)
     {
      Up1Buffer[bar]=EMPTY_VALUE;
      Dn1Buffer[bar]=EMPTY_VALUE;
      MqlDateTime tm;
      TimeToStruct(time[bar],tm);

      if(nd!=tm.day)
        {
         nd=tm.day;
         kd++;
         if(kd>int(nDays) && nDays) break;

         sdt=TimeToString(time[bar],TIME_DATE);

         nb1=iBarShift(NULL, 0, StringToTime(sdt+" "+Time1));
         nb2=iBarShift(NULL, 0, StringToTime(sdt+" "+Time2));

         if(nb1>nb2+1)
           {
            up=high[ArrayMaximum(high,nb2+1,nb1-nb2)];
            dn=low[ArrayMinimum(low,nb2+1,nb1-nb2)];
           }

         if(nb2>nb1+1)
           {
            up=high[ArrayMaximum(high,nb1+1,nb2-nb1)];
            dn=low[ArrayMinimum(low,nb1+1,nb2-nb1)];
           }
        }
      if((nb1>=bar && bar>nb2) || (nb2>=bar && bar>nb1))
        {
         Up1Buffer[bar]=up;
         Dn1Buffer[bar]=dn;
         Up0Buffer[bar]=up;
         Dn0Buffer[bar]=dn;
        }
      else
        {
         Up1Buffer[bar]=EMPTY_VALUE;
         Dn1Buffer[bar]=EMPTY_VALUE;
        }
     }

//---- основной цикл обнуления облака 1
   for(bar=0; bar<limit && !IsStopped(); bar++)
     {
      if(Up1Buffer[bar]==EMPTY_VALUE && Dn1Buffer[bar]==EMPTY_VALUE)
        {
         Up0Buffer[bar]=NULL;
         Dn0Buffer[bar]=NULL;
        }
     }

//----
   up=dn=EMPTY_VALUE;
//---- основной цикл расчёта индикаторов 4, 5, 6
   for(bar=limit-1; bar>=0 && !IsStopped(); bar--)
     {
      Up2Buffer[bar]=NULL;
      Dn2Buffer[bar]=NULL;
      Up3Buffer[bar]=EMPTY_VALUE;
      Dn3Buffer[bar]=EMPTY_VALUE;

      if(Up0Buffer[bar])
        {
         up=Up0Buffer[bar];
         dn=Dn0Buffer[bar];
        }
      else
        {
         Up2Buffer[bar]=Up3Buffer[bar]=up;
         Dn2Buffer[bar]=Dn3Buffer[bar]=dn;
         int bar1=bar+1;
         if(Up0Buffer[bar1])
           {
            Up2Buffer[bar1]=Up3Buffer[bar1]=up;
            Dn2Buffer[bar1]=Dn3Buffer[bar1]=dn;
           }
        }
     }
//---- основной цикл расчёта индикаторов 7
   for(bar=limit-1; bar>=0 && !IsStopped(); bar--)
     {
      ExtOpenBuffer[bar]=ExtCloseBuffer[bar]=ExtHighBuffer[bar]=ExtLowBuffer[bar]=NULL;
      ExtColorBuffer[bar]=4;
      //----
      if(Up2Buffer[bar] && close[bar]>Up2Buffer[bar])
        {
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         if(close[bar]>=open[bar]) ExtColorBuffer[bar]=3;
         else ExtColorBuffer[bar]=2;
        }
      //----
      if(Dn2Buffer[bar] && close[bar]<Dn2Buffer[bar])
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
   BuySignal("i-AnyRangeCldTail_System_Alert",ExtColorBuffer,rates_total,prev_calculated,close,spread);
   SellSignal("i-AnyRangeCldTail_System_Alert",ExtColorBuffer,rates_total,prev_calculated,close,spread);
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
   if(ColorArrow[index]!=4 && ColorArrow[index]>1 && (ColorArrow[index1]<2 || ColorArrow[index1]==4)) BuySignal=true;
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
   if(ColorArrow[index]<2 && ColorArrow[index1]>1) SellSignal=true;
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
