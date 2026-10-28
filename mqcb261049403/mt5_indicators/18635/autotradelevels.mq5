//+------------------------------------------------------------------+ 
//|                                              AutoTradeLevels.mq5 | 
//|                               Copyright © 2017, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.00"
#property description "Индикатор производит подмену всех значков совершённых сделок покупки и продажи"
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
#define RESET               0                   // Константа для возврата терминалу команды на пересчет индикатора
//+------------------------------------------------+ 
//|  Входные параметры индикатора                  |
//+------------------------------------------------+ 
//---- настройки визуального отображения индикатора
input string Sirname="AutoTradeLevels";  // Название для меток индикатора
input uint Len=3;  // Длина ценовых уровней в количестве свечей
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- имя для окон данных и лэйба для субъокон 
   IndicatorSetString(INDICATOR_SHORTNAME,"AutoTradeLevels");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectsDeleteAll(0,"AutoTradeLevels",-1,-1);
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
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<1) return(RESET);
   
   int total=ObjectsTotal(0,0,OBJ_ARROW_BUY);
//---- основной цикл замены Buy значков
   for(int kkk=total-1; kkk>=0 && !IsStopped(); kkk--)
     {
      string name=ObjectName(0,kkk,0,OBJ_ARROW_BUY);
      if(StringSubstr(name,0,9)=="autotrade")
        {
         datetime Time=datetime(ObjectGetInteger(0,name,OBJPROP_TIME,0));
         double Price=ObjectGetDouble(0,name,OBJPROP_PRICE,0);
         color Color=color(ObjectGetInteger(0,name,OBJPROP_COLOR));
         SetTline(0,"AutoTradeLevels"+name,0,Time,Price,Time+MathMax(1,Len)*PeriodSeconds(),Price,Color,0,2,name);
        }
     }
     
   total=ObjectsTotal(0,0,OBJ_ARROW_SELL);
//---- основной цикл замены Buy значков
   for(int kkk=total-1; kkk>=0 && !IsStopped(); kkk--)
     {
      string name=ObjectName(0,kkk,0,OBJ_ARROW_SELL);
      if(StringSubstr(name,0,9)=="autotrade")
        {
         datetime Time=datetime(ObjectGetInteger(0,name,OBJPROP_TIME,0));
         double Price=ObjectGetDouble(0,name,OBJPROP_PRICE,0);
         color Color=color(ObjectGetInteger(0,name,OBJPROP_COLOR));
         SetTline(0,"AutoTradeLevels"+name,0,Time,Price,Time+MathMax(1,Len)*PeriodSeconds(),Price,Color,0,2,name);
        }
     }
//----
   ChartRedraw(0);
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
