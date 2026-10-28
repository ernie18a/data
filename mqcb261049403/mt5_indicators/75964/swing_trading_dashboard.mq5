//+--------------------------------------------------------------------+
//|                                        Swing Trading Dashboard.mq5 |
//|                      Professional Trading Utility for MetaTrader 5 |
//|                                                                    |
//|                                  Copyright (c) 2026 Marian Beceanu |
//|                              https://www.mql5.com/en/users/zorbacc |
//|                          Email: marian.beceanu@gmail.com         | |
//+--------------------------------------------------------------------+
#property copyright "Copyright © 2026 Developer"
#property link      "https://forge.mql5.io"
#property version   "9.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Advanced Swing Trading Strategy Dashboard - Corrected Swing Logic & Arial Bold"

//--- Color Theme Dropdown Enumeration for Background
enum ENUM_BG_COLOR
{
    BG_DARK_BLUE   = C'8,23,38',     // Dark Blue
    BG_DEEP_BLACK  = C'10,10,10',    // Deep Black
    BG_CHARCOAL    = C'30,30,30',    // Charcoal Gray
    BG_NAVY        = C'10,25,47',    // Navy Blue
    BG_SLATE       = C'33,43,54'     // Slate Dark
};

input group "========== SWING SETTINGS =========="
input int                 InpLookbackBars          = 20;     // Lookback Bars (Current Timeframe)
input double              InpZonePercent           = 15.0;   // Boundary Zone Buffer (%)
input int                 InpTimerSeconds          = 1;      // Refresh Timer (Seconds)

input group "========== UI POSITION & SCALING =========="
input bool                InpShowPanel             = true;   // Show Dashboard Panel
input int                 InpPanelX                = 10;     // Offset X from Left (Pixels)
input int                 InpPanelY                = 10;     // Offset Y from Top (Pixels)
input int                 InpBaseFontSize          = 10;     // Base Font Size (Auto-Scales Panel)

input group "========== COLOR CUSTOMIZATION =========="
input ENUM_BG_COLOR       InpColorBackground       = BG_DARK_BLUE; // Background Color Theme
input color               InpColorTitle            = C'0,255,255'; // Title Text Color (Aqua)
input color               InpColorText             = C'245,245,245';// Standard Text Color (White)
input color               InpColorNeutral          = C'255,235,59';// Neutral Status Color (Yellow)
input color               InpColorBorder           = C'62,76,89';  // Panel Border Color

//--- Fixed Palette Constants for Signals
#define Q_GREEN    C'0,200,83'
#define Q_RED      C'255,82,82'
#define Q_ORANGE   C'255,152,0'

//--- Global variable for unique instance prefix and cleanup
string g_prefix = "";

//+------------------------------------------------------------------+
//| Helper: Get Current Timeframe as Clean Text String               |
//+------------------------------------------------------------------+
string GetCurrentTimeframeString()
{
   switch(_Period)
   {
      case PERIOD_M1:  return "M1";
      case PERIOD_M5:  return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H4:  return "H4";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN1";
      default:         return EnumToString(_Period);
   }
}

//+------------------------------------------------------------------+
//| Create Background Rectangle                                      |
//+------------------------------------------------------------------+
void CreateRectangle(string name,int x,int y,int w,int h,color bg,color border)
{
   ObjectDelete(0,name);
   if(ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
   {
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
      ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,border);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER); // Absolute Top-Left Corner
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   }
}

//+------------------------------------------------------------------+
//| Create UI Text Label with Arial Bold Font                        |
//+------------------------------------------------------------------+
void CreateLabel(string name,string text,int x,int y,int fontsize,color clr,bool bold=false)
{
   ObjectDelete(0,name);
   if(ObjectCreate(0,name,OBJ_LABEL,0,0,0))
   {
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetString(0,name,OBJPROP_FONT,"Arial Bold"); // Font Arial Bold
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER); // Absolute Top-Left Corner
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   }
}

//+------------------------------------------------------------------+
//| Thoroughly Delete All Objects Belonging to This Instance         |
//+------------------------------------------------------------------+
void DeletePanel()
{
   for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, -1, -1);
      if(StringFind(name, g_prefix) == 0)
      {
         ObjectDelete(0, name);
      }
   }
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Build Dashboard Panel with Dynamic Auto-Scaling                  |
//+------------------------------------------------------------------+
void BuildPanel()
{
   if(!InpShowPanel) return;
   DeletePanel();
   
   int x = InpPanelX;
   int y = InpPanelY;
   int baseFont = InpBaseFontSize;

   int titleSize  = baseFont + 4;
   int textSize   = baseFont;
   int actionSize = baseFont + 1;
   int footSize   = baseFont - 1;

   int panelWidth  = (int)(baseFont * 36);
   if(panelWidth < 360) panelWidth = 360;
   
   int rowSpacing  = (int)(baseFont * 3.2);
   int panelHeight = (int)(rowSpacing * 6.5);

   color bg_color = (color)InpColorBackground;

   CreateRectangle(g_prefix+"BG", x, y, panelWidth, panelHeight, bg_color, InpColorBorder);

   int currentY = y + 10;
   CreateLabel(g_prefix+"TITLE", "SWING TRADING SYSTEM", x + 14, currentY, titleSize, InpColorTitle, true);
   
   currentY += (int)(titleSize * 1.8);
   string symbolText = "SYMBOL: " + _Symbol + " (" + GetCurrentTimeframeString() + ")";
   CreateLabel(g_prefix+"SYMBOL", symbolText, x + 14, currentY, textSize, InpColorText, true);
   
   currentY += rowSpacing;
   CreateLabel(g_prefix+"HIGH", "RANGE HIGH: 0.00000", x + 14, currentY, textSize, InpColorText);
   
   currentY += rowSpacing;
   CreateLabel(g_prefix+"LOW", "RANGE LOW: 0.00000", x + 14, currentY, textSize, InpColorText);
   
   currentY += rowSpacing;
   CreateLabel(g_prefix+"BREAKSTAT", "STATUS: SCANNING", x + 14, currentY, actionSize, InpColorNeutral, true);
   
   currentY += rowSpacing;
   CreateLabel(g_prefix+"ACTION", "ACTION: WAIT", x + 14, currentY, actionSize, InpColorNeutral, true);
   
   currentY += (int)(rowSpacing * 0.9);
   CreateLabel(g_prefix+"FOOT", "Swing Trading Dashboard MT5", x + 14, currentY, footSize, InpColorTitle);

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Corrected Dynamic Swing Range Calculation & Status Logic         |
//+------------------------------------------------------------------+
void UpdatePanel()
{
   if(!InpShowPanel) return;
   
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   
   // Încercăm să preluăm barele pentru calcul pe timeframe-ul curent
   int total_bars = CopyRates(_Symbol, _Period, 0, InpLookbackBars + 1, rates);
   if(total_bars <= InpLookbackBars) return;

   // Calculăm cel mai înalt High și cel mai jos Low excluzând barax curentă în curs de formare (index 0) sau incluzând-o inteligent
   double highest = rates[1].high;
   double lowest  = rates[1].low;
   
   for(int i = 2; i <= InpLookbackBars; i++)
   {
      if(rates[i].high > highest) highest = rates[i].high;
      if(rates[i].low < lowest)   lowest  = rates[i].low;
   }

   double current_price = rates[0].close;
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   // Calculăm lățimea range-ului și zonele de alertă (suport / rezistență)
   double range_span = highest - lowest;
   if(range_span <= 0) range_span = 0.00001; // Prevenire împotriva împărțirii la zero

   double zone_buffer = range_span * (InpZonePercent / 100.0);
   double resistance_zone = highest - zone_buffer;
   double support_zone = lowest + zone_buffer;

   string stat = "MID-RANGE OSCILLATION";
   color stat_col = InpColorNeutral;
   string rec = "WAIT FOR RANGE BOUNDS";

   // Logica corectată de analiză a prețului în cadrul structurii de swing
   if(current_price > highest)
   {
      stat = "BULLISH BREAKOUT";
      stat_col = Q_GREEN;
      rec = "LOOK FOR CONTINUATION BUY";
   }
   else if(current_price < lowest)
   {
      stat = "BEARISH BREAKDOWN";
      stat_col = Q_RED;
      rec = "LOOK FOR CONTINUATION SELL";
   }
   else if(current_price >= resistance_zone)
   {
      stat = "TESTING RESISTANCE ZONE";
      stat_col = Q_ORANGE;
      rec = "WATCH FOR REJECTION / SELL SETUP";
   }
   else if(current_price <= support_zone)
   {
      stat = "TESTING SUPPORT ZONE";
      stat_col = Q_ORANGE;
      rec = "WATCH FOR BOUNCE / BUY SETUP";
   }

   // Actualizează etichetele grafice pe ecran
   ObjectSetString(0, g_prefix+"HIGH", OBJPROP_TEXT, "RANGE HIGH: " + DoubleToString(highest, digits));
   ObjectSetString(0, g_prefix+"LOW", OBJPROP_TEXT, "RANGE LOW: " + DoubleToString(lowest, digits));
   ObjectSetString(0, g_prefix+"BREAKSTAT", OBJPROP_TEXT, "STATUS: " + stat);
   ObjectSetInteger(0, g_prefix+"BREAKSTAT", OBJPROP_COLOR, stat_col);
   ObjectSetString(0, g_prefix+"ACTION", OBJPROP_TEXT, "ACTION: " + rec);

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Expert Initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   MathSrand((int)GetTickCount());
   int unique_id = MathRand();
   g_prefix = "SWING_DS_" + IntegerToString(ChartID()) + "_" + _Symbol + "_" + EnumToString(_Period) + "_" + IntegerToString(unique_id) + "_";
   
   BuildPanel();
   UpdatePanel();
   EventSetTimer(InpTimerSeconds);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert Deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   DeletePanel(); // Ștergere completă și sigură a tuturor obiectelor
}

//+------------------------------------------------------------------+
//| Expert Tick / Calculation function                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
{
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   UpdatePanel();
}