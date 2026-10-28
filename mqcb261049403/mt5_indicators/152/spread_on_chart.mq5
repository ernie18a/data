//+------------------------------------------------------------------+
//|                                              spread_on_chart.mq5 |
//|                                    Copyright © 2010, Forexometer |
//|                                       http://www.forexometer.com |
//|                                           master@forexometer.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Forexometer"
#property link      "http://www.forexometer.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

enum enCorners
  {
   upper_left =0,  // upper left
   lower_left =1,  // lower left
   lower_right=2,  // lower right
   upper_right=3   // upper right
  };

//--- input parameters
input string      _1="// --- Place settings ---";
input enCorners   Corner=0;
input int         XMargin=7;
input int         YMargin=12;
input string      _2="// --- Font settings ---";
input string      Font="Arial";
input color       Color=DarkOrange;
input int         Size=8;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   int iPlace_XMargin=0;
   if(XMargin>0) iPlace_XMargin=XMargin;

   int iPlace_YMargin=0;
   if(YMargin>0) iPlace_YMargin=YMargin;

   int iAnchor;
   switch(Corner)
     {
      case 0:  iAnchor=ANCHOR_LEFT_UPPER;    break;
      case 1:  iAnchor=ANCHOR_LEFT_LOWER;    break;
      case 2:  iAnchor=ANCHOR_RIGHT_LOWER;   break;
      case 3:  iAnchor=ANCHOR_RIGHT_UPPER;
     }

   ObjectCreate(0,"spread",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"spread",OBJPROP_ANCHOR,iAnchor);
   ObjectSetInteger(0,"spread",OBJPROP_CORNER,Corner);
   ObjectSetInteger(0,"spread",OBJPROP_XDISTANCE,iPlace_XMargin);
   ObjectSetInteger(0,"spread",OBJPROP_YDISTANCE,iPlace_YMargin);
   ObjectSetInteger(0,"spread",OBJPROP_FONTSIZE,Size);
   ObjectSetString(0,"spread",OBJPROP_FONT,Font);
   ObjectSetInteger(0,"spread",OBJPROP_COLOR,Color);

   ObjectCreate(0,"stoplevel",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"stoplevel",OBJPROP_ANCHOR,iAnchor);
   ObjectSetInteger(0,"stoplevel",OBJPROP_CORNER,Corner);
   ObjectSetInteger(0,"stoplevel",OBJPROP_XDISTANCE,iPlace_XMargin);
   ObjectSetInteger(0,"stoplevel",OBJPROP_YDISTANCE,iPlace_YMargin+int(1.5*Size));
   ObjectSetInteger(0,"stoplevel",OBJPROP_FONTSIZE,Size);
   ObjectSetString(0,"stoplevel",OBJPROP_FONT,Font);
   ObjectSetInteger(0,"stoplevel",OBJPROP_COLOR,Color);

   ObjectCreate(0,"freezelevel",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"freezelevel",OBJPROP_ANCHOR,iAnchor);
   ObjectSetInteger(0,"freezelevel",OBJPROP_CORNER,Corner);
   ObjectSetInteger(0,"freezelevel",OBJPROP_XDISTANCE,iPlace_XMargin);
   ObjectSetInteger(0,"freezelevel",OBJPROP_YDISTANCE,iPlace_YMargin+3*Size);
   ObjectSetInteger(0,"freezelevel",OBJPROP_FONTSIZE,Size);
   ObjectSetString(0,"freezelevel",OBJPROP_FONT,Font);
   ObjectSetInteger(0,"freezelevel",OBJPROP_COLOR,Color);

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,"spread");
   ObjectDelete(0,"stoplevel");
   ObjectDelete(0,"freezelevel");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   ObjectSetString(0,"spread",OBJPROP_TEXT,"spread = "+DoubleToString(SymbolInfoInteger(Symbol(),SYMBOL_SPREAD),1));
   ObjectSetString(0,"stoplevel",OBJPROP_TEXT,"stop level = "+DoubleToString(SymbolInfoInteger(Symbol(),SYMBOL_TRADE_STOPS_LEVEL),1));
   ObjectSetString(0,"freezelevel",OBJPROP_TEXT,"freeze level = "+DoubleToString(SymbolInfoInteger(Symbol(),SYMBOL_TRADE_FREEZE_LEVEL),1));

   return(0);
  }
//+------------------------------------------------------------------+
