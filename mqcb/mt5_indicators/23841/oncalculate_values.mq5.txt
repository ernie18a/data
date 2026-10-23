//+------------------------------------------------------------------+
//|                                           OnCalculate_Values.mq5 |
//|                                            https://forge.mql5.io |
//| MQ4 to MQ5 Migration: https://www.mql5.com/en/articles/81        |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property copyright    "Copyright © 2018-2019, MetaQuotes Software Corp."
#property version      "1.22"
#property link         "https://www.mql5.com/en/users/lukeb"
#property description  "Show the values of the OnCalculate Parameters."
#property description  "Displays Most_Recent_Value / Previous_Value / Start_Up_Value."
#property description  "Version 1.20 added additional controls for seeing and setting as_series and not_series."
#property description  "Author: https://www.mql5.com/en/users/lukeb."
#property strict
// #include <errordescription.mqh>  // errordescription.mqh is found at: https://www.mql5.com/en/code/79
//---- plot Line
#property indicator_buffers 1
#property indicator_plots   1
//---- plot Line display chracteristics such as Color
#property indicator_label1  "Line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- let user control startup of setting to series or not:
enum SERIES_ONOFF {ON, OFF};  // On Off enumberation to control if explicitly setting the array series type is on.
input SERIES_ONOFF StartWithSeriesSet = ON;
//--- indicator buffers
double LineBuffer[];  // Buffer to display the moving aveage line and capture iMA values for display.
//
int    MA_handle = NULL;  // The handle to us to access terminal iMA data
string comment_string="";  // a global value to use for displaying comments
MqlTick last_tick;   // a MQL5 built in Structure to hold data from the last tick (quote) processed in OnCalculate
//+---------------------------------------------------------------------------------------------------------+
//| display object control values and storage arrays ; the Data for making the lable objects of the display |
//+---------------------------------------------------------------------------------------------------------+
enum objectIndicies                   {CALLCOUNTER = 0,   BARSCOUNT,     WINDBARS,      WINDVIS,     BARSFUNC,    IBARSFUNC,    RATESTOTAL, PREVCALCULATED,          TIMEZEROCALC,          TIMEBARSCALC,        IMABARSVAL,        IMAZEROVAL,        OPENCALC,        HIGHCALC,        LOWCALC,        CLOSECALC,      TICKVOLUME,    VOLUMECALC,         ASKBID,     SPREADCALC,               SERIESONOFF, OnCalcEnumEnd };
const ENUM_OBJECT ary_dispObjType[] = {    OBJ_LABEL,     OBJ_LABEL,    OBJ_LABEL,    OBJ_LABEL,    OBJ_LABEL,    OBJ_LABEL,     OBJ_LABEL,      OBJ_LABEL,             OBJ_LABEL,             OBJ_LABEL,         OBJ_LABEL,         OBJ_LABEL,       OBJ_LABEL,       OBJ_LABEL,      OBJ_LABEL,        OBJ_LABEL,       OBJ_LABEL,     OBJ_LABEL,      OBJ_LABEL,      OBJ_LABEL,                 OBJ_LABEL  };
const string     ary_dispObjNames[] = { "Call_Count",   "BarsCount", "WindowBars", "WindVisible",  "BarsFunc",  "iBarsFunc",  "RatesTotal",    "Prev_Calc",      "Time_Zero_Calc",      "Time_Bars_Calc",    "IMA_Bars_VAL",    "IMA_ZERO_VAL",     "Open_Calc",     "High_Calc",     "Low_Calc",     "Close_Calc", "Tick_Vol_Calc", "Volume_Calc",      "ASK-BID",  "Spread_Calc",            "Series_ONOFF"  };
const int         ary_dispObjXPos[] = {           20,            20,           20,           20,           20,           20,            20,             20,                    20,                    20,                20,                20,              20,              20,             20,               20,              20,            20,             20,             20,                        20  };
const int         ary_dispObjYPos[] = {           20,            40,           60,           80,          100,          120,           140,            160,                   180,                   200,               220,               240,             260,             280,            300,              320,             340,           360,            380,            400,                       420  };
const color      ary_dispObjColor[] = {    clrYellow,     clrYellow,    clrYellow,    clrYellow,    clrYellow,    clrYellow,     clrYellow,      clrYellow,             clrYellow,             clrYellow,         clrYellow,    clrYellowGreen,       clrYellow,       clrYellow,      clrYellow,        clrYellow,       clrYellow,     clrYellow,      clrYellow, clrYellowGreen,              clrLimeGreen  };
string              ary_As_Series[] = {           "",            "",           "",           "",           "",           "",            "",             "",                    "",                    "",                "",                "",              "",              "",             "",               "",              "",            "",             "",             "",                        ""  };
string            ary_dispObjText[] = {           "",            "",           "",           "",           "",           "",            "",             "",                    "",                    "",                "",                "",              "",              "",             "",               "",              "",            "",             "",             "",                        ""  };
//--- this Structure has a member variable for each display object - to store the display objects value
struct OnCalcValues                   {uint callCount; int barsCalc; long winBars; long  winVis; int barsFunc;int iBarsFunc;int ratesTotal;   int prevCalc; datetime timeZeroCalc; datetime timeBarsCalc; double IMAZeroVal; double IMABarsVal; double openCalc; double highCalc; double lowCalc; double closeCalc; long tickVolume;   long volume;  int askBidPts;     int spread; SERIES_ONOFF seriesOnOff; };
OnCalcValues ary_OnCalcVals[3];      // store values passed into OnCalculate; Three instances of values - Newest, Prvious and First
//+------------------------------------------------------------------+
//| Program Constants                                                |
//+------------------------------------------------------------------+
const int DISPALYWINDOWZERO  = 0;
const int THECURRENTCHART    = 0;
//--- These constants identify the OnCalcValues structure intance being referenced; the most recent quote, previous quote or the very first Onalculate call.
const int ARRAYNEWVAL        = 0;  // Access the '0' instance of the ary_OnCalcVals array
const int ARRAYPREVVAL       = 1;  // Access the '1' instance of the ary_OnCalcVals array
const int ARRAYONSTARTUP     = ArrayRange(ary_OnCalcVals,0)-1;  // this is the value 2, to access the '2' instance of the ary_OnCalcVals array
const int k_notSetVal = 999;  // An Initializtion value that is easily recognized
//+------------------------------------------------------------------+
//| Program Global Variables                                         |
//+------------------------------------------------------------------+
bool      g_seriesSetting    = true;
bool      g_drawNeedded      = true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   ENUM_INIT_RETCODE init_return_code = INIT_SUCCEEDED;
   IndicatorSetString(INDICATOR_SHORTNAME,"OnCalculate_Values");  // Give the indicator a name
   //
   EventSetTimer(1);  // run the indicator off of a timer instead of off of quotes comming to OnCalculate, except for collectiong the latest quote data
   //
   //--- indicator buffers mapping - there is only the one buffer for the iMA values
   SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
   ArraySetAsSeries(LineBuffer,true);  // Set the IMA Buffer as a series buffer on startup
   int loop_counter = 0;
   do // Get the handle for the iMA data; initialize MA_handle
   {
      loop_counter++;
      if( MA_handle==NULL )               // Get the handle to access the terminal's iMA values
      {
         MA_handle = iMA(_Symbol,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_OPEN);
      }
      if( MA_handle==INVALID_HANDLE )   // Report any error getting the IMA handle
      {
         int error_code = GetLastError(); MA_handle=NULL;
         comment_string = __FUNCTION__+": Failed to Create MA_handle, attempt "+IntegerToString(loop_counter)+", Error: "+IntegerToString(error_code); //+", "+ErrorDescription(error_code);
         Comment(comment_string); Print(comment_string);
         // Sleep(500); // Sleep is not allowed in an Indictor.
         init_return_code = INIT_FAILED;
      }
   } while( (MA_handle==NULL) && (loop_counter<5) );
   //--- Set easily recognized 'not set yet value'
   for(int i= 0; i<ArrayRange(ary_OnCalcVals,0); i++ )  // Initialize the data values in all instances of the structure to an easily recognized value
   {
      ary_OnCalcVals[i].callCount=k_notSetVal;     ary_OnCalcVals[i].barsCalc=k_notSetVal;      ary_OnCalcVals[i].winBars=k_notSetVal;    ary_OnCalcVals[i].winVis=k_notSetVal;
      ary_OnCalcVals[i].barsFunc=k_notSetVal;      ary_OnCalcVals[i].iBarsFunc=k_notSetVal;     ary_OnCalcVals[i].ratesTotal=k_notSetVal; ary_OnCalcVals[i].prevCalc=k_notSetVal;
      ary_OnCalcVals[i].timeZeroCalc=k_notSetVal;  ary_OnCalcVals[i].timeBarsCalc=k_notSetVal;  ary_OnCalcVals[i].IMAZeroVal=k_notSetVal; ary_OnCalcVals[i].IMABarsVal=k_notSetVal;
      ary_OnCalcVals[i].openCalc=k_notSetVal;      ary_OnCalcVals[i].highCalc=k_notSetVal;      ary_OnCalcVals[i].lowCalc=k_notSetVal;    ary_OnCalcVals[i].closeCalc=k_notSetVal;
      ary_OnCalcVals[i].lowCalc=k_notSetVal;       ary_OnCalcVals[i].closeCalc=k_notSetVal;     ary_OnCalcVals[i].tickVolume=k_notSetVal; ary_OnCalcVals[i].volume=k_notSetVal;
      ary_OnCalcVals[i].askBidPts=k_notSetVal;     ary_OnCalcVals[i].spread=k_notSetVal;
   }
   //---
   ary_OnCalcVals[ARRAYNEWVAL].callCount = 0;  // initialize the call counter; the call counter counts the number of times OnCalculate is called.
   ary_OnCalcVals[ARRAYNEWVAL].seriesOnOff=StartWithSeriesSet;           // start with explicit setting to 'As_Series'
   return init_return_code;
}
//+------------------------------------------------------------------+
//| Indicator removal event handler                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  // When removed, the indicator should clean up after itself.
{
   EventKillTimer();  // Stop the timer
   for (int i = 0; i < OnCalcEnumEnd; i++)  // Delete all the dispaly objects
   {
      ObjectDelete(THECURRENTCHART,ary_dispObjNames[i]);
   }
   if(StringLen(comment_string)>0)  // If there is a Comment made by this indicator, remove the Comment display.
   {
      comment_string=""; Comment(comment_string);
   }
   ChartRedraw(ChartID()); // Redraw the chart without the display objects
}
//+------------------------------------------------------------------+
//| Chart Event Handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   bool chartRedraw = false; // no need for a chart redraw
   if(id==CHARTEVENT_OBJECT_CLICK)  // A chart object has been clicked.
   {
      if( sparam==ary_dispObjNames[SERIESONOFF] ) // Object to toggle the setting of arrays on or off has been clicked
      {
         ary_OnCalcVals[ARRAYNEWVAL].seriesOnOff = ary_OnCalcVals[ARRAYNEWVAL].seriesOnOff==ON?OFF:ON;  // Toggle the value
         chartRedraw=true;  // need to perform a chart redraw
      }
     else if( sparam==ary_dispObjNames[SPREADCALC] ) // Object to toggle the setting of arrays to series or not as series has been clicked
      {
         g_seriesSetting = g_seriesSetting==true?false:true;  // Toggle the value
         chartRedraw=true;  // need to perform a chart redraw
      }
     else if( sparam==ary_dispObjNames[IMAZEROVAL] ) // Object to toggle the series setting of the Line Buffer has been clicked
      {
         if(ArrayGetAsSeries(LineBuffer)) // check the value and toggle the series value
          {
            ArraySetAsSeries(LineBuffer,false);  // Set the IMA Buffer as not series
          }
         else
          {
            ArraySetAsSeries(LineBuffer,true);  // Set the IMA Buffer as a series
          }
         int total_bars = iBars(_Symbol,PERIOD_CURRENT);
         GetTerminalIMAData(total_bars,total_bars); // re-make the entire IMA buffer (LineBuffer)
         chartRedraw=true;  // need to perform a chart redraw
      }
   }
   else if(id==CHARTEVENT_CHART_CHANGE)  // The chart has been changed in some say, often its size has been changed with this event occurs.
   {
      SetChartBarValues();    // Function gets the chart bar counts
      chartRedraw=true;  // need to perform a chart redraw
   }
  if( chartRedraw ) // display with the changed settings
   {
      DisplayOnCalcValues();  // Set display values for all the display objects
      ChartRedraw(ChartID()); // Redraw the chart with the new values
   }
}
//+------------------------------------------------------------------+
//| Timer Event Fuction                                              |
//+------------------------------------------------------------------+
void  OnTimer(void)
{
   static long timer_count=0; timer_count++;
   // comment_string = "Timer Call Count: "+IntegerToString(timer_count);
   // Comment(comment_string);
   //+------------------------------------------------------------------+
   //| Display the Old and New Values                                   |
   //+------------------------------------------------------------------+
   if( (g_drawNeedded==true) || (!MathMod(timer_count,10.0)) ) // Detect if a redraw is needed, use MathMod to refresh at intervals if needed or not.
   {
      DisplayOnCalcValues();
      // comment_string = "Timer Call Count: "+IntegerToString(timer_count)+", Redraw state: "+(g_drawNeedded?"TRUE":"FALSE");
      g_drawNeedded = false;
      
   }
   // Comment(comment_string);
   //
}
long tick_count, start_ticks, finish_ticks, call_count=0;
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long& tick_volume[], const long& volume[], const int& spread[] )
{
   // start_ticks = GetTickCount();
   int toCopy;  // This indiates the number of data elements that should be coppied from the terminal to the Linebuffer (the moving averages buffer
   SetToCopyCount(toCopy, rates_total, prev_calculated);
   if(ary_OnCalcVals[ARRAYNEWVAL].seriesOnOff == ON)  // If seeting the series characteristics of the varialbes is on, do it
   {
     SetAsSeries( g_seriesSetting, time, open, high, low, close, tick_volume, volume, spread);
   }
   //+------------------------------------------------------------------+
   //| Save Previous On Calculate values into the Array                 |
   //+------------------------------------------------------------------+
   CopyNewToOld(ary_OnCalcVals[ARRAYNEWVAL].callCount);  // Place current new values into previous values, as the indicator will now get new values
   ary_OnCalcVals[ARRAYNEWVAL].callCount ++;             // Track number of calls to OnCalculate
   //+------------------------------------------------------------------+
   //| Find out if the arrays are series or not                         |
   //+------------------------------------------------------------------+
   DetermineSeriesStatus( time, open, high, low, close, tick_volume, volume, spread );
   //
   //+------------------------------------------------------------------+
   //| Load the new On Calculae values into the array                   |
   //+------------------------------------------------------------------+
   LoadOnCalculateValues(rates_total, prev_calculated, time, open, high, low, close, tick_volume, volume, spread);
   //
   //+------------------------------------------------------------------+
   //| Get Terminal iMA data for the MA Line (LineBuffer)               |
   //+------------------------------------------------------------------+
   GetTerminalIMAData(rates_total, toCopy);
   //
   //+--------------------------------------------------------------------------------+
   //| Load bars function and iMA values for comparison to the OnCalculate values     |
   //+--------------------------------------------------------------------------------+
   LoadOtherValues();
   //
   //finish_ticks = GetTickCount();
   //tick_count = finish_ticks-start_ticks;
   //comment_string = "Duration: "+IntegerToString(tick_count)+", Call Count: "+IntegerToString(ary_OnCalcVals[ARRAYNEWVAL].callCount);
   //Print(comment_string);
   //
   g_drawNeedded = true;  // Re-display the indicator with the next timer event.
   return rates_total;
}
//+------------------------------------------------------------------+
//| Load the new On Calculae values into the array                   |
//+------------------------------------------------------------------+
void LoadOnCalculateValues(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], 
     const double &high[], const double &low[], const double &close[], const long& tick_volume[], const long& volume[], const int& spread[] )
{
    ary_OnCalcVals[ARRAYNEWVAL].ratesTotal   = rates_total;
    ary_OnCalcVals[ARRAYNEWVAL].prevCalc     = prev_calculated;
    ary_OnCalcVals[ARRAYNEWVAL].timeZeroCalc = time[0];
    ary_OnCalcVals[ARRAYNEWVAL].timeBarsCalc = time[rates_total-1];
    ary_OnCalcVals[ARRAYNEWVAL].openCalc     = open[0];
    ary_OnCalcVals[ARRAYNEWVAL].highCalc     = high[0];
    ary_OnCalcVals[ARRAYNEWVAL].lowCalc      = low[0];
    ary_OnCalcVals[ARRAYNEWVAL].closeCalc    = close[0];
    ary_OnCalcVals[ARRAYNEWVAL].tickVolume   = tick_volume[0];
    ary_OnCalcVals[ARRAYNEWVAL].volume       = volume[0];
    ary_OnCalcVals[ARRAYNEWVAL].spread       = spread[0];
}
//+------------------------------------------------------------------+
//| Find out if the arrays are series or not                         |
//+------------------------------------------------------------------+
void DetermineSeriesStatus( const datetime &time[], const double &open[], const double &high[],
     const double &low[], const double &close[], const long& tick_volume[], const long& volume[], const int& spread[] )
{
    ary_As_Series[TIMEZEROCALC] = ArrayGetAsSeries(time)       ?"As_Series":"Not_Series";
    ary_As_Series[TIMEBARSCALC] = ary_As_Series[TIMEZEROCALC]; // Same buffer (time)
    ary_As_Series[OPENCALC]     = ArrayGetAsSeries(open)       ?"As_Series":"Not_Series";
    ary_As_Series[HIGHCALC]     = ArrayGetAsSeries(high)       ?"As_Series":"Not_Series";
    ary_As_Series[LOWCALC]      = ArrayGetAsSeries(low)        ?"As_Series":"Not_Series";
    ary_As_Series[CLOSECALC]    = ArrayGetAsSeries(close)      ?"As_Series":"Not_Series";
    ary_As_Series[TICKVOLUME]   = ArrayGetAsSeries(tick_volume)?"As_Series":"Not_Series";
    ary_As_Series[VOLUMECALC]   = ArrayGetAsSeries(volume)     ?"As_Series":"Not_Series";
    ary_As_Series[SPREADCALC]   = ArrayGetAsSeries(spread)     ?"As_Series":"Not_Series";
}
//+------------------------------------------------------------------+
//| Get Terminal iMA data for the MA Line (LineBuffer)               |
//+------------------------------------------------------------------+
void GetTerminalIMAData(const int& rates_total, const int& toCopy)
{
    if(CopyBuffer(MA_handle,0,0,toCopy,LineBuffer)<=0)  // copy iMA terminal data to the LineBuffer array; 0 or less, nothing was copied.
    {
      int err_code = GetLastError();
      comment_string = __FUNCTION__+": Getting MA data failed, asked for "+IntegerToString(toCopy)+" bars, Error: "+IntegerToString(err_code); // +", "+ErrorDescription(err_code);
      Comment(comment_string); Print(comment_string);
      ary_OnCalcVals[ARRAYNEWVAL].IMAZeroVal     = k_notSetVal;
      ary_OnCalcVals[ARRAYNEWVAL].IMABarsVal     = k_notSetVal;
    }
    else
    {
      ary_OnCalcVals[ARRAYNEWVAL].IMAZeroVal     = LineBuffer[0];
      ary_OnCalcVals[ARRAYNEWVAL].IMABarsVal     = LineBuffer[rates_total-1];
    }
}
//+------------------------------------------------------------------+
//| Load bars functions for comparison to the OnCalculate values     |
//+------------------------------------------------------------------+
void LoadOtherValues(void)
{
    ary_OnCalcVals[ARRAYNEWVAL].barsCalc   = BarsCalculated(MA_handle);  // Find out how many bars the terminal has finished calculations for
    ary_OnCalcVals[ARRAYNEWVAL].barsFunc   = Bars(Symbol(), Period());   // Find out the total number of bars in the Chart's timeseries.
    ary_OnCalcVals[ARRAYNEWVAL].iBarsFunc  = iBars(Symbol(),Period());   // Find out the total number of bars in the Chart's timeseries.
    //
    ary_As_Series[IMAZEROVAL]              = ArrayGetAsSeries(LineBuffer)?"As_Series":"Not_Series";  // Find out if the LineBuffer is 'as series' or 'not-as-series'
    ary_As_Series[IMABARSVAL]              = ary_As_Series[IMAZEROVAL]; // Same buffer; LineBuffer
    //
    SetChartBarValues();  // Get the Chart Bars and the Charts Visible Bars
    // Get the Ask and Bid values, calculate the spread
    SymbolInfoTick(_Symbol,last_tick);  // Last tick is a structure type defined by MQL5
    double ask = last_tick.ask;
    double bid = last_tick.bid;
    ary_OnCalcVals[ARRAYNEWVAL].askBidPts  = (int) ((ask-bid)/_Point);  // this is the most recent spread in points.
}
//+-----------------------------------------------------------------------------------------------------------------+
//| Create check for a new bar also ensure it loads on the first call - not used in the OnCalculate_Values indicator|
//+-----------------------------------------------------------------------------------------------------------------+
bool ThereIsANewBar(const datetime& time[])
{
   bool newBar = false;
   static datetime lastBarTime=0;
   if ( (time[0] > lastBarTime) || (1 == ary_OnCalcVals[ARRAYNEWVAL].callCount) )
   {
      lastBarTime = time[0];
      newBar = true;
   }
   return newBar;
}
void SetChartBarValues(void)
{
   ary_OnCalcVals[ARRAYNEWVAL].winBars = ChartGetInteger(ChartID(),CHART_VISIBLE_BARS);       // How many Bars are on the chart
   ary_OnCalcVals[ARRAYNEWVAL].winVis  = ChartGetInteger(ChartID(),CHART_FIRST_VISIBLE_BAR);  // What is the number of the first (oldest) bar on the chart
}
//+------------------------------------------------------------------+
//| Create text for each label to display the values                 |
//+------------------------------------------------------------------+
void CopyNewToOld(int CallCount)
{
   if (CallCount == 1 )  //  Coopy each value in the ARRAYNEWVAL array position to the ARRAYONSTARTUP position.
   {
      MoveNewTo(ARRAYONSTARTUP);  // store the first calls values to the startup alues location
   }
   MoveNewTo(ARRAYPREVVAL); // copy the value in the ARRAYNEWVAL to the ARRAYPREVVAL index position
}
void MoveNewTo(int aryIndx)  // copy the value in the ARRAYNEWVAL to the passed index position
{
      ary_OnCalcVals[aryIndx].callCount      = ary_OnCalcVals[ARRAYNEWVAL].callCount;
      ary_OnCalcVals[aryIndx].barsCalc       = ary_OnCalcVals[ARRAYNEWVAL].barsCalc;
      ary_OnCalcVals[aryIndx].winBars        = ary_OnCalcVals[ARRAYNEWVAL].winBars;
      ary_OnCalcVals[aryIndx].winVis         = ary_OnCalcVals[ARRAYNEWVAL].winVis;
      ary_OnCalcVals[aryIndx].IMAZeroVal     = ary_OnCalcVals[ARRAYNEWVAL].IMAZeroVal;
      ary_OnCalcVals[aryIndx].IMABarsVal     = ary_OnCalcVals[ARRAYNEWVAL].IMABarsVal;
      ary_OnCalcVals[aryIndx].barsFunc       = ary_OnCalcVals[ARRAYNEWVAL].barsFunc;
      ary_OnCalcVals[aryIndx].iBarsFunc      = ary_OnCalcVals[ARRAYNEWVAL].iBarsFunc;
      ary_OnCalcVals[aryIndx].ratesTotal     = ary_OnCalcVals[ARRAYNEWVAL].ratesTotal;
      ary_OnCalcVals[aryIndx].prevCalc       = ary_OnCalcVals[ARRAYNEWVAL].prevCalc;
      ary_OnCalcVals[aryIndx].timeZeroCalc   = ary_OnCalcVals[ARRAYNEWVAL].timeZeroCalc;
      ary_OnCalcVals[aryIndx].timeBarsCalc   = ary_OnCalcVals[ARRAYNEWVAL].timeBarsCalc;
      ary_OnCalcVals[aryIndx].openCalc       = ary_OnCalcVals[ARRAYNEWVAL].openCalc;
      ary_OnCalcVals[aryIndx].highCalc       = ary_OnCalcVals[ARRAYNEWVAL].highCalc;
      ary_OnCalcVals[aryIndx].lowCalc        = ary_OnCalcVals[ARRAYNEWVAL].lowCalc;
      ary_OnCalcVals[aryIndx].closeCalc      = ary_OnCalcVals[ARRAYNEWVAL].closeCalc;
      ary_OnCalcVals[aryIndx].tickVolume     = ary_OnCalcVals[ARRAYNEWVAL].tickVolume;
      ary_OnCalcVals[aryIndx].volume         = ary_OnCalcVals[ARRAYNEWVAL].volume;
      ary_OnCalcVals[aryIndx].askBidPts      = ary_OnCalcVals[ARRAYNEWVAL].askBidPts;
      ary_OnCalcVals[aryIndx].spread         = ary_OnCalcVals[ARRAYNEWVAL].spread;
      ary_OnCalcVals[aryIndx].seriesOnOff    = ary_OnCalcVals[ARRAYNEWVAL].seriesOnOff;
}
void DisplayOnCalcValues(void)
{
   for (int i = 0; i < OnCalcEnumEnd; i++)  // Access each display object and make its display text.
   {
      SetLabelObjectText(i);
   }
}
void SetLabelObjectText(const int ObjectID)  // Make Text for the display object at the passsed index
{
   string barsNumString = IntegerToString(ary_OnCalcVals[ARRAYNEWVAL].barsFunc-1);
   string promptString;
   switch(ObjectID)          //  Switch on the display objects:  Include not-lable objects to creater debug msg if erroneously called.
   {
      case CALLCOUNTER:
         ary_dispObjText[ObjectID] = "OnCalc Calls: "+IntegerToString(ary_OnCalcVals[ARRAYNEWVAL].callCount)+" / "+IntegerToString(ary_OnCalcVals[ARRAYPREVVAL].callCount)+" / "+IntegerToString(ary_OnCalcVals[ARRAYONSTARTUP].callCount);
         MakeALabel(ObjectID);
         break;
      case BARSCOUNT:
         ary_dispObjText[ObjectID] = "Bars Calculated: "+IntegerToString(ary_OnCalcVals[ARRAYNEWVAL].barsCalc)+" / "+IntegerToString(ary_OnCalcVals[ARRAYPREVVAL].barsCalc)+" / "+IntegerToString(ary_OnCalcVals[ARRAYONSTARTUP].barsCalc);
         MakeALabel(ObjectID);
         break;
      case WINDBARS:
         ary_dispObjText[ObjectID] = "Window Bars: "+IntegerToString(ary_OnCalcVals[ARRAYNEWVAL].winBars)+" / "+IntegerToString(ary_OnCalcVals[ARRAYPREVVAL].winBars)+" / "+IntegerToString(ary_OnCalcVals[ARRAYONSTARTUP].winBars);
         MakeALabel(ObjectID);
         break;
      case WINDVIS:
         ary_dispObjText[ObjectID] = "First Visible Bar #: "+IntegerToString(ary_OnCalcVals[ARRAYNEWVAL].winVis)+" / "+IntegerToString(ary_OnCalcVals[ARRAYPREVVAL].winVis)+" / "+IntegerToString(ary_OnCalcVals[ARRAYONSTARTUP].winVis);
         MakeALabel(ObjectID);
         break;
      case IMAZEROVAL:
         ary_dispObjText[ObjectID] =  "iMA_Val[0], "+ary_As_Series[ObjectID]+": "+DoubleToString(ary_OnCalcVals[ARRAYNEWVAL].IMAZeroVal,_Digits+1)+" / "+DoubleToString(ary_OnCalcVals[ARRAYPREVVAL].IMAZeroVal,_Digits)+" / "+DoubleToString(ary_OnCalcVals[ARRAYONSTARTUP].IMAZeroVal,_Digits);
         MakeALabel(ObjectID);
         break;
      case IMABARSVAL:
         ary_dispObjText[ObjectID] =  "iMA_Val["+barsNumString+"], "+ary_As_Series[ObjectID]+": "+DoubleToString(ary_OnCalcVals[ARRAYNEWVAL].IMABarsVal,_Digits+1)+" / "+DoubleToString(ary_OnCalcVals[ARRAYPREVVAL].IMABarsVal,_Digits)+" / "+DoubleToString(ary_OnCalcVals[ARRAYONSTARTUP].IMABarsVal,_Digits);
         MakeALabel(ObjectID);
         break;
      case IBARSFUNC:
         ary_dispObjText[ObjectID] = " iBars Func: "+IntegerToString(ary_OnCalcVals[ARRAYNEWVAL].iBarsFunc)+" / "+IntegerToString(ary_OnCalcVals[ARRAYPREVVAL].iBarsFunc)+" / "+IntegerToString(ary_OnCalcVals[ARRAYONSTARTUP].iBarsFunc);
         MakeALabel(ObjectID);
         break;
      case BARSFUNC:
         ary_dispObjText[ObjectID] = "Bars Func: "+IntegerToString(ary_OnCalcVals[ARRAYNEWVAL].barsFunc)+" / "+IntegerToString(ary_OnCalcVals[ARRAYPREVVAL].barsFunc)+" / "+IntegerToString(ary_OnCalcVals[ARRAYONSTARTUP].barsFunc);
         MakeALabel(ObjectID);
         break;
      case RATESTOTAL:
         ary_dispObjText[ObjectID] = "Rates Total: "+IntegerToString(ary_OnCalcVals[ARRAYNEWVAL].ratesTotal)+" / "+IntegerToString(ary_OnCalcVals[ARRAYPREVVAL].ratesTotal)+" / "+IntegerToString(ary_OnCalcVals[ARRAYONSTARTUP].ratesTotal);
         MakeALabel(ObjectID);
         break;
      case PREVCALCULATED:
         ary_dispObjText[ObjectID] = "Previous Calculated: "+IntegerToString(ary_OnCalcVals[ARRAYNEWVAL].prevCalc)+" / "+IntegerToString(ary_OnCalcVals[ARRAYPREVVAL].prevCalc)+" / "+IntegerToString(ary_OnCalcVals[ARRAYONSTARTUP].prevCalc);
         MakeALabel(ObjectID);
         break;
      case TIMEZEROCALC:    
         ary_dispObjText[ObjectID] = "time[0], "+ary_As_Series[ObjectID]+": "+TimeToString(ary_OnCalcVals[ARRAYNEWVAL].timeZeroCalc)+" / "+TimeToString(ary_OnCalcVals[ARRAYPREVVAL].timeZeroCalc)+" / "+TimeToString(ary_OnCalcVals[ARRAYONSTARTUP].timeZeroCalc);
         MakeALabel(ObjectID);
         break;
      case TIMEBARSCALC:    
         ary_dispObjText[ObjectID] = "time["+barsNumString+"], "+ary_As_Series[ObjectID]+": "+TimeToString(ary_OnCalcVals[ARRAYNEWVAL].timeBarsCalc)+" / "+TimeToString(ary_OnCalcVals[ARRAYPREVVAL].timeBarsCalc)+" / "+TimeToString(ary_OnCalcVals[ARRAYONSTARTUP].timeBarsCalc);
         MakeALabel(ObjectID);
         break;
      case OPENCALC:  
         ary_dispObjText[ObjectID] = "open[0], "+ary_As_Series[ObjectID]+": "+DoubleToString(ary_OnCalcVals[ARRAYNEWVAL].openCalc,_Digits+1)+" / "+DoubleToString(ary_OnCalcVals[ARRAYPREVVAL].openCalc,_Digits)+" / "+DoubleToString(ary_OnCalcVals[ARRAYONSTARTUP].openCalc,_Digits);
         MakeALabel(ObjectID);
         break;
      case HIGHCALC:
         ary_dispObjText[ObjectID] = "high[0], "+ary_As_Series[ObjectID]+": "+DoubleToString(ary_OnCalcVals[ARRAYNEWVAL].highCalc,_Digits+1)+" / "+DoubleToString(ary_OnCalcVals[ARRAYPREVVAL].highCalc,_Digits)+" / "+DoubleToString(ary_OnCalcVals[ARRAYONSTARTUP].highCalc,_Digits);
         MakeALabel(ObjectID);
         break;
      case LOWCALC:
         ary_dispObjText[ObjectID] = "low[0], "+ary_As_Series[ObjectID]+": "+DoubleToString(ary_OnCalcVals[ARRAYNEWVAL].lowCalc,_Digits+1)+" / "+DoubleToString(ary_OnCalcVals[ARRAYPREVVAL].lowCalc,_Digits)+" / "+DoubleToString(ary_OnCalcVals[ARRAYONSTARTUP].lowCalc,_Digits);
         MakeALabel(ObjectID);
         break;
      case CLOSECALC:
         ary_dispObjText[ObjectID] = "close[0], "+ary_As_Series[ObjectID]+": "+DoubleToString(ary_OnCalcVals[ARRAYNEWVAL].closeCalc,_Digits+1)+" / "+DoubleToString(ary_OnCalcVals[ARRAYPREVVAL].closeCalc,_Digits)+" / "+DoubleToString(ary_OnCalcVals[ARRAYONSTARTUP].closeCalc,_Digits);
         MakeALabel(ObjectID);
         break;
      case TICKVOLUME:
         ary_dispObjText[ObjectID] = "tick_volume[0], "+ary_As_Series[ObjectID]+": "+IntegerToString(ary_OnCalcVals[ARRAYNEWVAL].tickVolume)+" / "+IntegerToString(ary_OnCalcVals[ARRAYPREVVAL].tickVolume)+" / "+IntegerToString(ary_OnCalcVals[ARRAYONSTARTUP].tickVolume);
         MakeALabel(ObjectID);
         break;
      case VOLUMECALC:
         ary_dispObjText[ObjectID] = "volume[0], "+ary_As_Series[ObjectID]+": "+IntegerToString(ary_OnCalcVals[ARRAYNEWVAL].volume)+" / "+IntegerToString(ary_OnCalcVals[ARRAYPREVVAL].volume)+" / "+IntegerToString(ary_OnCalcVals[ARRAYONSTARTUP].volume);
         MakeALabel(ObjectID);
         break;
      case ASKBID:
         ary_dispObjText[ObjectID] = "Ask-Bid pts: "+IntegerToString(ary_OnCalcVals[ARRAYNEWVAL].askBidPts)+" / "+IntegerToString(ary_OnCalcVals[ARRAYPREVVAL].askBidPts)+" / "+IntegerToString(ary_OnCalcVals[ARRAYONSTARTUP].askBidPts);
         MakeALabel(ObjectID);
         break;
      case SPREADCALC:
         ary_dispObjText[ObjectID] = "spread[0], "+ary_As_Series[ObjectID]+": "+IntegerToString(ary_OnCalcVals[ARRAYNEWVAL].spread)+" / "+IntegerToString(ary_OnCalcVals[ARRAYPREVVAL].spread)+" / "+IntegerToString(ary_OnCalcVals[ARRAYONSTARTUP].spread);
         MakeALabel(ObjectID);
         break;
      case SERIESONOFF:
         promptString = g_seriesSetting?"Set Arrays to Series: ":"Set Arrays to Not_Series: ";
         ary_dispObjText[ObjectID] = promptString+(ary_OnCalcVals[ARRAYNEWVAL].seriesOnOff==ON?"ON":"OFF")+" / "+(ary_OnCalcVals[ARRAYPREVVAL].seriesOnOff==ON?"ON":"OFF")+" / "+(ary_OnCalcVals[ARRAYONSTARTUP].seriesOnOff==ON?"ON":"OFF");
         MakeALabel(ObjectID);
         break;
      default:
         comment_string = __FUNCTION__+" error: Got an Undefined Object ID: "+IntegerToString(ObjectID);
         break;
   }
}
//+------------------------------------------------------------------+
//| Display Label objects                                            |
//+------------------------------------------------------------------+
void MakeALabel(int displayOjectIndex)   // Display Text for the passed index
{
   long chartID = ChartID();
   int windowIndex=ObjectFind(ChartID(),ary_dispObjNames[displayOjectIndex]); // Find which window the object is in (does it exist?)
   if(windowIndex<0) // No window found with the object in it - Create the object
   {
      ObjectCreate(THECURRENTCHART,     ary_dispObjNames[displayOjectIndex], OBJ_LABEL, DISPALYWINDOWZERO, 0, 0);      // Create on window 0
      ObjectSetInteger(THECURRENTCHART, ary_dispObjNames[displayOjectIndex], OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);      //  Attach the text to the corner of the lable.
      ObjectSetInteger(THECURRENTCHART, ary_dispObjNames[displayOjectIndex], OBJPROP_HIDDEN, true);                    // Hidden, must press 'all' to see in object list
      // ObjectSetInteger(THECURRENTCHART, ary_dispObjNames[displayOjectIndex], OBJPROP_HIDDEN, false);                // Can be seen in object list
      ObjectSetInteger(THECURRENTCHART, ary_dispObjNames[displayOjectIndex], OBJPROP_SELECTABLE, true);                // True, Can be selected; properties seen with right click
      ObjectSetInteger(THECURRENTCHART, ary_dispObjNames[displayOjectIndex], OBJPROP_SELECTED,   false);               // false, not selected on creation
      ObjectSetInteger(THECURRENTCHART, ary_dispObjNames[displayOjectIndex], OBJPROP_CORNER, CORNER_RIGHT_LOWER);      // attach the lable to the corner of the chart
      ObjectSetInteger(THECURRENTCHART, ary_dispObjNames[displayOjectIndex], OBJPROP_FONTSIZE,  11);                   // Set the font size
      ObjectSetString (THECURRENTCHART, ary_dispObjNames[displayOjectIndex], OBJPROP_FONT,      "Arial");              // Set the font
      ObjectSetInteger(THECURRENTCHART, ary_dispObjNames[displayOjectIndex], OBJPROP_COLOR,     ary_dispObjColor[displayOjectIndex]);  // Set the color
   }
   ObjectSetInteger(THECURRENTCHART, ary_dispObjNames[displayOjectIndex], OBJPROP_XDISTANCE, ary_dispObjXPos[displayOjectIndex]);             // justify at xPos from the right
   ObjectSetInteger(THECURRENTCHART, ary_dispObjNames[displayOjectIndex], OBJPROP_YDISTANCE, ary_dispObjYPos[displayOjectIndex]);             // place at yPos from the top
   ObjectSetString (THECURRENTCHART, ary_dispObjNames[displayOjectIndex], OBJPROP_TEXT,      ary_dispObjText[displayOjectIndex]);             // set the text
}
//
//+------------------------------------------------------------------+
//| Set the number of terminal bars data to copy                     |
//+------------------------------------------------------------------+
void SetToCopyCount(int& to_copy, const int& rates_total, const int& prev_calculated) // Set the bar to use to start calulations
{
   if( (prev_calculated < 1) || (rates_total<prev_calculated) ) // Indicator has not ran for the first time or # of bars has changed.
   {
      to_copy = rates_total;
   }
   else //--- indicator has previously ran; not all data needs to be copied or re-evaluated
   {
      to_copy = (rates_total - prev_calculated)+1;
   }
}
void SetAsSeries(const bool& as_series, const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long& tick_volume[],
                const long& volume[], const int& spread[] )
{
   ArraySetAsSeries(time,as_series);   ArraySetAsSeries(open,as_series);   ArraySetAsSeries(high,as_series);
   ArraySetAsSeries(low,as_series);    ArraySetAsSeries(close,as_series);  ArraySetAsSeries(tick_volume,as_series);
   ArraySetAsSeries(volume,as_series); ArraySetAsSeries(spread,as_series);
}
//
