//+------------------------------------------------------------------+
//|                                              PriceGrid1_Plus.mq5 |
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2016, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link      "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//----
#property description "Сетка из круглых ценовых уровней" 
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
enum WIDTH
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
input string  SirName="PriceGrid1_Plus";     //Первая часть имени графических объектов
input uint  Digits_=2;                       //разряд сетки
input uint  Total=200;                       //количество блоков сетки сверху или снизу от цены
//----
input color  Color_A = clrSlateBlue;         //цвет уровня 1 
input bool ShowPriceLable_A = true;          //отображение значения ценовой метки 1 на ценовом графике
input color  Color_AL = clrBlueViolet;       //цвет ценовой метки 1 
input STYLE  Style_A = DASHDOTDOT_;          //стиль линии уровня 1
input WIDTH  Width_A = Width_1;              //толщина линии уровня 1
//----
input color  Color_B = clrDarkOrange;        //цвет уровня 2
input bool ShowPriceLable_B = true;          //отображение значения ценовой метки 2 на ценовом графике
input color  Color_BL = clrGold;             //цвет ценовой метки 2
input STYLE  Style_B = DASH_;                //стиль линии уровня 2
input WIDTH  Width_B = Width_1;              //толщина линии уровня 2
//----
input color  Color_C = clrMagenta;           //цвет уровня 3
input bool ShowPriceLable_C = true;          //отображение значения ценовой метки 3 на ценовом графике
input color  Color_CL = clrMagenta;          //цвет ценовой метки 3
input STYLE  Style_C = SOLID_;               //стиль линии уровня 3
input WIDTH  Width_C = Width_1;              //толщина линии уровня 3
//----
input color  Color_D = clrRed;               //цвет уровня 4
input bool ShowPriceLable_D = true;          //отображение значения ценовой метки 4 на ценовом графике
input color  Color_DL = clrRed;              //цвет ценовой метки 4
input STYLE  Style_D = SOLID_;               //стиль линии уровня 4
input WIDTH  Width_D = Width_1;              //толщина линии уровня 4
//----
input color  Color_E = clrLime;              //цвет уровня 5
input bool ShowPriceLable_E = true;          //отображение значения ценовой метки 5 на ценовом графике
input color  Color_EL = clrLime;             //цвет ценовой метки 5
input STYLE  Style_E = SOLID_;               //стиль линии уровня 5
input WIDTH  Width_E = Width_1;              //толщина линии уровня 5
//----
input uint FontSize = 2;                     //размер ценовых меток
input int  Shift = 5;                        //Сдвиг ценовых меток по горизонтали в барах
input bool ShowLineInfo = true;              //отображение значения уровня на ценовом графике
//+----------------------------------------------+
color clr,clrl;
STYLE Style;
WIDTH Width;
bool ShowPriceLable;
int middle,size,Normalize;
string ObjectNames[][2];
double PointPow10,PointPow100,PointPow1000,PointPow10000,PointPow100000,PriceGrid[],Price[];
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
   for(int count=0; count<size; count++) ObjectNames[count][0]=SirName+" PriceLine "+string(count);
   for(int count=0; count<size; count++) ObjectNames[count][1]=SirName+" PriceLable "+string(count);
//---- инициализация переменных         
   PointPow10=_Point*MathPow(10,Digits_);
   PointPow100=PointPow10*10;
   PointPow1000=PointPow10*100;
   PointPow10000=PointPow10*1000;
   PointPow100000=PointPow10*10000;
   middle=(size/2)-1;
   Normalize=int(_Digits-Digits_);
//---- инициализация переменных         
   for(int count=middle; count<size; count++) PriceGrid[count]=+NormalizeDouble(PointPow10*(count-middle),Normalize);
   for(int count=middle-1; count>=0; count--) PriceGrid[count]=-NormalizeDouble(PointPow10*(middle-count),Normalize);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   for(int count=0; count<size; count++) ObjectDelete(0,ObjectNames[count][0]);
   for(int count=0; count<size; count++) ObjectDelete(0,ObjectNames[count][1]);
//----
   ChartRedraw(0);
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
   static double  res_prev=0.0;
   double res=NormalizeDouble(PointPow10*MathCeil(close[rates_total-1]/PointPow10),Normalize);
   if(!(res-res_prev)) return(rates_total);
   res_prev=res;
   for(int count=0; count<size; count++) Price[count]=NormalizeDouble(res+PriceGrid[count],Normalize);
   datetime time0=time[rates_total-1]+PeriodSeconds()*Shift;
   datetime timeX=time[0];
   for(int count=0; count<size; count++)
     {
      if(!NormalizeDouble(Price[count]-PointPow100000*MathCeil(Price[count]/PointPow100000),Normalize))
        {
         clr=Color_E;
         clrl=Color_EL;
         ShowPriceLable=ShowPriceLable_E;
         Style=Style_E;
         Width=Width_E;
        }
      else if(!NormalizeDouble(Price[count]-PointPow10000*MathCeil(Price[count]/PointPow10000),Normalize))
        {
         clr=Color_D;
         clrl=Color_DL;
         ShowPriceLable=ShowPriceLable_D;
         Style=Style_D;
         Width=Width_D;
        }
      else if(!NormalizeDouble(Price[count]-PointPow1000*MathCeil(Price[count]/PointPow1000),Normalize))
        {
         clr=Color_C;
         clrl=Color_CL;
         ShowPriceLable=ShowPriceLable_C;
         Style=Style_C;
         Width=Width_C;
        }
      else  if(!NormalizeDouble(Price[count]-PointPow100*MathCeil(Price[count]/PointPow100),Normalize))
        {
         clr=Color_B;
         clrl=Color_BL;
         ShowPriceLable=ShowPriceLable_B;
         Style=Style_B;
         Width=Width_B;
        }
      else
        {
         clr=Color_A;
         clrl=Color_AL;
         ShowPriceLable=ShowPriceLable_A;
         Style=Style_A;
         Width=Width_A;
        }
      string info="";
      if(ShowLineInfo) info=ObjectNames[count][0]+" "+DoubleToString(Price[count],Normalize);
      SetTline(0,ObjectNames[count][0],0,timeX,Price[count],time0,Price[count],clr,Style,Width,info);
      if(ShowPriceLable)
        {
         if(ShowLineInfo) info=ObjectNames[count][1]+" "+DoubleToString(Price[count],Normalize);
         SetRightPrice(0,ObjectNames[count][1],0,time0,Price[count],clrl,FontSize,info);
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
      ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
      ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
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
                      color    Color,             // price color
                      int      fontsize,          // price size
                      string   text               // текст
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,fontsize);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
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
                   color    Color,             // price color
                   int      fontsize,          // price size
                   string   text               // текст
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color,fontsize,text);
   else
     {
      ObjectMove(chart_id,name,0,time,price);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }

//----
  }
//+------------------------------------------------------------------+
