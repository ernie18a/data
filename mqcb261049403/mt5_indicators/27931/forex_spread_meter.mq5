//+------------------------------------------------------------------+
//|                                           Forex_Spread_Meter.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "1.000"
#property description   "Display the spread meter on the chart."
//---
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 0
//+------------------------------------------------------------------+
//--- input parameters
input color  ColorSpread = clrDarkOrange;
input color  ColorMax    = clrOrangeRed;
input color  ColorAvg    = clrDarkOrange;
input color  ColorMin    = clrGold;
//+------------------------------------------------------------------+
//--- global variables
double max_spread=DBL_MIN;
double min_spread=DBL_MAX;
double avg_spread=0;
double sum_spread=0;
double cnt_spread=0;
//+------------------------------------------------------------------+
//--- indicator buffer
double buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Set the indicator properties
   SetIndexBuffer(0,buffer,INDICATOR_DATA);
   IndicatorSetString(INDICATOR_SHORTNAME,"Forex Spread Meter");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---
   UpdateSpreadMeter();

//--- Initialization completed successfully
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(0,"spread_meter_");
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
   UpdateSpreadMeter();

//---
   buffer[0]=-1;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateSpreadMeter()
  {
   double spread = (int)SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);

   max_spread = MathMax(spread,max_spread);
   min_spread = MathMin(spread,min_spread);

   cnt_spread++;
   sum_spread = sum_spread + spread;
   avg_spread = sum_spread / cnt_spread;

//-- create or update the labels
   LabelCreate(0,"spread_meter_max",           0, 10, 24, CORNER_RIGHT_LOWER,DoubleToString(max_spread,2),"Arial",8,ColorMax,0.0,ANCHOR_RIGHT_LOWER);
   LabelCreate(0,"spread_meter_max_label",     0, 43, 24, CORNER_RIGHT_LOWER,"max:","Arial",8,ColorMax,0.0,ANCHOR_RIGHT_LOWER);
   LabelCreate(0,"spread_meter_avg",           0, 10, 13, CORNER_RIGHT_LOWER,DoubleToString(avg_spread,2),"Arial",8,ColorAvg,0.0,ANCHOR_RIGHT_LOWER);
   LabelCreate(0,"spread_meter_avg_label",     0, 43, 13, CORNER_RIGHT_LOWER,"avg:","Arial",8,ColorAvg,0.0,ANCHOR_RIGHT_LOWER);
   LabelCreate(0,"spread_meter_min",           0, 10, 2,  CORNER_RIGHT_LOWER,DoubleToString(min_spread,2),"Arial",8,ColorMin,0.0,ANCHOR_RIGHT_LOWER);
   LabelCreate(0,"spread_meter_min_label",     0, 43, 2,  CORNER_RIGHT_LOWER,"min:","Arial",8,ColorMin,0.0,ANCHOR_RIGHT_LOWER);
   LabelCreate(0,"spread_meter_current",       0, 100,5,  CORNER_RIGHT_LOWER,DoubleToString(spread,0),"Arial",18,ColorSpread,0.0,ANCHOR_RIGHT_LOWER);
   LabelCreate(0,"spread_meter_current_label", 0, 140,5,  CORNER_RIGHT_LOWER,"Spread:","Arial",18,ColorSpread,0.0,ANCHOR_RIGHT_LOWER);
  }
//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool LabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
