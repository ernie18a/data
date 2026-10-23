//+------------------------------------------------------------------+ 
//|                        XDeMarker_Histogram_Vol_Direct_Alerts.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 8
#property indicator_buffers 8 
//---- использовано шесть графических построений
#property indicator_plots   6
//+-----------------------------------------+
//|  объявление констант                    |
//+-----------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------------+
//|  Параметры отрисовки максимума          |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован DeepSkyBlue цвет
#property indicator_color1 clrDeepSkyBlue
//---- линия индикатора - штрих-пунктир
#property indicator_style1  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "XDeMarker_Histogram_Vol Max"
//+-----------------------------------------+
//|  Параметры отрисовки уровня Res         |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован Blue цвет
#property indicator_color2 clrBlue
//---- линия индикатора - штрих-пунктир
#property indicator_style2  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "XDeMarker_Histogram_Vol Res"
//+-----------------------------------------+
//| Параметры отрисовки индикатора DeMarker |
//+-----------------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type3   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов индикатора использованы
#property indicator_color3  clrLime,clrGreen,clrMediumPurple,clrBrown,clrGold
//---- линия индикатора - сплошная
#property indicator_style3 STYLE_SOLID
//---- толщина линии индикатора равна 4
#property indicator_width3 4
//---- отображение метки индикатора
#property indicator_label3  "XDeMarker_Histogram_Vol"
//+-----------------------------------------+
//|  Параметры отрисовки уровня Supr        |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован Blue цвет
#property indicator_color4 clrBlue
//---- линия индикатора - штрих-пунктир
#property indicator_style4  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width4  1
//---- отображение метки индикатора
#property indicator_label4  "XDeMarker_Histogram_Vol Supr"
//+-----------------------------------------+
//|  Параметры отрисовки минимума           |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type5   DRAW_LINE
//---- в качестве цвета линии индикатора использован DeepSkyBlue цвет
#property indicator_color5 clrDeepSkyBlue
//---- линия индикатора - штрих-пунктир
#property indicator_style5  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width5  1
//---- отображение метки индикатора
#property indicator_label5  "XDeMarker_Histogram_Vol Min"
//+-----------------------------------------+
//|  Параметры отрисовки значков            |
//+-----------------------------------------+
//---- отрисовка индикатора 6 в виде цветного символа
#property indicator_type6   DRAW_COLOR_ARROW
//---- в качестве цветов индикатора использованы
#property indicator_color6  clrDeepSkyBlue,clrDeepPink
//---- толщина линии индикатора 6 равна 1
#property indicator_width6  1
//---- отображение метки индикатора
#property indicator_label6  "XDeMarker_Histogram_Vol_Direct"
//+-----------------------------------------+
//|  Описание класса CXMA                   |
//+-----------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+-----------------------------------------+
//|  объявление перечислений                |
//+-----------------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+-----------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА           |
//+-----------------------------------------+
input uint                DeMarkerPeriod=14;        // период индикатора
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;   // объём 
input int                 HighLevel2=+20;           // уровень перекупленности 2
input int                 HighLevel1=+15;           // уровень перекупленности 1
input int                 LowLevel1=-15;            // уровень перепроданности 1
input int                 LowLevel2=-20;            // уровень перепроданности 2
input Smooth_Method       MA_SMethod=MODE_SMA_;     // Метод усреднения
input uint                MA_Length=12;             // Глубина сглаживания                    
input int                 MA_Phase=15;              // параметр первого сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input int                 Shift=0;                  // Сдвиг индикатора по горизонтали в барах
input uint NumberofBar=1;          // Номер бара для подачи сигнала
input bool SoundON=true;           // Разрешение алерта
input uint NumberofAlerts=2;       // Количество алертов
input bool EMailON=false;          // Разрешение почтовой отправки сигнала
input bool PushON=false;           // Разрешение отправки сигнала на мобильный
//+-----------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
double UpIndBuffer[],DnIndBuffer[];
double MaxIndBuffer[],MinIndBuffer[];
double DirectBuffer[],ColorDirectBuffer[];
//---- Объявление целых переменных для хендлов индикаторов
int DeMarker_Handle;
//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total,min_rates_1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=int(DeMarkerPeriod);
   min_rates_total=min_rates_1+GetStartBars(MA_SMethod,MA_Length,MA_Phase);
//---- получение хендла индикатора iDeMarker
   DeMarker_Handle=iDeMarker(NULL,0,DeMarkerPeriod);
   if(DeMarker_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iDeMarker");
      return(INIT_FAILED);
     }   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,MaxIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(MaxIndBuffer,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpIndBuffer,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,DnIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnIndBuffer,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,MinIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(4,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(MinIndBuffer,true);
   
//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(6,DirectBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикаторапо горизонтали
   PlotIndexSetInteger(5,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(5,PLOT_SHOW_DATA,false);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(5,PLOT_ARROW,171);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DirectBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(7,ColorDirectBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorDirectBuffer,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"XDeMarker_Histogram_Vol_Direct_Alerts("+string(DeMarkerPeriod)+")");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
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
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(DeMarker_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных
   int to_copy,limit,bar,maxbar;
   double vol,xvol;
   
//---- индексация элементов в массивах как в таймсериях 
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(Open,true); 
   ArraySetAsSeries(High,true); 
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Spread,true); 
   
   maxbar=rates_total-min_rates_1-1;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=maxbar; // стартовый номер для расчета всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
   to_copy=limit+1;
   
//---- индексация элементов в массивах как в таймсериях  
   if(VolumeType==VOLUME_TICK) ArraySetAsSeries(Tick_Volume,true);
   else ArraySetAsSeries(Volume,true);

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(DeMarker_Handle,0,0,to_copy,IndBuffer)<=0) return(RESET);

//---- основной цикл раскраски индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      IndBuffer[bar]*=100; //домножаем значение DeMarker на 100 для удобства восприятия
      IndBuffer[bar]-=50; //сдвигаем значение DeMarker на 50 вниз (делаем индикатор симметричным относительно оси времени)  
      if(VolumeType==VOLUME_TICK) vol=double(Tick_Volume[bar]);
      else vol=double(Volume[bar]);
      IndBuffer[bar]*=vol; //домножаем значение DeMarker на объём
      IndBuffer[bar]=XMA1.XMASeries(maxbar,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,IndBuffer[bar],bar,true); //усредняем результат
      DirectBuffer[bar]=IndBuffer[bar];   
      xvol=XMA2.XMASeries(maxbar,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,vol,bar,true);  //усредняем объём  
      MaxIndBuffer[bar]=HighLevel2*xvol;
      UpIndBuffer[bar]=HighLevel1*xvol;
      DnIndBuffer[bar]=LowLevel1*xvol;
      MinIndBuffer[bar]=LowLevel2*xvol;
      //---- раскраска гистограммы
      int clr=2.0;
      if(IndBuffer[bar]>MaxIndBuffer[bar]) clr=0.0;
      else if(IndBuffer[bar]>UpIndBuffer[bar]) clr=1.0;
      else if(IndBuffer[bar]<MinIndBuffer[bar]) clr=4.0;
      else if(IndBuffer[bar]<DnIndBuffer[bar]) clr=3.0;
      ColorIndBuffer[bar]=clr;
      //---- раскраска значков
      if(IndBuffer[bar]>IndBuffer[bar+1]) clr=0.0;
      else if(IndBuffer[bar]<IndBuffer[bar+1]) clr=1.0;
      else clr=int(ColorDirectBuffer[bar+1]);
      ColorDirectBuffer[bar]=clr;
     }
//---     
   BuySignal("XDeMarker_Histogram_Vol_Direct_Alerts",rates_total,prev_calculated,Close,Spread);
   SellSignal("XDeMarker_Histogram_Vol_Direct_Alerts",rates_total,prev_calculated,Close,Spread);
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
    if(ColorDirectBuffer[index1]!=0 && ColorDirectBuffer[index]==0)
     {
      BuySignal=true;
      SignalText=SignalText+"Изменение направления движения гистограммы! ";
     } 
    //--- 
    if(ColorIndBuffer[index1]>1 && ColorIndBuffer[index]==1)
     {
      BuySignal=true;
      SignalText=SignalText+"Пробой уровня перекупленности 1! ";
     } 
    //--- 
    if(ColorIndBuffer[index1]>0 && ColorIndBuffer[index]==0)
     {
      BuySignal=true;
      SignalText=SignalText+"Пробой уровня перекупленности 2! ";
     } 
    //--- 
    if(ColorIndBuffer[index1]==3 && ColorIndBuffer[index]<3)
     {
      BuySignal=true;
      SignalText=SignalText+"Выход из зоны перепроданности 1! ";
     }
   //--- 
    if(ColorIndBuffer[index1]==4 && ColorIndBuffer[index]<4)
     {
      BuySignal=true;
      SignalText=SignalText+"Выход из зоны перепроданности 2! ";
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
    if(ColorDirectBuffer[index1]!=1 && ColorDirectBuffer[index]==1)
     {
      SellSignal=true;
      SignalText=SignalText+"Изменение направления движения гистограммы! ";
     } 
    //--- 
    if(ColorIndBuffer[index1]<3 && ColorIndBuffer[index]==3)
     {
      SellSignal=true;
      SignalText=SignalText+"Пробой уровня пепроданности 1! ";
     } 
    //--- 
    if(ColorIndBuffer[index1]<4 && ColorIndBuffer[index]==4)
     {
      SellSignal=true;
      SignalText=SignalText+"Пробой уровня пепроданности 2! ";
     } 
    //--- 
    if(ColorIndBuffer[index1]==1 && ColorIndBuffer[index]>1)
     {
      SellSignal=true;
      SignalText=SignalText+"Выход из зоны перекупленности 1! ";
     }
   //--- 
    if(ColorIndBuffer[index1]==0 && ColorIndBuffer[index]>0)
     {
      SellSignal=true;
      SignalText=SignalText+"Выход из зоны перекупленности 2! ";
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
