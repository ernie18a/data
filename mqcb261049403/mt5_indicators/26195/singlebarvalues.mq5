//+------------------------------------------------------------------+
//|       Show Single Bar Values with different ways of getting them |
//+------------------------------------------------------------------+
string shortName = "SingleBarValues";
#property copyright   "LukeB"
#property link        "https://www.mql5.com/en/users/lukeb"
#property version     "1.00";
#property description "Display Single Bar Values."
#property strict
// #include <errordescription.mqh>  // errordescription.mqh is found at: https://www.mql5.com/en/code/79 
//----
#property indicator_chart_window
//======= Custome EVENT Definitiions CHARTEVENT_CUSTOM_LAST — the last acceptable ID of a custom event (CHARTEVENT_CUSTOM +65535).
const ushort CHARTEVENT_MAKECHART = 37;
// Global Variables
const int WINDOW_ZERO = 0;
const int CHARTWINDOW = 0;
const int NOSHIFT     = 0;
const int COPYONEELEMENT      = 1;
enum ANCHOR_POINTS {ANCHOR_POINT_ZERO, ANCHOR_POINT_ONE};
enum BAR_INFO_MECH {COPY_FUNCS, RATES, DIRECT};
enum PERIOD_PARTS  {PART_ONE, PART_TWO};
enum ENUM_ON_OFF   {OFF, ON};
ENUM_TIMEFRAMES    workingTF;
ENUM_MA_METHOD     workingMaMethod;
BAR_INFO_MECH      workingMechanism;
// ========= User Input ====================
input int         Uniquifier       = 3;  // Display Offset and Unique Instance Number
input ENUM_ON_OFF DirectClick         = ON; // select bars with a mouse click
//======== Control Object Names ============================
enum   ENUM_CTRL_IDX   { BAR_UP,      BAR_DN,       PERIOD_START,    PERIOD_END,        INFO_MECH,    endObjIdx};
string ctrlObjName[] = { "BAR_UP",    "BAR_DN",     "PERIOD_START",  "PERIOD_END",      "INFO_MECH"    };
int    objXPos[]     = { 10,          60,           170,              220,              270            };
int    objYPos[]     = { 0,           0,            0,                0,                0              };
color  objClr[]      = {clrLimeGreen, clrLimeGreen, clrLimeGreen,     clrLimeGreen,     clrLimeGreen, clrLimeGreen   };
//========= Info Object Names ===========================
enum   INF_DISP_IDX    {INFO_HDR,        INFO_OPEN,      INFO_HIGH,      INFO_LOW,       INFO_CLOSE,      INFO_TIME,  endInfoIdx};
string infObjName[]  = {"INFO_HDR",      "INFO_OPEN",    "INFO_HIGH",    "INFO_LOW",     "INFO_CLOSE",    "INFO_TIME"           };
int    infXPos[]     = { 10,             10,             10,             10,             10,              10                    };
int    infYPos[]     = { 0,              0,              0,              0,              0,               0                     };
color  infClr[]      = { clrYellowGreen, clrYellowGreen, clrYellowGreen, clrYellowGreen, clrYellowGreen,  clrYellowGreen        };
//====================================
// ----- Make structures to hold display display object information -------------
struct BoxStruct
 {
   string editBoxName;
   int displayValue;
   int xPos;
   int yPos;
 } barNumBox = {"BarNumBox", 1, 110, 30};
struct RectStruct
 {
   string           rectName;
   ENUM_LINE_STYLE lineStyle;
   int             lineWidth;
   color           fillClr;
   double          topPrice, bottomPrice;
   datetime        startTime, endTime;
 } barRectangle = {"BarRectangle", STYLE_DASHDOT, 1, clrOldLace, 0,0,0 ,0};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
   int succeeded = INIT_SUCCEEDED;
   shortName += (IntegerToString(Uniquifier));
   IndicatorSetString(INDICATOR_SHORTNAME,shortName);  // Give the indicator a name
   workingTF        = getPeriodCurrent();
   workingMaMethod  = MODE_SMA;
   workingMechanism = RATES;
   for( ENUM_CTRL_IDX i=0; i<endObjIdx; i++ )
    {
      objYPos[i] = 10*Uniquifier;
      ctrlObjName[i] += IntegerToString(Uniquifier);
    }
   for( INF_DISP_IDX  i=0; i<endInfoIdx; i++ )
    {
      infYPos[i] = (16*Uniquifier)+(i*18);
      infObjName[i] += IntegerToString(Uniquifier);
    }
   barNumBox.editBoxName += IntegerToString(Uniquifier);
   barRectangle.rectName += IntegerToString(Uniquifier);
   //----
   runDisplay();
   return(succeeded);
 }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
   long chartID = ChartID();
   for(ENUM_CTRL_IDX i=0; i<endObjIdx; i++)
    {
      ObjectDelete(chartID,ctrlObjName[i]);
    }
   for( INF_DISP_IDX  i=0; i<endInfoIdx; i++ )
    {
      ObjectDelete(chartID,infObjName[i]);
    }
   // ObjectsDeleteAll(chartID);
   ObjectDelete(chartID,barNumBox.editBoxName);
   ObjectDelete(chartID,barRectangle.rectName);
 }
//+------------------------------------------------------------------+
//| expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
 {
   bool display = false;
   if( (id==CHARTEVENT_OBJECT_ENDEDIT) && (sparam==barNumBox.editBoxName) )
    {
      int boxValue = (int) StringToInteger(ObjectGetString(WINDOW_ZERO,barNumBox.editBoxName,OBJPROP_TEXT,0));
      int bars = iBars(_Symbol,workingTF);
      if( !((boxValue>-1) && (boxValue<bars)) )
       {
         barNumBox.displayValue = 1;
       }
      else
       {
         barNumBox.displayValue = boxValue;
       }
      display=true;
    }else if(id==CHARTEVENT_OBJECT_CLICK)
    {
      if(sparam==ctrlObjName[BAR_UP])
       {
         int bars = iBars(_Symbol,workingTF);
         if( (barNumBox.displayValue+1)<bars )
          {
            barNumBox.displayValue++;
          }
         else
          {
            barNumBox.displayValue = 0;
          }
         display=true;
       }
      if(sparam==ctrlObjName[BAR_DN])
       {
         int bars = iBars(_Symbol,workingTF);
         if( (barNumBox.displayValue-1)>=0 )
          {
            barNumBox.displayValue--;
          }
         else
          {
            barNumBox.displayValue = (bars-1);
          }
         display=true;
       }
      if( sparam==ctrlObjName[PERIOD_START] )
       {
         bool set = false;
         while (!set)   // If there are not enough bars, cycle until there is a TF with enough bars (the current TF had enough)
          {
            workingTF = getNextTF(workingTF);
            int bars = iBars(_Symbol,workingTF);
            if( barNumBox.displayValue < bars )
             {
               set=true;
             }
          }
         display=true;;
       }
      if( sparam==ctrlObjName[PERIOD_END] )
       {
         bool set = false;
         while (!set)  // If there are not enough bars, cycle until there is a TF with enough bars (the current TF had enough)
          {
            workingTF = getPreviousTF(workingTF);
            int bars = iBars(_Symbol,workingTF);
            if( barNumBox.displayValue < bars )
             {
               set=true;
             }
          }
         display=true;;
       }
      if(sparam==ctrlObjName[INFO_MECH])
       {
         workingMechanism = getNextMec(workingMechanism);
         display=true;
       }
    }else if( (id==CHARTEVENT_CLICK) && (DirectClick == ON) )
    {
      datetime chartClickTime;
      double   chartClickPrice;
      int windowNumber = 0;
      if( ChartXYToTimePrice( ChartID(), (int)lparam, (int)dparam, windowNumber, chartClickTime, chartClickPrice) )
       {
         int barNum = iBarShift(_Symbol, workingTF, chartClickTime, false);
         if( barNum > -1 )
          {
            barNumBox.displayValue = barNum;
            display=true;
          }else{
            int errCode = GetLastError();
            Print(__FUNCTION__," at ",TimeToString(chartClickTime,TIME_DATE|TIME_MINUTES)," iBarShift generated error: ",IntegerToString(errCode)); // ,", ",ErrorDescription(errCode));
          }
       }else{
         int errCode = GetLastError();
         Print(__FUNCTION__," ChartXYToTimePrice generated error: ",IntegerToString(errCode)); //,", ",ErrorDescription(errCode));
       }
    }else if(id==CHARTEVENT_CUSTOM+CHARTEVENT_MAKECHART)  // Request to Draw the Indicator Dashboard
    {
      if(lparam==Uniquifier)
       {
         runDisplay();
       }
    }
   if( display == true )
    {
      EventChartCustom(ChartID(),CHARTEVENT_MAKECHART, Uniquifier, NULL, NULL);  // Post an event to refresh the display.
    }
 }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
 {
      if( ( rates_total - prev_calculated > 0 ) )// new bar
       {
         EventChartCustom(ChartID(),CHARTEVENT_MAKECHART, Uniquifier, NULL, NULL);  // Post an event to refresh the display.
       }else if(barNumBox.displayValue<1)  // Redraw for bar zero with every quote
       {
         EventChartCustom(ChartID(),CHARTEVENT_MAKECHART, Uniquifier, NULL, NULL);  // Post an event to refresh the display.
       }
      return rates_total ;
 }
void displayControls(void)
 {
   displayABox(barNumBox);
   for(ENUM_CTRL_IDX i=0; i<endObjIdx; i++)
    {
      string dispText = getPromptTxt(i);
      manageALabel(ctrlObjName[i], dispText, objXPos[i], objYPos[i], objClr[i], 10);
    }
 }
void runDisplay(void)
 {
   static ulong callCount=0; callCount++;
   int barNum = barNumBox.displayValue, catlen;
   string barStr = IntegerToString(barNum);
   static double barClose, barHigh, barLow, barOpen, price[1];
   static MqlRates rates[1];
   datetime theTime=NULL, barTime[1];
   string hdrString, closeString, openString, highString, lowString, timeString;
   displayControls();
   ResetLastError();
   switch (workingMechanism)  // enum BAR_INFO_MECH {ARRAYS, IMAS, COPY_FUNCS, RATES};
    {
      case COPY_FUNCS:
         if( CopyClose(_Symbol,workingTF,barNum,COPYONEELEMENT,price)>-1) { barClose = price[0]; }else{int errCode = GetLastError(); ResetLastError(); PostTerminalError("CopyClose", barNum, workingTF, errCode, callCount);}
         if( CopyHigh(_Symbol,workingTF,barNum,COPYONEELEMENT,price)>-1) { barHigh = price[0]; }else{int errCode = GetLastError(); ResetLastError(); PostTerminalError("CopyHigh", barNum, workingTF, errCode, callCount);}
         if( CopyLow(_Symbol,workingTF,barNum,COPYONEELEMENT,price)>-1) { barLow = price[0]; }else{int errCode = GetLastError(); ResetLastError(); PostTerminalError("CopyLow", barNum, workingTF, errCode, callCount);}
         if( CopyOpen(_Symbol,workingTF,barNum,COPYONEELEMENT,price)>-1) { barOpen = price[0]; }else{int errCode = GetLastError(); ResetLastError(); PostTerminalError("CopyOpen", barNum, workingTF, errCode,callCount);}
         if( CopyTime(_Symbol,workingTF,barNum,COPYONEELEMENT,barTime)>-1) { theTime = barTime[0]; }else{int errCode = GetLastError(); ResetLastError(); PostTerminalError("CopyTime", barNum, workingTF, errCode,callCount);}
         catlen   = StringConcatenate(hdrString,"Bar: ",IntegerToString(barNum),"; Range: ",DoubleToString(barHigh-barLow,_Digits) );
         catlen   = StringConcatenate(closeString,"CopyClose = ",DoubleToString(barClose,_Digits) );
         catlen   = StringConcatenate(openString,"CopyOpen = ",DoubleToString(barOpen,_Digits) );
         catlen   = StringConcatenate(highString,"CopyHigh = ",DoubleToString(barHigh,_Digits) );
         catlen   = StringConcatenate(lowString,"CopyLow = ",DoubleToString(barLow,_Digits) );
         catlen   = StringConcatenate(timeString,"CopyTime = ",TimeToString(theTime,TIME_DATE|TIME_MINUTES) );
         break;
       case DIRECT:
         barClose = iClose(_Symbol,workingTF,barNum);
         if( barClose==0){int errCode = GetLastError(); ResetLastError(); PostTerminalError("iClose", barNum, workingTF, errCode, callCount);}
         barHigh = iHigh(_Symbol,workingTF,barNum);
         if( barHigh==0){int errCode = GetLastError(); ResetLastError(); PostTerminalError("iHigh", barNum, workingTF, errCode, callCount);}
         barLow = iLow(_Symbol,workingTF,barNum);
         if( barLow==0){int errCode = GetLastError(); ResetLastError(); PostTerminalError("iLow", barNum, workingTF, errCode, callCount);}
         barOpen = iOpen(_Symbol,workingTF,barNum);
         if( barOpen==0){int errCode = GetLastError(); ResetLastError(); PostTerminalError("iOpen", barNum, workingTF, errCode,callCount);}
         theTime = iTime(_Symbol,workingTF,barNum);
         if( theTime==NULL){int errCode = GetLastError(); ResetLastError(); PostTerminalError("iTime", barNum, workingTF, errCode,callCount);}
         catlen   = StringConcatenate(hdrString,"Bar: ",IntegerToString(barNum),"; Range: ",DoubleToString(barHigh-barLow,_Digits) );
         catlen   = StringConcatenate(closeString,"iClose = ",DoubleToString(barClose,_Digits) );
         catlen   = StringConcatenate(openString,"iOpen = ",DoubleToString(barOpen,_Digits) );
         catlen   = StringConcatenate(highString,"iHigh = ",DoubleToString(barHigh,_Digits) );
         catlen   = StringConcatenate(lowString,"iLow = ",DoubleToString(barLow,_Digits) );
         catlen   = StringConcatenate(timeString,"iTime = ",TimeToString(theTime,TIME_DATE|TIME_MINUTES) );
         break;
      case RATES: // fall thru with RATES as the default
      default:  // Just use RATES as the default
         if( CopyRates(_Symbol,workingTF,barNum,COPYONEELEMENT,rates) < 0 ) // get rates.time, rates.open, rates.high, rates.low, rates.close and more
          {
            int errCode = GetLastError(); ResetLastError();
            PostTerminalError("CopyRates", barNum, workingTF, errCode, callCount);
          }
         barClose = rates[0].close;
         barHigh  = rates[0].high;
         barLow   = rates[0].low;
         barOpen  = rates[0].open;
         theTime  = rates[0].time;
         catlen   = StringConcatenate(hdrString,"Bar: ",IntegerToString(barNum),"; Range: ",DoubleToString(barHigh-barLow,_Digits) );
         catlen   = StringConcatenate(closeString,"rates[].close = ",DoubleToString(barClose,_Digits) );
         catlen   = StringConcatenate(openString,"rates[].open  = ",DoubleToString(barOpen,_Digits) );
         catlen   = StringConcatenate(highString,"rates[].high  = ",DoubleToString(barHigh,_Digits) );
         catlen   = StringConcatenate(lowString,"rates[].low   = ",DoubleToString(barLow,_Digits) );
         catlen   = StringConcatenate(timeString,"rates[].time  = ",TimeToString(theTime,TIME_DATE|TIME_MINUTES) );
         break;
    }
   //
   manageALabel(infObjName[INFO_HDR], hdrString, infXPos[INFO_HDR], infYPos[INFO_HDR], infClr[INFO_HDR], 11);
   manageALabel(infObjName[INFO_CLOSE], closeString, infXPos[INFO_CLOSE], infYPos[INFO_CLOSE], infClr[INFO_CLOSE], 11);
   manageALabel(infObjName[INFO_OPEN], openString, infXPos[INFO_OPEN], infYPos[INFO_OPEN], infClr[INFO_OPEN], 11);
   manageALabel(infObjName[INFO_HIGH], highString, infXPos[INFO_HIGH], infYPos[INFO_HIGH], infClr[INFO_HIGH], 11);
   manageALabel(infObjName[INFO_LOW], lowString, infXPos[INFO_LOW], infYPos[INFO_LOW], infClr[INFO_LOW], 11);
   manageALabel(infObjName[INFO_TIME], timeString, infXPos[INFO_TIME], infYPos[INFO_TIME], infClr[INFO_TIME], 11);
   //
   barRectangle.topPrice    = barHigh;
   barRectangle.bottomPrice = barLow;
   barRectangle.startTime   = theTime;
   if( CopyTime(_Symbol,_Period,NOSHIFT,COPYONEELEMENT,barTime)>-1)  // Get the Chart's bar Zero time Succeeded
    {  
      if( barTime[0] < (theTime+PeriodSeconds(workingTF)) ) // Not working with statistics of bars inside chart bar zero
       {
         barRectangle.endTime = barTime[0]+PeriodSeconds(PERIOD_CURRENT);
       }
      else
       {
         barRectangle.endTime = theTime+PeriodSeconds(workingTF);
       }
    }else{ // Copytime Failure
      int errCode = GetLastError(); ResetLastError();
      int zeroBar=0;
      PostTerminalError("CopyTime", zeroBar, workingTF, errCode, callCount);
      barRectangle.endTime=TimeCurrent();
    }

   //
   makeARectangle(barRectangle);
 }
void PostTerminalError( const string operation, const int& barNum, const ENUM_TIMEFRAMES& tf, const int& errCode, const ulong& callCount)
 {
   Print( "Call: ",IntegerToString(callCount)," for ",operation," for bar: ",IntegerToString(barNum)," of Time Frame: ",getPeriodText(tf, PART_TWO)," posted error: "+IntegerToString(errCode)); //+", "+ErrorDescription(errCode));
 }
//
void displayABox( const BoxStruct& displayBox )
 {
   static long chartID = ChartID();
   string objName = displayBox.editBoxName;
   string displayStr = IntegerToString(displayBox.displayValue);
   int dispWindow = ObjectFind(chartID,objName);
   if ( dispWindow < 0 ) // if no such object, make it
    {
      ObjectCreate(chartID,objName,OBJ_EDIT,WINDOW_ZERO,     0, 0);
      ObjectSetInteger(chartID,objName,OBJPROP_FONTSIZE,    10);
      ObjectSetString (chartID,objName,OBJPROP_FONT,        "Arial");
      ObjectSetInteger(chartID,objName,OBJPROP_COLOR,       clrCornflowerBlue);
      ObjectSetInteger(chartID,objName,OBJPROP_BORDER_COLOR,clrBlack); 
      ObjectSetInteger(chartID,objName,OBJPROP_BGCOLOR,     clrLightGray);
      ObjectSetInteger(chartID,objName,OBJPROP_XSIZE,       50); 
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
   ObjectSetInteger(chartID,objName,OBJPROP_XDISTANCE,      displayBox.xPos );
   ObjectSetInteger(chartID,objName,OBJPROP_YDISTANCE,      displayBox.yPos );
   ObjectSetString (chartID, objName, OBJPROP_TEXT,         displayStr );
 }
//+------------------------------------------------------------------+
void manageALabel(const string& objName, const string dispStr, const int& xPos, const int& yPos, const color dispClr, const int fontSize = 12)
 {
   static long chartID = ChartID();
   if ( ObjectFind(chartID,objName) < 0 )  // if no such object, make it
    {
      ObjectCreate    (chartID, objName, OBJ_LABEL, WINDOW_ZERO,  0, 0);
      ObjectSetInteger(chartID, objName, OBJPROP_FONTSIZE,  fontSize);
      ObjectSetString (chartID, objName, OBJPROP_FONT,      "Arial");
      ObjectSetInteger(chartID, objName, OBJPROP_COLOR,     dispClr);
      ObjectSetInteger(chartID, objName, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
      ObjectSetInteger(chartID, objName, OBJPROP_ANCHOR,    ANCHOR_LEFT_UPPER);
      ObjectSetInteger(chartID, objName, OBJPROP_BACK,      true); 
      ObjectSetInteger(chartID, objName, OBJPROP_SELECTABLE,false); 
      ObjectSetInteger(chartID, objName, OBJPROP_SELECTED,  false); 
      ObjectSetInteger(chartID, objName, OBJPROP_HIDDEN,    true);
    }
   ObjectSetInteger(chartID, objName, OBJPROP_XDISTANCE, xPos );
   ObjectSetInteger(chartID, objName, OBJPROP_YDISTANCE, yPos );
   ObjectSetString (chartID, objName, OBJPROP_TEXT,      dispStr );
 }
//--------------------------------------------------------------------
void makeARectangle(const RectStruct& displayRect) 
 {
   static long chartID = ChartID();
   int windowIndex   = ObjectFind(chartID, displayRect.rectName); // Find which window the object is in (does it exist?)
   if(windowIndex<0)                         // No window found with the object in it - Create the object
    {
      if( ObjectCreate(chartID, displayRect.rectName, OBJ_RECTANGLE, CHARTWINDOW, displayRect.startTime, displayRect.topPrice, displayRect.endTime, displayRect.bottomPrice) )
       {
         ObjectSetInteger(chartID,  displayRect.rectName, OBJPROP_COLOR,      displayRect.fillClr);
         ObjectSetInteger(chartID,  displayRect.rectName, OBJPROP_STYLE,      displayRect.lineStyle);
         ObjectSetInteger(chartID,  displayRect.rectName, OBJPROP_WIDTH,      displayRect.lineWidth);
         ObjectSetInteger(chartID,  displayRect.rectName, OBJPROP_BACK,       true);
         ObjectSetInteger(chartID,  displayRect.rectName, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(chartID,  displayRect.rectName, OBJPROP_SELECTED,   false);
         ObjectSetInteger(chartID,  displayRect.rectName, OBJPROP_HIDDEN,     true);
       }
      else  // publish error if the object creation fails.
       { 
         int errCode      = GetLastError();
         string errString;
         int catLen = StringConcatenate(errString,__FUNCTION__," Failed to create object ",displayRect.rectName,", Error: ",IntegerToString(errCode)); //,", ",ErrorDescription(errCode));
         Print(errString); Comment(errString);
       } 
    }
   else  // Move the Object, it exists already
    {
      ObjectMove(chartID, displayRect.rectName, ANCHOR_POINT_ZERO, displayRect.startTime, displayRect.topPrice );
      ObjectMove(chartID, displayRect.rectName, ANCHOR_POINT_ONE,  displayRect.endTime, displayRect.bottomPrice );
    }
 }
//--------------------------------------------------------------------
string getInfoMecDescription(BAR_INFO_MECH mechanism)
 {
   string dispString;
   switch (mechanism)
    {
      case COPY_FUNCS: dispString = "COPY_FUNCS"; break;
      case RATES:      dispString = "RATES";     break;
      case DIRECT:     dispString = "DIRECT";     break;
      default:         dispString = "Unknown "+IntegerToString(mechanism); break;
    }
   return( dispString );
 }
//--------------------------------------------------------------------
BAR_INFO_MECH getNextMec(BAR_INFO_MECH mechanism)  // {ARRAYS, IMAS, COPY_FUNCS, RATES};
 {
   BAR_INFO_MECH nextMech;
   switch (mechanism)
    {
      case RATES:      nextMech = COPY_FUNCS; break;
      case COPY_FUNCS: nextMech = DIRECT;     break;
      case DIRECT:     nextMech = RATES;      break;
      default:         nextMech = RATES;      break;
    }
   return( nextMech );
 }
//--------------------------------------------------------------------
string getPromptTxt(ENUM_CTRL_IDX idx)
 {
   string dispString;
   switch (idx)
    {
      case BAR_UP:
         dispString = "Bar Up";
         break;
      case BAR_DN:
         dispString = "Bar Dn";
         break;
      case PERIOD_START:
         dispString = getPeriodText(workingTF,PART_ONE);
         break;
      case PERIOD_END:
         dispString = getPeriodText(workingTF,PART_TWO);
         break;
      case INFO_MECH:
         dispString = getInfoMecDescription(workingMechanism);
         break;
      default:
         dispString = "Unknown "+IntegerToString(idx);
         break;
    }
   return(dispString);
 }
string getPeriodText(ENUM_TIMEFRAMES tf, const PERIOD_PARTS partOneTwo)
{
   string returnString;
   switch (tf)
   {
      case PERIOD_M1:  returnString = (partOneTwo==PART_ONE)?"PERIOD":"_M1";  break;
      case PERIOD_M2:  returnString = (partOneTwo==PART_ONE)?"PERIOD":"_M2";  break;
      case PERIOD_M3:  returnString = (partOneTwo==PART_ONE)?"PERIOD":"_M3";  break;
      case PERIOD_M4:  returnString = (partOneTwo==PART_ONE)?"PERIOD":"_M4";  break;
      case PERIOD_M5:  returnString = (partOneTwo==PART_ONE)?"PERIOD":"_M5";  break;
      case PERIOD_M6:  returnString = (partOneTwo==PART_ONE)?"PERIOD":"_M6";  break;
      case PERIOD_M10: returnString = (partOneTwo==PART_ONE)?"PERIOD":"_M10"; break;
      case PERIOD_M12: returnString = (partOneTwo==PART_ONE)?"PERIOD":"_M12"; break;
      case PERIOD_M15: returnString = (partOneTwo==PART_ONE)?"PERIOD":"_M15"; break;
      case PERIOD_M20: returnString = (partOneTwo==PART_ONE)?"PERIOD":"_M20"; break;
      case PERIOD_M30: returnString = (partOneTwo==PART_ONE)?"PERIOD":"_M30"; break;
      case PERIOD_H1:  returnString = (partOneTwo==PART_ONE)?"PERIOD":"_H1";  break;
      case PERIOD_H2:  returnString = (partOneTwo==PART_ONE)?"PERIOD":"_H2";  break;
      case PERIOD_H3:  returnString = (partOneTwo==PART_ONE)?"PERIOD":"_H3";  break;
      case PERIOD_H4:  returnString = (partOneTwo==PART_ONE)?"PERIOD":"_H4";  break;
      case PERIOD_H6:  returnString = (partOneTwo==PART_ONE)?"PERIOD":"_H6";  break;
      case PERIOD_H8:  returnString = (partOneTwo==PART_ONE)?"PERIOD":"_H8";  break;
      case PERIOD_H12: returnString = (partOneTwo==PART_ONE)?"PERIOD":"_H12"; break;
      case PERIOD_D1:  returnString = (partOneTwo==PART_ONE)?"PERIOD":"_D1";  break;
      case PERIOD_W1:  returnString = (partOneTwo==PART_ONE)?"PERIOD":"_W1";  break;
      case PERIOD_MN1: returnString = (partOneTwo==PART_ONE)?"PERIOD":"_MN1"; break;
      default:  returnString = "Unknown: "+IntegerToString(tf);  break;  // whatcha gonna do?
   }
   return(returnString);
}
ENUM_TIMEFRAMES getNextTF(ENUM_TIMEFRAMES tf)
{
   ENUM_TIMEFRAMES returnTF;
   switch (tf)
   {
      case PERIOD_M1:  returnTF = PERIOD_M2;   break;
      case PERIOD_M2:  returnTF = PERIOD_M3;   break;
      case PERIOD_M3:  returnTF = PERIOD_M4;   break;
      case PERIOD_M4:  returnTF = PERIOD_M5;   break;
      case PERIOD_M5:  returnTF = PERIOD_M6;  break;
      case PERIOD_M6:  returnTF = PERIOD_M10;  break;
      case PERIOD_M10: returnTF = PERIOD_M12;  break;
      case PERIOD_M12: returnTF = PERIOD_M15;  break;
      case PERIOD_M15: returnTF = PERIOD_M20;  break;
      case PERIOD_M20: returnTF = PERIOD_M30;  break;
      case PERIOD_M30: returnTF = PERIOD_H1;   break;
      case PERIOD_H1:  returnTF = PERIOD_H2;   break;
      case PERIOD_H2:  returnTF = PERIOD_H3;   break;
      case PERIOD_H3:  returnTF = PERIOD_H4;   break;
      case PERIOD_H4:  returnTF = PERIOD_H6;   break;
      case PERIOD_H6:  returnTF = PERIOD_H8;   break;
      case PERIOD_H8:  returnTF = PERIOD_H12;  break;
      case PERIOD_H12: returnTF = PERIOD_D1;   break;
      case PERIOD_D1:  returnTF = PERIOD_W1;   break;
      case PERIOD_W1:  returnTF = PERIOD_MN1;  break;
      case PERIOD_MN1: returnTF = PERIOD_M1;   break;
      default:  returnTF = PERIOD_CURRENT;     break;  // whatcha gonna do?
    }
   return(returnTF);
 }
ENUM_TIMEFRAMES getPreviousTF(ENUM_TIMEFRAMES tf)
 {
   ENUM_TIMEFRAMES returnTF;
   switch (tf)
    {
      case PERIOD_M1:  returnTF = PERIOD_MN1;  break;
      case PERIOD_M2:  returnTF = PERIOD_M1;   break;
      case PERIOD_M3:  returnTF = PERIOD_M2;   break;
      case PERIOD_M4:  returnTF = PERIOD_M3;   break;
      case PERIOD_M5:  returnTF = PERIOD_M4;   break;
      case PERIOD_M6:  returnTF = PERIOD_M5;   break;
      case PERIOD_M10: returnTF = PERIOD_M6;   break;
      case PERIOD_M12: returnTF = PERIOD_M10;  break;
      case PERIOD_M15: returnTF = PERIOD_M12;   break;
      case PERIOD_M20: returnTF = PERIOD_M15;  break;
      case PERIOD_M30: returnTF = PERIOD_M20;  break;
      case PERIOD_H1:  returnTF = PERIOD_M30;  break;
      case PERIOD_H2:  returnTF = PERIOD_H1;   break;
      case PERIOD_H3:  returnTF = PERIOD_H2;   break;
      case PERIOD_H4:  returnTF = PERIOD_H3;   break;
      case PERIOD_H6:  returnTF = PERIOD_H4;   break;
      case PERIOD_H8:  returnTF = PERIOD_H6;   break;
      case PERIOD_H12: returnTF = PERIOD_H8;   break;
      case PERIOD_D1:  returnTF = PERIOD_H12;   break;
      case PERIOD_W1:  returnTF = PERIOD_D1;  break;
      case PERIOD_MN1: returnTF = PERIOD_W1;   break;
      default:  returnTF = getPeriodCurrent(); break;  // whatcha gonna do?
    }
   return(returnTF);
 }
ENUM_TIMEFRAMES getPeriodCurrent(void)
 {
   ENUM_TIMEFRAMES returnTF = (ENUM_TIMEFRAMES) Period();
   /*
   switch (returnTF)
    {
      case PERIOD_M1:  returnTF = PERIOD_M1;   break;
      case PERIOD_M2:  returnTF = PERIOD_M2;   break;
      case PERIOD_M3:  returnTF = PERIOD_M3;   break;
      case PERIOD_M4:  returnTF = PERIOD_M4;   break;
      case PERIOD_M5:  returnTF = PERIOD_M5;  break;
      case PERIOD_M6:  returnTF = PERIOD_M6;  break;
      case PERIOD_M10: returnTF = PERIOD_M10;  break;
      case PERIOD_M12: returnTF = PERIOD_M15;  break;
      case PERIOD_M15: returnTF = PERIOD_M15;  break;
      case PERIOD_M20: returnTF = PERIOD_M20;  break;
      case PERIOD_M30: returnTF = PERIOD_M30;   break;
      case PERIOD_H1:  returnTF = PERIOD_H1;   break;
      case PERIOD_H2:  returnTF = PERIOD_H2;   break;
      case PERIOD_H3:  returnTF = PERIOD_H3;   break;
      case PERIOD_H4:  returnTF = PERIOD_H4;   break;
      case PERIOD_H6:  returnTF = PERIOD_H6;   break;
      case PERIOD_H8:  returnTF = PERIOD_H8;  break;
      case PERIOD_H12: returnTF = PERIOD_H12;   break;
      case PERIOD_D1:  returnTF = PERIOD_D1;   break;
      case PERIOD_W1:  returnTF = PERIOD_W1;  break;
      case PERIOD_MN1: returnTF = PERIOD_MN1;   break;
      default:  returnTF = PERIOD_M1;     break;  // whatcha gonna do?
    }
   */
   return(returnTF);
 }
