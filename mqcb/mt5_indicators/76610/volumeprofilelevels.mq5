//+------------------------------------------------------------------+
//|                                          VolumeProfileLevels.mq5 |
//|                        Copyright 2026, MQL5 Code Base Submission |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Builds a horizontal volume histogram over a recent lookback window and "
#property description "marks the Point of Control and Value Area using the standard TPO/volume "
#property description "value-area expansion algorithm, refreshed once per new bar."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property strict

//--- which volume series feeds the histogram
enum ENUM_VP_VOLUME
  {
   VP_VOLUME_TICK = 0,  // Tick Volume (available on virtually every symbol)
   VP_VOLUME_REAL = 1   // Real Volume (only meaningful where the broker/exchange supplies it)
  };

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Profile Settings ==="
input int             InpLookbackBars    = 200;  // Lookback Window (most recent bars profiled)
input int             InpNumRows         = 24;   // Number of Price Rows (histogram buckets)
input ENUM_VP_VOLUME  InpVolumeType      = VP_VOLUME_TICK; // Volume Source
input double          InpValueAreaPercent = 70.0; // Value Area (% of total volume around the POC)
input bool             InpUpdateOnNewBarOnly = true; // Recalculate Only on a New Chart Bar

input group "=== Display ==="
input bool InpShowProfile        = true;  // Show the Volume Histogram Rows
input bool InpShowPOC            = true;  // Show the Point of Control Line
input bool InpShowValueArea      = true;  // Show the Value Area High/Low Lines
input int  InpProfileMaxWidthBars = 30;   // Max Sidebar Width (bars-equivalent, for the tallest row)

input group "=== Colors ==="
input color InpBuyDominantColor  = clrLime;      // Row Color — Bar Where Up-Close Volume Dominates
input color InpSellDominantColor = clrRed;       // Row Color — Bar Where Down-Close Volume Dominates
input color InpPOCColor          = clrWhite;     // Point of Control Line Color
input color InpValueAreaColor    = clrSilver;    // Value Area High/Low Line Color

//+------------------------------------------------------------------+
//| Global variables                                                  |
//+------------------------------------------------------------------+
string g_Prefix = "VPL_";

double g_BucketVol[];      // total (up + down) volume per price row, rebuilt each refresh
double g_BucketVolUp[];    // volume from up-closing bars per row
double g_BucketVolDown[];  // volume from down-closing bars per row
string g_RowObjName[];     // one chart object name per row, reused across refreshes

string g_POCName;
string g_VAHName;
string g_VALName;

datetime g_LastBarTime = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                        |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpNumRows < 2)
     {
      Alert("VolumeProfileLevels: 'Number of Price Rows' must be at least 2.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpLookbackBars < InpNumRows)
     {
      Alert("VolumeProfileLevels: 'Lookback Window' must be at least as large as 'Number of Price Rows'.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpValueAreaPercent <= 0.0 || InpValueAreaPercent > 100.0)
     {
      Alert("VolumeProfileLevels: 'Value Area %' must be between 0 and 100.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   IndicatorSetString(INDICATOR_SHORTNAME, "Volume Profile Levels");

   ArrayResize(g_BucketVol, InpNumRows);
   ArrayResize(g_BucketVolUp, InpNumRows);
   ArrayResize(g_BucketVolDown, InpNumRows);
   ArrayResize(g_RowObjName, InpNumRows);

   for(int r = 0; r < InpNumRows; r++)
      g_RowObjName[r] = g_Prefix + "Row" + IntegerToString(r);

   g_POCName = g_Prefix + "POC";
   g_VAHName = g_Prefix + "VAH";
   g_VALName = g_Prefix + "VAL";

   g_LastBarTime = 0; // forces a full rebuild on the very first OnCalculate call

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- remove every chart object this indicator has created, identified by its unique prefix
   ObjectsDeleteAll(0, g_Prefix);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                             |
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
   if(rates_total < InpNumRows + 2)
      return(0);

//--- unlike a simple rolling sum, a volume profile's row boundaries depend on
//--- the highest/lowest price across the whole lookback window — a value that
//--- cannot be updated with one addition/subtraction when the window slides
//--- (the bar leaving the window might have been the extreme). The honest,
//--- correct trade-off used here is: rebuild from the fixed-size lookback
//--- window only, and only when a new bar actually closes — never on every
//--- tick, and never by rescanning the chart's full history.
   bool shouldUpdate = true;

   if(InpUpdateOnNewBarOnly)
     {
      datetime currentBarTime = time[rates_total - 1];
      shouldUpdate = (prev_calculated == 0 || currentBarTime != g_LastBarTime);
      g_LastBarTime = currentBarTime;
     }

   if(shouldUpdate)
      RebuildProfile(rates_total, time, open, high, low, close, tick_volume, volume);

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Rebuilds the histogram, POC and Value Area from the most recent  |
//| InpLookbackBars bars, then refreshes every chart object          |
//+------------------------------------------------------------------+
void RebuildProfile(const int rates_total, const datetime &time[],
                     const double &open[], const double &high[], const double &low[], const double &close[],
                     const long &tick_volume[], const long &volume[])
  {
   int count = MathMin(InpLookbackBars, rates_total);
   int startIdx = rates_total - count;

//--- find the price range covered by the lookback window; the histogram rows
//--- are simple equal-height slices of this range
   double rangeHigh = high[startIdx];
   double rangeLow  = low[startIdx];
   for(int i = startIdx + 1; i < rates_total; i++)
     {
      if(high[i] > rangeHigh)
         rangeHigh = high[i];
      if(low[i] < rangeLow)
         rangeLow = low[i];
     }

   if(rangeHigh <= rangeLow)
      return; // degenerate range (e.g. a single flat bar), nothing meaningful to profile

   double bucketSize = (rangeHigh - rangeLow) / InpNumRows;

   ArrayInitialize(g_BucketVol, 0.0);
   ArrayInitialize(g_BucketVolUp, 0.0);
   ArrayInitialize(g_BucketVolDown, 0.0);

//--- assign each bar's entire volume to a single row, using its typical price
//--- (H+L+C)/3 — a deliberate simplification versus spreading one bar's
//--- volume across every row its range touches, chosen for both performance
//--- and code clarity; see the Recommended Use notes in the article
   for(int i = startIdx; i < rates_total; i++)
     {
      double typical = (high[i] + low[i] + close[i]) / 3.0;
      int row = (int)((typical - rangeLow) / bucketSize);
      if(row < 0)
         row = 0;
      if(row >= InpNumRows)
         row = InpNumRows - 1;

      double vol = (InpVolumeType == VP_VOLUME_TICK) ? (double)tick_volume[i] : (double)volume[i];

      g_BucketVol[row] += vol;
      if(close[i] >= open[i])
         g_BucketVolUp[row] += vol;
      else
         g_BucketVolDown[row] += vol;
     }

//--- Point of Control: the row with the single largest volume
   int pocRow = 0;
   double totalVol = 0.0;
   for(int r = 0; r < InpNumRows; r++)
     {
      totalVol += g_BucketVol[r];
      if(g_BucketVol[r] > g_BucketVol[pocRow])
         pocRow = r;
     }

//--- Value Area: starting from the POC, repeatedly add whichever adjacent row
//--- (above the current top or below the current bottom) holds more volume,
//--- until the accumulated volume reaches InpValueAreaPercent of the total —
//--- this is the standard TPO/volume value-area expansion algorithm
   int vaTop = pocRow;
   int vaBottom = pocRow;
   double target = totalVol * InpValueAreaPercent / 100.0;
   double cumVol = g_BucketVol[pocRow];

   while(cumVol < target)
     {
      bool hasAbove = (vaTop + 1 < InpNumRows);
      bool hasBelow = (vaBottom - 1 >= 0);
      if(!hasAbove && !hasBelow)
         break;

      double volAbove = hasAbove ? g_BucketVol[vaTop + 1] : -1.0;
      double volBelow = hasBelow ? g_BucketVol[vaBottom - 1] : -1.0;

      if(volAbove >= volBelow)
        {
         vaTop++;
         cumVol += g_BucketVol[vaTop];
        }
      else
        {
         vaBottom--;
         cumVol += g_BucketVol[vaBottom];
        }
     }

   double pocPrice = rangeLow + (pocRow + 0.5) * bucketSize;
   double vahPrice = rangeLow + (vaTop + 1) * bucketSize;
   double valPrice = rangeLow + vaBottom * bucketSize;

//--- find the tallest row so every other row's sidebar width can be scaled
//--- relative to it
   double maxRowVol = g_BucketVol[pocRow];

   datetime sidebarX1 = time[rates_total - 1];
   datetime sidebarFullWidth = sidebarX1 + (datetime)InpProfileMaxWidthBars * PeriodSeconds(_Period);

   if(InpShowProfile)
     {
      for(int r = 0; r < InpNumRows; r++)
        {
         double y1 = rangeLow + r * bucketSize;
         double y2 = y1 + bucketSize;

         double frac = (maxRowVol > 0.0) ? (g_BucketVol[r] / maxRowVol) : 0.0;
         datetime x2 = sidebarX1 + (datetime)MathRound(frac * InpProfileMaxWidthBars) * PeriodSeconds(_Period);
         if(x2 <= sidebarX1)
            x2 = sidebarX1 + PeriodSeconds(_Period); // keep a sliver visible even for empty rows

         color rowColor = (g_BucketVolUp[r] >= g_BucketVolDown[r]) ? InpBuyDominantColor : InpSellDominantColor;

         DrawOrMoveRow(g_RowObjName[r], sidebarX1, y1, x2, y2, rowColor);
        }
     }

   if(InpShowPOC)
      DrawOrMoveLine(g_POCName, time[startIdx], pocPrice, sidebarFullWidth, InpPOCColor, STYLE_SOLID, 2);

   if(InpShowValueArea)
     {
      DrawOrMoveLine(g_VAHName, time[startIdx], vahPrice, sidebarFullWidth, InpValueAreaColor, STYLE_DOT, 1);
      DrawOrMoveLine(g_VALName, time[startIdx], valPrice, sidebarFullWidth, InpValueAreaColor, STYLE_DOT, 1);
     }

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Creates a row rectangle, or moves/re-colors it if it exists —    |
//| the InpNumRows objects are created once and reused every refresh |
//+------------------------------------------------------------------+
void DrawOrMoveRow(const string name, const datetime x1, const double y1,
                    const datetime x2, const double y2, const color clr)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, x1, y1, x2, y2);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
     }
   else
     {
      ObjectMove(0, name, 0, x1, y1);
      ObjectMove(0, name, 1, x2, y2);
     }

   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//| Creates a horizontal reference line (POC / VAH / VAL), or moves  |
//| it if it already exists                                          |
//+------------------------------------------------------------------+
void DrawOrMoveLine(const string name, const datetime x1, const double price,
                     const datetime x2, const color clr, const ENUM_LINE_STYLE style, const int width)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TREND, 0, x1, price, x2, price);
      ObjectSetInteger(0, name, OBJPROP_STYLE, style);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   else
     {
      ObjectMove(0, name, 0, x1, price);
      ObjectMove(0, name, 1, x2, price);
     }

   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }
//+------------------------------------------------------------------+
