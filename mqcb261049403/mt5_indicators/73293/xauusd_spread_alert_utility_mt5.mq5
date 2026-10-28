//+------------------------------------------------------------------+
//|                                  XAUUSD Spread Alert Utility MT5 |
//|                               Educational spread monitoring tool |
//|                                   Developer: Mr. Brijesh Jaiswal |
//+------------------------------------------------------------------+
#property copyright "Mr. Brijesh Jaiswal"
#property link      "https://www.mql5.com/en/users/2rockworld/seller"
#property version   "1.00"
#property description "Educational MT5 utility for monitoring XAUUSD spread conditions."
#property description "Displays live spread on the chart and alerts when spread is above a chosen threshold."
#property description "This indicator is informational only. It does not open, close or manage trades."
#property indicator_chart_window
#property indicator_plots 1
#property indicator_buffers 1
#property indicator_label1 "Spread alert status"
#property indicator_type1 DRAW_NONE

enum SPREAD_PANEL_THEME
  {
   THEME_DARK_GOLD = 0,
   THEME_CLEAN_DARK = 1,
   THEME_BLUE_STANDARD = 2
  };

input string             InpPanelTitle        = "XAUUSD SPREAD ALERT"; // Panel title shown on the chart
input ENUM_BASE_CORNER   InpCorner            = CORNER_LEFT_UPPER;     // Panel chart corner
input int                InpX                 = 18;                    // Horizontal panel position in pixels
input int                InpY                 = 28;                    // Vertical panel position in pixels
input SPREAD_PANEL_THEME InpTheme             = THEME_DARK_GOLD;       // Panel color theme
input int                InpRefreshSeconds    = 1;                     // Refresh interval in seconds
input int                InpWarningSpreadPts  = 45;                    // Spread above this level is shown as warning
input int                InpDangerSpreadPts   = 80;                    // Spread above this level is shown as danger
input int                InpAlertCooldownSec  = 60;                    // Minimum seconds between repeated alerts
input bool               InpPopupAlert        = true;                  // Send terminal popup alert
input bool               InpSoundAlert        = false;                 // Play terminal sound alert
input string             InpSoundFile         = "alert.wav";           // Sound file from terminal Sounds folder
input bool               InpPushNotification  = false;                 // Send push notification if terminal is configured
input bool               InpEmailAlert        = false;                 // Send email alert if terminal is configured
input bool               InpShowDeveloperName = true;                  // Show developer name on chart panel
input bool               InpTesterManualMode  = false;                 // In Strategy Tester, use manual spread value for checking alerts
input int                InpTesterSpreadPts   = 100;                   // Manual tester spread value in points

string Prefix = "XSAU_MT5_";

double StatusBuffer[];

datetime LastAlertTime = 0;
int LastAlertLevel = 0;
string LastAlertText = "No alert yet";

color PanelBg;
color PanelBorder;
color HeaderBg;
color TextColor;
color MutedColor;
color AccentColor;
color GoodColor;
color WarnColor;
color BadColor;

int PanelWidth = 390;
int PanelHeight = 246;
int RowHeight = 24;

//+------------------------------------------------------------------+
//| Initialize indicator buffer, theme, chart objects and timer       |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, StatusBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetString(0, PLOT_LABEL, "Spread alert status");

   ApplyTheme();
   BuildPanel();
   UpdatePanel();
   EventSetTimer(MathMax(1, InpRefreshSeconds));
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Stop timer and remove all chart objects created by this indicator |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   DeleteObjects();
  }

//+------------------------------------------------------------------+
//| Keep hidden buffer active and refresh spread status on new ticks  |
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
      StatusBuffer[0] = CurrentSpreadPoints();
      UpdatePanel();
     }

   return rates_total;
  }

//+------------------------------------------------------------------+
//| Refresh panel by timer so spread changes are visible between ticks|
//+------------------------------------------------------------------+
void OnTimer()
  {
   UpdatePanel();
  }

//+------------------------------------------------------------------+
//| Select panel colors according to the chosen visual theme          |
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
//| Create panel background, labels and static chart text             |
//+------------------------------------------------------------------+
void BuildPanel()
  {
   DeleteObjects();

   CreateBox("Panel", InpX, InpY, PanelWidth, PanelHeight, PanelBg, PanelBorder);
   CreateBox("Header", InpX, InpY, PanelWidth, 48, HeaderBg, PanelBorder);

   CreateLabel("Title", InpX + 14, InpY + 9, InpPanelTitle, 12, AccentColor, true);
   CreateLabel("Subtitle", InpX + 14, InpY + 29, "Educational spread monitor for Gold", 8, MutedColor, false);

   int y = InpY + 62;
   for(int i = 0; i < 6; i++)
     {
      CreateLabel("Key" + IntegerToString(i), InpX + 16, y + i * RowHeight, "", 9, MutedColor, false);
      CreateLabel("Value" + IntegerToString(i), InpX + 172, y + i * RowHeight, "", 9, TextColor, true);
     }

   CreateBox("Footer", InpX, InpY + PanelHeight - 44, PanelWidth, 44, C'10,10,10', PanelBorder);
   CreateLabel("Footer1", InpX + 14, InpY + PanelHeight - 34, "Informational utility - no trade execution", 8, AccentColor, true);
   CreateLabel("Footer2", InpX + 14, InpY + PanelHeight - 17, DeveloperText(), 8, MutedColor, false);
  }

//+------------------------------------------------------------------+
//| Read current spread, update labels and send alerts when needed    |
//+------------------------------------------------------------------+
void UpdatePanel()
  {
   int spread_points = CurrentSpreadPoints();
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double spread_price = spread_points * point;

   int status_level = SpreadLevel(spread_points);
   string status_text = "NORMAL";
   color status_color = GoodColor;

   if(status_level == 1)
     {
      status_text = "WARNING";
      status_color = WarnColor;
     }
   else
      if(status_level == 2)
        {
         status_text = "DANGER";
         status_color = BadColor;
        }

   CheckSpreadAlert(spread_points, status_level);

   SetRow(0, "Symbol", SymbolText(), IsGoldSymbol(_Symbol) ? GoodColor : WarnColor);
   SetRow(1, "Live Spread", IntegerToString(spread_points) + " points", status_color);
   SetRow(2, "Spread Price", DoubleToString(spread_price, digits), TextColor);
   SetRow(3, "Status", status_text, status_color);
   SetRow(4, "Thresholds", "Warn " + IntegerToString(InpWarningSpreadPts) + " / Danger " + IntegerToString(InpDangerSpreadPts), MutedColor);
   SetRow(5, "Last Alert", LastAlertText, LastAlertLevel > 0 ? status_color : MutedColor);

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Return the broker-reported spread in points with safe fallback    |
//+------------------------------------------------------------------+
int CurrentSpreadPoints()
  {
   if(IsTesterManualMode())
      return MathMax(0, InpTesterSpreadPts);

   long spread = 0;
   if(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD, spread))
      return (int)MathMax(0, spread);

   MqlTick tick;
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(SymbolInfoTick(_Symbol, tick) && point > 0.0)
      return (int)MathRound((tick.ask - tick.bid) / point);

   return 0;
  }

//+------------------------------------------------------------------+
//| Check whether tester manual spread mode should override live data |
//+------------------------------------------------------------------+
bool IsTesterManualMode()
  {
   return MQLInfoInteger(MQL_TESTER) && InpTesterManualMode;
  }

//+------------------------------------------------------------------+
//| Convert spread value to normal, warning or danger status level    |
//+------------------------------------------------------------------+
int SpreadLevel(const int spread_points)
  {
   if(spread_points >= InpDangerSpreadPts)
      return 2;
   if(spread_points >= InpWarningSpreadPts)
      return 1;
   return 0;
  }

//+------------------------------------------------------------------+
//| Send selected alert types when spread exceeds configured limits   |
//+------------------------------------------------------------------+
void CheckSpreadAlert(const int spread_points, const int status_level)
  {
   if(status_level <= 0)
     {
      LastAlertLevel = 0;
      return;
     }

   datetime now = TimeCurrent();
   bool cooldown_finished = (now - LastAlertTime) >= MathMax(1, InpAlertCooldownSec);
   bool stronger_status = status_level > LastAlertLevel;
   if(!cooldown_finished && !stronger_status)
      return;

   string level_text = status_level == 2 ? "DANGER" : "WARNING";
   string message = _Symbol + " spread " + level_text + ": " + IntegerToString(spread_points) + " points";

   if(InpPopupAlert)
      Alert(message);
   if(InpSoundAlert)
      PlaySound(InpSoundFile);
   if(InpPushNotification)
      SendNotification(message);
   if(InpEmailAlert)
      SendMail("XAUUSD Spread Alert", message);

   LastAlertTime = now;
   LastAlertLevel = status_level;
   LastAlertText = level_text + " at " + IntegerToString(spread_points) + " pts";
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
//| Return symbol guidance text for the panel                         |
//+------------------------------------------------------------------+
string SymbolText()
  {
   if(IsGoldSymbol(_Symbol))
      return _Symbol + " OK";
   return "Use on XAUUSD / Gold";
  }

//+------------------------------------------------------------------+
//| Return developer line according to display setting                |
//+------------------------------------------------------------------+
string DeveloperText()
  {
   if(InpShowDeveloperName)
      return "Developer: Mr. Brijesh Jaiswal";
   return "";
  }

//+------------------------------------------------------------------+
//| Set text and color for one panel row                              |
//+------------------------------------------------------------------+
void SetRow(const int row, const string key, const string value, const color value_color)
  {
   string idx = IntegerToString(row);
   ObjectSetString(0, Prefix + "Key" + idx, OBJPROP_TEXT, key);
   ObjectSetString(0, Prefix + "Value" + idx, OBJPROP_TEXT, value);
   ObjectSetInteger(0, Prefix + "Value" + idx, OBJPROP_COLOR, value_color);
  }

//+------------------------------------------------------------------+
//| Create one rectangle label object                                 |
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
//| Create one chart label object                                     |
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
