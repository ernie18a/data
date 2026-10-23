//+------------------------------------------------------------------+
//|                                                     Fib_SR_6.mq5 |
//|                                      Copyright © 2006, Eli hayun |
//|                                          http://www.elihayun.com |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2006, Eli hayun"
//---- ссылка на сайт автора
#property link      "http://www.elihayun.com"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора не использовано ни одного буфера
#property indicator_buffers 0
//---- использовано ноль графических построений
#property indicator_plots   0
//+----------------------------------------------+ 
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET     0            // Константа для возврата терминалу команды на пересчет индикатора
#define FIB_RES3 "FIB_RES_3"
#define FIB_RES2 "FIB_RES_2"
#define FIB_RES1 "FIB_RES_1"
#define FIB_SUP1 "FIB_SUP_1"
#define FIB_SUP2 "FIB_SUP_2"
#define FIB_SUP3 "FIB_SUP_3"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES Timeframe=PERIOD_D1;  //Таймфрейм индикатора для расчета индикатора
input uint   NumberofBar=1;                 //Номер бара для расчета индикатора
input double Ratio1 = 0.618;                //первое соотношение
input double Ratio2 = 1.382;                //второе соотношение
input double Ratio3 = 2.764;                //третье соотношение
input double Step = 0.50;                   //шаг расширения
input color  Color_Res3 = clrAqua;          //цвет третьей зоны сопротивления
input color  Color_Res2 = clrLime;          //цвет второй зоны сопротивления
input color  Color_Res1 = clrGreen;         //цвет первой зоны сопротивления
input color  Color_Sup1 = clrRed;           //цвет первой зоны поддержки
input color  Color_Sup2 = clrMagenta;       //цвет второй зоны поддержки
input color  Color_Sup3 = clrYellow;        //цвет третьей зоны поддержки
input uint   RightTail=60;                  //выступ прямоугольников за нулевой бар вправо в минутах
input uint   LeftTail=60;                   //выступ прямоугольников за стартовый бар влево в минутах
//+----------------------------------------------+
uint SecondRightTail,SecondLeftTail;
//+------------------------------------------------------------------+
//|  Создание прямоугольного объекта                                 |
//+------------------------------------------------------------------+
void CreateRectangle
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время 1
 double   price1,        // цена 1
 datetime time2,         // время 2
 double   price2,        // цена 2
 color    Color,         // цвет линии
 bool     background,    // фоновое отображение линии
 string   text           // текст
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_RECTANGLE,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_FILL,true);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n"); //запрет всплывающей подсказки
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); //объект на заднем плане
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка прямоугольного объекта                            |
//+------------------------------------------------------------------+
void SetRectangle
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время 1
 double   price1,        // цена 1
 datetime time2,         // время 2
 double   price2,        // цена 2
 color    Color,         // цвет линии
 bool     background,    // фоновое отображение линии
 string   text           // текст
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRectangle(chart_id,name,nwin,time1,price1,time2,price2,Color,background,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//----
   SecondRightTail=RightTail*60;
   SecondLeftTail=LeftTail*60;
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- создание меток для отображения в DataWindow и имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Fib_SR");
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,FIB_SUP3);
   ObjectDelete(0,FIB_SUP2);
   ObjectDelete(0,FIB_SUP1);
   ObjectDelete(0,FIB_RES1);
   ObjectDelete(0,FIB_RES2);
   ObjectDelete(0,FIB_RES3);
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
   if(prev_calculated==rates_total && NumberofBar) return(rates_total);
//----
   double nClose[1],nHigh[1],nLow[1];
   datetime nTime[1];
   int to_copy;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//----
   to_copy=1;
//----
   if(CopyTime(NULL,Timeframe,0,to_copy,nTime)<to_copy)return(RESET);
   if(CopyClose(NULL,Timeframe,NumberofBar,to_copy,nClose)<to_copy)return(RESET);
   if(CopyHigh(NULL,Timeframe,NumberofBar,to_copy,nHigh)<to_copy)return(RESET);
   if(CopyLow(NULL,Timeframe,NumberofBar,to_copy,nLow)<to_copy)return(RESET);
//----   
   double C=nClose[0];
   double H=nHigh[0];
   double L=nLow[0];
   double R=(H-L);
//----
   C=(H+L+C)/3;
   
   double R1=R*Ratio1;
   double D=C+R*Step;
   double B=C-R*Step;   
   double D1=C+R1;
   double B1=C-R1;
//----
   double R2=R*Ratio2;
   double E=C+R*2*Step;
   double A=C-R*2*Step;  
   double E1=C+R2;
   double A1=C-R2;
   
//----      
   double R3=R*Ratio3;
   double F=C+R*4*Step;
   double G=C-R*4*Step;  
   double F1=C+R3;
   double G1=C-R3;
//----
   SetRectangle(0,FIB_RES3,0,nTime[0]-SecondLeftTail,F,time[0]+SecondRightTail,F1,Color_Res3,true,FIB_RES3);
   SetRectangle(0,FIB_RES2,0,nTime[0]-SecondLeftTail,E,time[0]+SecondRightTail,E1,Color_Res2,true,FIB_RES2);
   SetRectangle(0,FIB_RES1,0,nTime[0]-SecondLeftTail,D,time[0]+SecondRightTail,D1,Color_Res1,true,FIB_RES1);
   SetRectangle(0,FIB_SUP1,0,nTime[0]-SecondLeftTail,B,time[0]+SecondRightTail,B1,Color_Sup1,true,FIB_SUP1);
   SetRectangle(0,FIB_SUP2,0,nTime[0]-SecondLeftTail,A,time[0]+SecondRightTail,A1,Color_Sup2,true,FIB_SUP2);
   SetRectangle(0,FIB_SUP3,0,nTime[0]-SecondLeftTail,G,time[0]+SecondRightTail,G1,Color_Sup3,true,FIB_SUP3);
//----
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
