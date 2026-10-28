//+------===------------------------------------------------------------+ 
//|                               Color_PEMA_Envelopes_Digit_System.mq5 | 
//|                                         Copyright © 2010, Bruno Pio |
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2010, Bruno Pio"
#property link "" 
#property description "Пробойная система с использованием канала Color_PEMA_Envelopes_Digit"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов
#property indicator_buffers 11 
//---- использовано всего четыре графических построения
#property indicator_plots   4
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrLavender
//---- отображение метки индикатора
#property indicator_label1  "PEMA_Envelopes_Digit Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type2   DRAW_COLOR_LINE
//---- в качестве цветов линии использованы
#property indicator_color2  clrDeepPink,clrTeal
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width2  3
//---- отображение метки индикатора
#property indicator_label2  "PEMA_Envelopes_Digit Upper"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type3   DRAW_COLOR_LINE
//---- в качестве цветов линии использованы
#property indicator_color3  clrDeepPink,clrTeal
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width3  3
//---- отображение метки индикатора
#property indicator_label3  "PEMA_Envelopes_Digit Lower"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 4            |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветных свеч
#property indicator_type4 DRAW_COLOR_CANDLES
//---- в качестве цветов индикатора использованы
#property indicator_color4 clrYellow,clrDarkOrange,clrGray,clrLightSeaGreen,clrAqua
//---- линия индикатора - сплошная
#property indicator_style4 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width4 2
//---- отображение метки индикатора
#property indicator_label4 "PEMA_Envelopes_Digit_BARS"
//+----------------------------------------------+
//|  Описание класса CMoving_Average             |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CMoving_Average из файла SmoothAlgorithms.mqh
CMoving_Average EMA[8];
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
input string  SirName="PEMA_Envelopes_Digit"; // Первая часть имени графических объектов
input double EmaLength=50.01;             // глубина сглаживания                   
input Applied_price_ IPC=PRICE_CLOSE_;    // ценовая константа
input double    Deviation=0.1;            // Deviation
input int Shift=1;                        // сдвиг индикатора по горизонтали в барах
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
double ExtOpenBuffer[],ExtHighBuffer[],ExtLowBuffer[],ExtCloseBuffer[],ExtColorBuffer[];
double dPriceShift,PointPow10;
//---- Объявление стрингов для текстовых меток
string Up_Price_name,Dn_Price_name;
//---- Объявление глобальных переменных
int min_rates_total;
//+------------------------------------------------------------------+    
//| PEMA indicator initialization function                           | 
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
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,UpLineBuffer,INDICATOR_DATA);   
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorUpLineBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,DnLineBuffer,INDICATOR_DATA);   
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(5,ColorDnLineBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);

   
//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(6,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(8,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(9,ExtCloseBuffer,INDICATOR_DATA);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(10,ExtColorBuffer,INDICATOR_COLOR_INDEX);
   
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);
//---- осуществление сдвига индикатора 3 по горизонтали на Shift
   //PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
   
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"PEMA_Envelopes_Digit_System( Length = ",EmaLength,")");
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
//| PEMA iteration function                                          | 
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
   double res[9],PEMA,trend;

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
      res[6]=EMA[5].EMASeries(5,prev_calculated,rates_total,EmaLength,res[5],bar,false); 
      res[7]=EMA[6].EMASeries(6,prev_calculated,rates_total,EmaLength,res[6],bar,false); 
      res[8]=EMA[7].EMASeries(7,prev_calculated,rates_total,EmaLength,res[7],bar,false);    
      PEMA=8*res[1]-28*res[2]+56*res[3]-70*res[4]+56*res[5]-28*res[6]+8*res[7]-res[8];
      PEMA=PointPow10*MathRound(PEMA/PointPow10);
      UpLineBuffer[bar]=UpBuffer[bar]=(1+Deviation/100.0)*PEMA+dPriceShift;  
      DnLineBuffer[bar]=DnBuffer[bar]=(1-Deviation/100.0)*PEMA+dPriceShift;
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
     
//---- корректировка значения переменной first
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first+=int(Shift); // стартовый номер для расчета всех баров     
//---- Основной цикл раскраски баров индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int clr=2;
      ExtOpenBuffer[bar]=NULL;
      ExtCloseBuffer[bar]=NULL;
      ExtHighBuffer[bar]=NULL;
      ExtLowBuffer[bar]=NULL;

      if(close[bar]>UpBuffer[bar-Shift])
        {
         if(open[bar]<=close[bar]) clr=4;
         else clr=3;
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
        }

      if(close[bar]<DnBuffer[bar-Shift])
        {
         if(open[bar]>close[bar]) clr=0;
         else clr=1;
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
        }

      ExtColorBuffer[bar]=clr;
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
