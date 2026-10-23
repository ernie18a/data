//+------------------------------------------------------------------+
//|                                                      ParTest.mq5 |
//|                                        Copyright © 2005, Danilla |
//|                                                                  |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2005, Danilla"
//---- ссылка на сайт автора
#property link      ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- в индикаторе нет индикаторных буферов
#property indicator_buffers 0 
//---- в индикаторе нет графических построений
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
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET       0 // Константа для возврата терминалу команды на пересчёт индикатора
#define DAYSSIZE    60*60*24 // константа количества секунд в дне
#define SIZE10HOURS 60*60*10 // константа количества секунд в 10 часах
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input string  IndicatorSirname="Paramon";
//----
input color  Up_Color = clrMediumSeaGreen; //цвет верхнего уровня
input color  UpFill_Color = clrPaleGreen; //цвет заливки верхнего уровня
input color  Md_Color = clrBlue; //цвет среднего уровня
input color  Dn_Color=clrMagenta; //цвет  нижнего уровня
input color  DnFill_Color=clrPlum; //цвет заливки нижнего уровня
input color  DayColor=clrBlueViolet; //цвет уровня начала дня
//----
input STYLE  Up_Style = SOLID_;      //стиль вернего уровня
input STYLE  Md_Style = DASHDOTDOT_; //стиль среднего уровня
input STYLE  Dn_Style = SOLID_;      //стиль нижнего уровня
input STYLE  DayStyle = SOLID_;      //стиль уровня начала дня
//----
input Width  Up_Width = Width_3; //толщина вернего уровня
input Width  Md_Width = Width_1; //толщина среднего уровня
input Width  Dn_Width = Width_3; //толщина нижнего уровня
input Width  DayWidth = Width_3; //толщина уровня начала дня

//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//----
int DayExtremumsOffset=3600;
string UpLineName,MiddleLineName,DownLineName,DayLineName,UpRectangleName,DnRectangleName;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//----
   UpLineName=IndicatorSirname+" UpLine";
   MiddleLineName=IndicatorSirname+" MiddleLine";
   DownLineName=IndicatorSirname+" DownLine";
   DayLineName=IndicatorSirname+" DayLine";
   UpRectangleName=IndicatorSirname+" UpRectangle";
   DnRectangleName=IndicatorSirname+" DownRectangle";
//---- создание меток для отображения в DataWindow и имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Paramon");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,UpLineName);
   ObjectDelete(0,MiddleLineName);
   ObjectDelete(0,DownLineName);
   ObjectDelete(0,DayLineName);
   ObjectDelete(0,UpRectangleName);
   ObjectDelete(0,DnRectangleName);
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
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//----  
   double lowprice,highprice,avprice;
   int DayExtremumsBarOffset=0;
   datetime iTime[];
//----   

//---- копируем вновь появившиеся данные в массив iTime[]
   if(CopyTime(Symbol(),PERIOD_D1,0,1,iTime)<=0) return(RESET);
   
   int bar=0;
   while(time[bar]>=iTime[0]) bar++;
   if(bar) bar--;
//----
   if(TimeCurrent()%DAYSSIZE>SIZE10HOURS)
     {
      while(time[0]-time[DayExtremumsBarOffset]<DayExtremumsOffset && time[DayExtremumsBarOffset]%DAYSSIZE>SIZE10HOURS)
         DayExtremumsBarOffset++;

      if(DayExtremumsBarOffset) DayExtremumsBarOffset--;
     }
//----  
    lowprice=low[ArrayMinimum(low,DayExtremumsBarOffset,bar-DayExtremumsBarOffset)];
    highprice=high[ArrayMaximum(high,DayExtremumsBarOffset,bar-DayExtremumsBarOffset)];
   avprice=(highprice+lowprice)/2;
//----
   SetRectangle(0,UpRectangleName,0,time[bar],avprice,time[0]+PeriodSeconds(),highprice,UpFill_Color,SOLID_,Width_1,UpRectangleName+DoubleToString(highprice,_Digits));
   SetRectangle(0,DnRectangleName,0,time[bar],avprice,time[0]+PeriodSeconds(),lowprice,DnFill_Color,SOLID_,Width_1,DnRectangleName+DoubleToString(lowprice,_Digits));
   SetHline(0,UpLineName,0,highprice,Up_Color,Up_Style,Up_Width,UpLineName+DoubleToString(highprice,_Digits));
   SetHline(0,MiddleLineName,0,avprice,Md_Color,Md_Style,Md_Width,MiddleLineName+DoubleToString(avprice,_Digits));
   SetHline(0,DownLineName,0,lowprice,Dn_Color,Dn_Style,Dn_Width,DownLineName+DoubleToString(lowprice,_Digits));
   SetVline(0,DayLineName,0,time[bar],DayColor,DayStyle,DayWidth,true,"дневной бар");  
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
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   //--- включим (true) режим заливки прямоугольника 
   ObjectSetInteger(chart_id,name,OBJPROP_FILL,true); 
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка прямоугольника                                    |
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
//|  Создание вертикальной линии                                     |
//+------------------------------------------------------------------+
void CreateVline
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время вертикального уровня
 color    Color,         // цвет линии
 int      style,         // стиль линии
 int      width,         // толщина линии
 bool     background,// фоновое отображение линии
 string   text           // текст
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_VLINE,nwin,time1,999999999);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n"); //запрет всплывающей подсказки
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); //объект на заднем плане
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка вертикальной линии                                |
//+------------------------------------------------------------------+
void SetVline
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время вертикального уровня
 color    Color,         // цвет линии
 int      style,         // стиль линии
 int      width,         // толщина линии
 bool     background,// фоновое отображение линии
 string   text           // текст
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateVline(chart_id,name,nwin,time1,Color,style,width,background,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,999999999);
     }
//----
  }
//+------------------------------------------------------------------+
