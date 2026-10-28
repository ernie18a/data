//+------------------------------------------------------------------+
//|                             AsianSessionBreakoutBhanuCodeLab.mq5 |
//|                                           Copyright BhanuCodeLab |
//+------------------------------------------------------------------+
#property copyright "BhanuCodeLab"
#property version   "1.0"
#property strict
#property description "Draws the Asian-session range, extends its high and low to the broker-day end, and identifies post-session breakouts."

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+
enum ENUM_BCL_BREAKOUT_MODE
  {
   BCL_BREAKOUT_BY_CLOSE = 0,   // Confirm when a completed candle closes outside the range
   BCL_BREAKOUT_BY_WICK  = 1    // Confirm when a candle high or low penetrates the range
  };

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "==== Asian Session Settings ===="
input int                    InpSessionStartHour          = 0;                  // Session start hour in broker server time
input int                    InpSessionStartMinute        = 0;                  // Session start minute in broker server time
input int                    InpSessionEndHour            = 8;                  // Session end hour in broker server time
input int                    InpSessionEndMinute          = 0;                  // Session end minute in broker server time
input ENUM_TIMEFRAMES        InpRangeTimeframe            = PERIOD_M1;          // Timeframe used to calculate the session range
input ENUM_TIMEFRAMES        InpBreakoutTimeframe         = PERIOD_CURRENT;     // Timeframe used to confirm breakouts
input ENUM_BCL_BREAKOUT_MODE InpBreakoutMode              = BCL_BREAKOUT_BY_CLOSE; // Breakout confirmation method
input int                    InpHistoryDays               = 10;                 // Number of broker days to display
input bool                   InpIncludeWeekends           = false;              // Display Saturday and Sunday sessions
input int                    InpRefreshSeconds            = 1;                  // Timer refresh interval in seconds

input group "==== Session Range Appearance ===="
input bool                   InpShowSessionBackground     = true;               // Show the Asian-session range background
input color                  InpSessionBackgroundColor    = clrSteelBlue;       // Session range background color
input int                    InpSessionOpacityPercent     = 10;                 // Visual background opacity from 0 to 100
input color                  InpHighLineColor             = clrDeepSkyBlue;     // Asian-session high line color
input color                  InpLowLineColor              = clrTomato;          // Asian-session low line color
input ENUM_LINE_STYLE        InpLineStyle                 = STYLE_DASH;         // High and low line style
input int                    InpLineWidth                 = 1;                  // High and low line width
input bool                   InpShowPriceLabels           = true;               // Show high and low value labels
input int                    InpLabelFontSize             = 10;                 // High and low label font size
input string                 InpLabelFont                 = "Arial Bold";       // High and low label font
input int                    InpLabelOffsetMinutes        = 5;                  // Label offset after the session end
input bool                   InpShowBreakoutMarkers       = true;               // Show breakout markers
input int                    InpMarkerSize                = 2;                  // Breakout marker size

input group "==== Broker Day Separators ===="
input bool                   InpShowDaySeparators         = true;               // Show broker-day separator lines
input color                  InpDaySeparatorColor         = clrDimGray;         // Broker-day separator color
input ENUM_LINE_STYLE        InpDaySeparatorStyle         = STYLE_DOT;          // Broker-day separator style
input int                    InpDaySeparatorWidth         = 1;                  // Broker-day separator width

input group "==== Dashboard Settings ===="
input bool                   InpShowDashboard             = true;               // Show the current-day dashboard
input ENUM_BASE_CORNER       InpDashboardCorner           = CORNER_RIGHT_UPPER; // Dashboard corner
input int                    InpDashboardX                = 12;                 // Horizontal distance from the corner
input int                    InpDashboardY                = 24;                 // Vertical distance from the corner
input int                    InpDashboardMinimumWidth     = 284;                // Preferred minimum dashboard width
input int                    InpDashboardFontSize         = 8;                  // Dashboard normal font size
input string                 InpDashboardFont             = "Arial";            // Dashboard normal font
input string                 InpDashboardBoldFont         = "Arial Bold";       // Dashboard bold font
input color                  InpDashboardBackgroundColor  = C'48,52,60';        // Dashboard background color
input color                  InpDashboardHeaderColor      = C'35,38,45';        // Dashboard header color
input color                  InpDashboardCardColor        = C'59,64,73';        // Dashboard information-card color
input color                  InpDashboardBorderColor      = C'82,87,97';        // Dashboard border color
input color                  InpDashboardTextColor        = clrWhiteSmoke;      // Dashboard primary text color
input color                  InpDashboardMutedTextColor   = C'190,194,202';     // Dashboard secondary text color

//+------------------------------------------------------------------+
//| Structures                                                       |
//+------------------------------------------------------------------+
struct BCLSessionData
  {
   datetime          day_start;
   datetime          day_end;
   datetime          session_start;
   datetime          session_end;
   double            session_high;
   double            session_low;
   bool              has_range;
   bool              bullish_breakout;
   bool              bearish_breakout;
   datetime          bullish_breakout_time;
   datetime          bearish_breakout_time;
   double            bullish_breakout_price;
   double            bearish_breakout_price;
   string            status;
  };

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
string         g_object_prefix       = "";
datetime       g_current_day_start   = 0;
datetime       g_last_history_update = 0;
uint           g_last_refresh_tick   = 0;
BCLSessionData g_current_session;

//+------------------------------------------------------------------+
//| Returns the beginning of the broker calendar day                 |
//+------------------------------------------------------------------+
datetime BCLStartOfDay(const datetime value)
  {
   MqlDateTime date_parts;
   ZeroMemory(date_parts);

   if(!TimeToStruct(value,date_parts))
      return(0);

   date_parts.hour=0;
   date_parts.min=0;
   date_parts.sec=0;

   return(StructToTime(date_parts));
  }

//+------------------------------------------------------------------+
//| Returns a compact date key for object names                      |
//+------------------------------------------------------------------+
string BCLDayKey(const datetime day_start)
  {
   MqlDateTime date_parts;
   ZeroMemory(date_parts);

   if(!TimeToStruct(day_start,date_parts))
      return("00000000");

   return(StringFormat("%04d%02d%02d",
                       date_parts.year,
                       date_parts.mon,
                       date_parts.day));
  }

//+------------------------------------------------------------------+
//| Returns whether a broker date is a weekend                       |
//+------------------------------------------------------------------+
bool BCLIsWeekend(const datetime day_start)
  {
   MqlDateTime date_parts;
   ZeroMemory(date_parts);

   if(!TimeToStruct(day_start,date_parts))
      return(false);

   return(date_parts.day_of_week==0 ||
          date_parts.day_of_week==6);
  }

//+------------------------------------------------------------------+
//| Resolves PERIOD_CURRENT to the chart timeframe                   |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES BCLResolvedBreakoutTimeframe()
  {
   if(InpBreakoutTimeframe==PERIOD_CURRENT)
      return((ENUM_TIMEFRAMES)_Period);

   return(InpBreakoutTimeframe);
  }

//+------------------------------------------------------------------+
//| Returns a readable timeframe name                                |
//+------------------------------------------------------------------+
string BCLTimeframeText(const ENUM_TIMEFRAMES timeframe)
  {
   string text=EnumToString(timeframe);
   StringReplace(text,"PERIOD_","");

   return(text);
  }

//+------------------------------------------------------------------+
//| Returns the configured session-time text                         |
//+------------------------------------------------------------------+
string BCLSessionTimeText()
  {
   return(StringFormat("%02d:%02d-%02d:%02d",
                       InpSessionStartHour,
                       InpSessionStartMinute,
                       InpSessionEndHour,
                       InpSessionEndMinute));
  }

//+------------------------------------------------------------------+
//| Returns the full breakout-rule text                              |
//+------------------------------------------------------------------+
string BCLBreakoutRuleText()
  {
   if(InpBreakoutMode==BCL_BREAKOUT_BY_WICK)
      return("Wick penetration");

   return("Closed-candle close");
  }

//+------------------------------------------------------------------+
//| Returns the compact breakout-rule text                           |
//+------------------------------------------------------------------+
string BCLCompactBreakoutRuleText()
  {
   const string timeframe_text=
      BCLTimeframeText(BCLResolvedBreakoutTimeframe());

   if(InpBreakoutMode==BCL_BREAKOUT_BY_WICK)
      return("Wick / "+timeframe_text);

   return("Close / "+timeframe_text);
  }

//+------------------------------------------------------------------+
//| Returns an uppercase copy of text                                |
//+------------------------------------------------------------------+
string BCLUpperText(const string source)
  {
   string result=source;
   StringToUpper(result);

   return(result);
  }

//+------------------------------------------------------------------+
//| Returns the range size in points                                 |
//+------------------------------------------------------------------+
double BCLRangePoints(const BCLSessionData &data)
  {
   if(!data.has_range || _Point<=0.0)
      return(0.0);

   return((data.session_high-data.session_low)/_Point);
  }

//+------------------------------------------------------------------+
//| Blends a foreground color with a background color                |
//+------------------------------------------------------------------+
color BCLBlendColor(const color foreground,
                    const color background,
                    const int opacity_percent)
  {
   const int opacity=
      (int)MathMax(0,
                   MathMin(100,
                           opacity_percent));

   const uint foreground_value=(uint)foreground;
   const uint background_value=(uint)background;

   const int foreground_red=
      (int)(foreground_value & 0xFF);

   const int foreground_green=
      (int)((foreground_value>>8) & 0xFF);

   const int foreground_blue=
      (int)((foreground_value>>16) & 0xFF);

   const int background_red=
      (int)(background_value & 0xFF);

   const int background_green=
      (int)((background_value>>8) & 0xFF);

   const int background_blue=
      (int)((background_value>>16) & 0xFF);

   const int blended_red=
      (background_red*(100-opacity)+
       foreground_red*opacity)/100;

   const int blended_green=
      (background_green*(100-opacity)+
       foreground_green*opacity)/100;

   const int blended_blue=
      (background_blue*(100-opacity)+
       foreground_blue*opacity)/100;

   const uint blended_value=
      (uint)blended_red |
      ((uint)blended_green<<8) |
      ((uint)blended_blue<<16);

   return((color)blended_value);
  }

//+------------------------------------------------------------------+
//| Returns the simulated transparent session color                  |
//+------------------------------------------------------------------+
color BCLSessionFillColor()
  {
   const color chart_background=
      (color)ChartGetInteger(0,
                             CHART_COLOR_BACKGROUND,
                             0);

   return(BCLBlendColor(InpSessionBackgroundColor,
                        chart_background,
                        InpSessionOpacityPercent));
  }

//+------------------------------------------------------------------+
//| Initializes a session-data structure                             |
//+------------------------------------------------------------------+
void BCLInitializeSessionData(const datetime day_start,
                              BCLSessionData &data)
  {
   ZeroMemory(data);

   data.day_start=day_start;
   data.day_end=day_start+86400;

   data.session_start=day_start+
                      (InpSessionStartHour*3600)+
                      (InpSessionStartMinute*60);

   data.session_end=day_start+
                    (InpSessionEndHour*3600)+
                    (InpSessionEndMinute*60);

   data.status="Waiting for session";
  }

//+------------------------------------------------------------------+
//| Calculates the Asian-session high and low                        |
//+------------------------------------------------------------------+
bool BCLCalculateSessionRange(const datetime now,
                              BCLSessionData &data)
  {
   if(now<data.session_start)
      return(false);

   datetime calculation_end=data.session_end-1;

   if(now<data.session_end)
      calculation_end=now;

   if(calculation_end<data.session_start)
      return(false);

   MqlRates session_rates[];
   ArraySetAsSeries(session_rates,false);

   ResetLastError();

   const int copied=CopyRates(_Symbol,
                              InpRangeTimeframe,
                              data.session_start,
                              calculation_end,
                              session_rates);

   if(copied<=0)
      return(false);

   double range_high=-DBL_MAX;
   double range_low=DBL_MAX;

// Calculate the range using bars opening inside the session.
   for(int index=0; index<copied; index++)
     {
      if(session_rates[index].high>range_high)
         range_high=session_rates[index].high;

      if(session_rates[index].low<range_low)
         range_low=session_rates[index].low;
     }

   if(range_high==-DBL_MAX ||
      range_low==DBL_MAX   ||
      range_high<range_low)
      return(false);

   data.session_high=range_high;
   data.session_low=range_low;
   data.has_range=true;

   return(true);
  }

//+------------------------------------------------------------------+
//| Detects post-session bullish and bearish breakouts               |
//+------------------------------------------------------------------+
void BCLDetectBreakouts(const datetime now,
                        BCLSessionData &data)
  {
   if(!data.has_range || now<data.session_end)
      return;

   datetime scan_end=now;

   if(scan_end>=data.day_end)
      scan_end=data.day_end-1;

   if(scan_end<data.session_end)
      return;

   const ENUM_TIMEFRAMES breakout_timeframe=
      BCLResolvedBreakoutTimeframe();

   const int timeframe_seconds=
      PeriodSeconds(breakout_timeframe);

   MqlRates breakout_rates[];
   ArraySetAsSeries(breakout_rates,false);

   ResetLastError();

   const int copied=CopyRates(_Symbol,
                              breakout_timeframe,
                              data.session_end,
                              scan_end,
                              breakout_rates);

   if(copied<=0)
      return;

// Record the first bullish and bearish breakout of the day.
   for(int index=0; index<copied; index++)
     {
      if(InpBreakoutMode==BCL_BREAKOUT_BY_CLOSE &&
         timeframe_seconds>0)
        {
         const datetime bar_close_time=
            breakout_rates[index].time+
            timeframe_seconds;

         if(bar_close_time>now)
            continue;
        }

      bool bullish_condition=false;
      bool bearish_condition=false;

      if(InpBreakoutMode==BCL_BREAKOUT_BY_WICK)
        {
         bullish_condition=
            breakout_rates[index].high>
            data.session_high;

         bearish_condition=
            breakout_rates[index].low<
            data.session_low;
        }
      else
        {
         bullish_condition=
            breakout_rates[index].close>
            data.session_high;

         bearish_condition=
            breakout_rates[index].close<
            data.session_low;
        }

      if(bullish_condition &&
         !data.bullish_breakout)
        {
         data.bullish_breakout=true;

         data.bullish_breakout_time=
            breakout_rates[index].time;

         data.bullish_breakout_price=
            InpBreakoutMode==BCL_BREAKOUT_BY_WICK
            ? breakout_rates[index].high
            : breakout_rates[index].close;
        }

      if(bearish_condition &&
         !data.bearish_breakout)
        {
         data.bearish_breakout=true;

         data.bearish_breakout_time=
            breakout_rates[index].time;

         data.bearish_breakout_price=
            InpBreakoutMode==BCL_BREAKOUT_BY_WICK
            ? breakout_rates[index].low
            : breakout_rates[index].close;
        }

      if(data.bullish_breakout &&
         data.bearish_breakout)
         break;
     }
  }

//+------------------------------------------------------------------+
//| Assigns the current status text                                  |
//+------------------------------------------------------------------+
void BCLAssignStatus(const datetime now,
                     BCLSessionData &data)
  {
   if(!InpIncludeWeekends &&
      BCLIsWeekend(data.day_start))
     {
      data.status="Weekend disabled";
      return;
     }

   if(now<data.session_start)
     {
      data.status="Waiting for session";
      return;
     }

   if(!data.has_range)
     {
      data.status="No session data";
      return;
     }

   if(now<data.session_end)
     {
      data.status="Session forming";
      return;
     }

   if(data.bullish_breakout &&
      data.bearish_breakout)
     {
      if(data.bullish_breakout_time<
         data.bearish_breakout_time)
         data.status="Bullish then bearish";
      else
         if(data.bearish_breakout_time<
            data.bullish_breakout_time)
            data.status="Bearish then bullish";
         else
            data.status="Both sides broken";

      return;
     }

   if(data.bullish_breakout)
     {
      data.status="Bullish breakout";
      return;
     }

   if(data.bearish_breakout)
     {
      data.status="Bearish breakout";
      return;
     }

   data.status="Range intact";
  }

//+------------------------------------------------------------------+
//| Builds all values for one broker day                             |
//+------------------------------------------------------------------+
void BCLBuildSessionData(const datetime day_start,
                         const datetime now,
                         BCLSessionData &data)
  {
   BCLInitializeSessionData(day_start,data);

   if(!InpIncludeWeekends &&
      BCLIsWeekend(day_start))
     {
      BCLAssignStatus(now,data);
      return;
     }

   BCLCalculateSessionRange(now,data);
   BCLDetectBreakouts(now,data);
   BCLAssignStatus(now,data);
  }

//+------------------------------------------------------------------+
//| Creates or updates a two-point chart object                      |
//+------------------------------------------------------------------+
bool BCLEnsureTwoPointObject(const string name,
                             const ENUM_OBJECT object_type,
                             const datetime time_one,
                             const double price_one,
                             const datetime time_two,
                             const double price_two)
  {
   if(ObjectFind(0,name)<0)
     {
      ResetLastError();

      if(!ObjectCreate(0,
                       name,
                       object_type,
                       0,
                       time_one,
                       price_one,
                       time_two,
                       price_two))
        {
         PrintFormat("%s: ObjectCreate failed for %s. Error %d",
                     __FUNCTION__,
                     name,
                     GetLastError());

         return(false);
        }
     }
   else
     {
      ObjectMove(0,name,0,time_one,price_one);
      ObjectMove(0,name,1,time_two,price_two);
     }

   return(true);
  }

//+------------------------------------------------------------------+
//| Creates or updates the Asian-session background                  |
//+------------------------------------------------------------------+
void BCLDrawSessionRectangle(const BCLSessionData &data,
                             const string object_name)
  {
   if(!BCLEnsureTwoPointObject(object_name,
                               OBJ_RECTANGLE,
                               data.session_start,
                               data.session_high,
                               data.session_end,
                               data.session_low))
      return;

   const color fill_color=
      BCLSessionFillColor();

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_COLOR,
                    fill_color);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_FILL,
                    true);

// The blended fill remains behind the candles.
   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_BACK,
                    true);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_STYLE,
                    STYLE_SOLID);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_WIDTH,
                    1);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_SELECTABLE,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_SELECTED,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_HIDDEN,
                    true);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_ZORDER,
                    0);

   ObjectSetString(0,
                   object_name,
                   OBJPROP_TOOLTIP,
                   "Asian session range");
  }

//+------------------------------------------------------------------+
//| Creates or updates a horizontal session level                    |
//+------------------------------------------------------------------+
void BCLDrawRangeLine(const string object_name,
                      const datetime start_time,
                      const datetime end_time,
                      const double price,
                      const color line_color)
  {
   if(!BCLEnsureTwoPointObject(object_name,
                               OBJ_TREND,
                               start_time,
                               price,
                               end_time,
                               price))
      return;

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_COLOR,
                    line_color);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_STYLE,
                    InpLineStyle);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_WIDTH,
                    InpLineWidth);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_RAY_LEFT,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_RAY_RIGHT,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_BACK,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_SELECTABLE,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_SELECTED,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_HIDDEN,
                    true);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_ZORDER,
                    1);

   ObjectSetString(0,
                   object_name,
                   OBJPROP_TOOLTIP,
                   "\n");
  }

//+------------------------------------------------------------------+
//| Creates or updates a broker-day separator                        |
//+------------------------------------------------------------------+
void BCLDrawDaySeparator(const datetime day_start)
  {
   const string object_name=
      g_object_prefix+
      BCLDayKey(day_start)+
      "_DAY_SEPARATOR";

   if(!InpShowDaySeparators)
     {
      ObjectDelete(0,object_name);
      return;
     }

   if(ObjectFind(0,object_name)<0)
     {
      ResetLastError();

      if(!ObjectCreate(0,
                       object_name,
                       OBJ_VLINE,
                       0,
                       day_start,
                       0.0))
        {
         PrintFormat("%s: ObjectCreate failed for %s. Error %d",
                     __FUNCTION__,
                     object_name,
                     GetLastError());

         return;
        }
     }
   else
      ObjectMove(0,
                 object_name,
                 0,
                 day_start,
                 0.0);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_COLOR,
                    InpDaySeparatorColor);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_STYLE,
                    InpDaySeparatorStyle);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_WIDTH,
                    InpDaySeparatorWidth);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_BACK,
                    true);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_SELECTABLE,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_SELECTED,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_HIDDEN,
                    true);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_ZORDER,
                    0);

   ObjectSetString(0,
                   object_name,
                   OBJPROP_TOOLTIP,
                   "Broker day start: "+
                   TimeToString(day_start,TIME_DATE));
  }

//+------------------------------------------------------------------+
//| Creates or updates a high or low price label                     |
//+------------------------------------------------------------------+
void BCLDrawPriceLabel(const string object_name,
                       const datetime label_time,
                       const double label_price,
                       const string label_text,
                       const color label_color,
                       const ENUM_ANCHOR_POINT anchor)
  {
   if(ObjectFind(0,object_name)<0)
     {
      ResetLastError();

      if(!ObjectCreate(0,
                       object_name,
                       OBJ_TEXT,
                       0,
                       label_time,
                       label_price))
        {
         PrintFormat("%s: ObjectCreate failed for %s. Error %d",
                     __FUNCTION__,
                     object_name,
                     GetLastError());

         return;
        }
     }
   else
      ObjectMove(0,
                 object_name,
                 0,
                 label_time,
                 label_price);

   ObjectSetString(0,
                   object_name,
                   OBJPROP_TEXT,
                   label_text);

   ObjectSetString(0,
                   object_name,
                   OBJPROP_FONT,
                   InpLabelFont);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_FONTSIZE,
                    InpLabelFontSize);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_COLOR,
                    label_color);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_ANCHOR,
                    anchor);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_BACK,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_SELECTABLE,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_SELECTED,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_HIDDEN,
                    true);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_ZORDER,
                    2);

   ObjectSetString(0,
                   object_name,
                   OBJPROP_TOOLTIP,
                   "\n");
  }

//+------------------------------------------------------------------+
//| Creates or updates a breakout marker                             |
//+------------------------------------------------------------------+
void BCLDrawBreakoutMarker(const string object_name,
                           const datetime marker_time,
                           const double marker_price,
                           const bool bullish)
  {
   if(ObjectFind(0,object_name)<0)
     {
      ResetLastError();

      if(!ObjectCreate(0,
                       object_name,
                       OBJ_ARROW,
                       0,
                       marker_time,
                       marker_price))
        {
         PrintFormat("%s: ObjectCreate failed for %s. Error %d",
                     __FUNCTION__,
                     object_name,
                     GetLastError());

         return;
        }
     }
   else
      ObjectMove(0,
                 object_name,
                 0,
                 marker_time,
                 marker_price);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_ARROWCODE,
                    bullish ? 233 : 234);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_COLOR,
                    bullish
                    ? InpHighLineColor
                    : InpLowLineColor);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_WIDTH,
                    InpMarkerSize);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_ANCHOR,
                    bullish
                    ? ANCHOR_BOTTOM
                    : ANCHOR_TOP);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_BACK,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_SELECTABLE,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_SELECTED,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_HIDDEN,
                    true);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_ZORDER,
                    2);

   ObjectSetString(0,
                   object_name,
                   OBJPROP_TOOLTIP,
                   bullish
                   ? "Bullish Asian-session breakout"
                   : "Bearish Asian-session breakout");
  }

//+------------------------------------------------------------------+
//| Deletes session objects belonging to one broker day              |
//+------------------------------------------------------------------+
void BCLDeleteSessionObjects(const datetime day_start)
  {
   const string day_prefix=
      g_object_prefix+
      BCLDayKey(day_start)+
      "_";

   ObjectDelete(0,day_prefix+"BOX");
   ObjectDelete(0,day_prefix+"HIGH_LINE");
   ObjectDelete(0,day_prefix+"LOW_LINE");
   ObjectDelete(0,day_prefix+"HIGH_TEXT");
   ObjectDelete(0,day_prefix+"LOW_TEXT");
   ObjectDelete(0,day_prefix+"BULL_BREAK");
   ObjectDelete(0,day_prefix+"BEAR_BREAK");
  }

//+------------------------------------------------------------------+
//| Draws the Asian-session objects for one broker day               |
//+------------------------------------------------------------------+
void BCLDrawSessionObjects(const BCLSessionData &data,
                           const datetime now)
  {
   if(!data.has_range)
     {
      BCLDeleteSessionObjects(data.day_start);
      return;
     }

   const string day_prefix=
      g_object_prefix+
      BCLDayKey(data.day_start)+
      "_";

   const string rectangle_name=day_prefix+"BOX";
   const string high_line_name=day_prefix+"HIGH_LINE";
   const string low_line_name=day_prefix+"LOW_LINE";
   const string high_text_name=day_prefix+"HIGH_TEXT";
   const string low_text_name=day_prefix+"LOW_TEXT";
   const string bull_name=day_prefix+"BULL_BREAK";
   const string bear_name=day_prefix+"BEAR_BREAK";

   if(InpShowSessionBackground)
      BCLDrawSessionRectangle(data,rectangle_name);
   else
      ObjectDelete(0,rectangle_name);

   BCLDrawRangeLine(high_line_name,
                    data.session_start,
                    data.day_end,
                    data.session_high,
                    InpHighLineColor);

   BCLDrawRangeLine(low_line_name,
                    data.session_start,
                    data.day_end,
                    data.session_low,
                    InpLowLineColor);

   if(InpShowPriceLabels)
     {
      datetime label_time=
         data.session_end+
         (InpLabelOffsetMinutes*60);

      if(now<data.session_end)
         label_time=now+60;

      if(label_time>=data.day_end)
         label_time=data.day_end-60;

      BCLDrawPriceLabel(
         high_text_name,
         label_time,
         data.session_high,
         "ASIAN HIGH  "+
         DoubleToString(data.session_high,_Digits),
         InpHighLineColor,
         ANCHOR_LEFT_LOWER);

      BCLDrawPriceLabel(
         low_text_name,
         label_time,
         data.session_low,
         "ASIAN LOW   "+
         DoubleToString(data.session_low,_Digits),
         InpLowLineColor,
         ANCHOR_LEFT_UPPER);
     }
   else
     {
      ObjectDelete(0,high_text_name);
      ObjectDelete(0,low_text_name);
     }

   const double marker_offset=
      MathMax((data.session_high-data.session_low)*0.05,
              10.0*_Point);

   if(InpShowBreakoutMarkers &&
      data.bullish_breakout)
     {
      BCLDrawBreakoutMarker(
         bull_name,
         data.bullish_breakout_time,
         data.session_high+marker_offset,
         true);
     }
   else
      ObjectDelete(0,bull_name);

   if(InpShowBreakoutMarkers &&
      data.bearish_breakout)
     {
      BCLDrawBreakoutMarker(
         bear_name,
         data.bearish_breakout_time,
         data.session_low-marker_offset,
         false);
     }
   else
      ObjectDelete(0,bear_name);
  }

//+------------------------------------------------------------------+
//| Returns the status text color                                    |
//+------------------------------------------------------------------+
color BCLStatusTextColor(const string status)
  {
   if(status=="Bullish breakout")
      return(clrPaleGreen);

   if(status=="Bearish breakout")
      return(clrMistyRose);

   if(status=="Session forming")
      return(C'255,231,132');

   if(status=="Bullish then bearish" ||
      status=="Bearish then bullish" ||
      status=="Both sides broken")
      return(clrMoccasin);

   return(clrWhiteSmoke);
  }

//+------------------------------------------------------------------+
//| Returns the status background color                              |
//+------------------------------------------------------------------+
color BCLStatusBackgroundColor(const string status)
  {
   if(status=="Bullish breakout")
      return(C'35,96,64');

   if(status=="Bearish breakout")
      return(C'112,48,52');

   if(status=="Session forming")
      return(C'108,83,31');

   if(status=="Bullish then bearish" ||
      status=="Bearish then bullish" ||
      status=="Both sides broken")
      return(C'107,72,29');

   return(C'69,74,83');
  }

//+------------------------------------------------------------------+
//| Returns the current chart dimensions                             |
//+------------------------------------------------------------------+
void BCLGetChartDimensions(int &chart_width,
                           int &chart_height)
  {
   chart_width=
      (int)ChartGetInteger(0,
                           CHART_WIDTH_IN_PIXELS,
                           0);

   chart_height=
      (int)ChartGetInteger(0,
                           CHART_HEIGHT_IN_PIXELS,
                           0);

   chart_width=(int)MathMax(1,chart_width);
   chart_height=(int)MathMax(1,chart_height);
  }

//+------------------------------------------------------------------+
//| Limits the dashboard width to the visible chart                  |
//+------------------------------------------------------------------+
int BCLClampDashboardWidth(const int requested_width)
  {
   int chart_width=0;
   int chart_height=0;

   BCLGetChartDimensions(chart_width,
                         chart_height);

   const int available_width=
      (int)MathMax(1,
                   chart_width-8);

   return((int)MathMin(requested_width,
                       available_width));
  }

//+------------------------------------------------------------------+
//| Converts the dashboard corner into a top-left position           |
//+------------------------------------------------------------------+
void BCLDashboardTopLeft(const int panel_width,
                         const int panel_height,
                         int &left,
                         int &top)
  {
   int chart_width=0;
   int chart_height=0;

   BCLGetChartDimensions(chart_width,
                         chart_height);

   left=InpDashboardX;
   top=InpDashboardY;

   if(InpDashboardCorner==CORNER_RIGHT_UPPER ||
      InpDashboardCorner==CORNER_RIGHT_LOWER)
     {
      left=chart_width-
           InpDashboardX-
           panel_width;
     }

   if(InpDashboardCorner==CORNER_LEFT_LOWER ||
      InpDashboardCorner==CORNER_RIGHT_LOWER)
     {
      top=chart_height-
          InpDashboardY-
          panel_height;
     }

   const int maximum_left=
      (int)MathMax(0,
                   chart_width-panel_width);

   const int maximum_top=
      (int)MathMax(0,
                   chart_height-panel_height);

   left=(int)MathMax(0,
                     MathMin(left,
                             maximum_left));

   top=(int)MathMax(0,
                    MathMin(top,
                            maximum_top));
  }

//+------------------------------------------------------------------+
//| Creates or updates a dashboard rectangle                         |
//+------------------------------------------------------------------+
void BCLDrawDashboardRectangle(const string object_name,
                               const int left,
                               const int top,
                               const int width,
                               const int height,
                               const color background_color,
                               const color border_color,
                               const bool show_border,
                               const int z_order)
  {
   if(ObjectFind(0,object_name)<0)
     {
      ResetLastError();

      if(!ObjectCreate(0,
                       object_name,
                       OBJ_RECTANGLE_LABEL,
                       0,
                       0,
                       0))
        {
         PrintFormat("%s: ObjectCreate failed for %s. Error %d",
                     __FUNCTION__,
                     object_name,
                     GetLastError());

         return;
        }
     }

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_CORNER,
                    CORNER_LEFT_UPPER);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_XDISTANCE,
                    left);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_YDISTANCE,
                    top);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_XSIZE,
                    MathMax(1,width));

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_YSIZE,
                    MathMax(1,height));

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_BGCOLOR,
                    background_color);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_BORDER_COLOR,
                    show_border
                    ? border_color
                    : background_color);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_BORDER_TYPE,
                    BORDER_FLAT);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_BACK,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_SELECTABLE,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_SELECTED,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_HIDDEN,
                    true);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_ZORDER,
                    z_order);

   ObjectSetString(0,
                   object_name,
                   OBJPROP_TOOLTIP,
                   "\n");
  }

//+------------------------------------------------------------------+
//| Creates or updates one dashboard label                           |
//+------------------------------------------------------------------+
void BCLDrawDashboardLabel(
   const string object_name,
   const int left,
   const int top,
   const string text,
   const color text_color,
   const int font_size,
   const string font_name,
   const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER)
  {
   if(ObjectFind(0,object_name)<0)
     {
      ResetLastError();

      if(!ObjectCreate(0,
                       object_name,
                       OBJ_LABEL,
                       0,
                       0,
                       0))
        {
         PrintFormat("%s: ObjectCreate failed for %s. Error %d",
                     __FUNCTION__,
                     object_name,
                     GetLastError());

         return;
        }
     }

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_CORNER,
                    CORNER_LEFT_UPPER);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_ANCHOR,
                    anchor);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_XDISTANCE,
                    left);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_YDISTANCE,
                    top);

   ObjectSetString(0,
                   object_name,
                   OBJPROP_TEXT,
                   text);

   ObjectSetString(0,
                   object_name,
                   OBJPROP_FONT,
                   font_name);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_FONTSIZE,
                    font_size);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_COLOR,
                    text_color);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_BACK,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_SELECTABLE,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_SELECTED,
                    false);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_HIDDEN,
                    true);

   ObjectSetInteger(0,
                    object_name,
                    OBJPROP_ZORDER,
                    3);

   ObjectSetString(0,
                   object_name,
                   OBJPROP_TOOLTIP,
                   "\n");
  }

//+------------------------------------------------------------------+
//| Draws the compact current-session dashboard                      |
//+------------------------------------------------------------------+
void BCLDrawDashboard(const BCLSessionData &data)
  {
   const string dashboard_prefix=
      g_object_prefix+
      "DASH_";

   if(!InpShowDashboard)
     {
      ObjectsDeleteAll(0,
                       dashboard_prefix,
                       0,
                       -1);

      return;
     }

   const string high_value=
      data.has_range
      ? DoubleToString(data.session_high,_Digits)
      : "--";

   const string low_value=
      data.has_range
      ? DoubleToString(data.session_low,_Digits)
      : "--";

   const string range_value=
      data.has_range
      ? DoubleToString(BCLRangePoints(data),0)+" pts"
      : "--";

   const string date_value=
      TimeToString(data.day_start,TIME_DATE);

   const string rule_value=
      BCLCompactBreakoutRuleText();

   const int requested_width=
      (int)MathMax(248,
                   InpDashboardMinimumWidth);

   const int panel_width=
      BCLClampDashboardWidth(requested_width);

   const int padding=8;
   const int gap=5;
   const int header_height=32;
   const int accent_height=2;
   const int first_row_height=43;
   const int second_row_height=35;
   const int status_height=26;
   const int footer_height=17;

   const int panel_height=
      header_height+
      accent_height+
      padding+
      first_row_height+
      gap+
      second_row_height+
      gap+
      status_height+
      gap+
      footer_height+
      padding;

   int panel_left=0;
   int panel_top=0;

   BCLDashboardTopLeft(panel_width,
                       panel_height,
                       panel_left,
                       panel_top);

   const int content_left=
      panel_left+
      padding;

   const int content_width=
      panel_width-
      (padding*2);

   const int card_width=
      (content_width-gap)/2;

   const int right_card_left=
      content_left+
      card_width+
      gap;

   const int panel_center=
      panel_left+
      (panel_width/2);

   BCLDrawDashboardRectangle(
      dashboard_prefix+"PANEL",
      panel_left,
      panel_top,
      panel_width,
      panel_height,
      InpDashboardBackgroundColor,
      InpDashboardBorderColor,
      true,
      0);

   BCLDrawDashboardRectangle(
      dashboard_prefix+"HEADER",
      panel_left+1,
      panel_top+1,
      panel_width-2,
      header_height-1,
      InpDashboardHeaderColor,
      InpDashboardHeaderColor,
      false,
      1);

   BCLDrawDashboardRectangle(
      dashboard_prefix+"ACCENT",
      panel_left+1,
      panel_top+header_height,
      panel_width-2,
      accent_height,
      InpHighLineColor,
      InpHighLineColor,
      false,
      2);

   BCLDrawDashboardLabel(
      dashboard_prefix+"TITLE",
      panel_center,
      panel_top+
      (header_height/2),
      "ASIAN SESSION BREAKOUT",
      clrWhite,
      InpDashboardFontSize+2,
      InpDashboardBoldFont,
      ANCHOR_CENTER);

   int row_top=
      panel_top+
      header_height+
      accent_height+
      padding;

// Asian High and Asian Low share the first row.
   BCLDrawDashboardRectangle(
      dashboard_prefix+"HIGH_CARD",
      content_left,
      row_top,
      card_width,
      first_row_height,
      InpDashboardCardColor,
      InpDashboardCardColor,
      false,
      1);

   BCLDrawDashboardRectangle(
      dashboard_prefix+"LOW_CARD",
      right_card_left,
      row_top,
      card_width,
      first_row_height,
      InpDashboardCardColor,
      InpDashboardCardColor,
      false,
      1);

   BCLDrawDashboardLabel(
      dashboard_prefix+"HIGH_LABEL",
      content_left+
      (card_width/2),
      row_top+10,
      "ASIAN HIGH",
      InpDashboardMutedTextColor,
      InpDashboardFontSize,
      InpDashboardFont,
      ANCHOR_CENTER);

   BCLDrawDashboardLabel(
      dashboard_prefix+"HIGH_VALUE",
      content_left+
      (card_width/2),
      row_top+29,
      high_value,
      InpHighLineColor,
      InpDashboardFontSize+3,
      InpDashboardBoldFont,
      ANCHOR_CENTER);

   BCLDrawDashboardLabel(
      dashboard_prefix+"LOW_LABEL",
      right_card_left+
      (card_width/2),
      row_top+10,
      "ASIAN LOW",
      InpDashboardMutedTextColor,
      InpDashboardFontSize,
      InpDashboardFont,
      ANCHOR_CENTER);

   BCLDrawDashboardLabel(
      dashboard_prefix+"LOW_VALUE",
      right_card_left+
      (card_width/2),
      row_top+29,
      low_value,
      InpLowLineColor,
      InpDashboardFontSize+3,
      InpDashboardBoldFont,
      ANCHOR_CENTER);

   row_top+=first_row_height+gap;

// Range and Session share the second row.
   BCLDrawDashboardRectangle(
      dashboard_prefix+"RANGE_CARD",
      content_left,
      row_top,
      card_width,
      second_row_height,
      InpDashboardCardColor,
      InpDashboardCardColor,
      false,
      1);

   BCLDrawDashboardRectangle(
      dashboard_prefix+"SESSION_CARD",
      right_card_left,
      row_top,
      card_width,
      second_row_height,
      InpDashboardCardColor,
      InpDashboardCardColor,
      false,
      1);

   BCLDrawDashboardLabel(
      dashboard_prefix+"RANGE_LABEL",
      content_left+7,
      row_top+
      (second_row_height/2),
      "RANGE",
      InpDashboardMutedTextColor,
      InpDashboardFontSize,
      InpDashboardFont,
      ANCHOR_LEFT);

   BCLDrawDashboardLabel(
      dashboard_prefix+"RANGE_VALUE",
      content_left+
      card_width-7,
      row_top+
      (second_row_height/2),
      range_value,
      InpDashboardTextColor,
      InpDashboardFontSize+1,
      InpDashboardBoldFont,
      ANCHOR_RIGHT);

   BCLDrawDashboardLabel(
      dashboard_prefix+"SESSION_LABEL",
      right_card_left+7,
      row_top+
      (second_row_height/2),
      "SESSION",
      InpDashboardMutedTextColor,
      InpDashboardFontSize,
      InpDashboardFont,
      ANCHOR_LEFT);

   BCLDrawDashboardLabel(
      dashboard_prefix+"SESSION_VALUE",
      right_card_left+
      card_width-7,
      row_top+
      (second_row_height/2),
      BCLSessionTimeText(),
      InpDashboardTextColor,
      InpDashboardFontSize,
      InpDashboardBoldFont,
      ANCHOR_RIGHT);

   row_top+=second_row_height+gap;

   const color status_background=
      BCLStatusBackgroundColor(data.status);

   BCLDrawDashboardRectangle(
      dashboard_prefix+"STATUS_BACKGROUND",
      content_left,
      row_top,
      content_width,
      status_height,
      status_background,
      status_background,
      false,
      2);

   BCLDrawDashboardLabel(
      dashboard_prefix+"STATUS_LABEL",
      panel_center,
      row_top+
      (status_height/2),
      BCLUpperText(data.status),
      BCLStatusTextColor(data.status),
      InpDashboardFontSize+1,
      InpDashboardBoldFont,
      ANCHOR_CENTER);

   row_top+=status_height+gap;

   BCLDrawDashboardLabel(
      dashboard_prefix+"DATE",
      content_left,
      row_top+
      (footer_height/2),
      date_value,
      InpDashboardMutedTextColor,
      InpDashboardFontSize,
      InpDashboardFont,
      ANCHOR_LEFT);

   BCLDrawDashboardLabel(
      dashboard_prefix+"RULE",
      content_left+
      content_width,
      row_top+
      (footer_height/2),
      rule_value,
      InpDashboardMutedTextColor,
      InpDashboardFontSize,
      InpDashboardFont,
      ANCHOR_RIGHT);
  }

//+------------------------------------------------------------------+
//| Refreshes all configured historical sessions                     |
//+------------------------------------------------------------------+
void BCLRefreshAllSessions(const datetime now,
                           const bool delete_existing)
  {
   if(delete_existing)
      ObjectsDeleteAll(0,
                       g_object_prefix,
                       0,
                       -1);

   const datetime today_start=
      BCLStartOfDay(now);

// Draw sessions from the oldest configured date to today.
   for(int day_offset=InpHistoryDays-1;
       day_offset>=0;
       day_offset--)
     {
      const datetime candidate_time=
         today_start-
         (day_offset*86400);

      const datetime day_start=
         BCLStartOfDay(candidate_time);

      const datetime effective_now=
         day_offset==0
         ? now
         : day_start+86400;

      BCLDrawDaySeparator(day_start);

      BCLSessionData session_data;

      BCLBuildSessionData(day_start,
                          effective_now,
                          session_data);

      if(session_data.has_range)
         BCLDrawSessionObjects(session_data,
                               effective_now);
      else
         BCLDeleteSessionObjects(day_start);

      if(day_offset==0)
         g_current_session=session_data;
     }

   g_current_day_start=today_start;
   g_last_history_update=now;

   BCLDrawDashboard(g_current_session);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Refreshes the current broker-day session                         |
//+------------------------------------------------------------------+
void BCLRefreshCurrentSession(const datetime now)
  {
   const datetime today_start=
      BCLStartOfDay(now);

   if(today_start!=g_current_day_start)
     {
      BCLRefreshAllSessions(now,true);
      return;
     }

   BCLDrawDaySeparator(today_start);

   BCLSessionData session_data;

   BCLBuildSessionData(today_start,
                       now,
                       session_data);

   if(session_data.has_range)
      BCLDrawSessionObjects(session_data,
                            now);
   else
      BCLDeleteSessionObjects(today_start);

   g_current_session=session_data;

   BCLDrawDashboard(g_current_session);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Validates indicator input parameters                             |
//+------------------------------------------------------------------+
bool BCLValidateInputs()
  {
   if(InpSessionStartHour<0 ||
      InpSessionStartHour>23 ||
      InpSessionEndHour<0 ||
      InpSessionEndHour>23 ||
      InpSessionStartMinute<0 ||
      InpSessionStartMinute>59 ||
      InpSessionEndMinute<0 ||
      InpSessionEndMinute>59)
     {
      Print("Session hours must be 0-23 and minutes must be 0-59.");
      return(false);
     }

   const int start_minutes=
      (InpSessionStartHour*60)+
      InpSessionStartMinute;

   const int end_minutes=
      (InpSessionEndHour*60)+
      InpSessionEndMinute;

   if(end_minutes<=start_minutes)
     {
      Print("The session end must be later than the session start within the same broker day.");
      return(false);
     }

   if(InpHistoryDays<1 ||
      InpHistoryDays>365)
     {
      Print("History Days must be between 1 and 365.");
      return(false);
     }

   if(InpRefreshSeconds<1 ||
      InpRefreshSeconds>60)
     {
      Print("Refresh Seconds must be between 1 and 60.");
      return(false);
     }

   if(InpSessionOpacityPercent<0 ||
      InpSessionOpacityPercent>100)
     {
      Print("Session Opacity Percent must be between 0 and 100.");
      return(false);
     }

   if(InpLineWidth<1 ||
      InpLineWidth>5 ||
      InpMarkerSize<1 ||
      InpMarkerSize>5 ||
      InpDaySeparatorWidth<1 ||
      InpDaySeparatorWidth>5)
     {
      Print("Line widths and marker size must be between 1 and 5.");
      return(false);
     }

   if(InpLabelFontSize<6 ||
      InpDashboardFontSize<6)
     {
      Print("Label and dashboard font sizes must be at least 6.");
      return(false);
     }

   return(true);
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!BCLValidateInputs())
      return(INIT_PARAMETERS_INCORRECT);

   g_object_prefix=
      StringFormat("BCL_ASB_%I64d_%u_",
                   ChartID(),
                   GetTickCount());

   IndicatorSetString(
      INDICATOR_SHORTNAME,
      "Asian Session Range Breakout - BhanuCodeLab");

   EventSetTimer(InpRefreshSeconds);

   BCLRefreshAllSessions(TimeCurrent(),
                         true);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();

   ObjectsDeleteAll(0,
                    g_object_prefix,
                    0,
                    -1);

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
   const int rates_total,
   const int prev_calculated,
   const datetime &time[],
   const double &open[],
   const double &high[],
   const double &low[],
   const double &close[],
   const long &tick_volume[],
   const long &volume[],
   const int &spread[])
  {
   const uint current_tick=
      GetTickCount();

// Limit object refreshes during fast tick streams.
   if(current_tick-g_last_refresh_tick>=250)
     {
      g_last_refresh_tick=current_tick;

      BCLRefreshCurrentSession(TimeCurrent());
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Timer event handler                                              |
//+------------------------------------------------------------------+
void OnTimer()
  {
   const datetime now=
      TimeCurrent();

// Periodically rebuild all sessions and refresh blended colors.
   if(now-g_last_history_update>=60)
      BCLRefreshAllSessions(now,false);
   else
      BCLRefreshCurrentSession(now);
  }

//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(
   const int id,
   const long &lparam,
   const double &dparam,
   const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      // Rebuild session colors when the chart theme changes.
      BCLRefreshAllSessions(TimeCurrent(),false);
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
