//+------------------------------------------------------------------+
//|                                                    PriceGrid.mq5 |
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
//---- для расчёта и отрисовки индикатора не используются буферы
#property indicator_buffers 0
//---- не используются графические построения
#property indicator_plots  0
//+-----------------------------------+
//|  объявление перечисления          |
//+-----------------------------------+
enum Number
  {
   Number_0,
   Number_1,
   Number_2,
   Number_3
  };
//+-----------------------------------+
//|  объявление перечисления          |
//+-----------------------------------+  
enum Width
  {
   Width_1=1, //1
   Width_2,   //2
   Width_3,   //3
   Width_4,   //4
   Width_5    //5
  };
//+-----------------------------------+
//|  объявление перечисления          |
//+-----------------------------------+
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
input string  SirName="PriceGrid";          //Первая часть имени графических объектов
input uint  Digits_=2;                      //разряд сетки
input uint  Total=20;                        //количество блоков сетки сверху или снизу от цены
input color  Color_ = clrBlueViolet;        //цвет уровня
input STYLE  Style_ = DASHDOTDOT_;          //стиль линии уровня
input Width  Width_ = Width_1;              //толщина линии уровня 
//+----------------------------------------------+
int middle,size;
string ObjectNames[];
double Pow10,PointPow10,PriceGrid[],Price[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- распределение памяти под массивы переменных  
   size=int(Total*2);
   ArrayResize(ObjectNames,size);
   ArrayResize(PriceGrid,size);
   ArrayResize(Price,size);
//---- инициализация имён
   for(int count=0; count<size; count++) ObjectNames[count]=SirName+" PriceLine "+string(count);
//---- инициализация переменных         
   Pow10=MathPow(10,Digits_);
   PointPow10=_Point*Pow10;
   middle=(size/2)-1;
//---- инициализация переменных         
   for(int count=middle; count<size; count++) PriceGrid[count]=+PointPow10*(count-middle);  
   for(int count=middle-1; count>=0; count--) PriceGrid[count]=-PointPow10*(middle-count);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   for(int count=0; count<size; count++) ObjectDelete(0,ObjectNames[count]);
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
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//----   
  double res=PointPow10*MathFloor(close[rates_total-1]/PointPow10);
  for(int count=0; count<size; count++) Price[count]=res+PriceGrid[count];    
  for(int count=0; count<size; count++) SetHline(0,ObjectNames[count],0,Price[count],Color_,Style_,Width_,ObjectNames[count]+DoubleToString(Price[count],_Digits));
//----
   ChartRedraw(0);
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Создание горизонтального, ценового уровня                       |
//+------------------------------------------------------------------+
void CreateHline
(
 long   chart_id,      // идентификатор графика
 string name,          // имя объекта
 int    nwin,          // индекс окна
 double price,         // ценовой уровень
 color  Color,         // цвет линии
 int    style,         // стиль линии
 int    width,         // толщина линии
 string text           // текст
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_HLINE,0,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка горизонтального, ценового уровня                  |
//+------------------------------------------------------------------+
void SetHline
(
 long   chart_id,      // идентификатор графика
 string name,          // имя объекта
 int    nwin,          // индекс окна
 double price,         // ценовой уровень
 color  Color,         // цвет линии
 int    style,         // стиль линии
 int    width,         // толщина линии
 string text           // текст
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateHline(chart_id,name,nwin,price,Color,style,width,text);
   else
     {
      //ObjectSetDouble(chart_id,name,OBJPROP_PRICE,price);
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
     }
//----
  }
//+------------------------------------------------------------------+
