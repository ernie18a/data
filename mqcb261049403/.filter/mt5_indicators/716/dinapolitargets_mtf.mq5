//+------------------------------------------------------------------+
//|                                          DinapoliTargets_MTF.mq5 |
//|                                       Copyright © 2007, mishanya |
//|                                            mishanya_fx@yahoo.com |
//+------------------------------------------------------------------+
//--- author of the indicator
#property copyright "Copyright © 2007, mishanya"
//--- link to the website of the author
#property link      "mishanya_fx@yahoo.com"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- number of the indicator buffers
#property indicator_buffers 1
#property indicator_plots   1
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Declaration of enumeration                  |
//+----------------------------------------------+  
enum WIDTH
  {
   Width_1=1, // 1
   Width_2,   // 2
   Width_3,   // 3
   Width_4,   // 4
   Width_5    // 5
  };
//+----------------------------------------------+
//|  Declaration of enumeration                  |
//+----------------------------------------------+
enum STYLE
  {
   SOLID_,      // Solid line
   DASH_,       // Dashed line
   DOT_,        // Dotted line
   DASHDOT_,    // Dot-dash line
   DASHDOTDOT_  // Dot-dash line with double dots
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; // Chart period
input uint Length=6;                       // Smoothing period
input uint EndBar=1;                       // End bar for calculation
//---
input color  Start_line_Color=Magenta;     // Start level color
input STYLE  Start_line_Style = SOLID_;    // Start level style
input WIDTH  Start_line_Width = Width_2;   // Start line width
//---
input color  Target1_line_Color= Green;    // Target1 level color
input STYLE  Target1_line_Style = DASH_;   // Target1 level style
input WIDTH  Target1_line_Width= Width_1;  // Target1 level width
//---
input color  Target2_line_Color= Orange;   // Target2 level color
input STYLE  Target2_line_Style = DASH_;   // Target2 level style
input WIDTH  Target2_line_Width= Width_1;  // Target2 level width
//---
input color  Target3_line_Color= DarkOrchid; // Target3 level color
input STYLE  Target3_line_Style = DASH_;     // Target3 level style
input WIDTH  Target3_line_Width= Width_1;    // Target3 level width
//---
input color  Stop_line_Color= Red;      // Stop-loss level color
input STYLE  Stop_line_Style = DASH_;   // Stop-loss level style
input WIDTH  Stop_line_Width= Width_1;  // End level width
//+----------------------------------------------+
//--- declaration of global variables
bool   Init;
//--- declaration of a dynamic array that
//--- will be used as an indicator buffer
double Dinapolis[];
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int Dinapoli_Handle;
//+------------------------------------------------------------------+
//|  Creating horizontal price level                                 |
//+------------------------------------------------------------------+
void CreateHline(long   chart_id,   // chart ID
                 string name,       // object name
                 int    nwin,       // window index
                 double price,      // price level
                 color  Color,      // line color
                 int    style,      // line style
                 int    width,      // line width
                 string text)       // text
  {
//---
   ObjectCreate(chart_id,name,OBJ_HLINE,0,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//---
  }
//+------------------------------------------------------------------+
//|  Reinstallation of the horizontal price level                    |
//+------------------------------------------------------------------+
void SetHline(long   chart_id,   // chart ID
              string name,       // object name
              int    nwin,       // window index
              double price,      // price level
              color  Color,      // line color
              int    style,      // line style
              int    width,      // line width
              string text)       // text
  {
//---
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateHline(chart_id,name,nwin,price,Color,style,width,text);
     }
   else
     {
      // ObjectSetDouble(chart_id,name,OBJPROP_PRICE,price);
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
     }
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("DinapoliTargets indicator chart period cannot be less than the current chart period");
      Init=false;
      return(1);
     }

//--- getting handle of the DinapoliTargets indicator
   Dinapoli_Handle=iCustom(NULL,TimeFrame,"DinapoliTargets",Length,EndBar,
                           Start_line_Color,Start_line_Style,Start_line_Width,
                           Target1_line_Color,Target1_line_Style,Target1_line_Width,
                           Target2_line_Color,Target2_line_Style,Target2_line_Width,
                           Target3_line_Color,Target3_line_Style,Target3_line_Width,
                           Stop_line_Color,Stop_line_Style,Stop_line_Width);
   if(Dinapoli_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the DinapoliTargets indicator");
      return(1);
     }

//--- initialization of variables of the start of data calculation
   min_rates_total=int((Length+4)*PeriodSeconds(TimeFrame)/PeriodSeconds());

//--- set Dinapolis[] dynamic array as an indicator buffer
   SetIndexBuffer(0,Dinapolis,INDICATOR_CALCULATIONS);
//--- indexing the elements in the indicator buffer as timeseries  
   ArraySetAsSeries(Dinapolis,true);

//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//--- create labels to display in DataWindow 
//--- and a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"Dinapoli Targets");
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//---

//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &Time[],
                const double &Open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &Close[],
                const long &Tick_volume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- checking the number of bars to be enough for the calculation
   if(BarsCalculated(Dinapoli_Handle)<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(Dinapoli_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
