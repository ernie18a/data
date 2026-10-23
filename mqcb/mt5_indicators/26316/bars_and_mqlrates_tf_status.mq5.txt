//+------------------------------------------------------------------+
//| Utility to view status of Bars and MqlRates data availability    |
//+------------------------------------------------------------------+
string shortName="MQLRatesAndBars";
uint uniquifier      = 37501;   // a number to identify custom events from this indicator and make objects unique
#property copyright   "LukeB"
#property link        "https://www.mql5.com/en/users/lukeb"
#property version     "1.00";
#property  description "View TF Bar Count and Mqlrates (CopyRates) data availablity"
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
ENUM_ON_OFF outputLogs = OFF;
//===========================================
const ENUM_TIMEFRAMES TFPeriods[] = {PERIOD_M1,  PERIOD_M2, PERIOD_M3, PERIOD_M4, PERIOD_M5, PERIOD_M6, PERIOD_M10, PERIOD_M12, PERIOD_M15, PERIOD_M20
                                    ,PERIOD_M30, PERIOD_H1, PERIOD_H2, PERIOD_H3, PERIOD_H4, PERIOD_H6, PERIOD_H8,  PERIOD_H12, PERIOD_D1,  PERIOD_W1, PERIOD_MN1};
//===========================================
ENUM_YES_NO useSuggetedBar=NO;
uint suggestedBar = 0;
ENUM_ON_OFF panelDisplay = ON;
string statisticsSymbol;
//=====Start Defining Data for the Display ======================================
enum  ENUM_DISP_OBJ_IDX            { INFO_HDR_IDX,   BAR_ENTRY_IDX, SYMB_HDR_IDX,   SYMB_ENTRY_IDX, BARS_INFO_IDX,  RATES_INFO_IDX,  END_DIP_OBJ_IDX };
ENUM_OBJECT      disp_obj_type[] = { OBJ_LABEL,      OBJ_EDIT,      OBJ_LABEL,      OBJ_EDIT,       OBJ_LABEL,      OBJ_LABEL          };
string           disp_obj_name[] = { "INFO_HDR",     "BAR_ENTRY",   "SYMB_HDR",     "SYMB_ENTRY",   "BARS_INFO",    "RATES_INFO"       };
string            disp_obj_txt[] = { "Bar/Rates OF", "BAR:",        "Symbol:",      "",             "BARS",         "RATES"            };
color             disp_obj_clr[] = { clrLime,        clrDarkBlue,   clrLime,        clrDarkBlue,    clrLime,        clrLime            };
int              disp_obj_size[] = {  12,             10,             12,             9,              10,            10                };
uint                disp_X_pos[] = {  10,             0,              0,              0,              0,             0                 };
uint                disp_Y_pos[] = {  30,             0,              0,              0,              0,             0                 };
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
struct barCountsStruct
 {
   uint barCount;
   string disp;
   int errCode;
 } struc_barCounts[]; // hold the bar count information for each timeframe
uint GetMaxBarCount(const barCountsStruct& ary_barCountsStruc[])  // A utility to find the largets bar count in all the timeframes
 {
   uint maxCount = 0;
   for(int i=0; i<ArrayRange(ary_barCountsStruc,0); i++)
    {
      if(ary_barCountsStruc[i].barCount>maxCount)
         maxCount=ary_barCountsStruc[i].barCount;
    }
   return maxCount;
 }
string msg;
bool barCountsSucceeded = false;
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
   if( ArrayResize(struc_barCounts,ArrayRange(TFPeriods,0)) != ArrayRange(TFPeriods,0) )  // make the tfBarsCount array range match TFPeriods range
    {
      int errCode = GetLastError(); ResetLastError();
      msg = __FUNCTION__+" Array Resize Faild for struc_barCounts array, error: "+IntegerToString(errCode); //+", "+ErrorDescription(errCode);
      Print(msg);
      initCode = INIT_FAILED;
    }else if( ArrayResize(struc_tfRates,ArrayRange(TFPeriods,0)) != ArrayRange(TFPeriods,0) )  // make the rates array range match TFPeriods range
    {
      int errCode = GetLastError(); ResetLastError();
      msg = __FUNCTION__+" Array Resize Faild for struc_tfRates[], error: "+IntegerToString(errCode); //+", "+ErrorDescription(errCode);
      Print(msg);
      initCode = INIT_FAILED;
    }else{  // Arrays are the right size to proceed
      statisticsSymbol = _Symbol;   // Defaultto using the Chart Symbol
      uint callerCount=1;           // just for compatibility
      RunTheIndicator(__FUNCTION__, callerCount, TFPeriods, struc_barCounts, struc_tfRates, suggestedBar, useSuggetedBar);  // First display
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
         RunTheIndicator(sparam, callerCount, TFPeriods, struc_barCounts, struc_tfRates, suggestedBar, useSuggetedBar);
       }
    }else if(id==CHARTEVENT_OBJECT_CLICK)
    {
      static uint clickCount=0;  clickCount++;
      if(sparam==disp_obj_name[SYMB_HDR_IDX])   // Control Object; switch from input bar to default display
       {
         useSuggetedBar = (useSuggetedBar==YES)?NO:YES;
         RunTheIndicator(__FUNCTION__, clickCount, TFPeriods, struc_barCounts, struc_tfRates, suggestedBar, useSuggetedBar);
         ChartRedraw(ChartID());
       }else if(sparam==IntegerToString(uniquifier)+"ROW20|5")    // Turn outputing log information on and off
       {
         outputLogs = ((outputLogs==OFF)?ON:OFF);
         DisplayThePanel(struc_barCounts, struc_tfRates);    // Display with color change
         ChartRedraw(ChartID());
       }
    }else if(id==CHARTEVENT_OBJECT_DRAG){  //sparam = Name of the moved graphical object
      if( sparam==disp_obj_name[INFO_HDR_IDX] )  // This is the drage object, the pannel has been drug to a new location, display the panel at that location.
       {
         disp_X_pos[INFO_HDR_IDX] = (uint) ObjectGetInteger( ChartID(), sparam, OBJPROP_XDISTANCE, NOMODIFIER );   // Get after-drag Move Object Position
         disp_Y_pos[INFO_HDR_IDX] = (uint) ObjectGetInteger( ChartID(), sparam, OBJPROP_YDISTANCE, NOMODIFIER );   // Get after-drag Move Object Position
         SetObjXYPositions();
         DisplayThePanel(struc_barCounts, struc_tfRates);    // Display at the new position
         ChartRedraw(ChartID());
       }
    }else if( id==CHARTEVENT_OBJECT_ENDEDIT)
    {
      static uint editCount=0; editCount++;
      if(sparam==disp_obj_name[BAR_ENTRY_IDX])   // suggested Bar input, process user input.
       {
         int enteredBar = (int) StringToInteger(ObjectGetString(WINDOW_ZERO,disp_obj_name[BAR_ENTRY_IDX],OBJPROP_TEXT,0));
         if( enteredBar<0 ) enteredBar=0;
         uint maxBarNum = GetMaxBarCount(struc_barCounts);
         if(enteredBar>(int)maxBarNum) enteredBar=(int)maxBarNum;
         suggestedBar = enteredBar;
         useSuggetedBar = YES;
         RunTheIndicator(__FUNCTION__, editCount, TFPeriods, struc_barCounts, struc_tfRates, suggestedBar, useSuggetedBar);
         ChartRedraw(ChartID());
       }else if(sparam==disp_obj_name[SYMB_ENTRY_IDX])    // User input of a new symbol, process user input.
       {
         string enteredText = ObjectGetString(WINDOW_ZERO,disp_obj_name[SYMB_ENTRY_IDX],OBJPROP_TEXT,0);
         StringToUpper(enteredText);
         if(GetMarketSymbol(enteredText))  // Check to see if the entered value matches a market watch symbol
          {
            statisticsSymbol = enteredText;
          }
         RunTheIndicator(__FUNCTION__, editCount, TFPeriods, struc_barCounts, struc_tfRates, suggestedBar, useSuggetedBar);
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
   EventChartCustom(ChartID(),CHARTEVENT_RUNINDI, uniquifier, callCount, __FUNCTION__);  // Post an event to get bar counts for each time frame
   return rates_total;
 }
// ===   RunTheIndicator gets called from OnChartEvent ====================
void RunTheIndicator(const string caller, const uint& callerCount, const ENUM_TIMEFRAMES& tfPeriods[], barCountsStruct& barCountsStruc_ary[], tfRatesSruct& tfRatesStruc_ary[], const uint& requestedBar, const ENUM_YES_NO& useRequestedBar)
 {
   SetBarCountValues(caller, tfPeriods, barCountsStruc_ary, callerCount);  // Collect Bar Count information using Bars
   SetRatesBarNum(tfRatesStruc_ary, barCountsStruc_ary, suggestedBar, useSuggetedBar);  // Set the number of the bar to use for rates information using CopyRates
   SetCopyRatesAryVals(caller, tfPeriods, barCountsStruc_ary, struc_tfRates, callerCount );  // Set the Rates information (using CopyRates) for the selected Bar
   DisplayThePanel(barCountsStruc_ary, tfRatesStruc_ary);
 }
bool SetBarCountValues(const string caller, const ENUM_TIMEFRAMES& periods_ary[], barCountsStruct& ary_barCountsStruc[], const int& callerCount )  // Put the bar counts in barCount_ary for each period in TFPeriods_ary
 {
   bool succeeded=true;
   if( ArrayRange(periods_ary,0)==ArrayRange(ary_barCountsStruc,0) )  // Safe to proceed, they are the same size, as required
    {
      for(int idx=0; idx<ArrayRange(ary_barCountsStruc,0); idx++)  // loop thru the timeframes stored in periods_ary
       {
         if(SetBarCountForTF( caller, idx, periods_ary, ary_barCountsStruc, callerCount) ) // Get the Bar Count for each TimeFrame; True if Success
          { // Bars Succeeded, output a msg to that effect
            if( outputLogs == ON )
             {
               msg = __FUNCTION__+" Called by "+caller+" \"Bars\" succeeded on caller count "+IntegerToString(callerCount)
                     +". Bar count for "+_Symbol+" in time frame "+GetPeriodText(periods_ary[idx])
                     +" is "+IntegerToString(ary_barCountsStruc[idx].barCount);
               Print(msg);  // Comment(msg);
             }
            ary_barCountsStruc[idx].errCode = 0;  // Clear any errors.
            ary_barCountsStruc[idx].disp = GetPeriodText(periods_ary[idx])+" bars: "+IntegerToString(ary_barCountsStruc[idx].barCount);
            ary_barCountsStruc[idx].barCount --; // decrement by one so it refers to the actual oldest bar
          }
       }
    }
   return succeeded;
 }
bool SetBarCountForTF( const string& caller, const int& idx, const ENUM_TIMEFRAMES& periods_ary[], barCountsStruct& ary_barCountsStruc[], const uint& callerCount)
 {
   bool succeeded = true;
   ResetLastError();
   ary_barCountsStruc[idx].barCount = Bars(statisticsSymbol,periods_ary[idx]);  // Get the Bar count from Bars for the timeframe
   if( ary_barCountsStruc[idx].barCount==0 )  // Bars failed if the value is zero
    {
      ary_barCountsStruc[idx].errCode = GetLastError(); ResetLastError();  // capture the error
      if( outputLogs == ON )
       {
         msg = msg = __FUNCTION__+" called by "+caller+" on caller count "+IntegerToString(callerCount)
                     +" for "+_Symbol+" and Timeframe "+GetPeriodText(periods_ary[idx])+" \"Bars\" failed and posted error "
                     +IntegerToString(ary_barCountsStruc[idx].errCode); // +", "+ErrorDescription(ary_barCountsStruc[idx].errCode);
         Print(msg); // Comment(msg);  // Print details of the Bars error
       }
      ary_barCountsStruc[idx].disp = GetPeriodText(periods_ary[idx])+" ER: "+IntegerToString(ary_barCountsStruc[idx].errCode);
      succeeded = false;
    }
   return succeeded;
 }
void SetRatesBarNum(tfRatesSruct& tfRates_ary[], const barCountsStruct& barCount_ary[], const uint& requestedBar, const ENUM_YES_NO& useRequestedBar)  // determine bar to use in CopyRates
 {
   if( ArrayRange(tfRates_ary,0)==ArrayRange(barCount_ary,0) )  // Safe to proceed, they are the same size, as required
    {
      for( int idx=0; idx<ArrayRange(tfRates_ary,0); idx++)
       {
         if(useRequestedBar==YES)
          {
            if(barCount_ary[idx].barCount>requestedBar)
             {
               tfRates_ary[idx].barNum = requestedBar;
             }else{
               tfRates_ary[idx].barNum = barCount_ary[idx].barCount;
             }
          }else{
            tfRates_ary[idx].barNum = barCount_ary[idx].barCount;
          }
       }
    }
 }
bool SetCopyRatesAryVals(const string caller, const ENUM_TIMEFRAMES& periods_ary[], const barCountsStruct& barCount_ary[], tfRatesSruct& tfRates_ary[], const int callerCount) // put rates in the rates array using CopyRates
 {
   bool succeeded=true;
   for(int i=0; i<ArrayRange(periods_ary,0); i++)
    {
      if( SetRatesForBar(caller, periods_ary[i], tfRates_ary[i], callerCount) ) // Success if true  Call CopyRates for each Timeframe
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
bool SetRatesForBar(const string caller, const ENUM_TIMEFRAMES barTF, tfRatesSruct& ratesStruc, const int callerCount)  // Use CopyRates to get data for a single Bar
 {
   bool succeeded=true;
   if( CopyRates(statisticsSymbol, barTF, ratesStruc.barNum, COPYONEELEMENT, ratesStruc.mqlRates) < 0 ) // get rates.time, rates.open, rates.high, rates.low, rates.close and more
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
//
void DisplayThePanel(const barCountsStruct& barCount_ary[], const tfRatesSruct& tfRatesStruc_ary[])  // Display on the Chart
 {
   int tfIdx=0;
   for(ENUM_DISP_OBJ_IDX objIdx=0; objIdx<BARS_INFO_IDX; objIdx++)  // display the Header
    {
      SetDisplayText(objIdx, barCount_ary[tfIdx], tfRatesStruc_ary[tfIdx]);
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
      for(ENUM_DISP_OBJ_IDX objIdx=BARS_INFO_IDX, itrCount=0; objIdx<END_DIP_OBJ_IDX; objIdx++, itrCount++) //make the row
       {
         disp_Y_pos[objIdx] = disp_Y_pos[SYMB_HDR_IDX] + (20+(15*tfIdx));
         disp_X_pos[objIdx] = disp_X_pos[INFO_HDR_IDX] + (180*itrCount);
         disp_obj_name[objIdx] = IntegerToString(uniquifier)+"ROW"+IntegerToString(tfIdx)+"|"+IntegerToString(objIdx);
         SetDisplayText(objIdx, barCount_ary[tfIdx], tfRatesStruc_ary[tfIdx]);
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
void SetDisplayText(const ENUM_DISP_OBJ_IDX& objIdx, const barCountsStruct& stucBarCount, const tfRatesSruct& srucTfRates)  // Set the Display Text for each display object
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
         disp_obj_txt[SYMB_ENTRY_IDX] = statisticsSymbol;
         break;
      case BARS_INFO_IDX:
         disp_obj_txt[BARS_INFO_IDX] = stucBarCount.disp;
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
//--------------------------------------------------------------------
//