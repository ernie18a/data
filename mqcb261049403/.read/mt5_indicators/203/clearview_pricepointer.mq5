//+------------------------------------------------------------------+
//|                                       ClearView_PricePointer.mq5 |
//|                                           Copyright © 2010, AK20 |
//|                                             traderak20@gmail.com |
//+------------------------------------------------------------------+
#property copyright   "2010, traderak20@gmail.com"
#property description "ClearView PricePointer, bid/ask pointer with color-coded alerts every 500/1000 pips, daily high/low, high/low on the chart, historical high/low, shows last bid/ask/spread/tick-time"
#property description " "
#property description "This is indicator is best used together with: ClearView_RoundNumberMarker and ClearView_PeriodSeparator"
#property description " "
#property description "See the source file for instructions on usage"

/*----------------------------------------------------------------------------------------------------
   This is one of a set of three indicators to enhance the look of your charts.
   The other indicators are: ClearView_RoundNumberMarker and ClearView_PeriodSeparator
   A template to quickly load all three is also available: ClearView_ChartTemplate.tpl

   Use these indicators instead of the default 'Show grid' from the chart properties menu.

   These indicators may be more useful for manual or hybrid trading but even
   for automated trading they could provide visual clues for optimization of the system.
   
   The idea behind the indicators is that people have a tendency to set targets and stops
   on or near round numbers (50/100/500/1000 pips) on the chart and historical highs and lows.
   As a result these price points can become support or resistance areas.
   These indicators show clearly when price is near any of these points.
   
   When loading the indicators, allow time for the terminal to update the history
   for the current chart and to retrieve data from the monthly chart.
   
   The default color sets are optimized for use on a black background.

   *  Option to have high/low for the current chart and the historical high/low for the
      currency printed upon loading the indicator

   *  Option to set historical high/low manually in case your data-provider doesn't have
      deep enough history

   *  Turn on/off bid and ask lines separately

   *  Extend bid/ask lines to the start of the chart or just to the latest bar

   *  Bid/ask lines change color when near an important price point
      (500/1000 pips, daily high/low, high/low on the chart, historical high/low)

   *  Set how many pips before important price points the color of bid/ask lines should change
      (value is set in 4-digit pips, e.g. difference between 1.30104 and 1.30204 is 10 pips)

   *  Option to have the last (5th) digit in bid/ask/spread colored differently for clarity

   *  Set the corner where to show the bid/ask/spread/time of last tick

   *  Show the bid/ask/spread/time in the main window (default) or in another subwindow of the same chart

   *  NOTE: when using ClearView_PricePointer shift the chart for better visibility
      (check the box 'Chart shift' on the 'Common' tab of the chart properties)
----------------------------------------------------------------------------------------------------*/

#property indicator_chart_window
#property indicator_buffers  1
#property indicator_plots    1

//---- input parameters
input bool                 InpPrintHighLow=false;              // Print high/low information when indicator loads
input double               InpManualAbsHigh=0.0;               // Set historical high (0=use monthly chart)
input double               InpManualAbsLow=0.0;                // Set historical low (0=use monthly chart)
input bool                 InpShowBidLine=true;                // Show Bid line
input bool                 InpShowAskLine=true;                // Show Ask line
input bool                 InpShowRayLeft=false;               // Extend price pointer to the left
input color                InpPriceLineColor=C'14,72,131';     // Bid/Ask line default color
input int                  InpProximity_500_1000=55;           // Alert # of pips around 500/1000 markers
input color                InpMarker_500_1000=C'139,18,139';   // 500/1000 pips markers
input int                  InpProximity_DailyHighLow=10;       // Alert # of pips before high/low for the day
input color                InpMarker_DailyHighLow=DodgerBlue;  // High/low for the day
input int                  InpProximity_ChartHighLow=55;       // Alert # of pips before high/low on the chart
input color                InpMarker_ChartHighLow=Gold;        // High/low on the chart
input int                  InpProximity_AbsHighLow=55;         // Alert # of pips before historical high/low
input color                InpMarker_AbsHighLow=White;         // Historical high/low
input bool                 InpShowBidAsk=true;                 // Show Bid/Ask prices
input color                InpBidAskColor=DodgerBlue;          // Bid/Ask prices
input color                InpLastDigitkColor=DimGray;         // Last digit default color
input bool                 InpChangeLastDigitColor=false;      // Change color of last digit with Bid/Ask
input string               InpBidAskSeparator="/";             // Bid/Ask separator
input color                InpSeparatorColor=DimGray;          // Bid/Ask separator
input bool                 InpShowClock=true;                  // Show most recent tick time
input color                InpTimeColor=DimGray;               // Most recent tick time
input ENUM_BASE_CORNER     InpBaseCorner=CORNER_RIGHT_UPPER;   // Corner for Bid/Ask & time
input bool                 InpDrawAsBackground=false;          // Draw objects as background
input int                  InpWindowIdx=0;                     // Sub-window for Bid/Ask & clock (0=main)

//--- global variables
int                        X_Distance=6;                       // X distance in pixels from binding corner for clock and Bid/Ask
int                        Y_Distance1=18;                     // Y distance in pixels from binding corner for clock or Bid/Ask
int                        Y_Distance2=38;                     // Y distance in pixels from binding corner for clock or Bid/Ask
int                        Y_DistanceBidAsk;                   // Y distance in pixels from binding corner for Bid/Ask
int                        Y_DistanceClock;                    // Y distance in pixels from binding corner for clock
int                        lineExtender=2678400;               // seconds in a month: 60*60*24*31
int                        objAnchor;                          // anchor for clock and Bid/Ask price
int                        dailyHighInt=INT_MIN;               // highest high for the day in points
int                        dailyLowInt=INT_MAX;                // lowest low for the day in points
int                        chartHighInt=INT_MIN;               // highest high on the chart in points
int                        chartLowInt=INT_MAX;                // lowest low on the chart in points
int                        absHighInt=INT_MIN;                 // highest high on the monthly chart in points
int                        absLowInt=INT_MAX;                  // lowest low on the monthly chart in points
string                     bidAskFont="Courier";               // font for Bid/Ask prices, has to be a fixed width font
int                        bidAskFontSize=14;                  // fontsize for Bid/Ask prices
string                     clockFont="Arial";                  // font for clock
int                        clockFontSize=10;                   // fontsize for clock
int                        prox_500_1000;                      // number of pips around the 500 & 1000 pips markers
int                        prox_DailyHighLow;                  // number of pips before high and low for the day
int                        prox_ChartHighLow;                  // number of pips before high and low on the chart
int                        prox_AbsHighLow;                    // number of pips before high and low on the monthly chart
//+------------------------------------------------------------------+
//| Set spacer for text of label objects                             |
//+------------------------------------------------------------------+
void SetSpacerLength(string &f_CurString,string f_PrevString)
  {
//--- set length of spacer for text of label object
   int f_StrLenTotal=StringLen(f_PrevString);
   string f_StrSpacer;
   StringInit(f_StrSpacer,f_StrLenTotal,' ');
//--- objects are on the right hand side of the chart
   if(InpBaseCorner==CORNER_RIGHT_UPPER || InpBaseCorner==CORNER_RIGHT_LOWER)
      StringAdd(f_CurString,f_StrSpacer);
//--- objects are on the left hand side of the chart
   if(InpBaseCorner==CORNER_LEFT_UPPER || InpBaseCorner==CORNER_LEFT_LOWER)
     {
      StringAdd(f_StrSpacer,f_CurString);
      f_CurString=f_StrSpacer;
     }
  }
//+------------------------------------------------------------------+
//| Create label objects                                             |
//+------------------------------------------------------------------+
void CreateLabelObj(string f_ObjName,int f_Y_Distance,string f_ObjLabel,string f_ObjFont,int f_ObjFontSize,color f_ObjColor)
  {
   ObjectCreate(0,f_ObjName,OBJ_LABEL,InpWindowIdx,0,0);
   ObjectSetInteger(0,f_ObjName,OBJPROP_ANCHOR,objAnchor);
   ObjectSetInteger(0,f_ObjName,OBJPROP_CORNER,InpBaseCorner);
   ObjectSetInteger(0,f_ObjName,OBJPROP_XDISTANCE,X_Distance);
   ObjectSetInteger(0,f_ObjName,OBJPROP_YDISTANCE,f_Y_Distance);
   ObjectSetString(0,f_ObjName,OBJPROP_TEXT,f_ObjLabel);
   ObjectSetString(0,f_ObjName,OBJPROP_FONT,f_ObjFont);
   ObjectSetInteger(0,f_ObjName,OBJPROP_FONTSIZE,f_ObjFontSize);
   ObjectSetInteger(0,f_ObjName,OBJPROP_COLOR,f_ObjColor);
   ObjectSetInteger(0,f_ObjName,OBJPROP_BACK,InpDrawAsBackground);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- name for indicator
   IndicatorSetString(INDICATOR_SHORTNAME,"Price Pointer");

//--- set number of pips when to change color around the 500 & 1000 pips markers, high and low for the day
   prox_500_1000=InpProximity_500_1000*10;
//--- set number of pips when to change color before the highest high and the lowest low for the day
   prox_DailyHighLow=InpProximity_DailyHighLow*10;
//--- set number of pips when to change color before the highest high and the lowest low on the chart
   prox_ChartHighLow=InpProximity_ChartHighLow*10;
//--- set number of pips when to change color before the highest high and the lowest low on the monthly chart
   prox_AbsHighLow=InpProximity_AbsHighLow*10;

//--- set Y distance for Bid/Ask
   Y_DistanceBidAsk=Y_Distance2;
   if(InpShowClock==false || InpBaseCorner==CORNER_RIGHT_LOWER || InpBaseCorner==CORNER_LEFT_LOWER)
      Y_DistanceBidAsk=Y_Distance1;

//--- set Y distance for clock
   Y_DistanceClock=Y_Distance1;
   if(InpBaseCorner==CORNER_RIGHT_LOWER || InpBaseCorner==CORNER_LEFT_LOWER)
      Y_DistanceClock=Y_Distance2;

//--- set anchor point for Bid/Ask and clock
   switch(InpBaseCorner)
     {
      case CORNER_LEFT_UPPER:
         objAnchor=ANCHOR_LEFT_UPPER;break;
      case CORNER_LEFT_LOWER:
         objAnchor=ANCHOR_LEFT_LOWER;break;
      case CORNER_RIGHT_LOWER:
         objAnchor=ANCHOR_RIGHT_LOWER;break;
      case CORNER_RIGHT_UPPER:
         objAnchor=ANCHOR_RIGHT_UPPER;break;
      default:
         objAnchor=ANCHOR_RIGHT_UPPER;break;
     }

//--- initialization done
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete price pointer and clock from chart
   ObjectDelete(0,"objAskPointer");
   ObjectDelete(0,"objBidPointer");
   ObjectDelete(0,"objBidText");
   ObjectDelete(0,"objBidLastDigitText");
   ObjectDelete(0,"objAskText");
   ObjectDelete(0,"objAskLastDigitText");
   ObjectDelete(0,"objSpreadText");
   ObjectDelete(0,"objSpreadLastDigitText");
   ObjectDelete(0,"objSeparator1");
   ObjectDelete(0,"objSeparator2");
   ObjectDelete(0,"objTime");

   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| ClearView PricePointer                                           |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- set arrays as series, most recent entry at index [0]
   ArraySetAsSeries(Time,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);

//--- get current Bid
   double curBidVal=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   int curBidPips=(int)(curBidVal/Point());
//--- get current Ask
   double curAskVal=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   int curAskPips=(int)(curAskVal/Point());
//--- get current Spread
   int curSpreadVal=0;
   if(InpShowBidAsk==true)
      curSpreadVal=(int)SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);

//--- update highest high for the day
   if(curBidPips>dailyHighInt)
      dailyHighInt=(int)(SymbolInfoDouble(Symbol(),SYMBOL_BIDHIGH)/Point());
//--- update lowest low for the day
   if(curBidPips<dailyLowInt)
      dailyLowInt=(int)(SymbolInfoDouble(Symbol(),SYMBOL_BIDLOW)/Point());

//-- calculate higest high and lowest low on chart for first iteration
   if(prev_calculated<=0 || prev_calculated>rates_total)
     {
      MqlRates monthlyRates[];
      int absHighIdx=INT_MIN,absLowIdx=INT_MAX;

      if(InpManualAbsHigh==0 || InpManualAbsLow==0)
        {
         //--- get rate date for PERIOD_MN1 timeseries
         ArraySetAsSeries(monthlyRates,true);
         if(CopyRates(NULL,PERIOD_MN1,0,Bars(NULL,0),monthlyRates)<=0) return(0);
         //--- set highest high for PERIOD_MN1
         if(InpManualAbsHigh==0)
           {
            //--- reset array for PERIOD_MN1 high price series data
            double monthlyRatesHigh[];
            ArraySetAsSeries(monthlyRatesHigh,true);
            ArrayInitialize(monthlyRatesHigh,EMPTY_VALUE);
            ArrayResize(monthlyRatesHigh,Bars(NULL,PERIOD_MN1));
            //--- copy high data for PERIOD_MN1 to separate array
            for(int i=0;i<Bars(NULL,PERIOD_MN1);i++)
               monthlyRatesHigh[i]=monthlyRates[i].high;
            //--- calculate highest high for PERIOD_MN1
            absHighIdx=ArrayMaximum(monthlyRatesHigh,0,WHOLE_ARRAY);
            absHighInt=(int)(monthlyRatesHigh[absHighIdx]/Point());
           }
         //--- set lowest low for PERIOD_MN1
         if(InpManualAbsLow==0)
           {
            //--- reset array for PERIOD_MN1 low price series data
            double monthlyRatesLow[];
            ArraySetAsSeries(monthlyRatesLow,true);
            ArrayInitialize(monthlyRatesLow,EMPTY_VALUE);
            ArrayResize(monthlyRatesLow,Bars(NULL,PERIOD_MN1));
            //--- copy low data for PERIOD_MN1 to separate array
            for(int i=0;i<Bars(NULL,PERIOD_MN1);i++)
               monthlyRatesLow[i]=monthlyRates[i].low;
            //--- calculate lowest low for PERIOD_MN1
            absLowIdx=ArrayMinimum(monthlyRatesLow,0,WHOLE_ARRAY);
            absLowInt=(int)(monthlyRatesLow[absLowIdx]/Point());
           }
        }
      //--- manually set historical highest high
      if(InpManualAbsHigh!=0)
         absHighInt=(int)(InpManualAbsHigh/Point());
      //--- manually set historical lowest low
      if(InpManualAbsLow!=0)
         absLowInt=(int)(InpManualAbsLow/Point());

      //--- calculate highest high on chart
      int chartHighIdx=ArrayMaximum(High,0,WHOLE_ARRAY);
      chartHighInt=(int)(High[chartHighIdx]/Point());
      //--- calculate lowest low on chart
      int chartLowIdx=ArrayMinimum(Low,0,WHOLE_ARRAY);
      chartLowInt=(int)(Low[chartLowIdx]/Point());

      //--- print high/low information when indicator loads
      if(InpPrintHighLow==true)
        {
         //--- print highest high for PERIOD_MN1
         if(InpManualAbsHigh==0)
           {
            string absHighMonth=TimeToString(monthlyRates[absHighIdx].time,TIME_DATE);
            absHighMonth=StringSubstr(absHighMonth,0,StringLen(absHighMonth)-3);
            Print(Symbol()," [",absHighMonth,"] - Historical high on monthly chart: ",absHighInt*Point());
           }
         if(InpManualAbsHigh!=0)
            Print(Symbol()," - Historical high (set manually): ",absHighInt*Point());
         //--- print lowest for PERIOD_MN1
         if(InpManualAbsLow==0)
           {
            string absLowMonth=TimeToString(monthlyRates[absLowIdx].time,TIME_DATE);
            absLowMonth=StringSubstr(absLowMonth,0,StringLen(absLowMonth)-3);
            Print(Symbol()," [",absLowMonth,"] - Historical low on monthly chart: ",absLowInt*Point());
           }
         if(InpManualAbsLow!=0)
            Print(Symbol()," - Historical low (set manually): ",absLowInt*Point());
         //--- print highest high on chart
         string chartHighDateTime=TimeToString(Time[chartHighIdx],TIME_DATE|TIME_MINUTES);
         Print(Symbol()," [",chartHighDateTime,"] - Highest high on current chart: ",chartHighInt*Point());
         //--- print lowest low on chart
         string chartLowDateTime=TimeToString(Time[chartLowIdx],TIME_DATE|TIME_MINUTES);
         Print(Symbol()," [",chartLowDateTime,"] - Lowest low on current chart: ",chartLowInt*Point());
        }
     }
//--- update highest high on chart
   if(curBidPips>chartHighInt)
      chartHighInt=curBidPips;
//--- update lowest low on chart
   if(curBidPips<chartLowInt)
      chartLowInt=curBidPips;

//--- update highest high for PERIOD_MN1
   if(curBidPips>absHighInt)
      absHighInt=curBidPips;
//--- update lowest low for PERIOD_MN1
   if(curBidPips<absLowInt)
      absLowInt=curBidPips;

//--- set color for Bid/Ask text, Bid line and Ask line, last digit
   color bidAskColor=InpBidAskColor;
   color bidAskLineColor=InpPriceLineColor;
   color LastDigitColor=InpLastDigitkColor;
   bool update_bidAskLineColor=false;
   if(curAskPips>=dailyHighInt-prox_DailyHighLow || curBidPips<=dailyLowInt+prox_DailyHighLow)
     {
      bidAskColor=InpMarker_DailyHighLow;
      update_bidAskLineColor=true;
     }
   if(MathMod(curAskPips,10000)>=10000-prox_500_1000 || MathMod(curBidPips,10000)<=prox_500_1000 || 
      MathMod(curAskPips,5000)>=5000-prox_500_1000 || MathMod(curBidPips,5000)<=prox_500_1000)
     {
      bidAskColor=InpMarker_500_1000;
      update_bidAskLineColor=true;
     }
   if(curAskPips>=chartHighInt-prox_ChartHighLow || curBidPips<=chartLowInt+prox_ChartHighLow)
     {
      bidAskColor=InpMarker_ChartHighLow;
      update_bidAskLineColor=true;
     }
   if(curAskPips>=absHighInt-prox_AbsHighLow || curBidPips<=absLowInt+prox_AbsHighLow)
     {
      bidAskColor=InpMarker_AbsHighLow;
      update_bidAskLineColor=true;
     }

   if(update_bidAskLineColor==true) bidAskLineColor=bidAskColor;

//--- set color for last digit
   if(InpChangeLastDigitColor==true) LastDigitColor=bidAskColor;

//--- show Bid/Ask price
   if(InpShowBidAsk==true)
     {
      //--- create Spread Last Digit text
      string tempSpreadStr=IntegerToString(curSpreadVal);
      string curSpreadLastDigit=StringSubstr(tempSpreadStr,StringLen(tempSpreadStr)-1,1);
      //--- create Spread text
      string curSpreadStr=StringSubstr(tempSpreadStr,0,StringLen(tempSpreadStr)-1);
      if(curSpreadStr=="") curSpreadStr="0";
      //--- insert separator 1
      string separator_1=InpBidAskSeparator;
      //--- create Ask Last Digit text
      string tempAskStr=DoubleToString(curAskVal,Digits());
      string curAskLastDigit=StringSubstr(tempAskStr,StringLen(tempAskStr)-1,1);
      //--- create Ask text
      string curAskStr=StringSubstr(tempAskStr,StringLen(tempAskStr)-3,2);
      //--- insert separator 2
      string separator_2=InpBidAskSeparator;
      //--- create Bid Last Digit text
      string tempBidStr=DoubleToString(curBidVal,Digits());;
      string curBidLastDigit=StringSubstr(tempBidStr,StringLen(tempBidStr)-1,1);
      //--- create Bid text
      string curBidStr=StringSubstr(tempBidStr,0,StringLen(tempBidStr)-1);

      //--- add spacer to text for label objects
      if(InpBaseCorner==CORNER_RIGHT_UPPER || InpBaseCorner==CORNER_RIGHT_LOWER)
        {
         //--- set length for spacer Spread text
         SetSpacerLength(curSpreadStr,curSpreadLastDigit);
         //--- set length for spacer separator 1
         SetSpacerLength(separator_1,curSpreadStr);
         //--- set length for spacer Ask Last Digit text
         SetSpacerLength(curAskLastDigit,separator_1);
         //--- set length for spacer Ask text
         SetSpacerLength(curAskStr,curAskLastDigit);
         //--- set length for spacer separator 2
         SetSpacerLength(separator_2,curAskStr);
         //--- set length for spacer Bid Last Digit text
         SetSpacerLength(curBidLastDigit,separator_2);
         //--- set length for spacer Bid text
         SetSpacerLength(curBidStr,curBidLastDigit);
        }
      if(InpBaseCorner==CORNER_LEFT_UPPER || InpBaseCorner==CORNER_LEFT_LOWER)
        {
         //--- set length for spacer Bid Last Digit text
         SetSpacerLength(curBidLastDigit,curBidStr);
         //--- set length for spacer separator 2
         SetSpacerLength(separator_2,curBidLastDigit);
         //--- set length for spacer Ask text
         SetSpacerLength(curAskStr,separator_2);
         //--- set length for spacer Ask Last Digit text
         SetSpacerLength(curAskLastDigit,curAskStr);
         //--- set length for spacer separator 1
         SetSpacerLength(separator_1,curAskLastDigit);
         //--- set length for spacer Spread text
         SetSpacerLength(curSpreadStr,separator_1);
         //--- set length for spacer Spread Last Digit text
         SetSpacerLength(curSpreadLastDigit,curSpreadStr);
        }

      //--- update Spread Last Digit text
      if(ObjectFind(0,"objSpreadLastDigitText")==InpWindowIdx)
         ObjectSetString(0,"objSpreadLastDigitText",OBJPROP_TEXT,curSpreadLastDigit);
      //--- create Spread Last Digit text object
      else
         CreateLabelObj("objSpreadLastDigitText",Y_DistanceBidAsk,curSpreadLastDigit,bidAskFont,bidAskFontSize,LastDigitColor);

      //--- update Spread text
      if(ObjectFind(0,"objSpreadText")==InpWindowIdx)
        {
         ObjectSetString(0,"objSpreadText",OBJPROP_TEXT,curSpreadStr);
         ObjectSetInteger(0,"objSpreadText",OBJPROP_COLOR,bidAskColor);
        }
      //--- create Spread text object
      else
         CreateLabelObj("objSpreadText",Y_DistanceBidAsk,curSpreadStr,bidAskFont,bidAskFontSize,bidAskColor);

      //--- update separator 1 object
      if(ObjectFind(0,"objSeparator1")==InpWindowIdx)
         ObjectSetString(0,"objSeparator1",OBJPROP_TEXT,separator_1);
      //--- create separator 1 object
      else
         CreateLabelObj("objSeparator1",Y_DistanceBidAsk,separator_1,bidAskFont,bidAskFontSize,InpSeparatorColor);

      //--- update Ask Last Digit text
      if(ObjectFind(0,"objAskLastDigitText")==InpWindowIdx)
         ObjectSetString(0,"objAskLastDigitText",OBJPROP_TEXT,curAskLastDigit);
      //--- create Ask Last Digit text object
      else
         CreateLabelObj("objAskLastDigitText",Y_DistanceBidAsk,curAskLastDigit,bidAskFont,bidAskFontSize,LastDigitColor);

      //--- update Ask text
      if(ObjectFind(0,"objAskText")==InpWindowIdx)
        {
         ObjectSetString(0,"objAskText",OBJPROP_TEXT,curAskStr);
         ObjectSetInteger(0,"objAskText",OBJPROP_COLOR,bidAskColor);
        }
      //--- create Ask text object
      else
         CreateLabelObj("objAskText",Y_DistanceBidAsk,curAskStr,bidAskFont,bidAskFontSize,bidAskColor);

      //--- update separator 2 object
      if(ObjectFind(0,"objSeparator2")==InpWindowIdx)
         ObjectSetString(0,"objSeparator2",OBJPROP_TEXT,separator_2);
      //--- create separator 2 object
      else
         CreateLabelObj("objSeparator2",Y_DistanceBidAsk,separator_2,bidAskFont,bidAskFontSize,InpSeparatorColor);

      //--- update Bid Last Digit text
      if(ObjectFind(0,"objBidLastDigitText")==InpWindowIdx)
         ObjectSetString(0,"objBidLastDigitText",OBJPROP_TEXT,curBidLastDigit);
      //--- create Bid Last Digit text object
      else
         CreateLabelObj("objBidLastDigitText",Y_DistanceBidAsk,curBidLastDigit,bidAskFont,bidAskFontSize,LastDigitColor);

      //--- update Bid text
      if(ObjectFind(0,"objBidText")==InpWindowIdx)
        {
         ObjectSetString(0,"objBidText",OBJPROP_TEXT,curBidStr);
         ObjectSetInteger(0,"objBidText",OBJPROP_COLOR,bidAskColor);
        }
      //--- create Bid text object
      else
         CreateLabelObj("objBidText",Y_DistanceBidAsk,curBidStr,bidAskFont,bidAskFontSize,bidAskColor);
     }

//--- show Bid line
   if(InpShowBidLine==true)
     {
      //--- update Bid line
      if(ObjectFind(0,"objBidPointer")==0)
        {
         ObjectMove(0,"objBidPointer",0,Time[0],curBidVal);
         ObjectMove(0,"objBidPointer",1,Time[0]+lineExtender,curBidVal);
         ObjectSetInteger(0,"objBidPointer",OBJPROP_COLOR,bidAskLineColor);
        }
      //--- create Bid line object
      else
        {
         ObjectCreate(0,"objBidPointer",OBJ_TREND,0,Time[0],curBidVal,Time[0]+lineExtender,curBidVal);
         ObjectSetInteger(0,"objBidPointer",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,"objBidPointer",OBJPROP_RAY_RIGHT,true);
         ObjectSetInteger(0,"objBidPointer",OBJPROP_RAY_LEFT,InpShowRayLeft);
         ObjectSetInteger(0,"objBidPointer",OBJPROP_COLOR,bidAskLineColor);
         ObjectSetInteger(0,"objBidPointer",OBJPROP_BACK,InpDrawAsBackground);
        }
     }

//--- show Ask line
   if(InpShowAskLine==true)
     {
      //--- update Ask line
      if(ObjectFind(0,"objAskPointer")==0)
        {
         ObjectMove(0,"objAskPointer",0,Time[0],curAskVal);
         ObjectMove(0,"objAskPointer",1,Time[0]+lineExtender,curAskVal);
         ObjectSetInteger(0,"objAskPointer",OBJPROP_COLOR,bidAskLineColor);
        }
      //--- create Ask line object
      else
        {
         ObjectCreate(0,"objAskPointer",OBJ_TREND,0,Time[0],curAskVal,Time[0]+lineExtender,curAskVal);
         ObjectSetInteger(0,"objAskPointer",OBJPROP_STYLE,STYLE_DOT);
         ObjectSetInteger(0,"objAskPointer",OBJPROP_RAY_RIGHT,true);
         ObjectSetInteger(0,"objAskPointer",OBJPROP_RAY_LEFT,InpShowRayLeft);
         ObjectSetInteger(0,"objAskPointer",OBJPROP_COLOR,bidAskLineColor);
         ObjectSetInteger(0,"objAskPointer",OBJPROP_BACK,InpDrawAsBackground);
        }
     }

//--- show Clock
   if(InpShowClock==true)
     {
      //--- update clock
      if(ObjectFind(0,"objTime")==InpWindowIdx)
         ObjectSetString(0,"objTime",OBJPROP_TEXT,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
      //--- create clock object
      else
         CreateLabelObj("objTime",Y_DistanceClock,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),clockFont,clockFontSize,InpTimeColor);
     }

//--- return value of rates_total, will be used as prev_calculated in next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
