//+------------------------------------------------------------------+
//|                                              CandleCountdown.mq5 |
//|                                                  Zaven Vardanyan |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Zaven Vardanyan"
#property link      "http://vzvtrading.blogspot.com"
#property description "Candle Close Time Countdown"
#property indicator_plots 0
#property indicator_chart_window

enum crnr {LeftUp,LeftDown,RightUp,RightDown};

input crnr Corner=RightDown;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   CandleObject();
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,"CandleTimeCountdown");
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
   int total,count;
   int s,m,h,d;
   string countdown;
   count = Bars(Symbol(),PERIOD_CURRENT);
   total = (int)(TimeCurrent() - time[count-1]);
   total = PeriodSeconds() - total;

   s = total % 60;
   m = total / 60  % 60;
   h = total / 3600 % 24;
   d = total / 86400 % 7;


   if(d!=0)
     {
      countdown=IntegerToString(d)+" d "+IntegerToString(h)+" h "+IntegerToString(m)+" m "+IntegerToString(s)+" s";
     }
   else
     {
      if(h!=0)
        {
         countdown=IntegerToString(h)+" h "+IntegerToString(m)+" m "+IntegerToString(s)+" s";
        }
      else
        {
         countdown=IntegerToString(m)+" m "+IntegerToString(s)+" s";
        }
     }

   ObjectSetString(0,"CandleTimeCountdown",OBJPROP_TEXT,countdown);
   ChartRedraw(0);

//--- return value 
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|  User Functions                                                  |
//+------------------------------------------------------------------+

void CandleObject()
  {
   int x,y;
   x = 0;
   y = 0;

   switch(GetCorner(Corner))
     {
      case CORNER_LEFT_LOWER:
         x = 20;
         y = 40;
         break;
      case CORNER_LEFT_UPPER:
         x = 20;
         y = 20;
         break;
      case CORNER_RIGHT_UPPER:
         x = 140;
         y = 20;
         break;
      case CORNER_RIGHT_LOWER:
         x = 140;
         y = 40;
         break;
     }

   ObjectCreate(0,"CandleTimeCountdown",OBJ_EDIT,0,0,0);
   ObjectSetInteger(0,"CandleTimeCountdown",OBJPROP_READONLY,true);
   ObjectSetInteger(0,"CandleTimeCountdown",OBJPROP_CORNER,GetCorner(Corner));
   ObjectSetInteger(0,"CandleTimeCountdown",OBJPROP_FONTSIZE,9);
   ObjectSetInteger(0,"CandleTimeCountdown",OBJPROP_ALIGN,ALIGN_CENTER);
   ObjectSetInteger(0,"CandleTimeCountdown",OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,"CandleTimeCountdown",OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,"CandleTimeCountdown",OBJPROP_XSIZE,120);
   ObjectSetInteger(0,"CandleTimeCountdown",OBJPROP_YSIZE,20);
   ObjectSetInteger(0,"CandleTimeCountdown",OBJPROP_BGCOLOR,clrWhite);
   ObjectSetInteger(0,"CandleTimeCountdown",OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0,"CandleTimeCountdown",OBJPROP_BORDER_COLOR,clrRed);
   ObjectSetString(0,"CandleTimeCountdown",OBJPROP_FONT,"Tahoma");
  }

int GetCorner(crnr t)
  {
   switch(t)
     {
      case LeftUp:
         return(CORNER_LEFT_UPPER);
         break;
      case LeftDown:
         return(CORNER_LEFT_LOWER);
         break;
      case RightUp:
         return(CORNER_RIGHT_UPPER);
         break;
      case RightDown:
         return(CORNER_RIGHT_LOWER);
         break;
     }
   return(CORNER_RIGHT_LOWER);
  }
//+------------------------------------------------------------------+