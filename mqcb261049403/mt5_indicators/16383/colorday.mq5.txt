//+------------------------------------------------------------------+
//|                                                     ColorDay.mq5 |
//|                                              Copyright 2016, AM2 |
//|                                      http://www.forexsystems.biz |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, AM2"
#property link      "http://www.forexsystems.biz"
#property version   "1.00"
#property strict
#property indicator_chart_window

#property indicator_buffers 0
#property indicator_plots   0

input int   Days = 11;  // дней для расчета
input color UP = Blue;  // цвет бычьего дня 
input color DN = Red;   // цвет медвежьего дня

datetime tm[];
double op[];
double cl[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   Comment("");
   ArrayResize(tm,Days);
   ArrayResize(op,Days);
   ArrayResize(cl,Days);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
   DeleteObjects();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteObjects()
  {
   for(int i=ObjectsTotal(0,0,OBJ_RECTANGLE)-1;i>=0;i--)
     {
      string name=ObjectName(0,i,0,OBJ_RECTANGLE);
      if(StringFind(name,"Rect",0)>=0) ObjectDelete(0,name);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PutRect(string name,datetime t1,double p1,datetime t2,double p2,color clr)
  {
   ObjectDelete(0,name);
//--- создадим прямоугольник по заданным координатам
   ObjectCreate(0,name,OBJ_RECTANGLE,0,t1,p1,t2,p2);
//--- установим цвет прямоугольника
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
//--- включим (true) или отключим (false) режим заливки прямоугольника 
   ObjectSetInteger(0,name,OBJPROP_FILL,true);
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
   for(int i=0;i<=Days;i++)
     {
      CopyTime(NULL,PERIOD_D1,0,Days+1,tm);
      CopyOpen(NULL,PERIOD_D1,0,Days+1,op);
      CopyClose(NULL,PERIOD_D1,0,Days+1,cl);

      datetime time0=tm[i];
      datetime time1=time0+3600*24;
      double dopen=op[i];
      double dclose=cl[i];

      if(dclose<dopen) PutRect("Rect"+(string)dopen,time0,dopen,time1,dclose,DN);
      if(dclose>dopen) PutRect("Rect"+(string)dopen,time0,dopen,time1,dclose,UP);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
