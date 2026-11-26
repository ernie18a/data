//+------------------------------------------------------------------+
//|                                                   NxBreakout.mq5 |
//|                                      Copyright © 2005, Bill Sica |
//|                                         http://www.tetsuyama.com |
//+------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2005, Bill Sica"
//--- a link to the website of the author
#property link      "http://www.tetsuyama.com"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- no buffers are used for the calculation and drawing of the indicator
#property indicator_buffers 0
//--- 0 graphical plots are used
#property indicator_plots   0
//+----------------------------------------------+
//| declaration of constants                     |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Declaration of enumeration                   |
//+----------------------------------------------+
enum Width
  {
   Width_1=1, //1
   Width_2,   //2
   Width_3,   //3
   Width_4,   //4
   Width_5    //5
  };
//+----------------------------------------------+
//| Declaration of enumeration                   |
//+----------------------------------------------+
enum STYLE
  {
   SOLID_,       //Solid line
   DASH_,        //Dashed line
   DOT_,         //Dotted line
   DASHDOT_,     //Dot-dash line
   DASHDOTDOT_   // Dot-dash line with double dots
  };
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_D1; // Chart period
input uint  StartBar=1;                    // Starting bar for analysis
input uint  HowManyBars=5;                 // Number of bars for analysis
//---
input color  Color_R=clrMediumSeaGreen;    // Color of the resistance level
input STYLE  Style_R=SOLID_;               // Line style of the resistance level
input Width  Width_R=Width_2;              // Width of the resistance level line
//---
input color  Color_S=clrRed;               // Color of the support level
input STYLE  Style_S=SOLID_;               // Line style of the support level
input Width  Width_S=Width_2;              // Width of the support level line
//+------------------------------------------------------------------+
//| Getting a timeframe as a line                                    |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+
//| Creating horizontal price level                                  |
//+------------------------------------------------------------------+
void CreateHline(long   chart_id,      // Chart ID
                 string name,          // object name
                 int    nwin,          // window index
                 double price,         // price level
                 color  Color,         // line color
                 int    style,         // line style
                 int    width,         // line width
                 string text)          // text
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
//| Resetting the horizontal price level                             |
//+------------------------------------------------------------------+
void SetHline(long   chart_id,      // chart ID
              string name,          // object name
              int    nwin,          // window index
              double price,         // price level
              color  Color,         // line color
              int    style,         // line style
              int    width,         // line width
              string text)          // text
  {
//---
   if(ObjectFind(chart_id,name)==-1) CreateHline(chart_id,name,nwin,price,Color,style,width,text);
   else
     {
      //ObjectSetDouble(chart_id,name,OBJPROP_PRICE,price);
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
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Chart period for the NxBreakout indicator cannot be less than the current chart period");
      return(INIT_FAILED);
     }
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"NxBreakout( ",GetStringTimeframe(TimeFrame)," )");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//---
   ObjectDelete(0,"R_Line");
   ObjectDelete(0,"S_Line");
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
//--- 
   if(Bars(_Symbol,TimeFrame)<int(StartBar+HowManyBars)) return(RESET);
//--- declarations of local variables 
   double iHigh[],iLow[];
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(iHigh,true);
   ArraySetAsSeries(iLow,true);
//--- copy newly appeared data in the arrays
   if(CopyHigh(_Symbol,TimeFrame,StartBar,HowManyBars,iHigh)<int(HowManyBars)) return(RESET);
   if(CopyLow(_Symbol,TimeFrame,StartBar,HowManyBars,iLow)<int(HowManyBars)) return(RESET);
//--- finding extrema
   double HH=NormalizeDouble(iHigh[ArrayMaximum(iHigh,0,HowManyBars)],_Digits);
   double LL=NormalizeDouble(iLow[ArrayMinimum(iLow,0,HowManyBars)],_Digits);
//--- drawing horizontal levels on a chart
   SetHline(0,"R_Line",0,HH,Color_R,Style_R,Width_R,"R_Line"+DoubleToString(HH,_Digits));
   SetHline(0,"S_Line",0,LL,Color_S,Style_S,Width_S,"S_Line"+DoubleToString(LL,_Digits));
//---
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
