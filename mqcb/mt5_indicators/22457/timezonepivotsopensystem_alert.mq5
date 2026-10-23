//+----------------------------------------------------------------------------+
//|                                        TimeZonePivotsOpenSystem_Alert.mq5  |
//|                                                        Copyright © 2005,   |
//|                                                                            |
//+----------------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2005, "
#property link      ""
//---- номер версии индикатора
#property version   "1.00"
//---- описание индикатора
#property description ""
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано девять буферов
#property indicator_buffers 9
//---- использовано четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//| Параметры отрисовки облака                   |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет Lavender
#property indicator_color1 clrLavender
//---- отображение метки индикатора
#property indicator_label1  "TimeZonePivots"
//+----------------------------------------------+
//| Параметры отрисовки верхней линии            |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован Blue цвет
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
//---- в качестве цвета медвежьей линии индикатора использован MediumOrchid цвет
#property indicator_color3  clrMediumOrchid
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 3
#property indicator_width3  3
//---- отображение медвежьей метки индикатора
#property indicator_label3  "Lower Zone"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type4   DRAW_COLOR_CANDLES
#property indicator_color4   clrLimeGreen,clrTeal,clrGray,clrPurple,clrDeepPink
//---- отображение метки индикатора
#property indicator_label4  "TimeZonePivotsOpenSystem Open;TimeZonePivotsOpenSystem High;TimeZonePivotsOpenSystem Low;TimeZonePivotsOpenSystem Close"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  Объявление перечисления часов суток         |
//+----------------------------------------------+
enum HOURS
  {
   ENUM_HOUR_0=0,   //0
   ENUM_HOUR_1,     //1
   ENUM_HOUR_2,     //2
   ENUM_HOUR_3,     //3
   ENUM_HOUR_4,     //4
   ENUM_HOUR_5,     //5
   ENUM_HOUR_6,     //6
   ENUM_HOUR_7,     //7
   ENUM_HOUR_8,     //8
   ENUM_HOUR_9,     //9
   ENUM_HOUR_10,     //10
   ENUM_HOUR_11,     //11   
   ENUM_HOUR_12,     //12
   ENUM_HOUR_13,     //13
   ENUM_HOUR_14,     //14
   ENUM_HOUR_15,     //15
   ENUM_HOUR_16,     //16
   ENUM_HOUR_17,     //17
   ENUM_HOUR_18,     //18
   ENUM_HOUR_19,     //19
   ENUM_HOUR_20,     //20
   ENUM_HOUR_21,     //21  
   ENUM_HOUR_22,     //22
   ENUM_HOUR_23      //23    
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input HOURS  StartH=ENUM_HOUR_0;// Старт расчёта канала (Часы)
input uint Offset=100;          // ширина канала в пунктах
input uint NumberofBar=1;       // Номер бара для подачи сигнала
input bool SoundON=true;        // Разрешение алерта
input uint NumberofAlerts=2;    // Количество алертов
input bool EMailON=false;       // Разрешение почтовой отправки сигнала
input bool PushON=false;        // Разрешение отправки сигнала на мобильный
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[];
double DnBuffer[];
double Up0Buffer[];
double Dn0Buffer[];
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=4;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,Up0Buffer,INDICATOR_DATA);
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
   SetIndexBuffer(2,UpBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,DnBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(4,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(8,ExtColorBuffer,INDICATOR_COLOR_INDEX);

//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"TimeZonePivotsOpenSystem_Alert(",EnumToString(StartH),", ",Offset,")");
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
      Comment("Индикатору TimeZonePivotsOpenSystem_Alert нужен ТФ младше H2!");
      return(RESET);
     }
   else Comment("");
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   static double Last_open;
   static int Last_day,Last_hour,Last_bar;
   int bar,limit;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
      Last_open=NULL;
      Last_day=-1;
      Last_hour=-1;
      Last_bar=0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(spread,true);

//---- основной цикл расчёта индикатора по ценам открытия
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtOpenBuffer[bar]=ExtHighBuffer[bar]=ExtLowBuffer[bar]=ExtCloseBuffer[bar]=NULL;
      ExtColorBuffer[bar]=2;
      MqlDateTime tm;
      TimeToStruct(time[bar],tm);

      if(Last_day!=tm.day && tm.hour==StartH)
        {
         Last_day=tm.day;
         Last_hour=tm.hour;
         Last_open=open[bar];
         UpBuffer[bar+1]=DnBuffer[bar+1]=UpBuffer[bar+2]=DnBuffer[bar+2]=NULL;
         Up0Buffer[bar+1]=Dn0Buffer[bar+1]=Up0Buffer[bar+2]=Dn0Buffer[bar+2]=NULL;
        }

      if(Last_day>0)
        {
         UpBuffer[bar]=Up0Buffer[bar]=Last_open+Offset*_Point;
         DnBuffer[bar]=Dn0Buffer[bar]=Last_open-Offset*_Point;

         if(close[bar]>UpBuffer[bar])
           {
            ExtOpenBuffer[bar]=open[bar];
            ExtHighBuffer[bar]=high[bar];
            ExtLowBuffer[bar]=low[bar];
            ExtCloseBuffer[bar]=close[bar];
            if(close[bar]>=open[bar]) ExtColorBuffer[bar]=0;
            else ExtColorBuffer[bar]=1;
           }

         if(close[bar]<DnBuffer[bar])
           {
            ExtOpenBuffer[bar]=open[bar];
            ExtHighBuffer[bar]=high[bar];
            ExtLowBuffer[bar]=low[bar];
            ExtCloseBuffer[bar]=close[bar];
            if(close[bar]<=open[bar]) ExtColorBuffer[bar]=4;
            else ExtColorBuffer[bar]=3;
           }
        }
      else
        {
         UpBuffer[bar]=Up0Buffer[bar]=NULL;
         DnBuffer[bar]=Dn0Buffer[bar]=NULL;
        }
     }
//---     
   BuySignal("TimeZonePivotsOpenSystem_Alert",ExtColorBuffer,rates_total,prev_calculated,close,spread);
   SellSignal("TimeZonePivotsOpenSystem_Alert",ExtColorBuffer,rates_total,prev_calculated,close,spread);
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
   if(ColorArrow[index]<2 && ColorArrow[index1]>1) BuySignal=true;
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
   if(ColorArrow[index]>2 && ColorArrow[index1]<3) SellSignal=true;
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
