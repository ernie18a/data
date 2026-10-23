//+------------------------------------------------------------------+
//|                                   Float_Pivot_Smoothed_Digit.mq5 |
//|                                 Copyright © 2006, Nick A. Zhilin |
//|                                              rebus@dialup.etr.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Nick A. Zhilin"
#property link      "rebus@dialup.etr.ru"
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано семь буферов
#property indicator_buffers 7
//--- использовано пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован PaleGreen
#property indicator_color1  C'241,254,241'
//---- отображение метки индикатора
#property indicator_label1  "Upper Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки верхней границы         |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован DodgerBlue
#property indicator_color2  clrDodgerBlue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение бычей метки индикатора
#property indicator_label2  "Upper FloatPivot"
//+----------------------------------------------+
//|  Параметры отрисовки средней линии           |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован SlateBlue
#property indicator_color3  clrSlateBlue
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение медвежьей метки индикатора
#property indicator_label3  "Middle FloatPivot"
//+----------------------------------------------+
//|  Параметры отрисовки нижней границы          |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован DeepPink
#property indicator_color4  clrDeepPink
//---- линия индикатора 4 - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Lower FloatPivot"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type5   DRAW_FILLING
//---- в качестве цвета облака использован C'253,238,253'
#property indicator_color5  C'253,238,253'
//---- отображение метки индикатора
#property indicator_label5  "Lower Cloud"
//+----------------------------------------------+
//|  Описание классов усреднений                 |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMAL,XMAH,XMAP;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
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
   PRICE_TRENDFOLLOW1_,  //PRICE_TRENDFOLLOW0_2
   PRICE_DEMARK_         //Demark Price 
  };
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input string  SirName="Float_Pivot_Digit";         //Первая часть имени графических объектов
input int IPeriod=100;                             //Период поиска экстремумов
input ENUM_APPLIED_PRICE_ IPC=PRICE_MEDIAN_;       //ценовая константа
input Smooth_Method     HMA_Method=MODE_SMA_;      //Метод сглаживания
input uint              HLength=12;                //Глубина  сглаживания                    
input int               HPhase=100;                //Параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0;                                 //сдвиг индикатора по горизонтали в барах
input uint Digit=2;                                //количество разрядов округления
input bool ShowPrice=true;                         //показывать ценовые метки
input color Upper_color=clrTeal;                   //Цвет верхней ценовой метки
input color Middle_color=clrBlue;                  //Цвет средней ценовой метки
input color Lower_color=clrMagenta;                //Цвет нижней ценовой метки
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtUp1Buffer[];
double ExtUp2Buffer[];
double ExtABuffer[];
double ExtBBuffer[];
double ExtCBuffer[];
double ExtDn1Buffer[];
double ExtDn2Buffer[];
//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
//---- Объявление стрингов для текстовых меток
string upper_name,middle_name,lower_name;
double PointPow10;
//---- объявление глобальных переменных
int Count[];
double XHigh[],XLow[];
//+------------------------------------------------------------------+
//|  Пересчет позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+    
//| Float_Pivot Channel indicator initialization function            | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=GetStartBars(HMA_Method,HLength,HPhase)+1;
   min_rates_total+=int(MathMax(3,IPeriod));
//---- Инициализация стрингов
   upper_name=SirName+" upper text lable";
   middle_name=SirName+" middle text lable";
   lower_name=SirName+" lower text lable";
//---- инициализация переменных         
   PointPow10=_Point*MathPow(10,Digit);

//---- распределение памяти под массивы переменных  
   ArrayResize(Count,IPeriod);
   ArrayResize(XHigh,IPeriod);
   ArrayResize(XLow,IPeriod);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Count,true);
   ArraySetAsSeries(XHigh,true);
   ArraySetAsSeries(XLow,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtUp1Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtUp2Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,ExtABuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,ExtBBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,ExtCBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,ExtDn1Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,ExtDn2Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Float_Pivot_Smoothed_Digit(",IPeriod,",",HLength,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,upper_name);
   ObjectDelete(0,middle_name);
   ObjectDelete(0,lower_name);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| Float_Pivot Channel iteration function                           | 
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
   int first,bar;
//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated==0) // проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров
      ArrayInitialize(Count,NULL);
      ArrayInitialize(XHigh,NULL);
      ArrayInitialize(XLow,NULL);
     }
   else
     {
      first=prev_calculated-1;// стартовый номер для расчёта новых баров
     }

//---- Основной цикл расчёта канала
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Три вызова функции XMASeries.  
      double pivot=XMAP.XMASeries(0,prev_calculated,rates_total,HMA_Method,HPhase,HLength,PriceSeries(IPC,bar,open,low,high,close),bar,false);
      XHigh[Count[0]]=XMAH.XMASeries(0,prev_calculated,rates_total,HMA_Method,HPhase,HLength,high[bar],bar,false);
      XLow[Count[0]]=XMAL.XMASeries(0,prev_calculated,rates_total,HMA_Method,HPhase,HLength,low[bar],bar,false);      
      //----
      double max=XHigh[ArrayMaximum(XHigh,0,IPeriod)];
      double min=XLow[ArrayMinimum(XLow,0,IPeriod)];
      //---- Pivot
      double res=(max+min+pivot)/3;
      //---- (R1 - Pivot) / 2
      ExtABuffer[bar]=ExtUp1Buffer[bar]=PointPow10*MathCeil(((2*res-min)+res)/2/PointPow10);
      ExtCBuffer[bar]=ExtDn2Buffer[bar]=PointPow10*MathFloor((res+(2*res-max))/2/PointPow10);
      ExtBBuffer[bar]=ExtUp2Buffer[bar]=ExtDn1Buffer[bar]=PointPow10*MathRound(res/PointPow10);
      //---- 
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,IPeriod);
     }
//----
   if(ShowPrice)
     {
      int bar0=rates_total-Shift-1;
      datetime time0=time[bar0];
      SetRightPrice(0,upper_name,0,time0,ExtABuffer[bar0],Upper_color);
      SetRightPrice(0,middle_name,0,time0,ExtBBuffer[bar0],Middle_color);
      SetRightPrice(0,lower_name,0,time0,ExtCBuffer[bar0],Lower_color);
     }
//----
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  RightPrice creation                                             |
//+------------------------------------------------------------------+
void CreateRightPrice(long chart_id,// chart ID
                      string   name,              // object name
                      int      nwin,              // window index
                      datetime time,              // price level time
                      double   price,             // price level
                      color    Color              // Text color
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,2);
//----
  }
//+------------------------------------------------------------------+
//|  RightPrice reinstallation                                       |
//+------------------------------------------------------------------+
void SetRightPrice(long chart_id,// chart ID
                   string   name,              // object name
                   int      nwin,              // window index
                   datetime time,              // price level time
                   double   price,             // price level
                   color    Color              // Text color
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color);
   else ObjectMove(chart_id,name,0,time,price);
//----
  }
//+------------------------------------------------------------------+
