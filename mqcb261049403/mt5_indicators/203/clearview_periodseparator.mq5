//+------------------------------------------------------------------+
//|                                    ClearView_PeriodSeparator.mq5 |
//|                                           Copyright © 2010, AK20 |
//|                                             traderak20@gmail.com |
//+------------------------------------------------------------------+
#property copyright   "2010, traderak20@gmail.com"
#property description "ClearView PeriodSeparator, period separator to mark days, weeks, months and custom session start/end"
#property description " "
#property description "This is indicator is best used together with: ClearView_PricePointer and ClearView_RoundNumberMarker"
#property description " "
#property description "See the source file for instructions on usage"

/*----------------------------------------------------------------------------------------------------
   This is one of a set of three indicators to enhance the look of your charts.
   The other indicators are: ClearView_PricePointer and ClearView_RoundNumberMarker
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

   *  Choose between two color sets (bright or dim colors) to set the visibility of the lines drawn

   *  Draw lines as background (default and recommended) or on foreground

   *  Specify a custom start and end time to mark your trading hours

   *  Specify for each marker whether it should be shown at all (true/false) and up to which timeframe.
      E.g. you can choose to show daily markers only up to the 1-hour timeframe. This way your chart won't be
      cluttered with too many lines when switching between timeframes. On any timeframe it will automatically
      show only the lines you want to see.

   *  Apart from different colors, all markers have an object description to show whether it's the start/end
      of a session, day (includes three letter abbreviation for day of the week), week, month or year.

   *  Start and end of session and new day markers are projected into the future to give an indication
      how much time is left (if they're not visible, zoom out to see these markers)

----------------------------------------------------------------------------------------------------*/

#property indicator_chart_window
#property indicator_buffers  1
#property indicator_plots    1

//--- input parameters
input int                  InpMaxBars=2500;                          // Show separators for # bars (0=ALL)
input bool                 InpUseBrightColors=true;                  // Use bright colors
input bool                 InpDrawAsBackground=true;                 // Draw lines as background
input bool                 InpShowSessionSeparator=true;             // Show separator for session start/end
input ENUM_TIMEFRAMES      InpMaxTF_Session=PERIOD_M30;              // Show session separator up to timeframe
input int                  InpSessionStartTime=9;                    // Start hour of session (0-23)
input int                  InpShiftStartMins=0;                      // Shift start by minutes
input int                  InpSessionEndTime=18;                     // End hour of session (0-23)
input int                  InpShiftEndMins=0;                        // Shift end by minutes
input color                InpSessionStartColor=C'10,50,10';         // Start of session
input color                InpSessionStartColorBright=C'20,100,20';  // Start of session bright
input color                InpSessionEndColor=C'50,10,10';           // End of session
input color                InpSessionEndColorBright=C'100,20,20';    // End of session bright
input bool                 InpShowDailySeparator=true;               // Show separator between days
input ENUM_TIMEFRAMES      InpMaxTF_Daily=PERIOD_H4;                 // Show day separator up to timeframe
input color                InpDailyColor=C'0,33,66';                 // New day
input color                InpDailyColorBright=C'0,66,132';          // New day bright
input bool                 InpShowWeeklySeparator=true;              // Show separator between weeks
input ENUM_TIMEFRAMES      InpMaxTF_Weekly=PERIOD_H12;               // Show week separator up to timeframe
input color                InpWeeklyColor=C'66,0,66';                // New week
input color                InpWeeklyColorBright=C'132,0,132';        // New week bright
input bool                 InpShowMonthlySeparator=true;             // Show separator between months
input ENUM_TIMEFRAMES      InpMaxTF_Monthly=PERIOD_D1;               // Show month separator up to timeframe
input color                InpMonthlyColor=C'66,66,0';               // New month
input color                InpMonthlyColorBright=C'132,132,0';       // New month bright
input bool                 InpShowYearlySeparator=true;              // Show separator between years
input color                InpYearlyColor=C'66,33,0';                // New year
input color                InpYearlyColorBright=C'132,66,0';         // New year bright

//--- global variables
int                        sessionStartTime,sessionEndTime;          // start/end of session
datetime                   extendedSessionStartTime;                 // datetime for extended start of session separator
datetime                   extendedSessionEndTime;                   // datetime for extended end of session separator
datetime                   extendedNewDayTime;                       // datetime for extended new day separator
color                      sessionStartCol,sessionEndCol;            // colors for session start/end
color                      dailyCol,weeklyCol;                       // color for daily/weekly separator
color                      monthlyCol,yearlyCol;                     // colors for monthly/yearly separator
int                        oneDay=86400;                             // seconds in a day: 60*60*24
int                        drawingStyle;                             // drawing style for daily/weekly/monthly/yearly separators
//+------------------------------------------------------------------+
//| Delete all separators from chart                                 |
//+------------------------------------------------------------------+
void DeleteObjects()
  {
//--- count all VLINE objects
   int f_TotalObjects=ObjectsTotal(0,0,OBJ_VLINE);

   for(int i=f_TotalObjects-1;i>=0;i--)
     {
      //--- remove VLINE objects created by this indicator
      string f_ObjName=ObjectName(0,i,0,OBJ_VLINE);
      if(StringFind(f_ObjName,"objNewDay_",0)>=0 || StringFind(f_ObjName,"objNewWeek_",0)>=0 || 
         StringFind(f_ObjName,"objNewMonth_",0)>=0 || StringFind(f_ObjName,"objNewYear_",0)>=0 || 
         StringFind(f_ObjName,"objSessionStart_",0)>=0 || StringFind(f_ObjName,"objSessionEnd_",0)>=0)
         ObjectDelete(0,f_ObjName);
     }
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Create separator objects                                         |
//+------------------------------------------------------------------+
void CreateSeparatorObj(string f_ObjName,datetime f_Time,color f_ObjColor,int f_LineStyle,int f_LineWidth)
  {
   ObjectDelete(0,f_ObjName);
   ObjectCreate(0,f_ObjName,OBJ_VLINE,0,f_Time,0);
   ObjectSetInteger(0,f_ObjName,OBJPROP_BACK,InpDrawAsBackground);
   ObjectSetInteger(0,f_ObjName,OBJPROP_COLOR,f_ObjColor);
   ObjectSetInteger(0,f_ObjName,OBJPROP_STYLE,f_LineStyle);
   ObjectSetInteger(0,f_ObjName,OBJPROP_WIDTH,f_LineWidth);
  }
//+------------------------------------------------------------------+
//| Create separator objects                                         |
//+------------------------------------------------------------------+
string DayOfWeekString(int f_dayofweek)
  {
   switch(f_dayofweek)
     {
      case 0:  return("SUN");
      case 1:  return("MON");
      case 2:  return("TUE");
      case 3:  return("WED");
      case 4:  return("THU");
      case 5:  return("FRI");
      case 6:  return("SAT");
      default: return("");
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- name for indicator
   IndicatorSetString(INDICATOR_SHORTNAME,"Period Separator");

//--- adjust session start/end time
   sessionStartTime=InpSessionStartTime;
   if(InpSessionStartTime<0) sessionStartTime=1;
   if(InpSessionStartTime>23) sessionStartTime=23;
   sessionEndTime=InpSessionEndTime;
   if(InpSessionEndTime<0) sessionEndTime=1;
   if(InpSessionEndTime>23) sessionEndTime=23;

//--- set extended times to earliest time possible
   extendedSessionStartTime=0;
   extendedSessionEndTime=0;
   extendedNewDayTime=0;

//--- set colors to use for separators
   if(InpUseBrightColors==false)
     {
      sessionStartCol=InpSessionStartColor;
      sessionEndCol=InpSessionEndColor;
      dailyCol=InpDailyColor;
      weeklyCol=InpWeeklyColor;
      monthlyCol=InpMonthlyColor;
      yearlyCol=InpYearlyColor;
     }
   else
     {
      sessionStartCol=InpSessionStartColorBright;
      sessionEndCol=InpSessionEndColorBright;
      dailyCol=InpDailyColorBright;
      weeklyCol=InpWeeklyColorBright;
      monthlyCol=InpMonthlyColorBright;
      yearlyCol=InpYearlyColorBright;
     }

//--- set drawing style for daily/weekly/monthly/yearly separators
   if(Period()<=InpMaxTF_Session && InpShowSessionSeparator==true) drawingStyle=STYLE_DASH;
   else drawingStyle=STYLE_DOT;

//--- initialization done
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete separators from chart
   DeleteObjects();
  }
//+------------------------------------------------------------------+
//| ClearView PeriodSeparator                                        |
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

//--- check for data
   if(rates_total<100)
      return(0);

//--- set maximum number of bars to calculate
   int maxBars=InpMaxBars;
   if(maxBars>=rates_total || maxBars<0)
      maxBars=rates_total-2;
//--- set limit for which bars need to be (re)calculated
   int limit=0;
   if(prev_calculated==0 || prev_calculated<0 || prev_calculated>rates_total)
     {
      if(maxBars==0) limit=rates_total-2;
      if(maxBars>0) limit=maxBars;
     }
   else
      limit=rates_total-prev_calculated;

//--- main calculation loop
   for(int i=limit;i>=0;i--)
     {
      //--- create structure variable of Time
      MqlDateTime timeStruct,timeStruct_prev;
      TimeToStruct(Time[i],timeStruct);
      TimeToStruct(Time[i+1],timeStruct_prev);

      //--- set day of week
      int today_int=timeStruct.day_of_week;
      string today_str=DayOfWeekString(today_int);
      string curdate_str=TimeToString(Time[i],TIME_DATE);
      datetime curdate_datetime=StringToTime(curdate_str);

      //--- draw separators for start of session
      if(InpShowSessionSeparator==true && Period()<=InpMaxTF_Session)
        {
         //--- draw separator for start of session
         if(timeStruct.hour==sessionStartTime && timeStruct_prev.hour!=sessionStartTime)
            CreateSeparatorObj("objSessionStart_"+string(rates_total-i),Time[i]+(InpShiftStartMins*60),sessionStartCol,STYLE_DOT,0);
         //--- draw extended start of session separator
         if(i==0 && Time[i]>=extendedSessionStartTime)
           {
            extendedSessionStartTime=curdate_datetime+(sessionStartTime*3600)+(InpShiftStartMins*60);
            if(timeStruct.hour>=sessionStartTime)
               extendedSessionStartTime+=oneDay;
            CreateSeparatorObj("objSessionStart_Extended",extendedSessionStartTime,sessionStartCol,STYLE_DOT,0);
           }
        }
      //--- draw separators for end of session
      if(InpShowSessionSeparator==true && Period()<=InpMaxTF_Session)
        {
         //--- draw separator for end of session
         if(timeStruct.hour==sessionEndTime && timeStruct_prev.hour!=sessionEndTime)
            CreateSeparatorObj("objSessionEnd_"+string(rates_total-i),Time[i]+(InpShiftEndMins*60),sessionEndCol,STYLE_DOT,0);
         //--- draw extended end of session separator
         if(i==0 && Time[i]>=extendedSessionEndTime)
           {
            extendedSessionEndTime=curdate_datetime+(sessionEndTime*3600)+(InpShiftEndMins*60);
            if(timeStruct.hour>=sessionEndTime)
               extendedSessionEndTime+=oneDay;
            CreateSeparatorObj("objSessionEnd_Extended",extendedSessionEndTime,sessionEndCol,STYLE_DOT,0);
           }
        }
      //--- draw separator for start of a new year
      if(InpShowYearlySeparator==true && timeStruct.year!=timeStruct_prev.year)
        {
         CreateSeparatorObj("objNewYear_"+today_str+"_"+string(rates_total-i),Time[i],yearlyCol,drawingStyle,0);
         continue;
        }
      //--- draw separator for start of a new month
      if(InpShowMonthlySeparator==true && Period()<=InpMaxTF_Monthly && timeStruct.mon!=timeStruct_prev.mon)
        {
         CreateSeparatorObj("objNewMonth_"+today_str+"_"+string(rates_total-i),Time[i],monthlyCol,drawingStyle,0);
         continue;
        }
      //--- draw separator for start of a new week
      if(InpShowWeeklySeparator==true && Period()<=InpMaxTF_Weekly && timeStruct.day_of_week!=5 && timeStruct_prev.day_of_week==5)
        {
         CreateSeparatorObj("objNewWeek_"+today_str+"_"+string(rates_total-i),Time[i],weeklyCol,drawingStyle,0);
         continue;
        }
      //--- draw separators for start of a new day
      if(InpShowDailySeparator==true && Period()<=InpMaxTF_Daily)
        {
         //--- draw separators for start of a new day
         if(timeStruct.day_of_year!=timeStruct_prev.day_of_year)
            CreateSeparatorObj("objNewDay_"+today_str+"_"+string(rates_total-i),Time[i],dailyCol,drawingStyle,0);
         //--- draw extended start of new day separator
         if(i==0 && Time[i]>=extendedNewDayTime)
           {
            extendedNewDayTime=curdate_datetime+oneDay;
            CreateSeparatorObj("objNewDay_Extended",extendedNewDayTime,dailyCol,drawingStyle,0);
           }
        }
     }

//--- return value of rates_total, will be used as prev_calculated in next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
