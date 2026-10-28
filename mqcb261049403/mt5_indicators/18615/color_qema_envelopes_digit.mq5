//+------===------------------------------------------------------------+ 
//|                                      Color_QEMA_Envelopes_Digit.mq5 | 
//|                                         Copyright © 2010, Bruno Pio |
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2010, Bruno Pio"
#property link "" 
#property description "Pentuple Exponential Moving Average"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов
#property indicator_buffers 6 
//---- использовано всего три графических построения
#property indicator_plots   3
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrLavender
//---- отображение метки индикатора
#property indicator_label1  "QEMA_Envelopes_Digit Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type2   DRAW_COLOR_LINE
//---- в качестве цветов линии использованы
#property indicator_color2  clrOrange,clrTeal
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width2  3
//---- отображение метки индикатора
#property indicator_label2  "QEMA_Envelopes_Digit Upper"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type3   DRAW_COLOR_LINE
//---- в качестве цветов линии использованы
#property indicator_color3  clrOrange,clrTeal
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width3  3
//---- отображение метки индикатора
#property indicator_label3  "QEMA_Envelopes_Digit Lower"
//+----------------------------------------------+
//|  Описание класса CMoving_Average             |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CMoving_Average из файла SmoothAlgorithms.mqh
CMoving_Average EMA[5];
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input string  SirName="QEMA_Envelopes_Digit"; // Первая часть имени графических объектов
input double EmaLength=50.01;             // глубина сглаживания                   
input Applied_price_ IPC=PRICE_CLOSE_;    // ценовая константа
input double    Deviation=0.1;            // Deviation
input int Shift=0;                        // сдвиг индикатора по горизонтали в барах
input int PriceShift=0;                   // cдвиг индикатора по вертикали в пунктах
input uint Digit=2;                       // количество разрядов округления
input bool ShowPrice=true;                // показывать ценовую метку
//---- цвета ценовых меток
input color  Up_Price_color=clrTeal;         // цвет верхней ценовой метки
input color  Dn_Price_color=clrRed;         // цвет нижней ценовой метки
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpLineBuffer[],ColorUpLineBuffer[];
double DnLineBuffer[],ColorDnLineBuffer[];
double UpBuffer[],DnBuffer[];
double dPriceShift,PointPow10;
//---- Объявление стрингов для текстовых меток
string Up_Price_name,Dn_Price_name;
//---- Объявление глобальных переменных
int min_rates_total;
//+------------------------------------------------------------------+    
//| QEMA indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=6;
   PointPow10=_Point*MathPow(10,Digit);
//---- Инициализация стрингов
   Up_Price_name=SirName+"Up_Price";
   Dn_Price_name=SirName+"Dn_Price";
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,UpLineBuffer,INDICATOR_DATA);   
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorUpLineBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,DnLineBuffer,INDICATOR_DATA);   
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(5,ColorDnLineBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"QEMA_Envelopes_Digit( Length = ",EmaLength,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- завершение инициализации
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,Up_Price_name);
   ObjectDelete(0,Dn_Price_name);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| QEMA iteration function                                          | 
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
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- Объявление локальных переменных
   int first,bar;
   double res[6],QEMA,trend;

   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
   
//---- индексация элементов в массивах не как в таймсериях  
   ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);

//---- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      res[0]=PriceSeries(IPC,bar,open,low,high,close);
      res[1]=EMA[0].EMASeries(0,prev_calculated,rates_total,EmaLength,res[0],bar,false); 
      res[2]=EMA[1].EMASeries(1,prev_calculated,rates_total,EmaLength,res[1],bar,false); 
      res[3]=EMA[2].EMASeries(2,prev_calculated,rates_total,EmaLength,res[2],bar,false); 
      res[4]=EMA[3].EMASeries(3,prev_calculated,rates_total,EmaLength,res[3],bar,false); 
      res[5]=EMA[4].EMASeries(4,prev_calculated,rates_total,EmaLength,res[4],bar,false);    
      QEMA=5*res[1]-10*res[2]+10*res[3]-5*res[4]+res[5];
      QEMA=PointPow10*MathRound(QEMA/PointPow10);
      UpLineBuffer[bar]=UpBuffer[bar]=(1+Deviation/100.0)*QEMA+dPriceShift;  
      DnLineBuffer[bar]=DnBuffer[bar]=(1-Deviation/100.0)*QEMA+dPriceShift;
     }
//---- отображение ценовой метки
   if(ShowPrice)
     {
      int bar0=rates_total-1;
      datetime time0=time[bar0]+1*PeriodSeconds();
      SetRightPrice(0,Up_Price_name,0,time0,UpBuffer[bar0],Up_Price_color);
      SetRightPrice(0,Dn_Price_name,0,time0,DnBuffer[bar0],Dn_Price_color);
     }
//---- корректировка значения переменной first
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first++; // стартовый номер для расчета всех баров

//---- Основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      double clr=ColorUpLineBuffer[bar-1];
      trend=UpLineBuffer[bar]-UpLineBuffer[bar-1];
      if(trend>0) clr=1;
      if(trend<0) clr=0;
      ColorUpLineBuffer[bar]=ColorDnLineBuffer[bar]=clr;
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
