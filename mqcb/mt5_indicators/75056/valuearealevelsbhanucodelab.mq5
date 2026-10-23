//+------------------------------------------------------------------+
//|                 ValueAreaLevelsBhanuCodeLab.mq5                  |
//|       Session Value Area High, Point of Control, and Low         |
//|                         Copyright BhanuCodeLab                   |
//+------------------------------------------------------------------+
#property copyright "BhanuCodeLab"
#property version   "1.0"
#property description "Draws developing, previous, and historical value area levels: VAH, POC, and VAL."
#property strict

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

#property indicator_label1  "VAH"
#property indicator_type1   DRAW_NONE
#property indicator_label2  "POC"
#property indicator_type2   DRAW_NONE
#property indicator_label3  "VAL"
#property indicator_type3   DRAW_NONE

enum ENUM_BCL_VOLUME_SOURCE
  {
   BCL_VOLUME_TICK = 0,   // Tick volume
   BCL_VOLUME_REAL = 1    // Real volume, fallback to tick volume if zero
  };

enum ENUM_BCL_LABEL_OFFSET_UNIT
  {
   BCL_LABEL_OFFSET_POINTS      = 0,  // Points
   BCL_LABEL_OFFSET_TICKS       = 1,  // Trade ticks
   BCL_LABEL_OFFSET_PRICE_STEPS = 2   // Profile price steps
  };

//--- User inputs
input string                    InpObjectPrefix                         = "ValueArea";       // Unique chart object prefix
input ENUM_TIMEFRAMES           InpProfilePeriod                       = PERIOD_D1;         // Timeframe used to split profiles
input int                       InpProfilesToDraw                      = 20;                // Number of recent profiles to calculate
input ENUM_BCL_VOLUME_SOURCE    InpVolumeMode                          = BCL_VOLUME_TICK;    // Volume type used in profile calculation
input int                       InpPriceStepPoints                     = 1;                 // Profile row size in symbol points
input double                    InpValueAreaPercent                    = 70.0;              // Value area percentage
input bool                      InpFreezeCompleted                     = true;              // Keep completed profile levels unchanged
input int                       InpUpdateSeconds                       = 5;                 // Minimum seconds between live updates
input bool                      InpShowDevelopingValueArea             = true;              // Show current developing VA levels
input bool                      InpShowPreviousValueArea               = true;              // Show previous completed profile VA levels
input bool                      InpShowHistoricalValueAreas            = true;              // Show older completed profile VA levels
input bool                      InpShowHistoricalPreviousValueAreas    = true;              // Show older sessions' previous VA levels
input int                       InpPreviousLabelShiftBars              = 8;                 // Previous-day label shift bars
input int                       InpHistoricalLabelShiftBars            = 1;                 // Historical label shift bars
input int                       InpHistoricalPreviousLabelShiftBars    = 8;                 // Historical previous label shift bars

input color                     InpValueAreaLineColor                  = clrGold;           // VAH and VAL line color
input color                     InpPointOfControlLineColor             = clrAqua;            // POC line color
input int                       InpLineWidth                           = 1;                 // Level line width
input ENUM_LINE_STYLE           InpLineStyle                           = STYLE_SOLID;       // Level line style

input bool                      InpShowSessionBreakLine                = true;              // Show session break vertical line
input color                     InpSessionBreakColor                   = clrDimGray;        // Session break line color
input ENUM_LINE_STYLE           InpSessionBreakStyle                   = STYLE_DOT;         // Session break line style
input int                       InpSessionBreakWidth                   = 1;                 // Session break line width

input bool                      InpShowTextLabels                      = true;              // Show VAH/POC/VAL text labels
input bool                      InpShowPriceInLabel                    = true;              // Show price in label
input int                       InpLabelFontSize                       = 8;                 // Label font size
input int                       InpLabelShiftBars                      = 1;                 // Label shift from period start
input ENUM_BCL_LABEL_OFFSET_UNIT InpLabelOffsetUnit                    = BCL_LABEL_OFFSET_TICKS; // Label offset unit
input int                       InpLabelOffsetValue                    = 25;                // Label offset above line
input int                       InpLabelMinGapTicks                    = 20;                // Minimum gap between stacked labels

input bool                      InpShowDashboard                       = true;              // Show dashboard panel
input ENUM_BASE_CORNER          InpDashboardCorner                    = CORNER_LEFT_UPPER; // Dashboard corner
input int                       InpDashboardX                         = 10;                // Dashboard X distance
input int                       InpDashboardY                         = 25;                // Dashboard Y distance
input int                       InpDashboardWidth                     = 310;               // Dashboard width
input int                       InpDashboardFontSize                  = 8;                 // Dashboard font size
input color                     InpDashboardBgColor                   = C'18,18,18';       // Dashboard background
input color                     InpDashboardBorderColor               = clrDimGray;        // Dashboard border
input color                     InpDashboardTextColor                 = clrWhite;          // Dashboard text
input color                     InpDashboardHeaderColor               = clrGold;           // Dashboard header text

//--- Indicator buffers
double g_value_area_high_buffer[];
double g_point_of_control_buffer[];
double g_value_area_low_buffer[];

//--- Runtime state
string   g_prefix = "";
datetime g_current_profile_start = 0;
datetime g_last_update_time = 0;
datetime g_last_tester_chart_bar_time = 0;
bool     g_force_full_redraw = true;
bool     g_refresh_historical = true;
bool     g_is_tester = false;
bool     g_is_visual_tester = false;

double   g_current_vah = EMPTY_VALUE;
double   g_current_poc = EMPTY_VALUE;
double   g_current_val = EMPTY_VALUE;
datetime g_current_start_for_dashboard = 0;
bool     g_has_current_values = false;

double   g_previous_vah = EMPTY_VALUE;
double   g_previous_poc = EMPTY_VALUE;
double   g_previous_val = EMPTY_VALUE;
datetime g_previous_start_for_dashboard = 0;
bool     g_has_previous_values = false;

//+------------------------------------------------------------------+
//| Returns true when chart objects should be created or updated.    |
//+------------------------------------------------------------------+
bool AllowChartObjects()
  {
   return (!g_is_tester || g_is_visual_tester);
  }

//+------------------------------------------------------------------+
//| Checks whether chart bars are detailed enough for the profile.   |
//+------------------------------------------------------------------+
bool IsProfilePeriodCompatible()
  {
   ENUM_TIMEFRAMES profile_period = InpProfilePeriod;

   if(profile_period == PERIOD_CURRENT)
      profile_period = (ENUM_TIMEFRAMES)_Period;

   int source_seconds = PeriodSeconds((ENUM_TIMEFRAMES)_Period);
   int profile_seconds = PeriodSeconds(profile_period);

   if(source_seconds <= 0 || profile_seconds <= 0)
      return true;

   return (source_seconds <= profile_seconds);
  }

//+------------------------------------------------------------------+
//| Aligns a chart-bar time to the beginning of its profile period.  |
//+------------------------------------------------------------------+
datetime GetProfileStart(datetime bar_time)
  {
   ENUM_TIMEFRAMES profile_period = InpProfilePeriod;

   if(profile_period == PERIOD_CURRENT)
      profile_period = (ENUM_TIMEFRAMES)_Period;

   MqlDateTime parts;

   if(!TimeToStruct(bar_time, parts))
      return 0;

   if(profile_period == PERIOD_MN1)
     {
      parts.day = 1;
      parts.hour = 0;
      parts.min = 0;
      parts.sec = 0;
      return StructToTime(parts);
     }

   parts.hour = 0;
   parts.min = 0;
   parts.sec = 0;
   datetime day_start = StructToTime(parts);

   if(profile_period == PERIOD_W1)
     {
      int days_from_monday = (parts.day_of_week == 0) ? 6 : parts.day_of_week - 1;
      return day_start - (datetime)(days_from_monday * 86400);
     }

   int profile_seconds = PeriodSeconds(profile_period);

   if(profile_seconds <= 0)
      profile_seconds = PeriodSeconds((ENUM_TIMEFRAMES)_Period);

   if(profile_seconds <= 0)
      profile_seconds = 60;

   if(profile_seconds >= 86400)
      return day_start;

   MqlDateTime original_parts;

   if(!TimeToStruct(bar_time, original_parts))
      return day_start;

   int seconds_from_midnight = original_parts.hour * 3600 +
                               original_parts.min * 60 +
                               original_parts.sec;
   int bucket_start = (seconds_from_midnight / profile_seconds) * profile_seconds;

   return day_start + (datetime)bucket_start;
  }

//+------------------------------------------------------------------+
//| Collects recent profile starts directly from current-chart bars. |
//+------------------------------------------------------------------+
int BuildProfileStarts(const datetime &time[],
                       int rates_total,
                       int requested_count,
                       datetime &profile_starts[])
  {
   ArrayResize(profile_starts, 0);

   if(rates_total <= 0 || requested_count <= 0)
      return 0;

   datetime last_start = 0;
   int count = 0;

   for(int bar = 0; bar < rates_total && count < requested_count; bar++)
     {
      if(IsStopped())
         break;

      datetime profile_start = GetProfileStart(time[bar]);

      if(profile_start <= 0)
         continue;

      if(count == 0 || profile_start != last_start)
        {
         ArrayResize(profile_starts, count + 1);
         profile_starts[count] = profile_start;
         last_start = profile_start;
         count++;
        }
     }

   return count;
  }

//+------------------------------------------------------------------+
//| Returns timeframe length in seconds with a safe fallback.        |
//+------------------------------------------------------------------+
int GetSafePeriodSeconds(ENUM_TIMEFRAMES tf)
  {
   int sec = PeriodSeconds(tf);

   if(sec <= 0)
      sec = PeriodSeconds(_Period);

   if(sec <= 0)
      sec = 60;

   return sec;
  }

//+------------------------------------------------------------------+
//| Converts a timeframe value into a short readable label.          |
//+------------------------------------------------------------------+
string TimeframeToString(ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_CURRENT: return "CURRENT";
      case PERIOD_M1:      return "M1";
      case PERIOD_M2:      return "M2";
      case PERIOD_M3:      return "M3";
      case PERIOD_M4:      return "M4";
      case PERIOD_M5:      return "M5";
      case PERIOD_M6:      return "M6";
      case PERIOD_M10:     return "M10";
      case PERIOD_M12:     return "M12";
      case PERIOD_M15:     return "M15";
      case PERIOD_M20:     return "M20";
      case PERIOD_M30:     return "M30";
      case PERIOD_H1:      return "H1";
      case PERIOD_H2:      return "H2";
      case PERIOD_H3:      return "H3";
      case PERIOD_H4:      return "H4";
      case PERIOD_H6:      return "H6";
      case PERIOD_H8:      return "H8";
      case PERIOD_H12:     return "H12";
      case PERIOD_D1:      return "D1";
      case PERIOD_W1:      return "W1";
      case PERIOD_MN1:     return "MN1";
      default:             return "TF";
     }
  }

//+------------------------------------------------------------------+
//| Returns the configured profile row size as a price value.        |
//+------------------------------------------------------------------+
double GetProfilePriceStep()
  {
   int points_count = MathMax(1, InpPriceStepPoints);
   return _Point * points_count;
  }

//+------------------------------------------------------------------+
//| Returns a safe trade tick size for the current symbol.           |
//+------------------------------------------------------------------+
double GetSymbolTickSize()
  {
   double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   if(tick_size <= 0.0)
      tick_size = _Point;

   if(tick_size <= 0.0)
      tick_size = 0.00001;

   return tick_size;
  }

//+------------------------------------------------------------------+
//| Converts the label offset input into a price distance.           |
//+------------------------------------------------------------------+
double GetLabelOffsetPrice()
  {
   int value = MathMax(1, InpLabelOffsetValue);

   if(InpLabelOffsetUnit == BCL_LABEL_OFFSET_TICKS)
      return value * GetSymbolTickSize();

   if(InpLabelOffsetUnit == BCL_LABEL_OFFSET_PRICE_STEPS)
      return value * GetProfilePriceStep();

   return value * _Point;
  }

//+------------------------------------------------------------------+
//| Converts the minimum label gap input into a price distance.      |
//+------------------------------------------------------------------+
double GetLabelMinGapPrice()
  {
   int ticks = MathMax(1, InpLabelMinGapTicks);
   return ticks * GetSymbolTickSize();
  }

//+------------------------------------------------------------------+
//| Normalizes a price using the current symbol digits.              |
//+------------------------------------------------------------------+
double NormalizeSymbolPrice(double price)
  {
   return NormalizeDouble(price, _Digits);
  }

//+------------------------------------------------------------------+
//| Rounds a price down to the nearest profile row step.             |
//+------------------------------------------------------------------+
double RoundPriceDownToStep(double price, double step)
  {
   if(step <= 0.0)
      return price;

   return MathFloor(price / step) * step;
  }

//+------------------------------------------------------------------+
//| Rounds a price up to the nearest profile row step.               |
//+------------------------------------------------------------------+
double RoundPriceUpToStep(double price, double step)
  {
   if(step <= 0.0)
      return price;

   return MathCeil(price / step) * step;
  }

//+------------------------------------------------------------------+
//| Maps a price to the lower profile row index.                     |
//+------------------------------------------------------------------+
int GetFloorPriceIndex(double price, double low_price, double step)
  {
   if(step <= 0.0)
      return 0;

   return (int)MathFloor((price - low_price) / step + 0.000000001);
  }

//+------------------------------------------------------------------+
//| Maps a price to the upper profile row index.                     |
//+------------------------------------------------------------------+
int GetCeilPriceIndex(double price, double low_price, double step)
  {
   if(step <= 0.0)
      return 0;

   return (int)MathCeil((price - low_price) / step - 0.000000001);
  }

//+------------------------------------------------------------------+
//| Converts a profile row index back into a symbol price.           |
//+------------------------------------------------------------------+
double GetPriceFromIndex(int index, double low_price, double step)
  {
   return NormalizeDouble(low_price + index * step, _Digits);
  }

//+------------------------------------------------------------------+
//| Calculates the total volume stored in a profile array.           |
//+------------------------------------------------------------------+
double GetArraySum(const double &values[])
  {
   double total = 0.0;
   int size = ArraySize(values);

   for(int i = 0; i < size; i++)
      total += values[i];

   return total;
  }

//+------------------------------------------------------------------+
//| Finds the POC row and resolves equal-volume ties near center.    |
//+------------------------------------------------------------------+
int FindPointOfControlIndex(const double &profile[])
  {
   int size = ArraySize(profile);

   if(size <= 0)
      return -1;

   double max_value = profile[0];

   for(int i = 1; i < size; i++)
     {
      if(profile[i] > max_value)
         max_value = profile[i];
     }

   double center = (size - 1) / 2.0;
   int best_index = -1;
   double best_distance = DBL_MAX;

   for(int i = 0; i < size; i++)
     {
      if(MathAbs(profile[i] - max_value) <= 0.0000001)
        {
         double distance = MathAbs(i - center);

         if(distance < best_distance)
           {
            best_distance = distance;
            best_index = i;
           }
        }
     }

   return best_index;
  }

//+------------------------------------------------------------------+
//| Expands from POC until the configured value area is covered.     |
//+------------------------------------------------------------------+
void CalculateValueArea(const double &profile[],
                        int poc_index,
                        double value_area_percent,
                        int &val_index,
                        int &vah_index)
  {
   int size = ArraySize(profile);
   val_index = -1;
   vah_index = -1;

   if(size <= 0 || poc_index < 0 || poc_index >= size)
      return;

   double total = GetArraySum(profile);

   if(total <= 0.0)
     {
      val_index = poc_index;
      vah_index = poc_index;
      return;
     }

   double percent = MathMax(1.0, MathMin(value_area_percent, 100.0));
   double target = total * percent / 100.0;

   int low_index = poc_index;
   int high_index = poc_index;
   double included = profile[poc_index];

   while(included < target && (low_index > 0 || high_index < size - 1))
     {
      double below = (low_index > 0) ? profile[low_index - 1] : -1.0;
      double above = (high_index < size - 1) ? profile[high_index + 1] : -1.0;

      if(above > below)
        {
         high_index++;
         included += profile[high_index];
        }
      else if(below > above)
        {
         low_index--;
         included += profile[low_index];
        }
      else
        {
         if(low_index > 0)
           {
            low_index--;
            included += profile[low_index];
           }

         if(included >= target)
            break;

         if(high_index < size - 1)
           {
            high_index++;
            included += profile[high_index];
           }
        }
     }

   val_index = low_index;
   vah_index = high_index;
  }

//+------------------------------------------------------------------+
//| Makes a chart object non-selectable and hidden from object list. |
//+------------------------------------------------------------------+
void DisableObject(const string name)
  {
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| Deletes chart objects whose names begin with the supplied prefix.|
//+------------------------------------------------------------------+
void DeleteObjectsByPrefix(const string prefix)
  {
   if(!AllowChartObjects())
      return;

   int total = ObjectsTotal(0, -1, -1);

   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, -1, -1);

      if(StringFind(name, prefix) == 0)
         ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
//| Draws a vertical separator at the beginning of a profile.        |
//+------------------------------------------------------------------+
void DrawSeparator(const string profile_prefix, datetime separator_time)
  {
   if(!AllowChartObjects() || !InpShowSessionBreakLine)
      return;

   string name = profile_prefix + "SEP";
   ObjectDelete(0, name);

   if(!ObjectCreate(0, name, OBJ_VLINE, 0, separator_time, 0.0))
      return;

   ObjectSetInteger(0, name, OBJPROP_COLOR, InpSessionBreakColor);
   ObjectSetInteger(0, name, OBJPROP_STYLE, InpSessionBreakStyle);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, InpSessionBreakWidth);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);

   DisableObject(name);
  }

//+------------------------------------------------------------------+
//| Draws one horizontal VAH, POC, or VAL segment.                   |
//+------------------------------------------------------------------+
void DrawLevelLine(const string profile_prefix,
                   const string tag,
                   datetime from_time,
                   datetime to_time,
                   double price,
                   color line_color)
  {
   if(!AllowChartObjects())
      return;

   if(to_time <= from_time)
      to_time = from_time + GetSafePeriodSeconds(_Period);

   string name = profile_prefix + tag + "_LINE";
   ObjectDelete(0, name);

   if(!ObjectCreate(0, name, OBJ_TREND, 0, from_time, price, to_time, price))
      return;

   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, false);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_COLOR, line_color);
   ObjectSetInteger(0, name, OBJPROP_STYLE, InpLineStyle);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, InpLineWidth);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);

   DisableObject(name);
  }

//+------------------------------------------------------------------+
//| Calculates label time from a chart-bar shift.                    |
//+------------------------------------------------------------------+
datetime LabelTime(datetime base_time, int shift_bars)
  {
   return base_time + MathMax(0, shift_bars) * GetSafePeriodSeconds(_Period);
  }

//+------------------------------------------------------------------+
//| Builds level label text.                                         |
//+------------------------------------------------------------------+
string BuildLabelText(const string display_tag, double price)
  {
   if(InpShowPriceInLabel)
      return display_tag + " " + DoubleToString(price, _Digits);

   return display_tag;
  }

//+------------------------------------------------------------------+
//| Draws one text label for a profile level.                        |
//+------------------------------------------------------------------+
void DrawLevelLabel(const string profile_prefix,
                    const string object_tag,
                    const string display_tag,
                    datetime label_time,
                    double line_price,
                    double label_price,
                    color label_color)
  {
   if(!AllowChartObjects() || !InpShowTextLabels)
      return;

   string name = profile_prefix + object_tag + "_LABEL";
   ObjectDelete(0, name);

   if(!ObjectCreate(0, name, OBJ_TEXT, 0, label_time, NormalizeSymbolPrice(label_price)))
      return;

   ObjectSetString(0, name, OBJPROP_TEXT, BuildLabelText(display_tag, line_price));
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpLabelFontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, label_color);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);

   DisableObject(name);
  }

//+------------------------------------------------------------------+
//| Draws separator, level lines, and labels for one profile.        |
//+------------------------------------------------------------------+
void DrawSessionLevels(const string profile_prefix,
                       const string display_prefix,
                       datetime separator_time,
                       datetime line_start_time,
                       datetime line_end_time,
                       double vah,
                       double poc,
                       double val,
                       int label_shift_bars)
  {
   if(!AllowChartObjects())
      return;

   if(separator_time > 0)
      DrawSeparator(profile_prefix, separator_time);

   DrawLevelLine(profile_prefix, "VAH", line_start_time, line_end_time, vah, InpValueAreaLineColor);
   DrawLevelLine(profile_prefix, "POC", line_start_time, line_end_time, poc, InpPointOfControlLineColor);
   DrawLevelLine(profile_prefix, "VAL", line_start_time, line_end_time, val, InpValueAreaLineColor);

   datetime label_time = LabelTime(line_start_time, label_shift_bars);
   double offset = GetLabelOffsetPrice();
   double minimum_gap = MathMax(GetLabelMinGapPrice(), offset);

   double val_label = val + offset;
   double poc_label = poc + offset;
   double vah_label = vah + offset;

   if(poc_label < val_label + minimum_gap)
      poc_label = val_label + minimum_gap;

   if(vah_label < poc_label + minimum_gap)
      vah_label = poc_label + minimum_gap;

   DrawLevelLabel(profile_prefix, "VAH", display_prefix + "VAH", label_time, vah, vah_label, InpValueAreaLineColor);
   DrawLevelLabel(profile_prefix, "POC", display_prefix + "POC", label_time, poc, poc_label, InpPointOfControlLineColor);
   DrawLevelLabel(profile_prefix, "VAL", display_prefix + "VAL", label_time, val, val_label, InpValueAreaLineColor);
  }

//+------------------------------------------------------------------+
//| Formats a dashboard price or a placeholder.                      |
//+------------------------------------------------------------------+
string FormatDashboardPrice(double price, bool valid)
  {
   if(!valid || price == EMPTY_VALUE)
      return "--";

   return DoubleToString(price, _Digits);
  }

//+------------------------------------------------------------------+
//| Formats a dashboard timestamp or a placeholder.                  |
//+------------------------------------------------------------------+
string FormatDashboardTime(datetime time_value)
  {
   if(time_value <= 0)
      return "--";

   return TimeToString(time_value, TIME_DATE | TIME_MINUTES);
  }

//+------------------------------------------------------------------+
//| Formats value-area width in price units and points.              |
//+------------------------------------------------------------------+
string FormatDashboardWidth(double vah, double val, bool valid)
  {
   if(!valid || vah == EMPTY_VALUE || val == EMPTY_VALUE)
      return "--";

   double width_price = MathAbs(vah - val);
   double width_points = (_Point > 0.0) ? width_price / _Point : 0.0;

   return DoubleToString(width_price, _Digits) + " / " + DoubleToString(width_points, 0) + " pts";
  }

//+------------------------------------------------------------------+
//| Pads a string with spaces for dashboard alignment.               |
//+------------------------------------------------------------------+
string PadRight(string text, int total_length)
  {
   while(StringLen(text) < total_length)
      text += " ";

   return text;
  }

//+------------------------------------------------------------------+
//| Builds one aligned dashboard row.                               |
//+------------------------------------------------------------------+
string DashboardLine(string label, string value)
  {
   return PadRight(label, 9) + " : " + value;
  }

//+------------------------------------------------------------------+
//| Calculates dashboard top-left coordinates.                      |
//+------------------------------------------------------------------+
void GetDashboardBaseXY(int width, int height, int &base_x, int &base_y)
  {
   int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);

   int margin_x = MathMax(0, InpDashboardX);
   int margin_y = MathMax(0, InpDashboardY);

   bool use_right = (InpDashboardCorner == CORNER_RIGHT_UPPER || InpDashboardCorner == CORNER_RIGHT_LOWER);
   bool use_lower = (InpDashboardCorner == CORNER_LEFT_LOWER || InpDashboardCorner == CORNER_RIGHT_LOWER);

   base_x = use_right ? chart_width - width - margin_x : margin_x;
   base_y = use_lower ? chart_height - height - margin_y : margin_y;

   if(base_x < 0)
      base_x = 0;

   if(base_y < 0)
      base_y = 0;

   if(chart_width > width && base_x + width > chart_width)
      base_x = chart_width - width;

   if(chart_height > height && base_y + height > chart_height)
      base_y = chart_height - height;
  }

//+------------------------------------------------------------------+
//| Draws the dashboard background rectangle.                       |
//+------------------------------------------------------------------+
void DrawDashboardBox(const string name,
                      int width,
                      int height,
                      int base_x,
                      int base_y)
  {
   if(!AllowChartObjects())
      return;

   ObjectDelete(0, name);

   if(!ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
      return;

   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, base_x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, base_y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, InpDashboardBgColor);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpDashboardBorderColor);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);

   DisableObject(name);
  }

//+------------------------------------------------------------------+
//| Draws one text row inside the dashboard.                         |
//+------------------------------------------------------------------+
void DrawDashboardLabel(const string name,
                        int row,
                        const string text,
                        color text_color,
                        int base_x,
                        int base_y,
                        bool bold = false)
  {
   if(!AllowChartObjects())
      return;

   ObjectDelete(0, name);

   if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
      return;

   int row_height = MathMax(14, InpDashboardFontSize + 6);
   int x = base_x + 10;
   int y = base_y + 8 + row * row_height;

   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, bold ? "Arial" : "Consolas");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpDashboardFontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, text_color);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);

   DisableObject(name);
  }

//+------------------------------------------------------------------+
//| Refreshes the dashboard values.                                  |
//+------------------------------------------------------------------+
void DrawDashboard()
  {
   if(!AllowChartObjects())
      return;

   string dashboard_prefix = g_prefix + "DASH_";
   DeleteObjectsByPrefix(dashboard_prefix);

   if(!InpShowDashboard)
      return;

   int row_height = MathMax(14, InpDashboardFontSize + 6);
   int rows = 20;
   int height = 16 + rows * row_height;
   int width = MathMax(290, InpDashboardWidth);

   int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);

   if(chart_width > 50 && width > chart_width - 10)
      width = chart_width - 10;

   if(chart_height > 50 && height > chart_height - 10)
      height = chart_height - 10;

   int base_x = 0;
   int base_y = 0;
   GetDashboardBaseXY(width, height, base_x, base_y);

   DrawDashboardBox(dashboard_prefix + "BOX", width, height, base_x, base_y);

   int row = 0;

   DrawDashboardLabel(dashboard_prefix + "TITLE", row++, "VALUE AREA | BhanuCodeLab", InpDashboardHeaderColor, base_x, base_y, true);
   DrawDashboardLabel(dashboard_prefix + "SYMBOL", row++, _Symbol + "  |  Profile " + TimeframeToString(InpProfilePeriod) + "  |  Source " + TimeframeToString((ENUM_TIMEFRAMES)_Period), InpDashboardTextColor, base_x, base_y);
   row++;

   DrawDashboardLabel(dashboard_prefix + "CUR_HEAD", row++, "Developing profile", InpDashboardHeaderColor, base_x, base_y, true);
   DrawDashboardLabel(dashboard_prefix + "CUR_TIME", row++, DashboardLine("Start", FormatDashboardTime(g_current_start_for_dashboard)), InpDashboardTextColor, base_x, base_y);
   row++;
   DrawDashboardLabel(dashboard_prefix + "CUR_VAH", row++, DashboardLine("DVAH", FormatDashboardPrice(g_current_vah, g_has_current_values)), InpValueAreaLineColor, base_x, base_y);
   DrawDashboardLabel(dashboard_prefix + "CUR_POC", row++, DashboardLine("DPOC", FormatDashboardPrice(g_current_poc, g_has_current_values)), InpPointOfControlLineColor, base_x, base_y);
   DrawDashboardLabel(dashboard_prefix + "CUR_VAL", row++, DashboardLine("DVAL", FormatDashboardPrice(g_current_val, g_has_current_values)), InpValueAreaLineColor, base_x, base_y);
   DrawDashboardLabel(dashboard_prefix + "CUR_WIDTH", row++, DashboardLine("DVA Width", FormatDashboardWidth(g_current_vah, g_current_val, g_has_current_values)), InpDashboardTextColor, base_x, base_y);
   row++;

   DrawDashboardLabel(dashboard_prefix + "PREV_HEAD", row++, "Previous profile", InpDashboardHeaderColor, base_x, base_y, true);
   DrawDashboardLabel(dashboard_prefix + "PREV_TIME", row++, DashboardLine("Start", FormatDashboardTime(g_previous_start_for_dashboard)), InpDashboardTextColor, base_x, base_y);
   row++;
   DrawDashboardLabel(dashboard_prefix + "PREV_VAH", row++, DashboardLine("PDVAH", FormatDashboardPrice(g_previous_vah, g_has_previous_values)), InpValueAreaLineColor, base_x, base_y);
   DrawDashboardLabel(dashboard_prefix + "PREV_POC", row++, DashboardLine("PDPOC", FormatDashboardPrice(g_previous_poc, g_has_previous_values)), InpPointOfControlLineColor, base_x, base_y);
   DrawDashboardLabel(dashboard_prefix + "PREV_VAL", row++, DashboardLine("PDVAL", FormatDashboardPrice(g_previous_val, g_has_previous_values)), InpValueAreaLineColor, base_x, base_y);
   DrawDashboardLabel(dashboard_prefix + "PREV_WIDTH", row++, DashboardLine("PDVA Width", FormatDashboardWidth(g_previous_vah, g_previous_val, g_has_previous_values)), InpDashboardTextColor, base_x, base_y);
   row++;

   DrawDashboardLabel(dashboard_prefix + "UPDATED", row++, DashboardLine("Updated", TimeToString(TimeCurrent(), TIME_SECONDS)), InpDashboardTextColor, base_x, base_y);
  }

//+------------------------------------------------------------------+
//| Resolves current-chart array indexes for a time interval.       |
//+------------------------------------------------------------------+
bool GetChartArrayRange(const datetime &time[],
                        int rates_total,
                        datetime from_time,
                        datetime to_time,
                        int &first_index,
                        int &last_index)
  {
   first_index = -1;
   last_index = -1;

   if(rates_total <= 0 || to_time < from_time)
      return false;

   int newest = iBarShift(_Symbol, (ENUM_TIMEFRAMES)_Period, to_time, false);
   int oldest = iBarShift(_Symbol, (ENUM_TIMEFRAMES)_Period, from_time, false);

   if(newest < 0)
      newest = 0;

   if(oldest < 0)
      oldest = rates_total - 1;

   first_index = MathMax(0, MathMin(newest, oldest));
   last_index = MathMin(rates_total - 1, MathMax(newest, oldest));

   while(first_index <= last_index && time[first_index] > to_time)
      first_index++;

   while(last_index >= first_index && time[last_index] < from_time)
      last_index--;

   return (first_index <= last_index);
  }

//+------------------------------------------------------------------+
//| Builds one profile from current-chart bars and returns its VA.   |
//+------------------------------------------------------------------+
bool CalculateProfileLevels(const datetime &time[],
                            const double &high[],
                            const double &low[],
                            const long &tick_volume[],
                            const long &real_volume[],
                            int rates_total,
                            datetime from_time,
                            datetime to_time,
                            double &vah,
                            double &poc,
                            double &val)
  {
   vah = EMPTY_VALUE;
   poc = EMPTY_VALUE;
   val = EMPTY_VALUE;

   if(to_time <= from_time || IsStopped())
      return false;

   int first_bar = -1;
   int last_bar = -1;

   if(!GetChartArrayRange(time, rates_total, from_time, to_time, first_bar, last_bar))
      return false;

   double step = GetProfilePriceStep();

   if(step <= 0.0)
      step = _Point;

   double raw_low = low[first_bar];
   double raw_high = high[first_bar];

   for(int bar = first_bar + 1; bar <= last_bar; bar++)
     {
      if(IsStopped())
         return false;

      if(low[bar] < raw_low)
         raw_low = low[bar];

      if(high[bar] > raw_high)
         raw_high = high[bar];
     }

   double low_price = RoundPriceDownToStep(raw_low, step);
   double high_price = RoundPriceUpToStep(raw_high, step);
   int levels = GetCeilPriceIndex(high_price, low_price, step) + 1;

   if(levels <= 0 || levels > 50000)
      return false;

   double profile[];
   double profile_delta[];

   ArrayResize(profile, levels);
   ArrayResize(profile_delta, levels + 1);
   ArrayInitialize(profile, 0.0);
   ArrayInitialize(profile_delta, 0.0);

   for(int bar = first_bar; bar <= last_bar; bar++)
     {
      if(IsStopped())
         return false;

      int low_index = GetFloorPriceIndex(low[bar], low_price, step);
      int high_index = GetCeilPriceIndex(high[bar], low_price, step);

      low_index = MathMax(0, MathMin(low_index, levels - 1));
      high_index = MathMax(0, MathMin(high_index, levels - 1));

      if(low_index > high_index)
        {
         int temporary = low_index;
         low_index = high_index;
         high_index = temporary;
        }

      double bar_volume = 0.0;

      if(InpVolumeMode == BCL_VOLUME_REAL && real_volume[bar] > 0)
         bar_volume = (double)real_volume[bar];
      else
         bar_volume = (double)tick_volume[bar];

      int touched_levels = high_index - low_index + 1;

      if(touched_levels <= 0 || bar_volume <= 0.0)
         continue;

      double volume_per_level = bar_volume / touched_levels;
      profile_delta[low_index] += volume_per_level;
      profile_delta[high_index + 1] -= volume_per_level;
     }

   double running_volume = 0.0;

   for(int level = 0; level < levels; level++)
     {
      if(IsStopped())
         return false;

      running_volume += profile_delta[level];
      profile[level] = running_volume;
     }

   if(GetArraySum(profile) <= 0.0)
      return false;

   int poc_index = FindPointOfControlIndex(profile);

   if(poc_index < 0)
      return false;

   int val_index = -1;
   int vah_index = -1;

   CalculateValueArea(profile, poc_index, InpValueAreaPercent, val_index, vah_index);

   if(val_index < 0 || vah_index < 0)
      return false;

   poc = GetPriceFromIndex(poc_index, low_price, step);
   val = GetPriceFromIndex(val_index, low_price, step);
   vah = GetPriceFromIndex(vah_index, low_price, step);

   return true;
  }

//+------------------------------------------------------------------+
//| Clears all indicator buffers.                                    |
//+------------------------------------------------------------------+
void ClearAllBuffers()
  {
   ArrayInitialize(g_value_area_high_buffer, EMPTY_VALUE);
   ArrayInitialize(g_point_of_control_buffer, EMPTY_VALUE);
   ArrayInitialize(g_value_area_low_buffer, EMPTY_VALUE);
  }

//+------------------------------------------------------------------+
//| Resolves the buffer index range for a time interval.             |
//+------------------------------------------------------------------+
bool GetBufferIndexRange(int rates_total,
                         datetime from_time,
                         datetime to_time,
                         int &first_index,
                         int &last_index)
  {
   first_index = -1;
   last_index = -1;

   if(rates_total <= 0 || to_time < from_time)
      return false;

   int index_to = iBarShift(_Symbol, _Period, to_time, false);
   int index_from = iBarShift(_Symbol, _Period, from_time, false);

   if(index_to < 0)
      index_to = 0;

   if(index_from < 0)
      index_from = rates_total - 1;

   first_index = MathMax(0, MathMin(index_to, index_from));
   last_index = MathMin(rates_total - 1, MathMax(index_to, index_from));

   return (first_index <= last_index);
  }

//+------------------------------------------------------------------+
//| Clears buffer values only for the supplied time interval.        |
//+------------------------------------------------------------------+
void ClearBuffersForPeriod(int rates_total,
                           datetime from_time,
                           datetime to_time)
  {
   int first_index = -1;
   int last_index = -1;

   if(!GetBufferIndexRange(rates_total, from_time, to_time, first_index, last_index))
      return;

   for(int i = first_index; i <= last_index; i++)
     {
      g_value_area_high_buffer[i] = EMPTY_VALUE;
      g_point_of_control_buffer[i] = EMPTY_VALUE;
      g_value_area_low_buffer[i] = EMPTY_VALUE;
     }
  }

//+------------------------------------------------------------------+
//| Writes calculated levels only into the supplied time interval.   |
//+------------------------------------------------------------------+
void FillBuffersForPeriod(int rates_total,
                          datetime from_time,
                          datetime to_time,
                          double vah,
                          double poc,
                          double val)
  {
   int first_index = -1;
   int last_index = -1;

   if(!GetBufferIndexRange(rates_total, from_time, to_time, first_index, last_index))
      return;

   for(int i = first_index; i <= last_index; i++)
     {
      g_value_area_high_buffer[i] = vah;
      g_point_of_control_buffer[i] = poc;
      g_value_area_low_buffer[i] = val;
     }
  }

//+------------------------------------------------------------------+
//| Calculates and draws completed historical profiles once.        |
//+------------------------------------------------------------------+
void RefreshHistoricalProfiles(const datetime &profile_starts[],
                               int available,
                               const datetime &time[],
                               const double &high[],
                               const double &low[],
                               const long &tick_volume[],
                               const long &real_volume[],
                               int rates_total)
  {
   if(!AllowChartObjects())
      return;

   DeleteObjectsByPrefix(g_prefix + "HIST_");
   DeleteObjectsByPrefix(g_prefix + "HPREV_");

   int completed_count = available - 1;

   if(completed_count <= 0)
      return;

   double completed_vah[];
   double completed_poc[];
   double completed_val[];
   bool completed_ok[];

   ArrayResize(completed_vah, completed_count);
   ArrayResize(completed_poc, completed_count);
   ArrayResize(completed_val, completed_count);
   ArrayResize(completed_ok, completed_count);

   for(int index = 0; index < completed_count; index++)
     {
      if(IsStopped())
         return;

      int profile_index = index + 1;
      datetime profile_start = profile_starts[profile_index];
      datetime profile_end = profile_starts[profile_index - 1] - 1;

      completed_ok[index] = false;
      completed_vah[index] = EMPTY_VALUE;
      completed_poc[index] = EMPTY_VALUE;
      completed_val[index] = EMPTY_VALUE;

      if(profile_end <= profile_start)
         continue;

      if(profile_index == 1 &&
         g_has_previous_values &&
         g_previous_start_for_dashboard == profile_start)
        {
         completed_vah[index] = g_previous_vah;
         completed_poc[index] = g_previous_poc;
         completed_val[index] = g_previous_val;
         completed_ok[index] = true;
        }
      else
        {
         completed_ok[index] = CalculateProfileLevels(time,
                                                       high,
                                                       low,
                                                       tick_volume,
                                                       real_volume,
                                                       rates_total,
                                                       profile_start,
                                                       profile_end,
                                                       completed_vah[index],
                                                       completed_poc[index],
                                                       completed_val[index]);
        }
     }

   if(InpShowHistoricalValueAreas)
     {
      for(int index = 0; index < completed_count; index++)
        {
         if(IsStopped())
            return;

         if(!completed_ok[index])
            continue;

         int profile_index = index + 1;
         datetime profile_start = profile_starts[profile_index];
         datetime profile_end = profile_starts[profile_index - 1] - 1;
         string profile_prefix = g_prefix + "HIST_" + IntegerToString((long)profile_start) + "_";

         DrawSessionLevels(profile_prefix,
                           "",
                           profile_start,
                           profile_start,
                           profile_end,
                           completed_vah[index],
                           completed_poc[index],
                           completed_val[index],
                           InpHistoricalLabelShiftBars);
        }
     }

   if(InpShowHistoricalPreviousValueAreas)
     {
      for(int index = 0; index < completed_count - 1; index++)
        {
         if(IsStopped())
            return;

         if(!completed_ok[index + 1])
            continue;

         int profile_index = index + 1;
         datetime session_start = profile_starts[profile_index];
         datetime session_end = profile_starts[profile_index - 1] - 1;
         string profile_prefix = g_prefix + "HPREV_" + IntegerToString((long)session_start) + "_";

         DrawSessionLevels(profile_prefix,
                           "PD",
                           session_start,
                           session_start,
                           session_end,
                           completed_vah[index + 1],
                           completed_poc[index + 1],
                           completed_val[index + 1],
                           InpHistoricalPreviousLabelShiftBars);
        }
     }
  }

//+------------------------------------------------------------------+
//| Updates developing, previous, and historical profile levels.     |
//+------------------------------------------------------------------+
bool UpdateProfiles(const datetime &time[],
                    const double &high[],
                    const double &low[],
                    const long &tick_volume[],
                    const long &real_volume[],
                    int rates_total,
                    bool force_all)
  {
   if(rates_total <= 0 || IsStopped())
      return false;

   datetime starts[];

   int requested = MathMax(1, InpProfilesToDraw);
   int copied = BuildProfileStarts(time, rates_total, requested + 1, starts);

   if(copied <= 0)
      return false;

   int available = MathMin(requested, copied);
   datetime current_start = starts[0];
   datetime current_end = TimeCurrent();

   if(current_end < time[0])
      current_end = time[0] + GetSafePeriodSeconds((ENUM_TIMEFRAMES)_Period) - 1;

   if(force_all)
     {
      ClearAllBuffers();
      DeleteObjectsByPrefix(g_prefix);

      g_has_current_values = false;
      g_has_previous_values = false;
      g_current_vah = EMPTY_VALUE;
      g_current_poc = EMPTY_VALUE;
      g_current_val = EMPTY_VALUE;
      g_previous_vah = EMPTY_VALUE;
      g_previous_poc = EMPTY_VALUE;
      g_previous_val = EMPTY_VALUE;
      g_current_start_for_dashboard = 0;
      g_previous_start_for_dashboard = 0;
     }

   DeleteObjectsByPrefix(g_prefix + "DEV_");
   DeleteObjectsByPrefix(g_prefix + "PREV_");
   ClearBuffersForPeriod(rates_total, current_start, current_end);

   double current_vah = EMPTY_VALUE;
   double current_poc = EMPTY_VALUE;
   double current_val = EMPTY_VALUE;

   bool current_ok = CalculateProfileLevels(time,
                                             high,
                                             low,
                                             tick_volume,
                                             real_volume,
                                             rates_total,
                                             current_start,
                                             current_end,
                                             current_vah,
                                             current_poc,
                                             current_val);

   g_has_current_values = current_ok;

   if(current_ok)
     {
      g_current_vah = current_vah;
      g_current_poc = current_poc;
      g_current_val = current_val;
      g_current_start_for_dashboard = current_start;

      FillBuffersForPeriod(rates_total,
                           current_start,
                           current_end,
                           current_vah,
                           current_poc,
                           current_val);

      if(InpShowDevelopingValueArea)
        {
         DrawSessionLevels(g_prefix + "DEV_",
                           "D",
                           current_start,
                           current_start,
                           current_end,
                           current_vah,
                           current_poc,
                           current_val,
                           InpLabelShiftBars);
        }
      else if(InpShowSessionBreakLine)
        {
         DrawSeparator(g_prefix + "DEV_", current_start);
        }
     }

   if(available > 1)
     {
      datetime previous_start = starts[1];
      datetime previous_end = current_start - 1;

      bool same_cached_profile = (g_has_previous_values &&
                                  g_previous_start_for_dashboard == previous_start);

      bool recalculate_previous = (!InpFreezeCompleted ||
                                   !same_cached_profile ||
                                   force_all);

      if(recalculate_previous)
        {
         double previous_vah = EMPTY_VALUE;
         double previous_poc = EMPTY_VALUE;
         double previous_val = EMPTY_VALUE;

         bool previous_ok = CalculateProfileLevels(time,
                                                   high,
                                                   low,
                                                   tick_volume,
                                                   real_volume,
                                                   rates_total,
                                                   previous_start,
                                                   previous_end,
                                                   previous_vah,
                                                   previous_poc,
                                                   previous_val);

         g_has_previous_values = previous_ok;

         if(previous_ok)
           {
            g_previous_vah = previous_vah;
            g_previous_poc = previous_poc;
            g_previous_val = previous_val;
            g_previous_start_for_dashboard = previous_start;
           }
        }

      if(g_has_previous_values && InpShowPreviousValueArea)
        {
         DrawSessionLevels(g_prefix + "PREV_",
                           "PD",
                           current_start,
                           current_start,
                           current_end,
                           g_previous_vah,
                           g_previous_poc,
                           g_previous_val,
                           InpPreviousLabelShiftBars);
        }
     }
   else
     {
      g_has_previous_values = false;
      g_previous_vah = EMPTY_VALUE;
      g_previous_poc = EMPTY_VALUE;
      g_previous_val = EMPTY_VALUE;
      g_previous_start_for_dashboard = 0;
     }

   if(force_all || g_refresh_historical)
     {
      RefreshHistoricalProfiles(starts,
                                available,
                                time,
                                high,
                                low,
                                tick_volume,
                                real_volume,
                                rates_total);
      g_refresh_historical = false;
     }

   if(AllowChartObjects())
     {
      DrawDashboard();
      ChartRedraw(0);
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Initializes indicator buffers and runtime state.                 |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_prefix = InpObjectPrefix + "_" + _Symbol + "_" +
              TimeframeToString(InpProfilePeriod) + "_" +
              TimeframeToString((ENUM_TIMEFRAMES)_Period) + "_";

   SetIndexBuffer(0, g_value_area_high_buffer, INDICATOR_DATA);
   SetIndexBuffer(1, g_point_of_control_buffer, INDICATOR_DATA);
   SetIndexBuffer(2, g_value_area_low_buffer, INDICATOR_DATA);

   ArraySetAsSeries(g_value_area_high_buffer, true);
   ArraySetAsSeries(g_point_of_control_buffer, true);
   ArraySetAsSeries(g_value_area_low_buffer, true);

   PlotIndexSetString(0, PLOT_LABEL, "VAH");
   PlotIndexSetString(1, PLOT_LABEL, "POC");
   PlotIndexSetString(2, PLOT_LABEL, "VAL");

   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);

   PlotIndexSetInteger(0, PLOT_SHOW_DATA, true);
   PlotIndexSetInteger(1, PLOT_SHOW_DATA, true);
   PlotIndexSetInteger(2, PLOT_SHOW_DATA, true);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "BCL Value Area Levels [" +
                      TimeframeToString((ENUM_TIMEFRAMES)_Period) + "]");

   g_is_tester = (bool)MQLInfoInteger(MQL_TESTER);
   g_is_visual_tester = (bool)MQLInfoInteger(MQL_VISUAL_MODE);

   g_current_profile_start = 0;
   g_last_update_time = 0;
   g_last_tester_chart_bar_time = 0;
   g_force_full_redraw = true;
   g_refresh_historical = true;
   g_has_current_values = false;
   g_has_previous_values = false;

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Removes all chart objects created by this indicator.             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteObjectsByPrefix(g_prefix);
  }

//+------------------------------------------------------------------+
//| Main indicator calculation event.                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
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
   if(rates_total <= 0)
      return 0;

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(tick_volume, true);
   ArraySetAsSeries(volume, true);

//--- The profile is built only from the current chart timeframe.
//--- A chart timeframe larger than the selected profile period cannot
//--- provide valid intraprofile bars, so calculation is skipped.
   if(!IsProfilePeriodCompatible())
     {
      if(prev_calculated == 0)
         ClearAllBuffers();

      return rates_total;
     }

   bool force_all = (prev_calculated == 0 || g_force_full_redraw);
   datetime current_profile_start = GetProfileStart(time[0]);

   if(current_profile_start > 0)
     {
      if(g_current_profile_start == 0)
        {
         g_current_profile_start = current_profile_start;
        }
      else if(g_current_profile_start != current_profile_start)
        {
         g_current_profile_start = current_profile_start;
         g_refresh_historical = true;
        }
     }

   datetime chart_bar_time = time[0];
   bool chart_bar_changed = false;

   if(chart_bar_time > 0 && chart_bar_time != g_last_tester_chart_bar_time)
     {
      g_last_tester_chart_bar_time = chart_bar_time;
      chart_bar_changed = true;
     }

   datetime now = TimeCurrent();

   if(!force_all)
     {
      if(g_is_tester)
        {
         if(!chart_bar_changed && !g_refresh_historical)
            return rates_total;
        }
      else
        {
         int update_interval = MathMax(1, InpUpdateSeconds);

         if(g_last_update_time > 0 &&
            (now - g_last_update_time) < update_interval)
            return rates_total;
        }
     }

   bool updated = UpdateProfiles(time,
                                 high,
                                 low,
                                 tick_volume,
                                 volume,
                                 rates_total,
                                 force_all);

   if(updated)
     {
      g_last_update_time = now;
      g_force_full_redraw = false;
     }

   return rates_total;
  }
//+------------------------------------------------------------------+
