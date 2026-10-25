//+------------------------------------------------------------------+
//|                         Multi-Timeframe Candle Map               |
//|                         Educational tool for MQL5.com            |
//+------------------------------------------------------------------+
#property copyright "Talal N Z Aljarusha"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Maps the live price vertically inside candles from four configurable timeframes."
#property description "It also explains location agreement and dispersion without generating trade signals."
#property indicator_chart_window
#property indicator_plots 0

input ENUM_TIMEFRAMES InpTimeframe1       = PERIOD_M15;
input ENUM_TIMEFRAMES InpTimeframe2       = PERIOD_H1;
input ENUM_TIMEFRAMES InpTimeframe3       = PERIOD_H4;
input ENUM_TIMEFRAMES InpTimeframe4       = PERIOD_D1;
input bool            InpUseBidPrice      = true;       // Use Bid; otherwise use candle close
input int             InpRefreshSeconds   = 1;          // Panel refresh interval
input double          InpEdgeThreshold    = 20.0;       // Near-high/low boundary, percent
input int             InpAlignmentCount   = 3;          // Frames required for an edge alignment
input bool            InpEnableAlerts     = false;      // Alert on a new high/low alignment
input int             InpPanelX           = 14;
input int             InpPanelY           = 28;
input color           InpPanelColor       = C'17,24,32';
input color           InpBorderColor      = C'55,68,82';
input color           InpBullishColor     = clrMediumSeaGreen;
input color           InpBearishColor     = clrIndianRed;
input color           InpNeutralColor     = clrDarkGray;
input color           InpTextColor        = clrWhiteSmoke;
input color           InpMutedTextColor   = clrSilver;
input string          InpObjectPrefix     = "MTCM_";

struct CandleSnapshot
{
   ENUM_TIMEFRAMES timeframe;
   datetime        open_time;
   double          open;
   double          high;
   double          low;
   double          close;
   double          price;
   double          position_percent;
   double          range_points;
   int             remaining_seconds;
   bool            valid;
};

const int PANEL_WIDTH  = 430;
const int PANEL_HEIGHT = 300;
const int GAUGE_TOP    = 74;
const int GAUGE_HEIGHT = 126;
const int GAUGE_WIDTH  = 34;

ENUM_TIMEFRAMES g_timeframes[4];
string          g_last_alert_key = "";

//+------------------------------------------------------------------+
int OnInit()
{
   g_timeframes[0] = InpTimeframe1;
   g_timeframes[1] = InpTimeframe2;
   g_timeframes[2] = InpTimeframe3;
   g_timeframes[3] = InpTimeframe4;

   IndicatorSetString(INDICATOR_SHORTNAME, "Multi-Timeframe Candle Map");
   // Public validators may exercise zero or extreme input values. Clamp them
   // at the point of use so the indicator remains operational.
   EventSetTimer(MathMax(1, InpRefreshSeconds));
   BuildPanel();
   RefreshPanel();
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   DeletePanelObjects();
}

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
   return(rates_total);
}

//+------------------------------------------------------------------+
void OnTimer()
{
   RefreshPanel();
}

//+------------------------------------------------------------------+
void BuildPanel()
{
   DeletePanelObjects();

   CreateRectangleLabel(InpObjectPrefix + "BG", InpPanelX, InpPanelY,
                        PANEL_WIDTH, PANEL_HEIGHT, InpPanelColor,
                        InpBorderColor, 1);

   CreateTextLabel(InpObjectPrefix + "TITLE", InpPanelX + 12, InpPanelY + 9,
                   "MULTI-TIMEFRAME CANDLE MAP", InpTextColor, 10, "Arial Bold");
   CreateTextLabel(InpObjectPrefix + "SUBTITLE", InpPanelX + 12, InpPanelY + 27,
                   "Live position inside each developing candle", InpMutedTextColor, 7, "Arial");

   CreateTextLabel(InpObjectPrefix + "HIGH", InpPanelX + 10, InpPanelY + GAUGE_TOP - 5,
                   "HIGH", InpMutedTextColor, 7, "Arial");
   CreateTextLabel(InpObjectPrefix + "LOW", InpPanelX + 12,
                   InpPanelY + GAUGE_TOP + GAUGE_HEIGHT - 6,
                   "LOW", InpMutedTextColor, 7, "Arial");

   for(int column = 0; column < 4; column++)
      BuildGauge(column);

   CreateRectangleLabel(InpObjectPrefix + "SUMMARY_BG", InpPanelX + 8,
                        InpPanelY + 226, PANEL_WIDTH - 16, 62,
                        C'22,31,41', C'36,47,59', 1);
   CreateTextLabel(InpObjectPrefix + "SUMMARY", InpPanelX + 18, InpPanelY + 236,
                   "Waiting for price data...", InpTextColor, 9, "Arial Bold");
   CreateTextLabel(InpObjectPrefix + "DETAIL", InpPanelX + 18, InpPanelY + 256,
                   "", InpMutedTextColor, 8, "Arial");
   CreateTextLabel(InpObjectPrefix + "NOTE", InpPanelX + 18, InpPanelY + 273,
                   "Location context only - not a trend or entry signal.", InpMutedTextColor, 7, "Arial");
}

//+------------------------------------------------------------------+
void BuildGauge(const int column)
{
   const string base = InpObjectPrefix + "C" + IntegerToString(column) + "_";
   const int center_x = InpPanelX + 88 + column * 82;
   const int gauge_x  = center_x - GAUGE_WIDTH / 2;
   const int gauge_y  = InpPanelY + GAUGE_TOP;

   CreateTextLabel(base + "TF", center_x - 16, InpPanelY + 48,
                   "--", InpTextColor, 9, "Arial Bold");
   CreateRectangleLabel(base + "TRACK", gauge_x, gauge_y,
                        GAUGE_WIDTH, GAUGE_HEIGHT, C'39,49,60', C'65,77,90', 1);
   CreateRectangleLabel(base + "FILL", gauge_x + 3,
                        gauge_y + GAUGE_HEIGHT - 4,
                        GAUGE_WIDTH - 6, 1, InpNeutralColor, InpNeutralColor, 0);

   // The marker makes the exact percentage readable even when the fill is tall.
   CreateRectangleLabel(base + "MARK", gauge_x - 4,
                        gauge_y + GAUGE_HEIGHT / 2,
                        GAUGE_WIDTH + 8, 2, InpTextColor, InpTextColor, 0);
   CreateTextLabel(base + "PCT", center_x - 19,
                   InpPanelY + GAUGE_TOP + GAUGE_HEIGHT + 7,
                   "--", InpTextColor, 9, "Arial Bold");
   CreateTextLabel(base + "ZONE", center_x - 30,
                   InpPanelY + GAUGE_TOP + GAUGE_HEIGHT + 25,
                   "--", InpMutedTextColor, 7, "Arial");
   CreateTextLabel(base + "DIR", center_x - 28,
                   InpPanelY + GAUGE_TOP + GAUGE_HEIGHT + 40,
                   "--", InpNeutralColor, 7, "Arial");
   CreateTextLabel(base + "TIME", center_x - 30,
                   InpPanelY + GAUGE_TOP + GAUGE_HEIGHT + 55,
                   "--", InpMutedTextColor, 7, "Arial");
}

//+------------------------------------------------------------------+
void RefreshPanel()
{
   CandleSnapshot snapshots[4];
   int valid_count = 0;

   for(int column = 0; column < 4; column++)
   {
      ResetSnapshot(snapshots[column], g_timeframes[column]);
      if(ReadSnapshot(g_timeframes[column], snapshots[column]))
         valid_count++;
      UpdateGauge(column, snapshots[column]);
   }

   UpdateSummary(snapshots, valid_count);
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
bool ReadSnapshot(const ENUM_TIMEFRAMES timeframe, CandleSnapshot &snapshot)
{
   MqlRates bar[1];
   if(CopyRates(_Symbol, timeframe, 0, 1, bar) != 1)
      return(false);

   snapshot.open_time = bar[0].time;
   snapshot.open      = bar[0].open;
   snapshot.high      = bar[0].high;
   snapshot.low       = bar[0].low;
   snapshot.close     = bar[0].close;

   double bid = 0.0;
   if(!SymbolInfoDouble(_Symbol, SYMBOL_BID, bid) || bid <= 0.0)
      bid = bar[0].close;
   snapshot.price = InpUseBidPrice ? bid : bar[0].close;

   const double range = snapshot.high - snapshot.low;
   snapshot.range_points = range > 0.0 ? range / _Point : 0.0;

   // Normalization makes different symbols and timeframes comparable.
   snapshot.position_percent = (range > 0.0)
                               ? 100.0 * (snapshot.price - snapshot.low) / range
                               : 50.0;
   snapshot.position_percent = MathMax(0.0, MathMin(100.0, snapshot.position_percent));

   const int period_seconds = PeriodSeconds(timeframe);
   if(period_seconds > 0)
   {
      const datetime close_time = snapshot.open_time + period_seconds;
      snapshot.remaining_seconds = (int)MathMax(0, close_time - TimeCurrent());
   }

   snapshot.valid = true;
   return(true);
}

//+------------------------------------------------------------------+
void UpdateGauge(const int column, const CandleSnapshot &candle)
{
   const string base = InpObjectPrefix + "C" + IntegerToString(column) + "_";
   ObjectSetString(0, base + "TF", OBJPROP_TEXT, TimeframeText(candle.timeframe));

   if(!candle.valid)
   {
      ObjectSetString(0, base + "PCT", OBJPROP_TEXT, "N/A");
      ObjectSetString(0, base + "ZONE", OBJPROP_TEXT, "NO DATA");
      ObjectSetString(0, base + "DIR", OBJPROP_TEXT, "waiting");
      ObjectSetString(0, base + "TIME", OBJPROP_TEXT, "--");
      ObjectSetInteger(0, base + "FILL", OBJPROP_YSIZE, 1);
      return;
   }

   const bool bullish = candle.close > candle.open;
   const bool bearish = candle.close < candle.open;
   const color direction_color = bullish ? InpBullishColor :
                                 bearish ? InpBearishColor : InpNeutralColor;
   const string direction = bullish ? "BULL" : bearish ? "BEAR" : "FLAT";

   const int inner_height = GAUGE_HEIGHT - 6;
   const int fill_height = (int)MathMax(1.0,
                              MathRound(inner_height * candle.position_percent / 100.0));
   const int gauge_x = InpPanelX + 88 + column * 82 - GAUGE_WIDTH / 2;
   const int gauge_y = InpPanelY + GAUGE_TOP;
   const int fill_y = gauge_y + GAUGE_HEIGHT - 3 - fill_height;
   const int marker_y = gauge_y + GAUGE_HEIGHT - 3 -
                        (int)MathRound(inner_height * candle.position_percent / 100.0);

   ObjectSetInteger(0, base + "FILL", OBJPROP_YDISTANCE, fill_y);
   ObjectSetInteger(0, base + "FILL", OBJPROP_YSIZE, fill_height);
   ObjectSetInteger(0, base + "FILL", OBJPROP_BGCOLOR, direction_color);
   ObjectSetInteger(0, base + "FILL", OBJPROP_COLOR, direction_color);
   ObjectSetInteger(0, base + "MARK", OBJPROP_XDISTANCE, gauge_x - 4);
   ObjectSetInteger(0, base + "MARK", OBJPROP_YDISTANCE, marker_y);

   ObjectSetString(0, base + "PCT", OBJPROP_TEXT,
                   DoubleToString(candle.position_percent, 0) + "%");
   ObjectSetString(0, base + "ZONE", OBJPROP_TEXT,
                   LocationText(candle.position_percent));
   ObjectSetString(0, base + "DIR", OBJPROP_TEXT, direction);
   ObjectSetInteger(0, base + "DIR", OBJPROP_COLOR, direction_color);
   ObjectSetString(0, base + "TIME", OBJPROP_TEXT,
                   FormatRemainingTime(candle.remaining_seconds));
}

//+------------------------------------------------------------------+
void UpdateSummary(const CandleSnapshot &snapshots[], const int valid_count)
{
   if(valid_count == 0)
   {
      ObjectSetString(0, InpObjectPrefix + "SUMMARY", OBJPROP_TEXT,
                      "Waiting for synchronized price data...");
      ObjectSetString(0, InpObjectPrefix + "DETAIL", OBJPROP_TEXT, "");
      return;
   }

   int near_high = 0;
   int near_low = 0;
   int bullish = 0;
   int bearish = 0;
   double sum = 0.0;
   double minimum = 100.0;
   double maximum = 0.0;
   datetime newest_open = 0;

   for(int i = 0; i < 4; i++)
   {
      if(!snapshots[i].valid)
         continue;

      const double position = snapshots[i].position_percent;
      sum += position;
      minimum = MathMin(minimum, position);
      maximum = MathMax(maximum, position);
      const double edge = EffectiveEdgeThreshold();
      if(position <= edge) near_low++;
      if(position >= 100.0 - edge) near_high++;
      if(snapshots[i].close > snapshots[i].open) bullish++;
      if(snapshots[i].close < snapshots[i].open) bearish++;
      newest_open = MathMax(newest_open, snapshots[i].open_time);
   }

   const double average = sum / valid_count;
   const double dispersion = maximum - minimum;
   string headline;
   color headline_color = InpTextColor;
   string alert_key = "";

   const int alignment_count = EffectiveAlignmentCount();
   if(near_high >= alignment_count)
   {
      headline = IntegerToString(near_high) + " timeframes are near their candle highs";
      headline_color = InpBullishColor;
      alert_key = "HIGH_" + IntegerToString((long)newest_open);
   }
   else if(near_low >= alignment_count)
   {
      headline = IntegerToString(near_low) + " timeframes are near their candle lows";
      headline_color = InpBearishColor;
      alert_key = "LOW_" + IntegerToString((long)newest_open);
   }
   else if(dispersion <= 20.0)
   {
      headline = "Timeframe locations are closely aligned";
   }
   else
   {
      headline = "Mixed location across the selected timeframes";
      headline_color = InpNeutralColor;
   }

   const string detail = StringFormat("Average %.0f%% | Spread %.0f%% | Candle bodies: %d bull / %d bear",
                                      average, dispersion, bullish, bearish);
   ObjectSetString(0, InpObjectPrefix + "SUMMARY", OBJPROP_TEXT, headline);
   ObjectSetInteger(0, InpObjectPrefix + "SUMMARY", OBJPROP_COLOR, headline_color);
   ObjectSetString(0, InpObjectPrefix + "DETAIL", OBJPROP_TEXT, detail);

   if(InpEnableAlerts && alert_key != "" && alert_key != g_last_alert_key)
   {
      Alert(_Symbol, " ", headline, ". Average location: ",
            DoubleToString(average, 0), "%");
      g_last_alert_key = alert_key;
   }
}

//+------------------------------------------------------------------+
string LocationText(const double position)
{
   const double edge = EffectiveEdgeThreshold();
   if(position <= edge)
      return("NEAR LOW");
   if(position < 50.0)
      return("LOWER HALF");
   if(position < 100.0 - edge)
      return("UPPER HALF");
   return("NEAR HIGH");
}

//+------------------------------------------------------------------+
double EffectiveEdgeThreshold()
{
   return(MathMax(1.0, MathMin(49.0, InpEdgeThreshold)));
}

//+------------------------------------------------------------------+
int EffectiveAlignmentCount()
{
   return(MathMax(2, MathMin(4, InpAlignmentCount)));
}

//+------------------------------------------------------------------+
void CreateRectangleLabel(const string name,
                          const int x,
                          const int y,
                          const int width,
                          const int height,
                          const color background,
                          const color border,
                          const int border_width)
{
   if(!ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
      return;

   SetCommonProperties(name, x, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, background);
   ObjectSetInteger(0, name, OBJPROP_COLOR, border);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, border_width);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
}

//+------------------------------------------------------------------+
void CreateTextLabel(const string name,
                     const int x,
                     const int y,
                     const string text,
                     const color text_color,
                     const int font_size,
                     const string font)
{
   if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
      return;

   SetCommonProperties(name, x, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(0, name, OBJPROP_COLOR, text_color);
}

//+------------------------------------------------------------------+
void SetCommonProperties(const string name, const int x, const int y)
{
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
}

//+------------------------------------------------------------------+
string TimeframeText(const ENUM_TIMEFRAMES timeframe)
{
   string value = EnumToString(timeframe);
   StringReplace(value, "PERIOD_", "");
   return(value);
}

//+------------------------------------------------------------------+
string FormatRemainingTime(const int total_seconds)
{
   const int hours = total_seconds / 3600;
   const int minutes = (total_seconds % 3600) / 60;
   const int seconds = total_seconds % 60;

   if(hours > 0)
      return(StringFormat("%02d:%02d:%02d", hours, minutes, seconds));
   return(StringFormat("%02d:%02d", minutes, seconds));
}

//+------------------------------------------------------------------+
void ResetSnapshot(CandleSnapshot &snapshot, const ENUM_TIMEFRAMES timeframe)
{
   ZeroMemory(snapshot);
   snapshot.timeframe = timeframe;
   snapshot.position_percent = 50.0;
   snapshot.valid = false;
}

//+------------------------------------------------------------------+
void DeletePanelObjects()
{
   for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--)
   {
      const string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, InpObjectPrefix) == 0)
         ObjectDelete(0, name);
   }
}
//+------------------------------------------------------------------+
