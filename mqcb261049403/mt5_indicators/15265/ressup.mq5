//+------------------------------------------------------------------+
//|                                                       ResSup.mq5 |
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2016, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link      "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора не используются буферы
#property indicator_buffers 0
//---- не используются графические построения
#property indicator_plots  0
//+----------------------------------------------+
//|  Объявление констант                         |
//+----------------------------------------------+
#define RESET 0       // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Объявление перечисления                     |
//+----------------------------------------------+
enum Number
  {
   Number_0,
   Number_1,
   Number_2,
   Number_3
  };
//+----------------------------------------------+
//|  Объявление перечисления                     |
//+----------------------------------------------+  
enum Width
  {
   Width_1=1, //1
   Width_2,   //2
   Width_3,   //3
   Width_4,   //4
   Width_5    //5
  };
//+----------------------------------------------+
//|  Объявление перечисления                     |
//+----------------------------------------------+
enum STYLE
  {
   SOLID_,//Сплошная линия
   DASH_,//Штриховая линия
   DOT_,//Пунктирная линия
   DASHDOT_,//Штрих-пунктирная линия
   DASHDOTDOT_   //Штрих-пунктирная линия с двойными точками
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input string  SirName="ResSup";             //Первая часть имени графических объектов
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H1;  //период графика для поиска экстремумов
input uint SignalBar=1;                     //номер бара для поиска экстремумов
input uint  iPeriod=24;                     //период поиска экстремумов цены
input uint  iSize=15;                       //длина уровней в барах текущего графика
input uint  Digits_=0;                      //разряд округления цены
input color  Color_Bg = clrLavender;        //цвет фона
input color  Color_Up = clrLimeGreen;       //цвет линии сопротивления
input STYLE  Style_Up = SOLID_;             //стиль линии сопротивления
input Width  Width_Up = Width_4;            //толщина линии сопротивления
input color  Color_Dn = clrMagenta;         //цвет линии поддержки
input STYLE  Style_Dn = SOLID_;             //стиль линии поддержки
input Width  Width_Dn = Width_4;            //толщина линии поддержки
input uint FontSize = 2;                    //размер ценовых меток
//+----------------------------------------------+
double iLow[],iHigh[],PointPow10;
int min_rates_total1,min_rates_total2;
string UpLinesName,UpPriceName,DnLinesName,DnPriceName,BgName;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- распределение памяти под массивы переменных 
   ArrayResize(iLow,iPeriod);
   ArrayResize(iHigh,iPeriod);
//---- инициализация строковых имен объектов
   UpLinesName=SirName+" UpLine";
   UpPriceName=SirName+" UpPrice";
   DnLinesName=SirName+" DnLine";
   DnPriceName=SirName+" DnPrice";
   BgName=SirName+" Bg";
//---- инициализация переменных  
   min_rates_total1=int(iPeriod+SignalBar);
   min_rates_total2=int(iSize);
   double Pow10=MathPow(10,Digits_);
   PointPow10=_Point*Pow10;
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,UpLinesName);
   ObjectDelete(0,UpPriceName);
   ObjectDelete(0,DnLinesName);
   ObjectDelete(0,DnPriceName);
   ObjectDelete(0,BgName);
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
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчета
   if(Bars(Symbol(),TimeFrame)<min_rates_total1 || rates_total<min_rates_total2) return(RESET);
//---- копируем вновь появившиеся данные в массивы  
   if(CopyLow(Symbol(),TimeFrame,SignalBar,iPeriod,iLow)<=0) return(RESET);
   if(CopyHigh(Symbol(),TimeFrame,SignalBar,iPeriod,iHigh)<=0) return(RESET);
   double Min=PointPow10*MathRound(iLow[ArrayMinimum(iLow,0,WHOLE_ARRAY)]/PointPow10);
   double Max=PointPow10*MathRound(iHigh[ArrayMaximum(iHigh,0,WHOLE_ARRAY)]/PointPow10);
   datetime time1=time[rates_total-iSize];
   datetime time2=time[rates_total-1];
//----
   SetRectangle(0,BgName,0,time1,Min,time2,Max,Color_Bg,SOLID_,Width_1,"");
   SetTline(0,UpLinesName,0,time1,Min,time2,Min,Color_Dn,Style_Dn,Width_Dn,DoubleToString(Min,_Digits));
   SetTline(0,DnLinesName,0,time1,Max,time2,Max,Color_Up,Style_Up,Width_Up,DoubleToString(Max,_Digits));
   SetRightPrice(0,DnPriceName,0,time2,Min,Color_Dn,FontSize);
   SetRightPrice(0,UpPriceName,0,time2,Max,Color_Up,FontSize);
//----
   ChartRedraw(0);
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Создание прямоугольника                                         |
//+------------------------------------------------------------------+
void CreateRectangle(long     chart_id,      // идентификатор графика
                     string   name,          // имя объекта
                     int      nwin,          // индекс окна
                     datetime time1,         // время 1 ценового уровня
                     double   price1,        // 1 ценовой уровень
                     datetime time2,         // время 2 ценового уровня
                     double   price2,        // 2 ценовой уровень
                     color    Color,         // цвет линии
                     int      style,         // стиль линии
                     int      width,         // толщина линии
                     string   text)          // текст
  {
//----
   ObjectCreate(chart_id,name,OBJ_RECTANGLE,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_FILL,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка трендовой линии                                   |
//+------------------------------------------------------------------+
void SetRectangle(long     chart_id,      // идентификатор графика
                  string   name,          // имя объекта
                  int      nwin,          // индекс окна
                  datetime time1,         // время 1 ценового уровня
                  double   price1,        // 1 ценовой уровень
                  datetime time2,         // время 2 ценового уровня
                  double   price2,        // 2 ценовой уровень
                  color    Color,         // цвет линии
                  int      style,         // стиль линии
                  int      width,         // толщина линии
                  string   text)          // текст
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
//|  Создание трендовой линии                                        |
//+------------------------------------------------------------------+
void CreateTline(long     chart_id,      // идентификатор графика
                 string   name,          // имя объекта
                 int      nwin,          // индекс окна
                 datetime time1,         // время 1 ценового уровня
                 double   price1,        // 1 ценовой уровень
                 datetime time2,         // время 2 ценового уровня
                 double   price2,        // 2 ценовой уровень
                 color    Color,         // цвет линии
                 int      style,         // стиль линии
                 int      width,         // толщина линии
                 string   text)          // текст
  {
//----
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
//ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
//ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка трендовой линии                                   |
//+------------------------------------------------------------------+
void SetTline(long     chart_id,// идентификатор графика
              string   name,          // имя объекта
              int      nwin,          // индекс окна
              datetime time1,         // время 1 ценового уровня
              double   price1,        // 1 ценовой уровень
              datetime time2,         // время 2 ценового уровня
              double   price2,        // 2 ценовой уровень
              color    Color,         // цвет линии
              int      style,         // стиль линии
              int      width,         // толщина линии
              string   text) // текст
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
//|  RightPrice creation                                             |
//+------------------------------------------------------------------+
void CreateRightPrice(long chart_id,// chart ID
                      string   name,              // object name
                      int      nwin,              // window index
                      datetime time,              // price level time
                      double   price,             // price level
                      color    Color,             // Text color
                      int      fontsize           // Text font
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,fontsize);
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
                   int      fontsize           // Text font
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color,fontsize);
   else ObjectMove(chart_id,name,0,time,price);
//----
  }
//+------------------------------------------------------------------+
