//+---------------------------------------------------------------------+
//|                                       GRFLeadingEdger_Pivot_HTF.mq5 |
//|                                  Copyright © 2017, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "GRFLeadingEdger Bands Pivot"
//---- номер версии индикатора
#property version   "1.60"
//+--------------------------------------------+
//|  Параметры отрисовки индикатора            |
//+--------------------------------------------+
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots   0
//+--------------------------------------------+
//|  Объявление констант                       |
//+--------------------------------------------+
#define INDICATOR_NAME      "GRFLeadingEdger_Pivot_HTF"     // Имя индикатора
#define RESET               0                               // Константа для возврата терминалу команды на пересчет индикатора
//+--------------------------------------------+
//|  Входные параметры индикатора              |
//+--------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;              // Период графика
input string Symbols_Sirname="GRFLeadingEdger_Pivot_";  // Название для меток индикатора
input uint Samples=60;
input int  LookAhead=0;
input double StdLevel1=2.0;
input double  StdLevel2=4.0;
input color Up_Color=clrSpringGreen;                    // Цвет верхней полосы индикатора
input color Dn_Color=clrYellow;                         // Цвет нижней полосы индикатора
input uint SignalBar=0;                                 // номер бара для получения значений индикатора
input uint SignalLen=40;                                // Длина полос индикатора
//---- цвета ценовых меток
input color  Middle_color=clrBlue;
input color  Upper_color1=clrMediumSeaGreen;
input color  Lower_color1=clrRed;
input color  Upper_color2=clrDodgerBlue;
input color  Lower_color2=clrMagenta;
//+-----------------------------------+
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1;
//---- объявление глобальных переменных
string UpName,MiddleName,DnName;
//---- Объявление стрингов для текстовых меток
string upper_name1,middle_name,lower_name1,upper_name2,lower_name2;
int PerSignalLen;
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- получение хендла индикатора GRFLeadingEdge
   Ind_Handle=iCustom(Symbol(),TimeFrame,"GRFLeadingEdge",Samples,LookAhead,StdLevel1,StdLevel2,0,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора GRFLeadingEdge");
      return(INIT_FAILED);
     }
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(SignalLen);

//---- инициализация переменных
   UpName=Symbols_Sirname+"Upper Band";
   MiddleName=Symbols_Sirname+"Middle Band";
   DnName=Symbols_Sirname+"Lower Band";
   PerSignalLen=int(SignalLen)*PeriodSeconds();
//---- Инициализация стрингов
   upper_name1=Symbols_Sirname+" upper text lable 1";
   middle_name=Symbols_Sirname+" middle text lable";
   lower_name1=Symbols_Sirname+" lower text lable 1";
   upper_name2=Symbols_Sirname+" upper text lable 2";
   lower_name2=Symbols_Sirname+" lower text lable 2";

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
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
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//---- Объявление переменных с плавающей точкой  
   static double Up1[1],Up2[1],Middle[1],Dn1[1],Dn2[1];

//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ind_Handle,1,SignalBar,1,Up2)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,2,SignalBar,1,Up1)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,0,SignalBar,1,Middle)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,3,SignalBar,1,Dn1)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,4,SignalBar,1,Dn2)<=0) return(RESET);

   int bar0=rates_total-1;
   int bar1=rates_total-int(MathMax(SignalLen-1,0));
   datetime time0=time[bar0]+2*PeriodSeconds();
   datetime time1=time0-PerSignalLen;

//---- Рисуем на графике верхний прямоугольник полосы
   SetRectangle(0,UpName,0,time1,Up1[0],time0,Up2[0],Up_Color,STYLE_SOLID,1,UpName);
//---- Рисуем на графике нижний прямоугольник полосы
   SetRectangle(0,DnName,0,time1,Dn1[0],time0,Dn2[0],Dn_Color,STYLE_SOLID,1,DnName);
//---- Рисуем на графике среднюю линию   
   SetTline(0,MiddleName,0,time1,Middle[0],time0,Middle[0],Middle_color,STYLE_SOLID,1,MiddleName);
//---- Рисуем на графике ценовые метки   
   SetRightPrice(0,upper_name1,0,time[bar0],Up1[0],Upper_color1,"Georgia");
   SetRightPrice(0,lower_name1,0,time[bar0],Dn1[0],Lower_color1,"Georgia");
   SetRightPrice(0,middle_name,0,time[bar0],Middle[0],Middle_color,"Georgia");
   SetRightPrice(0,upper_name2,0,time[bar0],Up2[0],Upper_color2,"Georgia");
   SetRightPrice(0,lower_name2,0,time[bar0],Dn2[0],Lower_color2,"Georgia");
//----
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Создание прямоугольника                                         |
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
//|  Переустановка  прямоугольника                                   |
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
//|  RightPrice creation                                             |
//+------------------------------------------------------------------+
void CreateRightPrice(long chart_id,// chart ID
                      string   name,              // object name
                      int      nwin,              // window index
                      datetime time,              // price level time
                      double   price,             // price level
                      color    Color,             // Text color
                      string   Font               // Text font
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
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
                   color    Color,             // Text color
                   string   Font               // Text font
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color,Font);
   else ObjectMove(chart_id,name,0,time,price);
//----
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
