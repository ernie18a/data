//+------------------------------------------------------------------+
//|                                                    example3D.mq5 |
//|                                           Copyright 2016, DC2008 |
//|                             https://www.mql5.com/ru/users/dc2008 |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2016, DC2008"
#property link          "https://www.mql5.com/ru/users/dc2008"
#property version       "1.00"
#property description   "Демонстрация 3D индикатора Moving Average"
//--- Объявление констант
#define  StepX    10    // шаг по оси Х [bar]
#define  StepY    10    // шаг по оси Y [bar]
#define  _X       50    // количество узлов по оси Х
#define  _Y       20    // количество узлов по оси Y
#define  W1       1     // толщина линий
#define  W2       3     // толщина крайних линий
//--- Макросы
#define  ObjSet1  ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID)
#define  ObjSet2  ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false)
#define  ObjSet3  ObjectSetInteger(0,name,OBJPROP_RAY_LEFT,false)
#define  ObjSet4  ObjectSetInteger(0,name,OBJPROP_BACK,true)
#define  ObjSet5  ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false)
#define  ObjSet   ObjSet1;ObjSet2;ObjSet3;ObjSet4;ObjSet5
//--- Подключаем файлы классов
#include <3D\USC.mqh>
//---
#property indicator_chart_window
//--- Количество буферов для расчета индикатора
#property indicator_buffers 0
//--- Количество графических серий в индикаторе
#property indicator_plots   0
//--- Объявляем переменные
CUSC        USC;
double fun[_X][_Y];  // 3D функция
//--- 
double      MA[];
int         iMA_handle[_Y];
int         period[_Y]={10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   USC.Create("3D");
//---
   ArraySetAsSeries(MA,true);
   for(int i=0;i<_Y;i++)
      iMA_handle[i]=iMA(_Symbol,_Period,period[i],0,MODE_SMA,PRICE_CLOSE);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Функция 3D индикатора Moving Average
   for(int i=0;i<_X;i++)
      for(int j=0;j<_Y;j++)
        {
         CopyBuffer(iMA_handle[j],0,i*StepX,1,MA);
         fun[i][j]=MA[0];
        }

//--- линии X
   for(int i=1;i<_X;i++)
      for(int j=0;j<_Y;j++)
        {
         sPointCoordinates p0=USC.Z(fun[(i-1)][j], // функция
                                    (i-1)*StepX,   // X
                                    -j*StepY);     // Y
         sPointCoordinates p1=USC.Z(fun[i][j],     // функция
                                    i*StepX,       // X
                                    -j*StepY);     // Y
         string name="MA("+(string)period[j]+") x"+(string)i+"y"+(string)j;
         ObjectCreate(0,name,OBJ_TREND,0,p0.time,p0.price,p1.time,p1.price);
         if(fun[i][j]>USC.m_price && fun[i-1][j]>USC.m_price)
            ObjectSetInteger(0,name,OBJPROP_COLOR,clrRed);
         else
            ObjectSetInteger(0,name,OBJPROP_COLOR,clrBlue);
         ObjectSetInteger(0,name,OBJPROP_WIDTH,W1);
         if(j==0 || j==_Y-1)
            ObjectSetInteger(0,name,OBJPROP_WIDTH,W2);
         ObjSet;
        }
//--- линии Y
   for(int i=0;i<_X;i++)
      for(int j=1;j<_Y;j++)
        {
         sPointCoordinates p0=USC.Z(fun[i][j-1],   // функция
                                    i*StepX,       // X
                                    -(j-1)*StepY); // Y
         sPointCoordinates p1=USC.Z(fun[i][j],     // функция
                                    i*StepX,       // X
                                    -j*StepY);     // Y
         string name="line yz "+"x"+(string)i+"y"+(string)j;
         ObjectCreate(0,name,OBJ_TREND,0,p0.time,p0.price,p1.time,p1.price);
         ObjectSetInteger(0,name,OBJPROP_COLOR,clrGreen);
         ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
         ObjSet;
        }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   USC.OnEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
