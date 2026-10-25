//+------------------------------------------------------------------+
//|                                  ClearView_RoundNumberMarker.mq5 |
//|                                           Copyright © 2010, AK20 |
//|                                             traderak20@gmail.com |
//+------------------------------------------------------------------+
#property copyright   "2010, traderak20@gmail.com"
#property description "ClearView RoundNumberMarker, draws markers for every 50/100/500/1000 pips, high/low on the chart, historical high/low"
#property description " "
#property description "This is indicator is best used together with: ClearView_PricePointer and ClearView_PeriodSeparator"
#property description " "
#property description "See the source file for instructions on usage"

/*----------------------------------------------------------------------------------------------------
   This is one of a set of three indicators to enhance the look of your charts.
   The other indicators are: ClearView_PricePointer and ClearView_PeriodSeparator
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

   *  Choose between two color sets (bright or dim colors) to set the visibility
      of the lines drawn
   
   *  Draw lines as background (default and recommended) or on foreground
   
   *  Option to have high/low for the current chart and the historical high/low
      for the currency printed upon loading the indicator
   
   *  Option to set historical high/low manually in case your data-provider doesn't
      have deep enough history
   
   *  When historical high/low, or high/low on chart is hit by price, it marks this point
      as a possible support/resistance area while also showing the new high/low.
      NOTE: you can easily see how this works by manually setting the historical high/low
      to a price only a few pips from the current price. Then wait for price to hit the high/low
      and see how the lines split to mark the previous high/low and the current high/low.
   
   *  Set how long this previous high/low price point should remain marked (default=1 day).
      NOTE: if you change timeframe or reload the chart or the indicator this information is lost.
   
   *  Specify for each marker up to which timeframe it should be shown. E.g. you can choose to show
      100 pip markers (EURUSD 1.3000, 1.3100 etc) only up to the 1-hour timeframe. This way your chart
      won't be cluttered with too many lines when switching between timeframes. On any timeframe it will
      automatically show only the lines you want to see.
   
   *  Apart from different colors, all markers have an object description to show whether it's marking
      50 pips, a 100, 500, 1000 pips, the chart's (previous) high/low or the (previous) historical high/low.

----------------------------------------------------------------------------------------------------*/

#property indicator_chart_window
#property indicator_buffers  1
#property indicator_plots    1

//---- input parameters
input bool                 InpPrintHighLow=false;                       // Print high/low information when indicator loads
input double               InpManualAbsHigh=0.0;                        // Set historical high (0=use monthly chart)
input double               InpManualAbsLow=0.0;                         // Set historical low (0=use monthly chart)
input ENUM_TIMEFRAMES      InpResetDelayTime=PERIOD_D1;                 // Delay to reset previous high/low marker
input bool                 InpUseBrightColors=true;                     // Use bright colors
input bool                 InpDrawAsBackground=true;                    // Draw lines as background
input ENUM_TIMEFRAMES      InpMaxTF_1000=PERIOD_MN1;                    // Show 1000 pips marker up to timeframe
input color                InpMarker_1000=C'70,10,70';                  // 1000 pips marker
input color                InpMarker_1000_Brt=C'140,20,140';            // 1000 pips marker bright
input ENUM_TIMEFRAMES      InpMaxTF_500=PERIOD_D1;                      // Show 500 pips marker up to timeframe
input color                InpMarker_500=C'70,10,70';                   // 500 pips marker
input color                InpMarker_500_Brt=C'140,20,140';             // 500 pips marker bright
input ENUM_TIMEFRAMES      InpMaxTF_100=PERIOD_H4;                      // Show 100 pips marker up to timeframe
input color                InpMarker_100=C'8,45,8';                     // 100 pips marker
input color                InpMarker_100_Brt=C'16,90,16';               // 100 pips marker bright
input ENUM_TIMEFRAMES      InpMaxTF_50=PERIOD_H1;                       // Show 50 pips marker up to timeframe
input color                InpMarker_50=C'0,25,50';                     // 50 pips marker
input color                InpMarker_50_Brt=C'0,50,100';                // 50 pips marker bright
input color                InpMarker_ChartHigh=C'125,105,0';            // Highest high on the chart
input color                InpMarker_ChartHigh_Brt=C'250,210,0';        // Highest high on the chart bright
input color                InpMarker_ChartLow=C'125,105,0';             // Lowest low on the chart
input color                InpMarker_ChartLow_Brt=C'250,210,0';         // Lowest low on the chart bright
input color                InpMarker_AbsHigh=C'127,127,127';            // Historical high
input color                InpMarker_AbsHigh_Brt=White;                 // Historical high bright
input color                InpMarker_AbsLow=C'127,127,127';             // Historical low
input color                InpMarker_AbsLow_Brt=White;                  // Historical low bright

//--- global variables
int                        highestExtended,lowestExtended;              // Limits between which to draw markers
int                        absHighInt,absLowInt;                        // value of highest high and lowest low for PERIOD_MN1
int                        prevAbsHighInt,prevAbsLowInt;                // value of previous highest high and lowest low for PERIOD_MN1
datetime                   newAbsHighDate,newAbsLowDate;                // date of new highest high and lowest low for PERIOD_MN1
bool                       newAbsHigh,newAbsLow;                        // flag to show a new highest high or lowest low has been made for PERIOD_MN1
int                        chartHighInt,chartLowInt;                    // value of highest high and lowest low on chart
int                        prevChartHighInt,prevChartLowInt;            // value of previous highest high and lowest low on chart
datetime                   newChartHighDate,newChartLowDate;            // date of new highest high and lowest low on the chart
bool                       newChartHigh,newChartLow;                    // flag to show a new highest high or lowest low has been made on the chart
color                      marker_1000_Clr,marker_500_Clr;              // colors for 1000 & 500 pips markers
color                      marker_100_Clr,marker_50_Clr;                // colors for 100 & 50 pips markers
color                      marker_ChartHigh_Clr,marker_ChartLow_Clr;    // colors for highest high & lowest low markers
color                      marker_AbsHigh_Clr,marker_AbsLow_Clr;        // colors for absolute highest high & absolute lowest low markers
int                        resetDelay;                                  // delay before marker for previous high/low is reset
//+------------------------------------------------------------------+
//| Delete all markers from chart                                    |
//+------------------------------------------------------------------+
void DeleteObjects()
  {
//--- delete all high and low markers from chart
   ObjectDelete(0,"objMarker_HISTORICAL_HIGH");
   ObjectDelete(0,"objMarker_PREV_HISTORICAL_HIGH");
   ObjectDelete(0,"objMarker_HISTORICAL_LOW");
   ObjectDelete(0,"objMarker_PREV_HISTORICAL_LOW");
   ObjectDelete(0,"objMarker_CHART_HIGH");
   ObjectDelete(0,"objMarker_PREV_CHART_HIGH");
   ObjectDelete(0,"objMarker_CHART_LOW");
   ObjectDelete(0,"objMarker_PREV_CHART_LOW");
//--- delete all round number markers from chart
   for(int i=highestExtended;i>=lowestExtended;)
     {
      if(MathMod(i,10000)==0) ObjectDelete(0,"objMarker_1000_"+string(i));
      if(MathMod(i,5000)==0) ObjectDelete(0,"objMarker_500_"+string(i));
      if(MathMod(i,1000)==0) ObjectDelete(0,"objMarker_100_"+string(i));
      if(MathMod(i,500)==0) ObjectDelete(0,"objMarker_50_"+string(i));
      i-=500;
     }
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Delete specific marker from chart                                |
//+------------------------------------------------------------------+
void DeleteObject(string f_ObjName)
  {
//--- delete marker from chart
   ObjectDelete(0,f_ObjName);
  }
//+------------------------------------------------------------------+
//| Create marker objects                                            |
//+------------------------------------------------------------------+
void CreateMarkerObj(string f_ObjName,int f_Price,color f_ObjColor,ENUM_LINE_STYLE f_ObjLineStyle,int f_ObjWidth)
  {
//--- delete any existing object with the same name
   ObjectDelete(0,f_ObjName);
//--- create new marker object
   ObjectCreate(0,f_ObjName,OBJ_HLINE,0,0,f_Price*Point());
   ObjectSetInteger(0,f_ObjName,OBJPROP_BACK,InpDrawAsBackground);
   ObjectSetInteger(0,f_ObjName,OBJPROP_COLOR,f_ObjColor);
   ObjectSetInteger(0,f_ObjName,OBJPROP_STYLE,f_ObjLineStyle);
   ObjectSetInteger(0,f_ObjName,OBJPROP_WIDTH,f_ObjWidth);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- name for indicator
   IndicatorSetString(INDICATOR_SHORTNAME,"Round Number Marker");

//--- set time delay before marker for previous high/low is reset
   resetDelay=PeriodSeconds(InpResetDelayTime);

//--- reset flags for making a new high/low on the chart or for PERIOD_MN1
   newAbsHigh=false;
   newAbsLow=false;
   newChartHigh=false;
   newChartLow=false;

//--- set colors to use for separators
   if(InpUseBrightColors==false)
     {
      marker_1000_Clr=InpMarker_1000;
      marker_500_Clr=InpMarker_500;
      marker_100_Clr=InpMarker_100;
      marker_50_Clr=InpMarker_50;
      marker_ChartHigh_Clr=InpMarker_ChartHigh;
      marker_ChartLow_Clr=InpMarker_ChartLow;
      marker_AbsHigh_Clr=InpMarker_AbsHigh;
      marker_AbsLow_Clr=InpMarker_AbsLow;
     }
   else
     {
      marker_1000_Clr=InpMarker_1000_Brt;
      marker_500_Clr=InpMarker_500_Brt;
      marker_100_Clr=InpMarker_100_Brt;
      marker_50_Clr=InpMarker_50_Brt;
      marker_ChartHigh_Clr=InpMarker_ChartHigh_Brt;
      marker_ChartLow_Clr=InpMarker_ChartLow_Brt;
      marker_AbsHigh_Clr=InpMarker_AbsHigh_Brt;
      marker_AbsLow_Clr=InpMarker_AbsLow_Brt;
     }

//--- initialization done
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete markers from chart
   DeleteObjects();
  }
//+------------------------------------------------------------------+
//| ClearView RoundNumberMarker                                      |
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
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Time,true);

//--- flags set to determine whether markers need to be (re)drawn
   bool drawAbsHighMarker=false;
   bool drawPrevAbsHighMarker=false;
   bool drawAbsLowMarker=false;
   bool drawPrevAbsLowMarker=false;
   bool drawChartHighMarker=false;
   bool drawPrevChartHighMarker=false;
   bool drawChartLowMarker=false;
   bool drawPrevChartLowMarker=false;
   bool drawRoundNumberMarkers=false;

//-- draw objects on first iteration
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

      //--- initialize previous values for historical highest high and historical lowest low
      prevAbsHighInt=absHighInt;
      prevAbsLowInt=absLowInt;

      //--- calculate highest high on chart
      int chartHighIdx=ArrayMaximum(High,0,WHOLE_ARRAY);
      chartHighInt=(int)(High[chartHighIdx]/Point());
      prevChartHighInt=chartHighInt;
      //--- set how much higher than the highest high lines will be drawn
      highestExtended=chartHighInt-(int)MathMod(chartHighInt,500)+500+10000;
      //--- calculate lowest low on chart
      int chartLowIdx=ArrayMinimum(Low,0,WHOLE_ARRAY);
      chartLowInt=(int)(Low[chartLowIdx]/Point());
      prevChartLowInt=chartLowInt;
      //--- set how much lower than the lowest low lines will be drawn
      lowestExtended=chartLowInt-(int)MathMod(chartLowInt,500)-10000;

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

      //--- (re)draw markers
      drawAbsHighMarker=true;
      drawAbsLowMarker=true;
      drawChartHighMarker=true;
      drawChartLowMarker=true;
      drawRoundNumberMarkers=true;
     }

//--- get current Bid and Ask
   int curBid;
   curBid=(int)(SymbolInfoDouble(Symbol(),SYMBOL_BID)/Point());

//--- check for new highest high for PERIOD_MN1
   if(curBid>absHighInt)
     {
      if(newAbsHigh==false)
        {
         drawPrevAbsHighMarker=true;
         //--- mark time of new absolute highest high
         newAbsHighDate=TimeCurrent();
         //--- set flag for new absolute highest high
         newAbsHigh=true;
        }
      // reset value for absolute highest high
      absHighInt=curBid;
      //--- (re)draw marker for absolute highest high
      drawAbsHighMarker=true;
     }
//--- the marker for the previous highest high for PERIOD_MN1 remains visible to indicate an area of possible support
//--- after the resetDelay has expired, remove the previous highest high marker for PERIOD_MN1
   if(newAbsHigh==true && TimeCurrent()>=newAbsHighDate+resetDelay)
     {
      //--- reset previous highest high for PERIOD_MN1 to current highest high for PERIOD_MN1
      prevAbsHighInt=absHighInt;
      //--- remove marker for previous highest high for PERIOD_MN1
      DeleteObject("objMarker_PREVABSHIGH");
      newAbsHigh=false;
     }

//--- check for new lowest low for PERIOD_MN1
   if(curBid<absLowInt)
     {
      if(newAbsLow==false)
        {
         drawPrevAbsLowMarker=true;
         // mark time of new absolute lowest low
         newAbsLowDate=TimeCurrent();
         //--- set flag for new absolute lowest low
         newAbsLow=true;
        }
      // reset value for absolute lowest low
      absLowInt=curBid;
      //--- (re)draw marker for absolute lowest low
      drawAbsLowMarker=true;
     }
//--- the marker for the previous lowest low for PERIOD_MN1 remains visible to indicate an area of possible resistance
//--- after the resetDelay has expired, remove the previous lowest low marker for PERIOD_MN1
   if(newAbsLow==true && TimeCurrent()>=newAbsLowDate+resetDelay)
     {
      //--- reset previous lowest low for PERIOD_MN1 to current lowest low for PERIOD_MN1
      prevAbsLowInt=absLowInt;
      //--- remove marker for previous lowest low for PERIOD_MN1
      DeleteObject("objMarker_PREVABSLOW");
      newAbsLow=false;
     }

//--- check for new highest high on chart
   if(curBid>chartHighInt)
     {
      if(newChartHigh==false)
        {
         if(prevChartHighInt!=prevAbsHighInt)
            drawPrevChartHighMarker=true;
         //--- mark time of new highest high on chart
         newChartHighDate=TimeCurrent();
         //--- set flag for new highest high on chart
         newChartHigh=true;
        }
      // reset value for highest high on chart
      chartHighInt=curBid;
      //--- (re)draw marker for highest high on chart
      if(chartHighInt!=absHighInt)
         drawChartHighMarker=true;
      //--- remove marker for highest high on chart
      if(chartHighInt==absHighInt)
         DeleteObject("objMarker_CHARTHIGH");
     }
//--- the marker for the previous highest high on the chart remains visible to indicate an area of possible support
//--- after the resetDelay has expired, remove the marker for the previous highest high on the chart
   if(newChartHigh==true && TimeCurrent()>=newChartHighDate+resetDelay)
     {
      //--- reset previous highest high on chart to current highest high on chart
      prevChartHighInt=chartHighInt;
      //--- remove marker for previous highest high on chart
      DeleteObject("objMarker_PREVCHARTHIGH");
      newChartHigh=false;
     }

//--- check for new lowest low on chart
   if(curBid<chartLowInt)
     {
      if(newChartLow==false)
        {
         if(prevChartLowInt!=prevAbsLowInt)
            drawPrevChartLowMarker=true;
         //--- mark time of new lowest low on chart
         newChartLowDate=TimeCurrent();
         //--- set flag for new lowest low on chart
         newChartLow=true;
        }
      // reset value for lowest low on chart
      chartLowInt=curBid;
      //--- (re)draw marker for lowest low on chart
      if(chartLowInt!=absLowInt)
         drawChartLowMarker=true;
      //--- remove marker for lowest low on chart
      if(chartLowInt==absLowInt)
         DeleteObject("objMarker_CHARTLOW");
     }
//--- the marker for the previous lowest low on the chart remains visible to indicate an area of possible resistance
//--- after the resetDelay has expired, remove the marker for the previous lowest low on the chart
   if(newChartLow==true && TimeCurrent()>=newChartLowDate+resetDelay)
     {
      //--- reset previous lowest low on chart to current lowest low on chart
      prevChartLowInt=chartLowInt;
      //--- remove marker for previous lowest low on chart
      DeleteObject("objMarker_PREVCHARTLOW");
      newChartLow=false;
     }

//--- (re)draw objects if Bid/Ask comes within 200 pips of current limits
   if(curBid<=lowestExtended+2000 || curBid>=highestExtended-2000)
     {
      //--- set new limits
      if(curBid>=highestExtended-2000) highestExtended+=5000;
      if(curBid<=lowestExtended+2000) lowestExtended-=5000;
      //--- (re)draw round number markers
      drawRoundNumberMarkers=true;
     }

//--- (re)draw round number markers
   if(drawRoundNumberMarkers==true)
     {
      for(int i=highestExtended;i>=lowestExtended;)
        {
         if(MathMod(i,10000)==0 && Period()<=InpMaxTF_1000)
           {
            CreateMarkerObj("objMarker_1000_"+string(i),i,marker_1000_Clr,STYLE_DASHDOT,1);
            i-=500;
            continue;
           }
         if(MathMod(i,5000)==0 && Period()<=InpMaxTF_500)
           {
            CreateMarkerObj("objMarker_500_"+string(i),i,marker_500_Clr,STYLE_DASHDOT,1);
            i-=500;
            continue;
           }
         if(MathMod(i,1000)==0 && Period()<=InpMaxTF_100)
           {
            CreateMarkerObj("objMarker_100_"+string(i),i,marker_100_Clr,STYLE_DASHDOT,1);
            i-=500;
            continue;
           }
         if(MathMod(i,500)==0 && Period()<=InpMaxTF_50)
            CreateMarkerObj("objMarker_50_"+string(i),i,marker_50_Clr,STYLE_DASHDOT,1);
         i-=500;
        }
     }

//--- (re)draw highest high on chart marker
   if(drawChartHighMarker==true)
      CreateMarkerObj("objMarker_CHART_HIGH",chartHighInt,marker_ChartHigh_Clr,STYLE_DASHDOT,1);
//--- (re)draw previous highest high on chart marker
   if(drawPrevChartHighMarker==true)
      CreateMarkerObj("objMarker_PREV_CHART_HIGH",prevChartHighInt,marker_ChartHigh_Clr,STYLE_DOT,1);
//--- (re)draw lowest low on chart marker
   if(drawChartLowMarker==true && chartLowInt!=absLowInt)
      CreateMarkerObj("objMarker_CHART_LOW",chartLowInt,marker_ChartLow_Clr,STYLE_DASHDOT,1);
//--- (re)draw previous lowest low on chart marker
   if(drawPrevChartLowMarker==true)
      CreateMarkerObj("objMarker_PREV_CHART_LOW",prevChartLowInt,marker_ChartLow_Clr,STYLE_DOT,1);

//--- (re)draw highest high for PERIOD_MN1
   if(drawAbsHighMarker==true)
      CreateMarkerObj("objMarker_HISTORICAL_HIGH",absHighInt,marker_AbsHigh_Clr,STYLE_DASH,1);
//--- (re)draw previous highest high for PERIOD_MN1
   if(drawPrevAbsHighMarker==true)
      CreateMarkerObj("objMarker_PREV_HISTORICAL_HIGH",prevAbsHighInt,marker_AbsHigh_Clr,STYLE_DOT,1);
//--- (re)draw lowest low for PERIOD_MN1
   if(drawAbsLowMarker==true)
      CreateMarkerObj("objMarker_HISTORICAL_LOW",absLowInt,marker_AbsLow_Clr,STYLE_DASH,1);
//--- (re)draw previous lowest low for PERIOD_MN1
   if(drawPrevAbsLowMarker==true)
      CreateMarkerObj("objMarker_PREV_HISTORICAL_LOW",prevAbsLowInt,marker_AbsLow_Clr,STYLE_DOT,1);

//--- return value of rates_total, will be used as prev_calculated in next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
