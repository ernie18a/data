//+------------------------------------------------------------------+
//|                                        MultiSymbolAlertPanel.mq5 |
//|                                    Copyright 2025, Hammad Dilber |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2025, Hammad Dilber"
#property link        "https://www.mql5.com/en/users/homirana"
#property version     "1.00"
#property description "Multi-Symbol High/Low Break Alert Panel"

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- Symbols
input group "=== Symbols ==="
input string InpSymbols = "EURUSD,GBPUSD,USDJPY,USDCHF,AUDUSD,USDCAD,NZDUSD,EURJPY,GBPJPY,EURGBP";

//--- Timeframe enum (D1 and above only)
enum ENUM_TF_SELECT
  {
   TF_D1  = PERIOD_D1,    // D1 - Daily
   TF_W1  = PERIOD_W1,    // W1 - Weekly
   TF_MN1 = PERIOD_MN1    // MN1 - Monthly
  };

input group "=== Timeframe ==="
input ENUM_TF_SELECT InpTimeframe = TF_D1;  // Timeframe

//--- Date filter
input group "=== Date Filter ==="
input bool     InpUseDateFilter = false;             // Enable specific date
input datetime InpDate          = __DATE__;          // Date to show H/L for

//--- Panel settings
input group "=== Panel Settings ==="
input int    InpFontSize  = 9;
input color  InpClrTitle  = clrGold;
input color  InpClrHeader = clrAqua;
input color  InpClrBull   = clrLime;
input color  InpClrBear   = clrTomato;
input color  InpClrWatch  = clrYellow;
input color  InpClrNormal = C'180,210,255';
input color  InpClrDim    = C'100,120,150';
input color  InpClrBG     = C'10,10,18';
input double InpNearPct   = 0.10;

//--- H/L Lines
input group "=== H/L Lines ==="
input bool   InpDrawLines = true;        // Draw High/Low lines on chart
input color  InpClrHLine  = clrLime;     // High line color
input color  InpClrLLine  = clrTomato;   // Low line color
input int    InpLineWidth = 1;           // Line width
input bool   InpLineLabel = true;        // Show price label on line

//--- Alerts
input group "=== Alerts ==="
input bool   InpPopup     = true;
input bool   InpSound     = true;
input string InpSoundFile = "alert.wav";

//+------------------------------------------------------------------+
#define PRE      "MSAP_"
#define MAXS     50
#define W_SYM    10
#define W_BID    11
#define W_HIGH   11
#define W_LOW    11
#define W_STATUS 14
#define W_TOTAL  (W_SYM + W_BID + W_HIGH + W_LOW + W_STATUS)
#define PAD_X    20
#define PAD_Y    50

string   g_sym[];
int      g_cnt = 0;
datetime g_aH[];
datetime g_aL[];

//+------------------------------------------------------------------+
string PadR(string s, int w)
  {
   int len = StringLen(s);
   if(len >= w) return StringSubstr(s, 0, w);
   string out = s;
   for(int i = len; i < w; i++) out += " ";
   return out;
  }

//+------------------------------------------------------------------+
string TFName(ENUM_TF_SELECT tf)
  {
   switch(tf)
     {
      case TF_D1:  return "D1";
      case TF_W1:  return "W1";
      case TF_MN1: return "MN1";
      default:     return "??";
     }
  }

//+------------------------------------------------------------------+
void BuildList()
  {
   g_cnt = 0;
   ArrayResize(g_sym, 0);
   ArrayResize(g_aH,  0);
   ArrayResize(g_aL,  0);

   string raw = InpSymbols;
   StringTrimLeft(raw);
   StringTrimRight(raw);
   if(raw == "") return;

   string parts[];
   int count = StringSplit(raw, ',', parts);

   for(int i = 0; i < count && g_cnt < MAXS; i++)
     {
      string s = parts[i];
      StringTrimLeft(s);
      StringTrimRight(s);
      if(s == "") continue;
      if(!SymbolSelect(s, true)) continue;
      ArrayResize(g_sym, g_cnt + 1);
      ArrayResize(g_aH,  g_cnt + 1);
      ArrayResize(g_aL,  g_cnt + 1);
      g_sym[g_cnt] = s;
      g_aH[g_cnt]  = 0;
      g_aL[g_cnt]  = 0;
      g_cnt++;
     }
  }

//+------------------------------------------------------------------+
// Get H/L for a symbol — uses date filter if enabled
//+------------------------------------------------------------------+
bool GetHL(string sym, double &outH, double &outL)
  {
   if(InpUseDateFilter)
     {
      // Find the bar that matches the selected date
      datetime dayStart = InpDate - (InpDate % 86400);  // normalize to day start
      int shift = iBarShift(sym, (ENUM_TIMEFRAMES)InpTimeframe, dayStart, false);
      if(shift < 0) return false;
      MqlRates rt[];
      if(CopyRates(sym, (ENUM_TIMEFRAMES)InpTimeframe, shift, 1, rt) != 1) return false;
      outH = rt[0].high;
      outL = rt[0].low;
     }
   else
     {
      MqlRates rt[];
      if(CopyRates(sym, (ENUM_TIMEFRAMES)InpTimeframe, 0, 1, rt) != 1) return false;
      outH = rt[0].high;
      outL = rt[0].low;
     }
   return true;
  }

//+------------------------------------------------------------------+
void DrawMainBG(int rows)
  {
   string n = PRE + "MAINBG";
   ObjectDelete(0, n);
   ObjectCreate(0, n, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_CORNER,      CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE,   PAD_X - 10);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE,   PAD_Y - 10);
   ObjectSetInteger(0, n, OBJPROP_XSIZE,       500);
   ObjectSetInteger(0, n, OBJPROP_YSIZE,       (rows + 5) * 18 + 20);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR,     InpClrBG);
   ObjectSetInteger(0, n, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, n, OBJPROP_COLOR,       C'60,60,90');
   ObjectSetInteger(0, n, OBJPROP_WIDTH,       1);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN,      true);
   ObjectSetInteger(0, n, OBJPROP_BACK,        false);
   ObjectSetInteger(0, n, OBJPROP_ZORDER,      0);
  }

//+------------------------------------------------------------------+
void DrawRowBG(string id, int y, int rowH)
  {
   string n = PRE + "RBG" + id;
   ObjectDelete(0, n);
   ObjectCreate(0, n, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_CORNER,      CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE,   PAD_X - 9);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE,   y - 1);
   ObjectSetInteger(0, n, OBJPROP_XSIZE,       498);
   ObjectSetInteger(0, n, OBJPROP_YSIZE,       rowH);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR,     InpClrBG);
   ObjectSetInteger(0, n, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, n, OBJPROP_COLOR,       InpClrBG);
   ObjectSetInteger(0, n, OBJPROP_WIDTH,       0);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN,      true);
   ObjectSetInteger(0, n, OBJPROP_BACK,        false);
   ObjectSetInteger(0, n, OBJPROP_ZORDER,      1);
  }

//+------------------------------------------------------------------+
void Lbl(string id, string txt, int x, int y, color c, int fs = -1)
  {
   string n = PRE + id;
   ObjectDelete(0, n);
   ObjectCreate(0, n, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_BACK,       false);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0, n, OBJPROP_ZORDER,     10);
   ObjectSetString(0,  n, OBJPROP_TEXT,       txt);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE,  x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE,  y);
   ObjectSetInteger(0, n, OBJPROP_COLOR,      c);
   ObjectSetString(0,  n, OBJPROP_FONT,       "Courier New");
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE,   (fs < 0 ? InpFontSize : fs));
  }

//+------------------------------------------------------------------+
void FireAlert(string sym, string dir, double price, double lvl)
  {
   string tfStr = TFName(InpTimeframe);
   string msg   = sym + " [" + tfStr + "] " + dir + " BROKEN! Price=" +
                  DoubleToString(price, 5) + " Level=" + DoubleToString(lvl, 5);
   if(InpPopup) Alert(msg);
   if(InpSound) PlaySound(InpSoundFile);
  }

//+------------------------------------------------------------------+
string MakeDivider()
  {
   string d = "";
   for(int i = 0; i < W_TOTAL; i++) d += "-";
   return d;
  }

//+------------------------------------------------------------------+
void DrawHLine(string objName, double price, color clr, string tooltip)
  {
   if(ObjectFind(0, objName) < 0)
      ObjectCreate(0, objName, OBJ_HLINE, 0, 0, price);
   else
      ObjectSetDouble(0, objName, OBJPROP_PRICE, price);

   ObjectSetInteger(0, objName, OBJPROP_COLOR,      clr);
   ObjectSetInteger(0, objName, OBJPROP_WIDTH,      InpLineWidth);
   ObjectSetInteger(0, objName, OBJPROP_STYLE,      STYLE_DASH);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0, objName, OBJPROP_BACK,       true);
   ObjectSetString(0,  objName, OBJPROP_TOOLTIP,    tooltip);
  }

//+------------------------------------------------------------------+
void DrawTextLabel(string objName, datetime tPos, double price, string txt, color clr)
  {
   if(ObjectFind(0, objName) < 0)
      ObjectCreate(0, objName, OBJ_TEXT, 0, tPos, price);

   ObjectSetInteger(0, objName, OBJPROP_TIME,       tPos);
   ObjectSetDouble(0,  objName, OBJPROP_PRICE,      price);
   ObjectSetString(0,  objName, OBJPROP_TEXT,       txt);
   ObjectSetInteger(0, objName, OBJPROP_COLOR,      clr);
   ObjectSetString(0,  objName, OBJPROP_FONT,       "Courier New");
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE,   InpFontSize);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0, objName, OBJPROP_BACK,       false);
  }

//+------------------------------------------------------------------+
// Draw High/Low lines for current chart symbol
//+------------------------------------------------------------------+
void DrawHLLines()
  {
   if(!InpDrawLines) return;

   string chartSym = Symbol();

   for(int idx = 0; idx < g_cnt; idx++)
     {
      if(g_sym[idx] != chartSym) continue;

      int    symDigs = (int)SymbolInfoInteger(chartSym, SYMBOL_DIGITS);
      double hlHigh  = 0;
      double hlLow   = 0;

      if(!GetHL(chartSym, hlHigh, hlLow)) break;

      string objHigh = PRE + "HL_HIGH";
      string objLow  = PRE + "HL_LOW";

      // Tooltip shows full info, line label shows just "High" / "Low"
      DrawHLine(objHigh, hlHigh, InpClrHLine,
                "High: " + DoubleToString(hlHigh, symDigs));
      DrawHLine(objLow,  hlLow,  InpClrLLine,
                "Low: "  + DoubleToString(hlLow,  symDigs));

      if(InpLineLabel)
        {
         datetime lblTime = iTime(chartSym, PERIOD_CURRENT, 0);
         string   objHLbl = PRE + "HL_HLBL";
         string   objLLbl = PRE + "HL_LLBL";

         // Only "High" / "Low" — no TF prefix, 4 extra spaces for right offset
         DrawTextLabel(objHLbl, lblTime, hlHigh,
                       "     High: " + DoubleToString(hlHigh, symDigs),
                       InpClrHLine);
         DrawTextLabel(objLLbl, lblTime, hlLow,
                       "     Low:  " + DoubleToString(hlLow,  symDigs),
                       InpClrLLine);
        }
      break;
     }
  }

//+------------------------------------------------------------------+
void UpdatePanel()
  {
   int rowH = 18;
   int panY = PAD_Y;
   int panX = PAD_X;
   int row  = 0;

   DrawMainBG(g_cnt);

   string tfStr = TFName(InpTimeframe);

   // Title — show date if filter is on
   string titleExtra = "";
   if(InpUseDateFilter)
      titleExtra = "  [" + TimeToString(InpDate, TIME_DATE) + "]";

   Lbl("TITLE", "=== Multi-Symbol " + tfStr + " H/L Panel" + titleExtra + " ===",
       panX, panY + rowH * row, InpClrTitle, InpFontSize + 1);
   row++;

   string hdr = PadR("SYMBOL",        W_SYM)  +
                PadR("  BID",         W_BID)  +
                PadR(tfStr + " HIGH", W_HIGH) +
                PadR(tfStr + " LOW",  W_LOW)  +
                " STATUS";
   Lbl("HDR", hdr, panX, panY + rowH * row, InpClrHeader);
   row++;

   Lbl("DIV1", MakeDivider(), panX, panY + rowH * row, InpClrDim, InpFontSize - 1);
   row++;

   for(int i = 0; i < g_cnt; i++)
     {
      string sym   = g_sym[i];
      string rowId = IntegerToString(i);
      int    digs  = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
      double bid   = SymbolInfoDouble(sym, SYMBOL_BID);

      DrawRowBG(rowId, panY + rowH * row, rowH);

      double dayHigh = 0;
      double dayLow  = 0;
      bool   dataOk  = GetHL(sym, dayHigh, dayLow);

      if(!dataOk || bid == 0.0)
        {
         Lbl("R" + rowId,
             PadR(sym, W_SYM) + PadR("---", W_BID) +
             PadR("---", W_HIGH) + PadR("---", W_LOW) + "NO DATA",
             panX, panY + rowH * row, InpClrDim);
         row++;
         continue;
        }

      double rng      = dayHigh - dayLow;
      double nearZone = rng * InpNearPct;
      bool   brokeH   = bid > dayHigh;
      bool   brokeL   = bid < dayLow;
      bool   nearH    = (!brokeH && bid >= dayHigh - nearZone);
      bool   nearL    = (!brokeL && bid <= dayLow  + nearZone);

      color  rowClr;
      string status;
      if(brokeH)      { rowClr = InpClrBull;   status = ">> BROKE HIGH"; }
      else if(brokeL) { rowClr = InpClrBear;   status = "<< BROKE LOW";  }
      else if(nearH)  { rowClr = InpClrWatch;  status = "~ NEAR HIGH";   }
      else if(nearL)  { rowClr = InpClrWatch;  status = "~ NEAR LOW";    }
      else            { rowClr = InpClrNormal; status = "watching";       }

      string rowTxt = PadR(sym,                          W_SYM)  +
                      PadR(DoubleToString(bid,     digs), W_BID)  +
                      PadR(DoubleToString(dayHigh, digs), W_HIGH) +
                      PadR(DoubleToString(dayLow,  digs), W_LOW)  +
                      status;

      Lbl("R" + rowId, rowTxt, panX, panY + rowH * row, rowClr);
      row++;

      // Alerts only fire on live (non-date-filter) mode
      if(!InpUseDateFilter)
        {
         datetime barTime = iTime(sym, (ENUM_TIMEFRAMES)InpTimeframe, 0);
         if(brokeH && barTime != g_aH[i]) { g_aH[i] = barTime; FireAlert(sym, "HIGH", bid, dayHigh); }
         if(brokeL && barTime != g_aL[i]) { g_aL[i] = barTime; FireAlert(sym, "LOW",  bid, dayLow);  }
        }
     }

   Lbl("DIV2", MakeDivider(), panX, panY + rowH * row, InpClrDim, InpFontSize - 1);
   row++;
   Lbl("FTR",
       "Symbols: " + IntegerToString(g_cnt) +
       "   TF: "   + tfStr +
       "   Updated: " + TimeToString(TimeCurrent(), TIME_MINUTES | TIME_SECONDS),
       panX, panY + rowH * row, InpClrDim, InpFontSize - 1);

   DrawHLLines();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME,
                      "MultiSymbol Alert Panel [" + TFName(InpTimeframe) + "]");
   BuildList();
   if(g_cnt == 0) { Alert("No valid symbols!"); return INIT_FAILED; }
   EventSetMillisecondTimer(1000);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, PRE);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
void OnTimer() { UpdatePanel(); }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
  {
   UpdatePanel();
   return rates_total;
  }
//+------------------------------------------------------------------+