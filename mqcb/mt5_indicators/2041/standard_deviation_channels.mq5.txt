//+------------------------------------------------------------------+
//|                                  Standard_Deviation_Channels.mq5 |
//|                Copyright © 2006, tageiger, aka fxid10t@yahoo.com |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2006, tageiger, aka fxid10t@yahoo.com"
//--- link to the website of the author
#property link      "https://www.metaquotes.net"
//--- Indicator version
#property version   "1.00"
#property description "Standard_Deviation_Channels"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- number of indicator buffers is 0
#property indicator_buffers 0 
//--- 0 graphical plots are used
#property indicator_plots   0
//+------------------------------------------------+
//|  Declaration of constants                      |
//+------------------------------------------------+
#define RESET 0 // A constant for returning the indicator recalculation command to the terminal
//+------------------------------------------------+
//| Enumeration for the level width                |
//+------------------------------------------------+ 
enum ENUM_WIDTH // Type of constant
  {
   w_1 = 1,     // 1
   w_2,         // 2
   w_3,         // 3
   w_4,         // 4
   w_5          // 5
  };
//+------------------------------------------------+
//| Indicator input parameters                   |
//+------------------------------------------------+
input string lines_sirname="Standard_Deviation_Channels"; // Graphic objects group name
input ENUM_TIMEFRAMES period=PERIOD_CURRENT;              // Chart period
input int STD_Rgres_length=56;                            // Bars back regression begins
input double STD_Rgres_width=1.618;                       // Widest channel
input double STD_width=0.618;                             // Inside channel
input color widest_color=clrBlue;                         // Widest color
input ENUM_LINE_STYLE widest_style=STYLE_SOLID;           // Widest style
input ENUM_WIDTH widest_width=w_3;                        // Widest width
input color inside_color=clrBlue;                         // Inside color
input ENUM_LINE_STYLE inside_style=STYLE_SOLID;           // Inside style
input ENUM_WIDTH inside_width=w_3;                        // Inside width
//+----------------------------------------------+

string name1,name2;
//+------------------------------------------------------------------+
//|  Creating a standard deviation channel                           |
//+------------------------------------------------------------------+
void CreateStdDevChannel(long     chart_id,      // Chart ID
                         string   name,          // object name
                         int      nwin,          // window index
                         datetime time1,         // price level time 1
                         double   price1,        // price level 1
                         datetime time2,         // price level time 2
                         double   price2,        // price level 2
                         double   stdwidth,      // width
                         color    Color,         // line color
                         int      style,         // line style
                         int      width,         // line width
                         string   text)          // text
  {
//---
   ObjectCreate(chart_id,name,OBJ_STDDEVCHANNEL,nwin,time1,price1,time2,price2);
   ObjectSetDouble(chart_id,name,OBJPROP_DEVIATION,stdwidth);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//---
  }
//+------------------------------------------------------------------+
//|  Resetting the standard deviation channel                        |
//+------------------------------------------------------------------+
void SetStdDevChannel(long     chart_id,      // chart id
                      string   name,          // object name
                      int      nwin,          // window index
                      datetime time1,         // price level time 1
                      double   price1,        // price level 1
                      datetime time2,         // price level time 2
                      double   price2,        // price level 2
                      double   stdwidth,      // width
                      color    Color,         // line color
                      int      style,         // line style
                      int      width,         // line width
                      string   text)          // text
  {
//---
   if(ObjectFind(chart_id,name)==-1) CreateStdDevChannel(chart_id,name,nwin,time1,price1,time2,price2,stdwidth,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetDouble(chart_id,name,OBJPROP_DEVIATION,stdwidth);
     }
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables
   name1=lines_sirname+" 1";
   name2=lines_sirname+" 2";
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//--- delete the level, if necessary
   ObjectDelete(0,name1);
   ObjectDelete(0,name2);
//---
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- declarations of local variables 
   double;
   datetime iTime[];
//--- copy newly appeared data in the array
   if(CopyTime(NULL,period,STD_Rgres_length,1,iTime)<=0) return(RESET);
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//---
   SetStdDevChannel(0,name1,0,iTime[0],close[STD_Rgres_length],time[0],close[0],STD_Rgres_width,inside_color,inside_style,inside_width,name1);
   SetStdDevChannel(0,name2,0,iTime[0],close[STD_Rgres_length],time[0],close[0],STD_width,widest_color,widest_style,widest_width,name2);
//---
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
