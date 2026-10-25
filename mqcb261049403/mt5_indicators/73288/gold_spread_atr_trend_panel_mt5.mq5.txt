//+------------------------------------------------------------------+
//|                                  Gold Spread ATR Trend Panel MT5 |
//|                                        Educational chart utility |
//|                                          Author: Brijesh Jaiswal |
//+------------------------------------------------------------------+
#property copyright "Brijesh Jaiswal"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Educational XAUUSD chart panel for MetaTrader 5."
#property description "Displays spread, ATR volatility, EMA trend bias, RSI, daily range and session information."
#property description "This is an informational indicator only. It does not open, close or manage trades."
#property indicator_chart_window
#property indicator_plots 1
#property indicator_buffers 1
#property indicator_label1 "Dashboard status"
#property indicator_type1 DRAW_NONE

enum DASHBOARD_THEME
  {
   THEME_DARK_GOLD = 0,
   THEME_CLEAN_DARK = 1,
   THEME_BLUE_STANDARD = 2
  };

input string           InpDashboardTitle   = "GOLD SPREAD ATR TREND PANEL"; // Dashboard title shown in the header
input ENUM_BASE_CORNER InpCorner           = CORNER_LEFT_UPPER;             // Dashboard chart corner
input int              InpX                = 18;                            // Horizontal dashboard position in pixels
input int              InpY                = 28;                            // Vertical dashboard position in pixels
input DASHBOARD_THEME  InpTheme            = THEME_DARK_GOLD;               // Dashboard color theme
input int              InpRefreshSeconds   = 1;                             // Dashboard refresh interval in seconds
input int              InpATRPeriod        = 14;                            // Chart timeframe ATR period for volatility reading
input int              InpFastEMAPeriod    = 20;                            // Chart timeframe fast EMA period for trend bias
input int              InpSlowEMAPeriod    = 50;                            // Chart timeframe slow EMA period for trend bias
input int              InpTrendEMAPeriod   = 200;                           // Chart timeframe EMA period for major trend filter
input int              InpRSIPeriod        = 14;                            // Chart timeframe RSI period for market condition
input double           InpLowATRPoints     = 120.0;                         // ATR value below this is shown as quiet volatility
input double           InpHighATRPoints    = 420.0;                         // ATR value above this is shown as high volatility
input int              InpSpreadWarningPts = 45;                            // Spread warning level in points
input bool             InpShowAccountInfo  = true;                          // Show account type on dashboard

string Prefix = "GSAT_MT5_";

double DashboardBuffer[];

double CachedAtrPoints = 0.0;
double CachedFastEMA = 0.0;
double CachedSlowEMA = 0.0;
double CachedTrendEMA = 0.0;
double CachedRSI = 50.0;
double CachedRangePoints = 0.0;

color PanelBg;
color PanelBorder;
color HeaderBg;
color TextColor;
color MutedColor;
color AccentColor;
color GoodColor;
color WarnColor;
color BadColor;

int PanelWidth = 430;
int RowHeight = 24;
int PanelHeight = 332;

//+------------------------------------------------------------------+
//| Initialize indicator buffers, handles and dashboard objects       |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, DashboardBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetString(0, PLOT_LABEL, "Dashboard status");

   ApplyTheme();

   BuildDashboard();
   UpdateDashboard();
   EventSetTimer(MathMax(1, InpRefreshSeconds));
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Release indicator handles and remove dashboard objects            |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   DeleteObjects();
  }

//+------------------------------------------------------------------+
//| Keep the hidden indicator buffer active for CodeBase validation   |
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
   if(rates_total > 0)
     {
      DashboardBuffer[0] = 0.0;
      CalculateChartMetrics(rates_total, high, low, close);
      UpdateDashboard();
     }

   return rates_total;
  }

//+------------------------------------------------------------------+
//| Refresh dashboard values on timer events                          |
//+------------------------------------------------------------------+
void OnTimer()
  {
   UpdateDashboard();
  }

//+------------------------------------------------------------------+
//| Calculate dashboard metrics from current chart price arrays       |
//+------------------------------------------------------------------+
void CalculateChartMetrics(const int rates_total,
                           const double &high[],
                           const double &low[],
                           const double &close[])
  {
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point <= 0.0)
      point = _Point;

   CachedAtrPoints = CalculateATRPoints(rates_total, high, low, close, point);
   CachedFastEMA = CalculateEMAValue(rates_total, close, InpFastEMAPeriod);
   CachedSlowEMA = CalculateEMAValue(rates_total, close, InpSlowEMAPeriod);
   CachedTrendEMA = CalculateEMAValue(rates_total, close, InpTrendEMAPeriod);
   CachedRSI = CalculateRSIValue(rates_total, close, InpRSIPeriod);

   int last = rates_total - 1;
   CachedRangePoints = 0.0;
   if(last >= 0 && point > 0.0)
      CachedRangePoints = (high[last] - low[last]) / point;
  }

//+------------------------------------------------------------------+
//| Select dashboard colors according to the chosen visual theme      |
//+------------------------------------------------------------------+
void ApplyTheme()
  {
   if(InpTheme == THEME_CLEAN_DARK)
     {
      PanelBg = clrBlack;
      PanelBorder = clrDimGray;
      HeaderBg = clrDarkSlateGray;
      TextColor = clrWhite;
      MutedColor = clrSilver;
      AccentColor = clrLightSteelBlue;
     }
   else
      if(InpTheme == THEME_BLUE_STANDARD)
        {
         PanelBg = clrMidnightBlue;
         PanelBorder = clrSteelBlue;
         HeaderBg = clrNavy;
         TextColor = clrWhite;
         MutedColor = clrLightSteelBlue;
         AccentColor = clrDeepSkyBlue;
        }
      else
        {
         PanelBg = C'16,16,16';
         PanelBorder = C'164,119,32';
         HeaderBg = C'70,47,11';
         TextColor = clrWhite;
         MutedColor = C'190,190,190';
         AccentColor = C'255,190,58';
        }

   GoodColor = C'60,200,120';
   WarnColor = C'255,190,58';
   BadColor = C'235,85,85';
  }

//+------------------------------------------------------------------+
//| Create all dashboard rectangles and labels on the chart           |
//+------------------------------------------------------------------+
void BuildDashboard()
  {
   DeleteObjects();

   CreateBox("Panel", InpX, InpY, PanelWidth, PanelHeight, PanelBg, PanelBorder);
   CreateBox("Header", InpX, InpY, PanelWidth, 48, HeaderBg, PanelBorder);

   CreateLabel("Title", InpX + 14, InpY + 9, InpDashboardTitle, 12, AccentColor, true);
   CreateLabel("Subtitle", InpX + 14, InpY + 29, "Educational XAUUSD Market Utility", 8, MutedColor, false);

   int y = InpY + 62;
   for(int i = 0; i < 9; i++)
     {
      CreateLabel("Key" + IntegerToString(i), InpX + 16, y + i * RowHeight, "", 9, MutedColor, false);
      CreateLabel("Value" + IntegerToString(i), InpX + 184, y + i * RowHeight, "", 9, TextColor, true);
     }

   CreateBox("Footer", InpX, InpY + PanelHeight - 48, PanelWidth, 48, C'10,10,10', PanelBorder);
   CreateLabel("Footer1", InpX + 14, InpY + PanelHeight - 38, "For market observation and learning", 9, AccentColor, true);
   CreateLabel("Footer2", InpX + 14, InpY + PanelHeight - 19, "Informational indicator - no trade execution", 8, MutedColor, false);
  }

//+------------------------------------------------------------------+
//| Read market data and update dashboard rows                        |
//+------------------------------------------------------------------+
void UpdateDashboard()
  {
   double fast = CachedFastEMA;
   double slow = CachedSlowEMA;
   double trend = CachedTrendEMA;
   double rsi = CachedRSI;

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point <= 0.0)
      point = _Point;

   double spreadPts = (ask - bid) / point;
   if(spreadPts <= 0.0)
      spreadPts = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);

   double atrPts = CachedAtrPoints;
   double rangePts = CachedRangePoints;

   string trendText = "MIXED / WAIT";
   color trendColor = WarnColor;
   if(fast > slow && bid > trend)
     {
      trendText = "BULLISH";
      trendColor = GoodColor;
     }
   else
      if(fast < slow && bid < trend)
        {
         trendText = "BEARISH";
         trendColor = BadColor;
        }

   string rsiText = "NEUTRAL " + DoubleToString(rsi, 1);
   color rsiColor = WarnColor;
   if(rsi >= 60.0)
     {
      rsiText = "BULLISH " + DoubleToString(rsi, 1);
      rsiColor = GoodColor;
     }
   else
      if(rsi <= 40.0)
        {
         rsiText = "BEARISH " + DoubleToString(rsi, 1);
         rsiColor = BadColor;
        }

   string spreadText = DoubleToString(spreadPts, 0) + " pts";
   color spreadColor = spreadPts <= InpSpreadWarningPts ? GoodColor : BadColor;

   string atrText = "NORMAL " + DoubleToString(atrPts, 0) + " pts";
   color atrColor = GoodColor;
   if(atrPts < InpLowATRPoints)
     {
      atrText = "LOW " + DoubleToString(atrPts, 0) + " pts";
      atrColor = WarnColor;
     }
   else
      if(atrPts > InpHighATRPoints)
        {
         atrText = "HIGH " + DoubleToString(atrPts, 0) + " pts";
         atrColor = BadColor;
        }

   string goldCheck = IsGoldSymbol(_Symbol) ? "XAUUSD / GOLD" : "Attach to XAUUSD";
   color goldColor = IsGoldSymbol(_Symbol) ? GoodColor : WarnColor;

   SetRow(0, "Symbol", goldCheck, goldColor);
   SetRow(1, "Trend Bias", trendText, trendColor);
   SetRow(2, "RSI Condition", rsiText, rsiColor);
   SetRow(3, "Chart ATR Volatility", atrText, atrColor);
   SetRow(4, "Live Spread", spreadText, spreadColor);
   SetRow(5, "Current Bar Range", DoubleToString(rangePts, 0) + " pts", TextColor);
   SetRow(6, "Session", SessionName(), AccentColor);
   SetRow(7, "Account Type", AccountTypeText(), TextColor);
   SetRow(8, "Dashboard Status", "ACTIVE", GoodColor);

   if(!InpShowAccountInfo)
     {
      SetRow(7, "Account Info", "HIDDEN", MutedColor);
     }

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Calculate a simple ATR value from current chart arrays            |
//+------------------------------------------------------------------+
double CalculateATRPoints(const int rates_total,
                          const double &high[],
                          const double &low[],
                          const double &close[],
                          const double point)
  {
   if(rates_total < 2 || point <= 0.0)
      return 0.0;

   int period = MathMax(1, InpATRPeriod);
   int last = rates_total - 1;
   int first = MathMax(1, last - period + 1);
   double total = 0.0;
   int count = 0;

   //--- average true range is calculated directly to avoid external indicator handles
   for(int i = first; i <= last; i++)
     {
      double high_low = high[i] - low[i];
      double high_close = MathAbs(high[i] - close[i - 1]);
      double low_close = MathAbs(low[i] - close[i - 1]);
      total += MathMax(high_low, MathMax(high_close, low_close));
      count++;
     }

   if(count <= 0)
      return 0.0;
   return (total / count) / point;
  }

//+------------------------------------------------------------------+
//| Calculate the latest EMA value from current chart close prices    |
//+------------------------------------------------------------------+
double CalculateEMAValue(const int rates_total, const double &close[], const int period)
  {
   if(rates_total <= 0)
      return 0.0;

   int safe_period = MathMax(1, period);
   double alpha = 2.0 / (safe_period + 1.0);
   double ema = close[0];

   //--- build EMA from oldest to newest available bar
   for(int i = 1; i < rates_total; i++)
      ema = alpha * close[i] + (1.0 - alpha) * ema;

   return ema;
  }

//+------------------------------------------------------------------+
//| Calculate the latest RSI value from current chart close prices    |
//+------------------------------------------------------------------+
double CalculateRSIValue(const int rates_total, const double &close[], const int period)
  {
   int safe_period = MathMax(1, period);
   if(rates_total <= safe_period)
      return 50.0;

   int last = rates_total - 1;
   int first = MathMax(1, last - safe_period + 1);
   double gain = 0.0;
   double loss = 0.0;

   //--- simple RSI calculation for educational display purposes
   for(int i = first; i <= last; i++)
     {
      double change = close[i] - close[i - 1];
      if(change > 0.0)
         gain += change;
      else
         loss += MathAbs(change);
     }

   if(loss <= 0.0)
      return 100.0;

   double rs = gain / loss;
   return 100.0 - (100.0 / (1.0 + rs));
  }

//+------------------------------------------------------------------+
//| Check whether the current symbol name looks like Gold or XAUUSD   |
//+------------------------------------------------------------------+
bool IsGoldSymbol(const string symbol)
  {
   string upper = symbol;
   StringToUpper(upper);
   return StringFind(upper, "XAU") >= 0 || StringFind(upper, "GOLD") >= 0;
  }

//+------------------------------------------------------------------+
//| Detect whether the account name, server or currency suggests cent |
//+------------------------------------------------------------------+
string AccountTypeText()
  {
   string currency = AccountInfoString(ACCOUNT_CURRENCY);
   string server = AccountInfoString(ACCOUNT_SERVER);
   string name = AccountInfoString(ACCOUNT_NAME);
   string combined = currency + " " + server + " " + name;
   StringToUpper(combined);

   if(StringFind(combined, "CENT") >= 0 || StringFind(combined, "USC") >= 0)
      return "CENT / MICRO";
   return "STANDARD";
  }

//+------------------------------------------------------------------+
//| Return a simple session label based on the server hour            |
//+------------------------------------------------------------------+
string SessionName()
  {
   MqlDateTime tm;
   TimeToStruct(TimeCurrent(), tm);
   int hour = tm.hour;

   if(hour >= 0 && hour < 7)
      return "ASIA";
   if(hour >= 7 && hour < 13)
      return "LONDON OPEN";
   if(hour >= 13 && hour < 17)
      return "LONDON / NY";
   if(hour >= 17 && hour < 22)
      return "NEW YORK";
   return "ROLLOVER";
  }

//+------------------------------------------------------------------+
//| Set text and color for one dashboard row                          |
//+------------------------------------------------------------------+
void SetRow(const int row, const string key, const string value, const color valueColor)
  {
   string idx = IntegerToString(row);
   ObjectSetString(0, Prefix + "Key" + idx, OBJPROP_TEXT, key);
   ObjectSetString(0, Prefix + "Value" + idx, OBJPROP_TEXT, value);
   ObjectSetInteger(0, Prefix + "Value" + idx, OBJPROP_COLOR, valueColor);
  }

//+------------------------------------------------------------------+
//| Create one dashboard rectangle object                             |
//+------------------------------------------------------------------+
void CreateBox(const string suffix,
               const int x,
               const int y,
               const int width,
               const int height,
               const color bg,
               const color border)
  {
   string name = Prefix + suffix;
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_COLOR, border);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| Create one dashboard text label object                            |
//+------------------------------------------------------------------+
void CreateLabel(const string suffix,
                 const int x,
                 const int y,
                 const string text,
                 const int size,
                 const color clr,
                 const bool bold)
  {
   string name = Prefix + suffix;
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetString(0, name, OBJPROP_FONT, bold ? "Arial Bold" : "Arial");
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| Delete all chart objects created by this indicator                |
//+------------------------------------------------------------------+
void DeleteObjects()
  {
   for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, Prefix) == 0)
         ObjectDelete(0, name);
     }
  }
//+------------------------------------------------------------------+
