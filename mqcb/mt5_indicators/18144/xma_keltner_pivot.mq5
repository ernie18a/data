//+---------------------------------------------------------------------+
//|                                               XMA_Keltner_Pivot.mq5 |
//|                                  Copyright © 2017, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "XMA Keltner Pivot"
//---- номер версии индикатора
#property version   "1.60"
//+------------------------------------------------+ 
//|  Параметры отрисовки индикатора                |
//+------------------------------------------------+ 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots   0
//+------------------------------------------------+ 
//|  Объявление констант                           |
//+------------------------------------------------+
#define INDICATOR_NAME      "XMA_Keltner_Pivot"  // Имя индикатора
#define RESET               0                    // Константа для возврата терминалу команды на пересчет индикатора
//+--------------------------------------------+
//|  Описание классов усреднений               |
//+--------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+--------------------------------------------+
//---- объявление переменных классов CXMA и CStdDeviation из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+--------------------------------------------+
//|  объявление перечислений                   |
//+--------------------------------------------+
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
//+--------------------------------------------+
//|  объявление перечислений                   |
//+--------------------------------------------+
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
//+------------------------------------------------+ 
//|  Входные параметры индикатора                  |
//+------------------------------------------------+ 
input string Symbols_Sirname="XMA_Keltner_Pivot_";  // Название для меток индикатора
input Smooth_Method XMA_Method=MODE_SMA_;      // метод усреднения
input uint XLength=100;                        // глубина  усреднения                    
input int XPhase=15;                           // параметр первого усреднения,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input double Ratio1=1.0;                       // девиация 1
input double Ratio2=3.0;                       // девиация 2
input Applied_price_ IPC=PRICE_CLOSE_;         // ценовая константа
input color Up_Color=clrSkyBlue;               // Цвет верхней полосы индикатора
input color Dn_Color=clrHotPink;               // Цвет нижней полосы индикатора
input uint SignalBar=0;                        // номер бара для получения значений индикатора
input uint SignalLen=40;                       // Длина полос индикатора
//+-----------------------------------+
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1;
//---- объявление глобальных переменных
string UpName,DnName;
int PerSignalLen;
//+------------------------------------------------------------------+
//|  Создание трендовой линии                                        |
//+------------------------------------------------------------------+
void CreateRectangle
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
   ObjectCreate(chart_id,name,OBJ_RECTANGLE,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
   ObjectSetInteger(chart_id,name,OBJPROP_FILL,true);
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка трендовой линии                                   |
//+------------------------------------------------------------------+
void SetRectangle
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
   if(ObjectFind(chart_id,name)==-1) CreateRectangle(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
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
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=GetStartBars(XMA_Method,XLength,XPhase)+1;
   min_rates_total=min_rates_1+int(XLength);

//---- инициализация переменных
   UpName=Symbols_Sirname+"Upper Band";
   DnName=Symbols_Sirname+"Lower Band";
   PerSignalLen=int(SignalLen)*PeriodSeconds();

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
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
   ObjectsDeleteAll(0,Symbols_Sirname,-1,-1);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
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
   if(rates_total<min_rates_total) return(RESET);
//---- Объявление переменных с плавающей точкой  
   double price,line,Keltner,Keltner1,Keltner2;
   static double Up1,Up2,Dn1,Dn2;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=0; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total-int(SignalBar) && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      line=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,price,bar,false);
      Keltner=GetKeltner(XLength,bar,high,low);
      //----
      Keltner1=Ratio1*Keltner;
      Up1=line+Keltner1;
      Dn1=line-Keltner1;
      //----
      Keltner2=Ratio2*Keltner;
      Up2=line+Keltner2;
      Dn2=line-Keltner2;
     }

   int bar0=rates_total-1;
   int bar1=rates_total-int(MathMax(SignalLen-1,0));
   datetime time0=time[bar0]+2*PeriodSeconds();
   datetime time1=time0-PerSignalLen;


//---- Рисуем на графике верхний прямоугольник полосы Боллинджера
   SetRectangle(0,UpName,0,time1,Up1,time0,Up2,Up_Color,STYLE_SOLID,1,UpName);
//---- Рисуем на графике нижний прямоугольник полосы Боллинджера
   SetRectangle(0,DnName,0,time1,Dn1,time0,Dn2,Dn_Color,STYLE_SOLID,1,DnName);
//----
   ChartRedraw(0);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
// вычисление половины ширины канала Келтнера                        |
//+------------------------------------------------------------------+ 
double GetKeltner(int period,int bar,const double &High[],const double &Low[])
  {
//----
   double Resalt,sum=0;
   for(int iii=0; iii<period; iii++)
     {
      int index=MathMax(bar-iii,0);
      sum+=High[index]-Low[index];
     }
   Resalt=sum/period;
   return(Resalt);
//----
  }
//+------------------------------------------------------------------+
