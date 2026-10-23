//+------------------------------------------------------------------+
//|                                                  mCandle_row.mq5 |
//|                                                         MVS 2017 |
//|                                https://www.mql5.com/ru/users/mvs |
//+------------------------------------------------------------------+
#property copyright "https://www.mql5.com/ru/users/mvs"
#property copyright "MVS © 2017"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property strict

//--- input parameters
input int   ObjFs    = 8;              // Font size arrow

input color BullArr  = clrRoyalBlue;   // Bull arrow candle
input color BearArr  = clrMagenta;     // Bear arrow candle
input color CrossArr = clrDarkOrange;  // Cross arrow candle

input bool  Alerts   = true;           // Alert ON/OFF
input int   Candles  = 4;              // Count Candles

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete graphics
   ObjectsDeleteAll(0,"Bull_");
   ObjectsDeleteAll(0,"Bear_");
   ObjectsDeleteAll(0,"Cross_");
   ChartRedraw();
//---
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
   int up=0,dn=0,res=0;
   int limit=rates_total-prev_calculated;

   if(limit==0)
      return(rates_total);

   if(limit==1)
      limit=20;
//---
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//---
   for(int i=limit-1; i>0; i--)
     {
      // бычьи
      if(open[i]<close[i])
        {
         up++;
         SetText("Bull_"+(string)time[i],(string)up,time[i],high[i],BullArr);
        }
      else up=0;

      // медвежьи
      if(open[i]>close[i])
        {
         dn++;
         SetText("Bear_"+(string)time[i],(string)dn,time[i],high[i],BearArr);
        }
      else dn=0;

      // open = close
      res=up+dn*-1;
      if(res==0)
         SetText("Cross_"+(string)time[i],(string)res,time[i],high[i],CrossArr);
     }

// Alert
   if(Alerts && limit==20)
     {
      if(up>=Candles) Alert(Symbol(),": Time = ",time[0],": UP = ",(int)up);
      if(dn>=Candles) Alert(Symbol(),": Time = ",time[0],": DN = ",(int)dn);
     }
     
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+----------------------------------------------------------------------------+
void SetText(string nm,string text,datetime t,double p,color clr)
  {
   if(ObjectFind(0,nm)<0)
     {
      ObjectCreate(0,nm,OBJ_TEXT,0,0,0);
      ObjectSetString(0,nm,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,nm,OBJPROP_FONTSIZE,ObjFs);
      ObjectSetInteger(0,nm,OBJPROP_ANCHOR,ANCHOR_LOWER);
      ObjectSetInteger(0,nm,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,nm,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,nm,OBJPROP_BACK,false);
      ObjectSetInteger(0,nm,OBJPROP_HIDDEN,false);
      ObjectSetString(0,nm,OBJPROP_TEXT,text);
      ObjectSetDouble(0,nm,OBJPROP_PRICE,p);
      ObjectSetInteger(0,nm,OBJPROP_TIME,t);
     }
  }
//+----------------------------------------------------------------------------+
