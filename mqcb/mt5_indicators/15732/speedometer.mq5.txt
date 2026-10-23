//+------------------------------------------------------------------+
//|                                                   Speedometr.mq5 |
//|                                              Copyright 2016, AM2 |
//|                                      http://www.forexsystems.biz |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, AM2"
#property link      "http://www.forexsystems.biz"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0

input int              FontSize     = 12;                   // Размер шрифта
input string           FontName     = "Arial";              // Наименование шрифта
input color            ClrWay       = Red;                  // Цвет метки - путь цены в пунктах
input color            ClrSpeed     = Yellow;               // Цвет метки - скорость пункты в секунду
input color            ClrTime      = White;                // Цвет метки - изменение времени в микросекундах
input int              SpeedSound   = 20;                   // Оповещение превышения скорости
input ENUM_BASE_CORNER Corner       = CORNER_RIGHT_UPPER;   // Угол для вывода информации
input bool             AlertOn      = true;                 // Включение оповещения

bool one=true;
double LastBid;
ulong LastTime=0,T=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");
   ObjectDelete(0,"Label1");
   ObjectDelete(0,"Label2");
   ObjectDelete(0,"Label3");
  }
//+------------------------------------------------------------------+
//|  Установка меток                                                 |
//+------------------------------------------------------------------+
void PutLabel(string name,string text,int x,int y,color clr)
  {
   ObjectDelete(0,name);
//--- создадим текстовую метку
   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
//--- установим координаты метки
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
//--- установим угол графика, относительно которого будут определяться координаты точки
   ObjectSetInteger(0,name,OBJPROP_CORNER,Corner);
//--- установим текст
   ObjectSetString(0,name,OBJPROP_TEXT,text);
//--- установим шрифт текста
   ObjectSetString(0,name,OBJPROP_FONT,FontName);
//--- установим размер шрифта
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FontSize);
//--- установим цвет
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
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
//---
   double speed=0,way=0,Bid=0;
   ulong dt=0;

   T=GetMicrosecondCount();
   Bid=SymbolInfoDouble(_Symbol,SYMBOL_BID); 
    
   if(LastBid!=Bid)
     {
      dt=T-LastTime;
      way=(Bid-LastBid)/_Point;
      speed=way/dt;

      // Mетки в правой половине графика
      if(Corner==CORNER_RIGHT_UPPER || Corner==CORNER_RIGHT_LOWER)
        {
         PutLabel("Label1","Way: "+(string)NormalizeDouble(way,2),150,30,ClrWay);
         PutLabel("Label2","Time: "+(string)NormalizeDouble(dt,2),150,55,ClrTime);
         PutLabel("Label3","Speed: "+(string)NormalizeDouble(speed*1000000,2),150,80,ClrSpeed);
        }
      else // Mетки в левой половине графика
        {
         PutLabel("Label1","Way: "+(string)NormalizeDouble(way,2),20,30,ClrWay);
         PutLabel("Label2","Time: "+(string)NormalizeDouble(dt,2),20,55,ClrTime);
         PutLabel("Label3","Speed: "+(string)NormalizeDouble(speed*1000000,2),20,80,ClrSpeed);
        }
     }
     
   LastTime=T;     
   LastBid=Bid;

   if(MathAbs(speed*1000000)<SpeedSound) one=true;
// Оповещения при включенной опции AlertOn
   if((MathAbs(speed*1000000)>SpeedSound && one && AlertOn))
     {
      Alert("Скорость выше "+(string)SpeedSound+" пунктов в секунду!");
      SendNotification("Скорость выше: "+(string)SpeedSound+" пунктов в секунду!");
      SendMail("Сигнал индикатора","Скорость выше: "+(string)SpeedSound+" пунктов в секунду!");
      one=false;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
