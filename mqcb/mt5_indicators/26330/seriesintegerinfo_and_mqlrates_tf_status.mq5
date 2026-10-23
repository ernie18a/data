//+------------------------------------------------------------------+
//| Utility to view status of Bars and MqlRates data availability    |
//+------------------------------------------------------------------+
string shortName="MQLRatesAndSeriesIntegerInfo";
uint uniquifier      = 37503;   // a number to identify custom events from this indicator and make objects unique
#property copyright   "LukeB"
#property link        "https://www.mql5.com/en/users/lukeb"
#property version     "1.02";  // Left off the row M1 - MN1 identifier in version 1.00.  fixed in 1.02
#property  description "View TF Bar Count retreives with SeriesIntegerInfo and Mqlrates (CopyRates) data availablity"
#property  description "for all the TimeFrames of a Market Symbol"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
// #include <errordescription.mqh>  // errordescription.mqh is found at: https://www.mql5.com/en/code/79
//======= Custome EVENT Definitiions =====================
const ushort CHARTEVENT_RUNINDI = 37500;
//=======
const int COPYONEELEMENT = 1;
const int WINDOW_ZERO    = 0;
const int NOMODIFIER     = 0;
enum  ENUM_YES_NO { YES, NO };
enum  ENUM_ON_OFF { ON, OFF };
ENUM_ON_OFF outputLogs;
//===========================================
const ENUM_TIMEFRAMES TFPeriods[] = {PERIOD_M1,  PERIOD_M2, PERIOD_M3, PERIOD_M4, PERIOD_M5, PERIOD_M6, PERIOD_M10, PERIOD_M12, PERIOD_M15, PERIOD_M20
                                    ,PERIOD_M30, PERIOD_H1, PERIOD_H2, PERIOD_H3, PERIOD_H4, PERIOD_H6, PERIOD_H8,  PERIOD_H12, PERIOD_D1,  PERIOD_W1, PERIOD_MN1};
//===========================================
ENUM_YES_NO useSuggetedBar=NO;
int suggestedBar = 0;
ENUM_ON_OFF panelDisplay = ON;
string statisticsSymbol;
//=====Start Defining Data for the Display ======================================
enum  ENUM_DISP_OBJ_IDX            { INFO_HDR_IDX,   BAR_ENTRY_IDX, SYMB_HDR_IDX,   SYMB_ENTRY_IDX, SERIES_INFO_IDX, RATES_INFO_IDX,  END_DIP_OBJ_IDX };
ENUM_OBJECT      disp_obj_type[] = { OBJ_LABEL,      OBJ_EDIT,      OBJ_LABEL,      OBJ_EDIT,       OBJ_LABEL,       OBJ_LABEL          };
string           disp_obj_name[] = { "INFO_HDR",     "BAR_ENTRY",   "SYMB_HDR",     "SYMB_ENTRY",   "SERIES_INFO",   "RATES_INFO"       };
string            disp_obj_txt[] = { "Bar/Rates OF", "BAR:",        "Symbol:",      "",             "SERIES",        "RATES"            };
color             disp_obj_clr[] = { clrLime,        clrDarkBlue,   clrLime,        clrDarkBlue,    clrLime,         clrLime            };
int              disp_obj_size[] = {  12,             10,             12,             9,             10,              10                };
uint                disp_X_pos[] = {  10,             0,              0,              0,             0,               0                 };
uint                disp_Y_pos[] = {  20,             0,              0,              0,             0,               0                 };
void SetObjXYPositions(void)  // Set Base Positions for Object Display
 {
   disp_X_pos[BAR_ENTRY_IDX]   = disp_X_pos[INFO_HDR_IDX]+110;
   disp_Y_pos[BAR_ENTRY_IDX]   = disp_Y_pos[INFO_HDR_IDX];
   disp_X_pos[SYMB_HDR_IDX]    = disp_X_pos[INFO_HDR_IDX]+180;
   disp_Y_pos[SYMB_HDR_IDX]    = disp_Y_pos[INFO_HDR_IDX];
   disp_X_pos[SYMB_ENTRY_IDX]  = disp_X_pos[INFO_HDR_IDX]+240;
   disp_Y_pos[SYMB_ENTRY_IDX]  = disp_Y_pos[INFO_HDR_IDX];
 }
//======= END Information Panel Display Information ============                                    
struct tfRatesSruct
 {
   string disp;
   uint barNum;
   int errCode;
   MqlRates mqlRates[1];
 } struc_tfRates[];  // hold the Rates values for each timeframe
struct SeriesInfoStruc
 {
   int      m_barsCount;
   datetime m_firstBarDate;
   int      m_firstBarNum;
   bool     m_isSyncronized;
   int      m_barErrCode, m_barDateErrCode, m_syncErrCode;
   void SeriesInfoStruc(void) // Constructor
    {
      setInitialValues();
    }
   void setInitialValues(void)
    {
      m_barErrCode=0; m_barDateErrCode=0; m_syncErrCode=0;
      m_barsCount     = INT_MIN;
      m_firstBarDate  = NULL;
      m_firstBarNum   = INT_MIN;
      m_isSyncronized = false;
    }
   void setBarTimeAndNum(const datetime firstBarTime, const string& symbol, const ENUM_TIMEFRAMES& tf )
    {
      m_firstBarDate = firstBarTime;
      m_firstBarNum  = iBarShift(symbol, tf, firstBarTime, false);
      if(m_firstBarNum < 0)
       {
         int errCode = GetLastError(); ResetLastError();
         Print(__FUNCTION__,", iBarShift for ",GetPeriodText(tf)," produced error "+IntegerToString(errCode)); //,", ",ErrorDescription(errCode));
       }
    }
 } struc_seriesInfo[];  // hold the Rates values for each timeframe
string msg;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
   ENUM_INIT_RETCODE initCode = INIT_SUCCEEDED;
   shortName += IntegerToString(uniquifier);                       // Make objects and the name unique using the uniquifier value
   IndicatorSetString(INDICATOR_SHORTNAME,shortName);              // Give the indicator a name
   SetObjXYPositions();                                            // Set Display Object Positions
   for(int idx=0; idx<ArrayRange(disp_obj_name,0); idx++)  // Add the 'unique' value to the object names
    {
      disp_obj_name[idx] = IntegerToString(uniquifier)+disp_obj_name[idx];
    }
   if( ArrayResize(struc_tfRates,ArrayRange(TFPeriods,0)) != ArrayRange(TFPeriods,0) )  // make the rates array range match TFPeriods range
    {
      int errCode = GetLastError(); ResetLastError();
      msg = __FUNCTION__+" Array Resize Faild for struc_tfRates[], error: "+IntegerToString(errCode); //+", "+ErrorDescription(errCode);
      Print(msg);
      initCode = INIT_FAILED;
    }else if( ArrayResize(struc_seriesInfo,ArrayRange(TFPeriods,0)) != ArrayRange(TFPeriods,0) )  // make the rates array range match TFPeriods range
    {
      int errCode = GetLastError(); ResetLastError();
      msg = __FUNCTION__+" Array Resize Faild for struc_seriesInfo[], error: "+IntegerToString(errCode); //+", "+ErrorDescription(errCode);
      Print(msg);
      initCode = INIT_FAILED;
    }else{  // Arrays are the right size to proceed
      statisticsSymbol = _Symbol;   // Defaultto using the Chart Symbol
      uint callerCount=1;           // just for compatibility
      outputLogs = ON;
      RunTheIndicator(__FUNCTION__, callerCount, statisticsSymbol, TFPeriods, struc_tfRates, struc_seriesInfo, suggestedBar, useSuggetedBar);  // First display
    }
   return initCode;
 }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
   if(StringLen(msg)>0)
    {
      msg=""; Comment(msg);  // removes comment from the chart.
    }
   for(int i=ObjectsTotal(ChartID())-1; i>=0; i-- )  // Delete objects identified with 'uniquifier' as belonging to this indicator
    {
      string objName = ObjectName(ChartID(),i);
      string objSubStr = StringSubstr(objName, 0, StringLen(IntegerToString(uniquifier)));
      if(objSubStr==IntegerToString(uniquifier))
       {
         ObjectDelete(ChartID(),objName);
       }
    }
   ChartRedraw(ChartID()); // makes the on-chart text disapear fast
 }
//+------------------------------------------------------------------+
//| Chart Event Handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
 {
   if(id==CHARTEVENT_CUSTOM+CHARTEVENT_RUNINDI)  // Run the Indicator Customer Event; Do the work of the indicqtor
    {
      if(lparam==uniquifier)   // ensure the event is for this indicator
       {
         int callerCount = (int) dparam;  // Display as from OnCalculate
         RunTheIndicator(sparam, callerCount, statisticsSymbol, TFPeriods, struc_tfRates, struc_seriesInfo, suggestedBar, useSuggetedBar);
       }
    }else if(id==CHARTEVENT_OBJECT_CLICK)
    {
      static uint clickCount=0;  clickCount++;
      if(sparam==disp_obj_name[SYMB_HDR_IDX])   // Control Object; switch from input bar to default display
       {
         useSuggetedBar = (useSuggetedBar==YES)?NO:YES;
         RunTheIndicator(__FUNCTION__, clickCount, statisticsSymbol, TFPeriods, struc_tfRates, struc_seriesInfo, suggestedBar, useSuggetedBar);
         ChartRedraw(ChartID());
       }else if(sparam==IntegerToString(uniquifier)+"ROW20|5")    // Turn outputing log information on and off
       {
         outputLogs = ((outputLogs==OFF)?ON:OFF);
         DisplayThePanel(struc_tfRates, struc_seriesInfo, TFPeriods, statisticsSymbol);    // Display with color change
         ChartRedraw(ChartID());
       }
    }else if(id==CHARTEVENT_OBJECT_DRAG){  //sparam = Name of the moved graphical object
      if( sparam==disp_obj_name[INFO_HDR_IDX] )  // This is the drage object, the pannel has been drug to a new location, display the panel at that location.
       {
         disp_X_pos[INFO_HDR_IDX] = (uint) ObjectGetInteger( ChartID(), sparam, OBJPROP_XDISTANCE, NOMODIFIER );   // Get after-drag Move Object Position
         disp_Y_pos[INFO_HDR_IDX] = (uint) ObjectGetInteger( ChartID(), sparam, OBJPROP_YDISTANCE, NOMODIFIER );   // Get after-drag Move Object Position
         SetObjXYPositions();
         DisplayThePanel(struc_tfRates, struc_seriesInfo, TFPeriods, statisticsSymbol);    // Display at the new position
         ChartRedraw(ChartID());
       }
    }else if( id==CHARTEVENT_OBJECT_ENDEDIT)
    {
      static uint editCount=0; editCount++;
      if(sparam==disp_obj_name[BAR_ENTRY_IDX])   // suggested Bar input, process user input.
       {
         int enteredBar = (int) StringToInteger(ObjectGetString(WINDOW_ZERO,disp_obj_name[BAR_ENTRY_IDX],OBJPROP_TEXT,0));
         if( enteredBar<0 ) enteredBar=0;
         uint maxBarNum = GetMaxBarCount(struc_seriesInfo);
         if(enteredBar>(int)maxBarNum) enteredBar=(int)maxBarNum;
         suggestedBar = enteredBar;
         useSuggetedBar = YES;
         RunTheIndicator(__FUNCTION__, editCount, statisticsSymbol, TFPeriods, struc_tfRates, struc_seriesInfo, suggestedBar, useSuggetedBar);
         ChartRedraw(ChartID());
       }else if(sparam==disp_obj_name[SYMB_ENTRY_IDX])    // User input of a new symbol, process user input.
       {
         string enteredText = ObjectGetString(WINDOW_ZERO,disp_obj_name[SYMB_ENTRY_IDX],OBJPROP_TEXT,0);
         StringToUpper(enteredText);
         if(GetMarketSymbol(enteredText))  // Check to see if the entered value matches a market watch symbol
          {
            statisticsSymbol = enteredText;
          }
         RunTheIndicator(__FUNCTION__, editCount, statisticsSymbol, TFPeriods, struc_tfRates, struc_seriesInfo, suggestedBar, useSuggetedBar);
         ChartRedraw(ChartID());
       }
    }
 }
bool GetMarketSymbol(string& enteredText)  // Check to see if entered text matches a market watch symbol
 {
   bool found = false;
   msg = "";
   for(int i=0; i<SymbolsTotal(true); i++)  // check all the marketwatch symbols
    {
      string symbol = SymbolName(i,true);
      if(StringSubstr(symbol,0,StringLen(enteredText))==enteredText)
       {
         enteredText = symbol;
         found=true;
         break;  //  Quit looking if a match is found
       }
    }
   Print(msg);
   return found;
 }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
 {
   static ulong callCount=0; callCount++;
   if(prev_calculated < 1)  // The first time its run
    {
      outputLogs = OFF;  // Start with loggin off, but allow them to be turned on and off by the user after.
    }
   EventChartCustom(ChartID(),CHARTEVENT_RUNINDI, uniquifier, callCount, __FUNCTION__);  // Post an event to run "RunTheIndicator"
   return rates_total;
 }
// ===   RunTheIndicator gets called from OnChartEvent ====================
void RunTheIndicator(const string caller, const uint& callerCount, const string& statsSymbol, const ENUM_TIMEFRAMES& tfPeriods[]
                     ,tfRatesSruct& tfRatesStruc_ary[], SeriesInfoStruc& seriesInfo_ary[], const uint& requestedBar, const ENUM_YES_NO& useRequestedBar)
 {
   SetSeriesInfoAryVals(caller, statsSymbol, tfPeriods, seriesInfo_ary, callerCount);   // Collect Bar Count information using "SeriesInfoInteger"
   SetRatesBarNum(tfRatesStruc_ary, seriesInfo_ary, suggestedBar, useSuggetedBar);      // Set the number of the bar to use for rates information using CopyRates
   SetCopyRatesAryVals(caller, statsSymbol, tfPeriods, struc_tfRates, callerCount );    // Set the Rates information (using CopyRates) for the selected Bar
   DisplayThePanel(tfRatesStruc_ary, seriesInfo_ary, tfPeriods, statsSymbol);           // Display the collected statistics
 }
//====== Begin Collect Series Info functions ==========
bool SetSeriesInfoAryVals(const string caller, const string& statSymbol, const ENUM_TIMEFRAMES& periods_ary[], SeriesInfoStruc& seriesInfo_ary[], const int callerCount) // put series info into the struc aray using SeriesInfoInteger
 {
   bool succeeded=true;
   for(int i=0; i<ArrayRange(seriesInfo_ary,0); i++)  // seriesInfo_ary and periods_ary MUST have the same number of elements
    {
      if( SetSeriesInfoForTf(caller, statSymbol, periods_ary[i], seriesInfo_ary[i], callerCount) ) // Success if true  Call SetSeriesInfoForTf for each Timeframe
       {
         if( outputLogs == ON )
          {
            msg = __FUNCTION__+" Called by "+caller+" on callerCount "+IntegerToString(callerCount)+" \"SeriesInfoInteger\" succeeded for "
                  +_Symbol+" in time frame "+GetPeriodText(periods_ary[i])+" for symbol "+statSymbol;
            Print(msg);  // Comment(msg);
          }
       }else{
         succeeded = false;
       }
    }
   return succeeded;
 }
bool SetSeriesInfoForTf(const string caller, const string& statSymbol, const ENUM_TIMEFRAMES tf, SeriesInfoStruc& seriesInfoStruc, const int callerCount)  // Use SeriesInfoInteger to get data for a single Bar
 {
   // m_barErrCode=0; m_barDateErrCode=0; m_syncErrCode=0;
   bool succeeded=true;
   long seriesLongInfo;
   if( SeriesInfoInteger(statSymbol, tf, SERIES_BARS_COUNT, seriesLongInfo)==false ) // What is the Bars Count for the timeseries
    {
      seriesInfoStruc.m_barErrCode = GetLastError(); ResetLastError();
      if( outputLogs == ON )
       {
         msg = __FUNCTION__+" Caller: "+caller+", caller count"+IntegerToString(callerCount)+" \"SeriesInfoInteger\" call for bars of Time Frame: "
               +GetPeriodText(tf)+" posted error: "+IntegerToString(seriesInfoStruc.m_barErrCode); //+", "+ErrorDescription(seriesInfoStruc.m_barErrCode);
         Print(msg);  // Comment(msg);
       }
      seriesInfoStruc.m_barsCount = 1;  // There's always at least 1, right?
      succeeded = false;
    }else{
      seriesInfoStruc.m_barsCount = (int) seriesLongInfo;
      seriesInfoStruc.m_barErrCode = 0;
    }
   if( SeriesInfoInteger(statSymbol, tf, SERIES_FIRSTDATE, seriesLongInfo) == false ) // What is the first date for the time series.
    {
      seriesInfoStruc.m_barDateErrCode = GetLastError(); ResetLastError();
      if( outputLogs == ON )
       {
         msg = __FUNCTION__+" Caller: "+caller+", caller count"+IntegerToString(callerCount)+" \"SeriesInfoInteger\" call for First Date of Time Frame: "
               +GetPeriodText(tf)+" posted error: "+IntegerToString(seriesInfoStruc.m_barDateErrCode); //+", "+ErrorDescription(seriesInfoStruc.m_barDateErrCode);
         Print(msg);  // Comment(msg);
       }
      datetime timeCurrent = TimeCurrent();  // There's always bar zero with the current time in it - hopefully...
      seriesInfoStruc.setBarTimeAndNum( timeCurrent, statSymbol, tf );
      succeeded = false;
    }else{
      seriesInfoStruc.setBarTimeAndNum( (datetime) seriesLongInfo, statSymbol, tf );
      seriesInfoStruc.m_barDateErrCode = 0;
    }
   if( SeriesInfoInteger(statSymbol, tf, SERIES_SYNCHRONIZED, seriesLongInfo) == false ) // is terminal data for the timeseries syncronized
    {
      seriesInfoStruc.m_syncErrCode = GetLastError(); ResetLastError();
      if( outputLogs == ON )
       {
         msg = __FUNCTION__+" Caller: "+caller+", caller count"+IntegerToString(callerCount)+" \"SeriesInfoInteger\" call for Synchronization of Time Frame: "
               +GetPeriodText(tf)+" posted error: "+IntegerToString(seriesInfoStruc.m_syncErrCode); //+", "+ErrorDescription(seriesInfoStruc.m_syncErrCode);
         Print(msg);  // Comment(msg);
       }
      seriesInfoStruc.m_isSyncronized = false;  // must be false if it errored out.
      succeeded = false;
    }else{
      seriesInfoStruc.m_isSyncronized = (bool) seriesLongInfo;
      seriesInfoStruc.m_syncErrCode = 0;
    }
   return succeeded;
 }
//====== END Collect Series Info functions ============
//====== Begin Collect CopyRates Info Functions =======
void SetRatesBarNum(tfRatesSruct& tfRates_ary[], SeriesInfoStruc& seriesInfo_ary[], const int& requestedBar, const ENUM_YES_NO& useRequestedBar)  // determine bar to use in CopyRates
 {
   if( ArrayRange(tfRates_ary,0)==ArrayRange(seriesInfo_ary,0) )  // Safe to proceed, they are the same size, as required
    {
      for( int idx=0; idx<ArrayRange(seriesInfo_ary,0); idx++)
       {
         if(useRequestedBar==YES)
          {
            if(seriesInfo_ary[idx].m_barsCount>requestedBar)
             {
               tfRates_ary[idx].barNum = requestedBar;
             }else{
               tfRates_ary[idx].barNum = seriesInfo_ary[idx].m_firstBarNum;
             }
          }else{
            tfRates_ary[idx].barNum = seriesInfo_ary[idx].m_firstBarNum;
          }
       }
    }
 }
bool SetCopyRatesAryVals(const string caller, const string& statsSymbol, const ENUM_TIMEFRAMES& periods_ary[], tfRatesSruct& tfRates_ary[], const int callerCount) // put rates in the rates array using CopyRates
 {
   bool succeeded=true;
   for(int i=0; i<ArrayRange(periods_ary,0); i++) // barCount_ary and periods_ary MUST have the same number of elements
    {
      if( SetRatesForBar(caller, statsSymbol, periods_ary[i], tfRates_ary[i], callerCount) ) // Success if true  Call CopyRates for each Timeframe
       {
         if( outputLogs == ON )
          {
            msg = __FUNCTION__+" Called by "+caller+" on callerCount "+IntegerToString(callerCount)+" \"CopyRates\" succeeded for "
                  +_Symbol+" in time frame "+GetPeriodText(periods_ary[i])+" for bar "+IntegerToString(tfRates_ary[i].barNum);
            Print(msg);
          }
         tfRates_ary[i].disp    = "Bar "+IntegerToString(tfRates_ary[i].barNum)+", "+TimeToString(tfRates_ary[i].mqlRates[0].time,TIME_DATE|TIME_MINUTES);
       }else{
         tfRates_ary[i].disp    = "Bar "+IntegerToString(tfRates_ary[i].barNum)+", ER: "+IntegerToString(tfRates_ary[i].errCode);
         tfRates_ary[i].errCode = 0;  // clear any errors
         succeeded = false;
       }
    }
   return succeeded;
 }
bool SetRatesForBar(const string caller, const string& statsSymbol, const ENUM_TIMEFRAMES barTF, tfRatesSruct& ratesStruc, const int callerCount)  // Use CopyRates to get data for a single Bar
 {
   bool succeeded=true;
   if( CopyRates(statsSymbol, barTF, ratesStruc.barNum, COPYONEELEMENT, ratesStruc.mqlRates) < 0 ) // get rates.time, rates.open, rates.high, rates.low, rates.close and more
    {
      ratesStruc.errCode= GetLastError(); ResetLastError();
      if( outputLogs == ON )
       {
         msg = __FUNCTION__+" Caller: "+caller+", caller count"+IntegerToString(callerCount)+" CopyRates Call for bar: "+IntegerToString(ratesStruc.barNum)
               +" of Time Frame: "+GetPeriodText(barTF)+" posted error: "+IntegerToString(ratesStruc.errCode); //+", "+ErrorDescription(ratesStruc.errCode);
         Print(msg);
       }
      succeeded = false;
    }
   return succeeded;
 }
//====== END Collect CopyRates Info Functions =========
//====== Begin Display functions ======================
void DisplayThePanel(const tfRatesSruct& tfRatesStruc_ary[], const SeriesInfoStruc& seriesInfoStruc[], const ENUM_TIMEFRAMES& tf_ary[], const string& statsSymbol)  // Display on the Chart
 {
   int tfIdx=0;
   for(ENUM_DISP_OBJ_IDX objIdx=0; objIdx<SERIES_INFO_IDX; objIdx++)  // display the Header
    {
      SetDisplayText(objIdx, tf_ary[tfIdx], statsSymbol, tfRatesStruc_ary[tfIdx], seriesInfoStruc[tfIdx]);
      switch (disp_obj_type[objIdx])  // Choose which 'object maker' to use
       {
         case OBJ_LABEL:
            ManageALabel(objIdx);
            break;
         case OBJ_EDIT:
            DisplayABox(objIdx);
       }
 
    }
   for(tfIdx=0; tfIdx<ArrayRange(TFPeriods,0); tfIdx++) // Display one row for each timeframe
    {
      for(ENUM_DISP_OBJ_IDX objIdx=SERIES_INFO_IDX, itrCount=0; objIdx<END_DIP_OBJ_IDX; objIdx++, itrCount++) //make the row
       {
         disp_Y_pos[objIdx] = disp_Y_pos[SYMB_HDR_IDX] + (20+(15*tfIdx));
         disp_X_pos[objIdx] = disp_X_pos[INFO_HDR_IDX]+(itrCount*330);
         disp_obj_name[objIdx] = IntegerToString(uniquifier)+"ROW"+IntegerToString(tfIdx)+"|"+IntegerToString(objIdx);
         SetDisplayText(objIdx, tf_ary[tfIdx], statsSymbol, tfRatesStruc_ary[tfIdx], seriesInfoStruc[tfIdx]);
         switch (disp_obj_type[objIdx])  // The switch could be removed, as there is only OBJ_LABEL here
          {
         case OBJ_LABEL:
            ManageALabel(objIdx);
            break;
         case OBJ_EDIT:
            DisplayABox(objIdx);
          }
       }
    }
 }
void SetDisplayText(const ENUM_DISP_OBJ_IDX& objIdx, const ENUM_TIMEFRAMES& tf, const string& statsSymbol, const tfRatesSruct& srucTfRates, const SeriesInfoStruc& seriesInfoStruc)  // Set the Display Text for each display object
 {
   switch (objIdx)
    {
      case INFO_HDR_IDX:
         if(panelDisplay==ON)
          {
            disp_obj_txt[INFO_HDR_IDX] = "Rates and Bar:";
          }else{  // is OFF
            disp_obj_txt[INFO_HDR_IDX] = "Rates and Bars OFF";
          }
         break;
      case BAR_ENTRY_IDX:
         if(useSuggetedBar==NO)
          {
            disp_obj_txt[BAR_ENTRY_IDX] = "Oldest";
          }else{ // is YES
            disp_obj_txt[BAR_ENTRY_IDX] = IntegerToString(suggestedBar);
          }
         break;
      case SYMB_HDR_IDX:
         disp_obj_txt[SYMB_HDR_IDX] = "Symbol:";
         break;
      case SYMB_ENTRY_IDX:
         disp_obj_txt[SYMB_ENTRY_IDX] = statsSymbol;
         break;
      case SERIES_INFO_IDX:
         disp_obj_txt[SERIES_INFO_IDX] = GetPeriodText(tf)+" "+((seriesInfoStruc.m_isSyncronized==true)?"SYNC":"UN_SYNCH")+", Bars: "+IntegerToString(seriesInfoStruc.m_barsCount)+", Time: "+TimeToString(seriesInfoStruc.m_firstBarDate,TIME_DATE|TIME_MINUTES);
         break;
      case RATES_INFO_IDX:
         disp_obj_txt[RATES_INFO_IDX] = srucTfRates.disp;
         break;
      default:
         if(objIdx<END_DIP_OBJ_IDX)
          {
            disp_obj_txt[objIdx] = "What the Heck "+IntegerToString(objIdx);
          }
          msg = __FUNCTION__+" called with invalid value: "+IntegerToString(objIdx);
          Print(msg); //  Comment(msg);
         break;
    }
 }
//
void DisplayABox(const ENUM_DISP_OBJ_IDX& objIdx) // display user entry boxes
 {
   static long chartID = ChartID();
   string objName = disp_obj_name[objIdx];
   int dispWindow = ObjectFind(chartID,objName);
   if ( dispWindow < 0 ) // if no such object, make it
    {
      ObjectCreate(chartID,objName,OBJ_EDIT,WINDOW_ZERO,     0, 0);
      ObjectSetInteger(chartID,objName,OBJPROP_FONTSIZE,    disp_obj_size[objIdx]);
      ObjectSetString (chartID,objName,OBJPROP_FONT,        "Arial");
      ObjectSetInteger(chartID,objName,OBJPROP_BORDER_COLOR,clrBlack); 
      ObjectSetInteger(chartID,objName,OBJPROP_BGCOLOR,     clrLightGray);
      ObjectSetInteger(chartID,objName,OBJPROP_XSIZE,       60); 
      ObjectSetInteger(chartID,objName,OBJPROP_YSIZE,       20);
      ObjectSetInteger(chartID,objName,OBJPROP_ALIGN,       ALIGN_CENTER); 
      ObjectSetInteger(chartID,objName,OBJPROP_CORNER,      CORNER_LEFT_UPPER);
      ObjectSetInteger(chartID,objName,OBJPROP_ANCHOR,      ANCHOR_LEFT_UPPER);
      ObjectSetInteger(chartID,objName,OBJPROP_READONLY,    false); 
      ObjectSetInteger(chartID,objName,OBJPROP_BACK,        false); 
      ObjectSetInteger(chartID,objName,OBJPROP_SELECTABLE,  false); 
      ObjectSetInteger(chartID,objName,OBJPROP_SELECTED,    false);
      ObjectSetInteger(chartID,objName,OBJPROP_HIDDEN,      true);
    }
   ObjectSetInteger(chartID, objName, OBJPROP_COLOR,     disp_obj_clr[objIdx] );
   ObjectSetInteger(chartID, objName, OBJPROP_XDISTANCE, disp_X_pos[objIdx]   );
   ObjectSetInteger(chartID, objName, OBJPROP_YDISTANCE, disp_Y_pos[objIdx]   );
   ObjectSetString (chartID, objName, OBJPROP_TEXT,      disp_obj_txt[objIdx] );
 }
//+------------------------------------------------------------------+
void ManageALabel(const ENUM_DISP_OBJ_IDX& objIdx)  // Display allthe on-chart labels
 {
   color objColor;
   string objName = disp_obj_name[objIdx];
   if( (outputLogs==ON)&&(objName==IntegerToString(uniquifier)+"ROW20|5"))
    {
      objColor = clrYellowGreen;
    }else{
      objColor = disp_obj_clr[objIdx];
    }
   bool selectable=false;
   if(objIdx==INFO_HDR_IDX)
    {
      selectable=true;  // Enable moving the display location on the chart
    }
   static long chartID = ChartID();
   if ( ObjectFind(chartID,objName) < 0 )  // if no such object, make it
    {
      ObjectCreate    (chartID, objName, OBJ_LABEL, WINDOW_ZERO,  0, 0);
      ObjectSetInteger(chartID, objName, OBJPROP_FONTSIZE,  disp_obj_size[objIdx]);
      ObjectSetString (chartID, objName, OBJPROP_FONT,      "Arial");
      ObjectSetInteger(chartID, objName, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
      ObjectSetInteger(chartID, objName, OBJPROP_ANCHOR,    ANCHOR_LEFT_UPPER);
      ObjectSetInteger(chartID, objName, OBJPROP_BACK,      true); 
      ObjectSetInteger(chartID, objName, OBJPROP_SELECTABLE,selectable); 
      ObjectSetInteger(chartID, objName, OBJPROP_SELECTED,  false); 
      ObjectSetInteger(chartID, objName, OBJPROP_HIDDEN,    true);
    }
   ObjectSetInteger(chartID, objName, OBJPROP_COLOR,     objColor             );
   ObjectSetInteger(chartID, objName, OBJPROP_XDISTANCE, disp_X_pos[objIdx]   );
   ObjectSetInteger(chartID, objName, OBJPROP_YDISTANCE, disp_Y_pos[objIdx]   );
   ObjectSetString (chartID, objName, OBJPROP_TEXT,      disp_obj_txt[objIdx] );
 }
// ====== END Dispoay functions =================
// ====== Begin General Utilities ===============
string GetPeriodText(const ENUM_TIMEFRAMES& tf)  // Utility to get text identifying each Timeframe
 {
   string returnString;
   ENUM_TIMEFRAMES workingTF = tf;
   if(tf == PERIOD_CURRENT)
    {
      workingTF = Period();
    }
   switch (workingTF)
    {
      case PERIOD_M1:  returnString = "M1";  break;
      case PERIOD_M2:  returnString = "M2";  break;
      case PERIOD_M3:  returnString = "M3";  break;
      case PERIOD_M4:  returnString = "M4";  break;
      case PERIOD_M5:  returnString = "M5";  break;
      case PERIOD_M6:  returnString = "M6";  break;
      case PERIOD_M10: returnString = "M10"; break;
      case PERIOD_M12: returnString = "M12"; break;
      case PERIOD_M15: returnString = "M15"; break;
      case PERIOD_M20: returnString = "M20"; break;
      case PERIOD_M30: returnString = "M30"; break;
      case PERIOD_H1:  returnString = "H1";  break;
      case PERIOD_H2:  returnString = "H2";  break;
      case PERIOD_H3:  returnString = "H3";  break;
      case PERIOD_H4:  returnString = "H4";  break;
      case PERIOD_H6:  returnString = "H6";  break;
      case PERIOD_H8:  returnString = "H8";  break;
      case PERIOD_H12: returnString = "H12"; break;
      case PERIOD_D1:  returnString = "D1";  break;
      case PERIOD_W1:  returnString = "W1";  break;
      case PERIOD_MN1: returnString = "MN1"; break;
      default:  returnString = "Unknown: "+IntegerToString(tf);  break;  // whatcha gonna do?
    }
   return returnString;
 }
int GetMaxBarCount(const SeriesInfoStruc& seriesInfoStruc[])  // A utility to find the largest bar count in all the timeframes
 {
   int maxCount = 0;
   for(int i=0; i<ArrayRange(seriesInfoStruc,0); i++)
    {
      if(seriesInfoStruc[i].m_barsCount>maxCount)
         maxCount=seriesInfoStruc[i].m_barsCount;
    }
   return maxCount;
 }
// ====== END General Utilities ===============