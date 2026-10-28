//+------------------------------------------------------------------+
//|                                                      PIPQind.mq5 |
//|                                       Copyright © 2005, emsjoflo | 
//|                                  automaticforec.invisionzone.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, emsjoflo" 
#property link      "automaticforec.invisionzone.com" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов 6
#property indicator_buffers 6 
//---- использовано всего четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type1 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color1 clrLime
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки сигнальной линии
#property indicator_label1  "Buy PIPQind signal"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type2 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color2 clrRed
//---- линия индикатора - сплошная
#property indicator_style2 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2 2
//---- отображение метки сигнальной линии
#property indicator_label2  "Sell PIPQind signal"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора гистограммы  |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде гистограммы
#property indicator_type3   DRAW_COLOR_HISTOGRAM2
//---- в качестве цветов линии индикатора использованы
#property indicator_color3  clrDodgerBlue,clrTomato
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение бычьей метки индикатора
#property indicator_label3  "PIPQind Histogram"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора линии        |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован цвет Indigo
#property indicator_color4  clrIndigo
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width4  2
//---- отображение медвежьей метки индикатора
#property indicator_label4  "PIPQind Line"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double nPips=65;
input bool SendAlert=false;
input bool SendEmail=false;
input int AlertMinutesB4close=5;
input int AlertEveryNMinutes =10;
input double ATRmultiplier=0.45;
input int Shift=0;      // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double UpArrow[];
double DownArrow[];
double BlueBar[],RedBar[],ColorBar[];
double TrStopDots[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,ATR_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   int ATR_Period=14;
   min_rates_total=int(ATR_Period)+3;

//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"PIPQind(",string(nPips),", ",string(Shift),")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpArrow,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(UpArrow,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DownArrow,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(DownArrow,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,BlueBar,INDICATOR_DATA);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(BlueBar,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,RedBar,INDICATOR_DATA);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(RedBar,true);

//---- превращение динамического массива в цветовой буфер
   SetIndexBuffer(4,ColorBar,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ColorBar,true);

//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,TrStopDots,INDICATOR_DATA);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(TrStopDots,true);

//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
//---   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectsDeleteAll(0,"PIPQind_",-1,-1);
   Comment("");
//----
   ChartRedraw(NULL);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//--- объявления локальных переменных 
   int to_copy,limit,bar,i;
   double ATR[];
   datetime alertsent=NULL;
   string MinutesB4Barcloses;
   double cnt=0;
   double stop,atr,atrstop;
   double TrStopLevel=0;
   string name;
   static double PREV;

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(spread,true);
   ArraySetAsSeries(ATR,true);

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1;               // стартовый номер для расчета всех баров
      PREV=close[limit];
     }
   else
     {
      limit=rates_total-prev_calculated;                 // стартовый номер для расчета новых баров
     }
   to_copy=limit+1;
   
//--- копируем вновь появившиеся данные в массив ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      UpArrow[bar]=NULL;
      DownArrow[bar]=NULL;
      BlueBar[bar]=NULL;
      RedBar[bar]=NULL;

      if(close[bar]==PREV)
        {
         TrStopLevel=PREV;
        }
      else
        {
         if(close[bar+1]<=PREV && close[bar]<PREV)
           {
            TrStopLevel=MathMin(PREV,close[bar]+nPips*_Point);
           }
         else
           {
            if(close[bar+1]>=PREV && close[bar]>PREV)
              {
               TrStopLevel=MathMax(PREV,close[bar]-nPips*_Point);
              }
            else
              {
               if(close[bar]>PREV)
                 {
                  TrStopLevel=close[bar]-nPips*_Point;
                 }
               else TrStopLevel=close[bar]+nPips*_Point;
              }
           }
        }
      TrStopDots[bar]=TrStopLevel;
      if(UpArrow[bar] && UpArrow[bar]!=TrStopDots[bar]) UpArrow[bar]=NULL;
      if(DownArrow[bar]!=TrStopDots[bar]) DownArrow[bar]=NULL;
      if(close[bar]>TrStopLevel && (close[bar+1]<PREV || (close[bar+1]<=TrStopDots[bar+1] && close[bar+2]<TrStopDots[bar+2])) && PREV)
        {
         atr=ATR[bar];
         stop=low[ArrayMinimum(low,bar,3)];
         atrstop=NormalizeDouble(TrStopLevel-atr*ATRmultiplier,_Digits);
         if(atrstop>stop) stop=atrstop;

         name="PIPQind_"+TimeToString(time[bar],TIME_MINUTES);
         SetTline(0,name,0,time[bar+2],stop,time[bar],stop,clrDodgerBlue,0,2,DoubleToString(stop,_Digits));
         Comment(stop);
         double Bid=close[bar];
         double Ask=Bid+_Point*spread[bar];
         if((Bid>TrStopDots[0]) && (close[1]<=TrStopDots[1]) && ((TimeCurrent()-time[0])>=(time[0]-time[1]-AlertMinutesB4close*60)) && (TimeCurrent()-alertsent>AlertEveryNMinutes*60))
           {
            MinutesB4Barcloses=TimeToString((time[0]-time[1])-(TimeCurrent()-time[0]),TIME_MINUTES);
            if(SendAlert) Alert("Look for Buying opportunity soon");
            if(SendEmail) SendMail("Possible Buy setup on "+Symbol(),"PIPQind anticpates a Buy signal on "+Symbol()+" in "+MinutesB4Barcloses+" minutes"+" at "+TimeToString(TimeCurrent())+" Bid: "+
               DoubleToString(Bid,_Digits)+" Ask: "+DoubleToString(Ask,_Digits)+" close[0]:"+DoubleToString(close[0],_Digits)+"close[1]: "+DoubleToString(close[1],_Digits)+" TrStopDots[1]: "+
               DoubleToString(TrStopDots[1],_Digits)+" PREV: "+DoubleToString(PREV,_Digits)+" TrStopLevel: "+DoubleToString(TrStopLevel,_Digits)+" TrStopDots[0]: "+DoubleToString(TrStopDots[0],_Digits));
            alertsent=TimeCurrent();
           }
         RedBar[bar]=low[bar];
         BlueBar[bar]=high[bar];
         ColorBar[bar]=0;
         UpArrow[bar]=TrStopLevel;
        }
      if(close[bar]<TrStopLevel && (close[bar+1]>PREV || (close[bar+1]>=TrStopDots[bar+1] && close[bar+2]>=TrStopDots[bar+2])) && PREV)
        {
         atr=ATR[bar];
         stop=high[ArrayMaximum(high,bar,3)];
         atrstop=NormalizeDouble(TrStopLevel+atr*ATRmultiplier,_Digits);
         if(atrstop<stop) stop=atrstop;

         name="PIPQind_"+TimeToString(time[bar],TIME_MINUTES);
         SetTline(0,name,0,time[bar+2],stop,time[bar],stop,clrRed,0,2,DoubleToString(stop,_Digits));
         Comment(stop);

         double Bid=close[bar];
         double Ask=Bid+_Point*spread[bar];

         if((Ask<TrStopDots[0]) && (close[1]>=TrStopDots[1]) && ((TimeCurrent()-time[0])>=(time[0]-time[1]-AlertMinutesB4close*60)) && (TimeCurrent()-alertsent>AlertEveryNMinutes*60))
           {
            MinutesB4Barcloses=TimeToString((time[0]-time[1])-(TimeCurrent()-time[0]),TIME_MINUTES);
            if(SendAlert)Alert("Look for Selling opportunity soon");
            if(SendEmail) SendMail("Possible Sell setup on "+Symbol(),"PIPQind anticipates a sell signal on "+Symbol()+" in "+MinutesB4Barcloses+" minutes "+" at "+TimeToString(TimeCurrent())+" Bid: "+
               DoubleToString(Bid,_Digits)+" Ask: "+DoubleToString(Ask,_Digits)+" close[0]:"+DoubleToString(close[0],_Digits)+"close[1]: "+DoubleToString(close[1],_Digits)+" TrStopDots[1]: "+
               DoubleToString(TrStopDots[1],_Digits)+" PREV: "+DoubleToString(PREV,_Digits)+" TrStopLevel: "+DoubleToString(TrStopLevel,_Digits)+" TrStopDots[0]: "+DoubleToString(TrStopDots[0],_Digits));
            alertsent=TimeCurrent();
           }
         BlueBar[bar]=high[bar];
         RedBar[bar]=low[bar];
         ColorBar[bar]=1;
         DownArrow[bar]=TrStopLevel;
        }
      if(bar) PREV=TrStopLevel;
     }
   i=1;
   if(UpArrow[i]>0 && UpArrow[i]<TrStopDots[i]) UpArrow[i]=NULL;
   if(DownArrow[i]>TrStopDots[i]) DownArrow[i]=NULL;
//----     
   ChartRedraw(NULL);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Создание трендовой линии                                        |
//+------------------------------------------------------------------+
void CreateTline
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время 1 ценового уровня
 double   price1,        // 1 ценовой уровень
 datetime time2,         // время 2 ценового уровня
 double   price2,        // 2 ценовой уровень
 color    Color,         // цвет линии
 int      style,         // стиль линии
 int      width,         // толщина линии
 string   text           // текст
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,false);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка трендовой линии                                   |
//+------------------------------------------------------------------+
void SetTline
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время 1 ценового уровня
 double   price1,        // 1 ценовой уровень
 datetime time2,         // время 2 ценового уровня
 double   price2,        // 2 ценовой уровень
 color    Color,         // цвет линии
 int      style,         // стиль линии
 int      width,         // толщина линии
 string   text           // текст
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+
