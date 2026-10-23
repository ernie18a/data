//+------------------------------------------------------------------+
//|                                                 Color_Spread.mq5 |
//|                                    Copyright © 2017, SelfTraders |
//|                                               http://www.stfx.tk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, SelfTraders"
#property link      "http://www.stfx.tk"
#property description ""
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
#define INDICATOR_NAME      "Color_Spread"      // Имя индикатора
#define RESET               0                   // Константа для возврата терминалу команды на пересчет индикатора
#define NAMES_SYMBOLS_FONT  "Georgia"           // Шрифт для названия индикатора
//+------------------------------------------------+ 
//|  Перечисление для отображения спреда           |
//+------------------------------------------------+ 
enum SpreadMode
  {
   ENUM_POINT_SPREAD=0,     // в пунктах 
   ENUM_TRUE_SPREAD         // в единицах ценового графика
  };
//+------------------------------------------------+ 
//|  Входные параметры индикатора                  |
//+------------------------------------------------+ 
input SpreadMode Spread_Mode=ENUM_TRUE_SPREAD;          // вариант индикации спреда
input string Symbols_Sirname="Color_Spread_";           // Название для меток индикатора
input color Spread_Color=clrLime;                       // Цвет спреда
input color Right_Color=clrDarkBlue;                    // Цвет правой части индикатора
input color Left_Color=clrDodgerBlue;                   // Цвет левой части индикатора
input uint Font_Size=15;                                // Размер шрифта для отображеня спреда
//+-----------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление глобальных переменных
string RightName,LeftName,SpreadName;
int PerSec5,PerSec10,PerSec400;
//+------------------------------------------------------------------+
//|  Создание текстовой метки                                        |
//+------------------------------------------------------------------+
void CreateText(long   chart_id,         // идентификатор графика
                string name,             // имя объекта
                int    nwin,             // индекс окна
                datetime time,           // время ценового уровня
                double price,            // ценовой уровень
                string text,             // текст
                string textTT,           // текст всплывающей подсказки
                color  Color,            // цвет текста
                string Font,             // шрифт текста
                int    Size)             // размер шрифта
  {
//----
   ObjectCreate(chart_id,name,OBJ_TEXT,nwin,time,price);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,textTT);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); //объект на заднем плане
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка текстовой метки                                   |
//+------------------------------------------------------------------+
void SetText(long   chart_id,         // идентификатор графика
             string name,             // имя объекта
             int    nwin,             // индекс окна
             datetime time,           // время ценового уровня
             double price,            // ценовой уровень
             string text,             // текст
             string textTT,           // текст всплывающей подсказки
             color  Color,            // цвет текста
             string Font,             // шрифт текста
             int    Size)             // размер шрифта
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateText(chart_id,name,nwin,time,price,text,textTT,Color,Font,Size);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,nwin,time,price);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
     }
//----
  }
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
//---- инициализация переменных начала отсчета данных
   min_rates_total=300;

//---- инициализация переменных
   RightName=Symbols_Sirname+"Right";
   LeftName=Symbols_Sirname+"Left";
   SpreadName=Symbols_Sirname+"Lable";
   PerSec5=5*PeriodSeconds();
   PerSec10=10*PeriodSeconds();
   PerSec400=400*PeriodSeconds();

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
//---- 
   int bar0=rates_total-1;
   int bar1=rates_total-MathMin(300,bar0);
   double Bid=close[bar0];
   double Spread=spread[bar0]*_Point;
   double Ask=Bid+Spread;
   double dSpread=Bid+Spread/1.05;
   string sSpread;
   if(Spread_Mode==ENUM_TRUE_SPREAD) sSpread=DoubleToString(Spread,_Digits);
   else sSpread=string(spread[bar0]);


//---- Рисуем на графике левый прямоугольник спреда  
   SetRectangle(0,LeftName,0,time[0],Bid,time[bar0]+PerSec5,Ask,Left_Color,STYLE_SOLID,1,LeftName);
//---- Рисуем на графике правый прямоугольник спреда  
  SetRectangle(0,RightName,0,time[bar0]+PerSec5,Bid,time[bar0]+PerSec400,Ask,Right_Color,STYLE_SOLID,1,RightName);
//---- Рисуем на графике текстовую метку спреда    
   SetText(0,SpreadName,0,time[bar0]+PerSec10,dSpread,sSpread,sSpread,Spread_Color,NAMES_SYMBOLS_FONT,Font_Size);
//----
   ChartRedraw(0);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
