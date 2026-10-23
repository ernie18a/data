//+------------------------------------------------------------------+
//|                                 MultiTimeframeTrendDashboard.mq5 |
//|                        Copyright 2026, MQL5 Code Base Submission |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "A ranked, color-coded panel showing the current trend direction of the "
#property description "active symbol across several higher timeframes at once, using a "
#property description "Fast/Slow moving-average cross evaluated independently per timeframe."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property strict

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Timeframes to Display ==="
input bool InpShowM15 = true;   // Show M15
input bool InpShowM30 = true;   // Show M30
input bool InpShowH1  = true;   // Show H1
input bool InpShowH4  = true;   // Show H4
input bool InpShowD1  = true;   // Show D1
input bool InpShowW1  = false;  // Show W1

input group "=== Trend Detection ==="
input int                InpFastMAPeriod = 10;          // Fast MA Period
input int                InpSlowMAPeriod = 30;          // Slow MA Period
input ENUM_MA_METHOD      InpMAMethod     = MODE_SMA;    // MA Method
input ENUM_APPLIED_PRICE  InpAppliedPrice = PRICE_CLOSE; // Applied Price
input bool                InpShowMAValues = false;       // Show Fast/Slow MA Values in Panel
input bool                InpUpdateOnNewBarOnly = true;  // Recalculate Only on a New Chart Bar

input group "=== Panel Layout ==="
input ENUM_BASE_CORNER InpPanelCorner    = CORNER_LEFT_UPPER; // Panel Corner
input int               InpPanelXDistance = 12;   // Panel X Distance (pixels)
input int               InpPanelYDistance = 18;   // Panel Y Distance (pixels)
input int               InpFontSize       = 9;    // Font Size

input group "=== Panel Colors ==="
input color  InpBullColor      = clrLime;       // Row Color — Bullish (Fast > Slow)
input color  InpBearColor      = clrRed;        // Row Color — Bearish (Fast < Slow)
input color  InpNeutralColor   = clrSilver;     // Row Color — Neutral / Not Ready
input color  InpPanelTextColor = clrWhite;      // Title Text Color
input color  InpPanelBgColor   = C'20,20,20';   // Panel Background Color

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
#define TF_SLOT_COUNT 6
string          g_TFLabel[TF_SLOT_COUNT]  = {"M15", "M30", "H1", "H4", "D1", "W1"};
ENUM_TIMEFRAMES g_TFValue[TF_SLOT_COUNT]  = {PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1};
bool            g_TFEnabled[TF_SLOT_COUNT];

int g_FastHandle[TF_SLOT_COUNT];
int g_SlowHandle[TF_SLOT_COUNT];

//--- indices into the arrays above for slots that are both enabled by the
//--- user AND successfully created a valid indicator handle
int g_ActiveSlot[TF_SLOT_COUNT];
int g_ActiveCount = 0;

string g_Prefix = "MTFDash_";
string g_PanelBgName;
string g_TitleName;

//--- one dedicated label object per row (title + one per active timeframe),
//--- each with its own fixed vertical position — never a single multi-line
//--- label, which does not reliably render as separate lines in MT5
#define PANEL_MAX_LINES (TF_SLOT_COUNT + 1)
string g_LineNames[PANEL_MAX_LINES];
int    g_TotalLines  = 0;
int    g_LineHeight  = 0;
int    g_PanelPadTop  = 6;
int    g_PanelPadSide = 8;

datetime g_LastBarTime = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                        |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpFastMAPeriod < 1 || InpSlowMAPeriod < 1)
     {
      Alert("MultiTimeframeTrendDashboard: MA periods must be at least 1.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpFastMAPeriod >= InpSlowMAPeriod)
     {
      Alert("MultiTimeframeTrendDashboard: Fast MA Period must be smaller than Slow MA Period.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   g_TFEnabled[0] = InpShowM15;
   g_TFEnabled[1] = InpShowM30;
   g_TFEnabled[2] = InpShowH1;
   g_TFEnabled[3] = InpShowH4;
   g_TFEnabled[4] = InpShowD1;
   g_TFEnabled[5] = InpShowW1;

   g_ActiveCount = 0;

   for(int i = 0; i < TF_SLOT_COUNT; i++)
     {
      g_FastHandle[i] = INVALID_HANDLE;
      g_SlowHandle[i] = INVALID_HANDLE;

      if(!g_TFEnabled[i])
         continue;

      int fastH = iMA(_Symbol, g_TFValue[i], InpFastMAPeriod, 0, InpMAMethod, InpAppliedPrice);
      int slowH = iMA(_Symbol, g_TFValue[i], InpSlowMAPeriod, 0, InpMAMethod, InpAppliedPrice);

      if(fastH == INVALID_HANDLE || slowH == INVALID_HANDLE)
        {
         //--- this timeframe's handles failed to create (rare, e.g. unsupported
         //--- timeframe on this symbol) — skip it gracefully instead of failing
         //--- the whole indicator
         Print("MultiTimeframeTrendDashboard: could not create MA handle for ", g_TFLabel[i], ", skipping it.");
         continue;
        }

      g_FastHandle[i] = fastH;
      g_SlowHandle[i] = slowH;
      g_ActiveSlot[g_ActiveCount] = i;
      g_ActiveCount++;
     }

   g_TotalLines = 1 + g_ActiveCount; // title row + one row per active timeframe
   g_LineHeight = InpFontSize + 8;

   g_PanelBgName = g_Prefix + "PanelBG";
   g_TitleName   = g_Prefix + "Title";

   for(int i = 0; i < PANEL_MAX_LINES; i++)
      g_LineNames[i] = g_Prefix + "Row" + IntegerToString(i);

   IndicatorSetString(INDICATOR_SHORTNAME, "Multi-Timeframe Trend Dashboard");

   CreatePanel();
   g_LastBarTime = 0; // forces a full refresh on the very first OnCalculate call

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- release every indicator handle this instance created, so the terminal
//--- can free the underlying calculation buffers
   for(int i = 0; i < TF_SLOT_COUNT; i++)
     {
      if(g_FastHandle[i] != INVALID_HANDLE)
         IndicatorRelease(g_FastHandle[i]);
      if(g_SlowHandle[i] != INVALID_HANDLE)
         IndicatorRelease(g_SlowHandle[i]);
     }

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
   if(rates_total < 1)
      return(0);

//--- the dashboard reads a handful of higher-timeframe indicator handles, not
//--- the current chart's own history, so its cost per refresh is small and
//--- constant either way; InpUpdateOnNewBarOnly simply throttles how often
//--- that refresh runs
   bool shouldUpdate = true;

   if(InpUpdateOnNewBarOnly)
     {
      datetime currentBarTime = time[rates_total - 1];
      shouldUpdate = (prev_calculated == 0 || currentBarTime != g_LastBarTime);
      g_LastBarTime = currentBarTime;
     }

   if(shouldUpdate)
      UpdatePanel();

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Creates the background rectangle, the title row, and one row per |
//| active timeframe — all as separate objects with fixed Y offsets  |
//+------------------------------------------------------------------+
void CreatePanel()
  {
   if(ObjectFind(0, g_PanelBgName) < 0)
     {
      ObjectCreate(0, g_PanelBgName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_CORNER, InpPanelCorner);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_XDISTANCE, InpPanelXDistance - g_PanelPadSide);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_YDISTANCE, InpPanelYDistance - g_PanelPadTop);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_XSIZE, 200);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_YSIZE, g_TotalLines * g_LineHeight + g_PanelPadTop * 2);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_BGCOLOR, InpPanelBgColor);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_COLOR, clrDimGray);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_BACK, false);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, g_PanelBgName, OBJPROP_HIDDEN, true);
     }

   for(int i = 0; i < g_TotalLines; i++)
     {
      string lineName = g_LineNames[i];
      int rowY = InpPanelYDistance + i * g_LineHeight;

      if(ObjectFind(0, lineName) < 0)
         ObjectCreate(0, lineName, OBJ_LABEL, 0, 0, 0);

      ObjectSetInteger(0, lineName, OBJPROP_CORNER, InpPanelCorner);
      ObjectSetInteger(0, lineName, OBJPROP_XDISTANCE, InpPanelXDistance);
      ObjectSetInteger(0, lineName, OBJPROP_YDISTANCE, rowY);
      ObjectSetInteger(0, lineName, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetString(0, lineName, OBJPROP_FONT, (i == 0) ? "Consolas Bold" : "Consolas");
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, (i == 0) ? InpPanelTextColor : InpNeutralColor);
      ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, lineName, OBJPROP_HIDDEN, true);
      ObjectSetString(0, lineName, OBJPROP_TEXT, (i == 0) ? "MTF TREND DASHBOARD" : "");
     }
  }

//+------------------------------------------------------------------+
//| Rough monospace-font width estimate, in pixels, for a given text |
//+------------------------------------------------------------------+
int EstimateTextWidthPx(const string text)
  {
   return (int)MathRound(StringLen(text) * (InpFontSize * 0.62));
  }

//+------------------------------------------------------------------+
//| Reads the latest Fast/Slow MA values for every active timeframe  |
//| and refreshes each panel row accordingly                         |
//+------------------------------------------------------------------+
void UpdatePanel()
  {
   int maxWidthPx = EstimateTextWidthPx("MTF TREND DASHBOARD");

   for(int a = 0; a < g_ActiveCount; a++)
     {
      int slot = g_ActiveSlot[a];
      string rowName = g_LineNames[a + 1]; // row 0 is the title

      double fastBuf[];
      double slowBuf[];
      ArraySetAsSeries(fastBuf, true);
      ArraySetAsSeries(slowBuf, true);

      bool ready = (CopyBuffer(g_FastHandle[slot], 0, 0, 1, fastBuf) > 0) &&
                   (CopyBuffer(g_SlowHandle[slot], 0, 0, 1, slowBuf) > 0);

      string rowText;
      color  rowColor;

      if(!ready)
        {
         rowText  = StringFormat("%-4s N/A", g_TFLabel[slot]);
         rowColor = InpNeutralColor;
        }
      else
        {
         double fastVal = fastBuf[0];
         double slowVal = slowBuf[0];
         string trendWord;

         if(fastVal > slowVal)
           {
            trendWord = "BULLISH";
            rowColor  = InpBullColor;
           }
         else
            if(fastVal < slowVal)
              {
               trendWord = "BEARISH";
               rowColor  = InpBearColor;
              }
            else
              {
               trendWord = "NEUTRAL";
               rowColor  = InpNeutralColor;
              }

         rowText = StringFormat("%-4s %s", g_TFLabel[slot], trendWord);

         if(InpShowMAValues)
            rowText += StringFormat("  F:%s S:%s",
                                     DoubleToString(fastVal, _Digits),
                                     DoubleToString(slowVal, _Digits));
        }

      ObjectSetString(0, rowName, OBJPROP_TEXT, rowText);
      ObjectSetInteger(0, rowName, OBJPROP_COLOR, rowColor);

      int w = EstimateTextWidthPx(rowText);
      if(w > maxWidthPx)
         maxWidthPx = w;
     }

//--- resize the panel to comfortably fit the widest current row, so it
//--- never clips regardless of symbol digits, MA values, or timeframe mix
   int panelWidth  = MathMax(140, maxWidthPx + g_PanelPadSide * 2);
   int panelHeight = g_TotalLines * g_LineHeight + g_PanelPadTop * 2;

   ObjectSetInteger(0, g_PanelBgName, OBJPROP_XSIZE, panelWidth);
   ObjectSetInteger(0, g_PanelBgName, OBJPROP_YSIZE, panelHeight);

   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
