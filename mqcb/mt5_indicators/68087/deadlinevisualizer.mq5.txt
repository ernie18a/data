//+------------------------------------------------------------------+
//|                                         Dead-Line-Visualizer.mq5 |
//|   PropGuard MT5 – Daily Loss & Max Drawdown Dead-Line Visualizer |
//|                                   Copyright 2025, StratCoreAlpha |
//|                                   https://www.stratcorealpha.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, StratCoreAlpha"
#property link      "https://www.stratcorealpha.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input double   InpDailyMaxDDPercent = 5.0;         // Daily Max Drawdown (%)
input double   InpOverallMaxDDPercent = 10.0;      // Overall Max Drawdown (%)
input bool     InpTrailingDrawdown = true;         // Trailing Drawdown Mode
input double   InpStartCapital = 100000.0;         // Account Start Capital (if trailing OFF)
input bool     InpShowBothLines = false;           // Show Daily & Overall Lines Separately
input int      InpCorner = CORNER_LEFT_UPPER;      // Dashboard Corner
input int      InpDashboardXOffset = 10;           // Dashboard X Offset
input int      InpDashboardYOffset = 10;           // Dashboard Y Offset
input color    InpDeadLineColor = clrRed;          // Dead-Line Color
input color    InpDailyLineColor = clrOrangeRed;   // Daily Line Color (if separate)
input color    InpOverallLineColor = clrMaroon;   // Overall Line Color (if separate)
input int      InpLineWidth = 2;                   // Line Width
input int      InpWarningThresholdPercent = 10;    // Warning Threshold (% of buffer)

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
// Account state
double g_current_balance = 0;
double g_current_equity = 0;
double g_peak_equity_overall = 0;
double g_peak_equity_daily = 0;
double g_start_of_day_balance = 0;
datetime g_current_broker_day = 0;
bool g_has_positions = false;

// Chart objects prefixes
const string PREFIX = "PropGuard_";
const string DEADLINE_EFFECTIVE = PREFIX + "DeadLine_Effective";
const string DEADLINE_DAILY = PREFIX + "DeadLine_Daily";
const string DEADLINE_OVERALL = PREFIX + "DeadLine_Overall";
const string UI_PANEL = PREFIX + "UI_Panel";
const string UI_TEXT_PREFIX = PREFIX + "UI_Text_";

// Last update tracking
datetime g_last_update_time = 0;
int g_last_position_count = -1;

//+------------------------------------------------------------------+
//| OnInit - Indicator initialization                                |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize account data
   g_current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   g_current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   g_peak_equity_overall = g_current_equity;
   g_peak_equity_daily = g_current_equity;
   
   // Determine current broker day
   g_current_broker_day = GetBrokerDayStart(TimeCurrent());
   g_start_of_day_balance = GetStartOfDayBalance();
   
   // Create dashboard
   CreateDashboard();
   
   // Initial update
   UpdateDeadLine();
   
   // Set timer for periodic updates (every 5 seconds)
   EventSetTimer(5);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| OnDeinit - Indicator deinitialization                            |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Kill timer
   EventKillTimer();
   
   // Clean up all chart objects
   ObjectsDeleteAll(0, PREFIX);
}

//+------------------------------------------------------------------+
//| OnCalculate - Main indicator calculation function                |
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
   // Check for new day
   datetime current_day = GetBrokerDayStart(TimeCurrent());
   if(current_day != g_current_broker_day)
   {
      g_current_broker_day = current_day;
      ResetDailyValues();
   }
   
   // Update dead-line calculation for current market state
   UpdateDeadLine();
   g_last_update_time = TimeCurrent();
   
   return(rates_total);
}

//+------------------------------------------------------------------+
//| OnTimer - Timer event handler for periodic updates               |
//+------------------------------------------------------------------+
void OnTimer()
{
   // Force refresh even without new ticks (e.g., position close during low volatility)
   UpdateDeadLine();
   g_last_update_time = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Get broker day start for given time                              |
//+------------------------------------------------------------------+
datetime GetBrokerDayStart(datetime time)
{
   MqlDateTime dt;
   TimeToStruct(time, dt);
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   return StructToTime(dt);
}

//+------------------------------------------------------------------+
//| Get start of day balance                                         |
//+------------------------------------------------------------------+
double GetStartOfDayBalance()
{
   // In a real implementation, this would be retrieved from historical data
   // For now, we use current balance as approximation
   return AccountInfoDouble(ACCOUNT_BALANCE);
}

//+------------------------------------------------------------------+
//| Reset daily values                                               |
//+------------------------------------------------------------------+
void ResetDailyValues()
{
   g_start_of_day_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   g_peak_equity_daily = AccountInfoDouble(ACCOUNT_EQUITY);
   Comment("PropGuard: Daily values reset - New trading day started");
}

//+------------------------------------------------------------------+
//| Get position count for symbol                                    |
//+------------------------------------------------------------------+
int GetPositionCountForSymbol(string symbol)
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetSymbol(i) == symbol)
         count++;
   }
   return count;
}

//+------------------------------------------------------------------+
//| Calculate dead-line price                                        |
//+------------------------------------------------------------------+
void UpdateDeadLine()
{
   // Update account values
   g_current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   g_current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   // Update peak equities if trailing mode
   if(InpTrailingDrawdown)
   {
      if(g_current_equity > g_peak_equity_overall)
         g_peak_equity_overall = g_current_equity;
      if(g_current_equity > g_peak_equity_daily)
         g_peak_equity_daily = g_current_equity;
   }
   
   // Calculate drawdown limits
   double daily_ref_value = InpTrailingDrawdown ? g_peak_equity_daily : g_start_of_day_balance;
   double overall_ref_value = InpTrailingDrawdown ? g_peak_equity_overall : InpStartCapital;
   
   double daily_max_loss = daily_ref_value * (InpDailyMaxDDPercent / 100.0);
   double overall_max_loss = overall_ref_value * (InpOverallMaxDDPercent / 100.0);
   
   double min_equity_daily = daily_ref_value - daily_max_loss;
   double min_equity_overall = overall_ref_value - overall_max_loss;
   
   // Calculate allowed loss until violation
   double allowed_loss_daily = g_current_equity - min_equity_daily;
   double allowed_loss_overall = g_current_equity - min_equity_overall;
   
   // Count positions for this symbol
   int pos_count = GetPositionCountForSymbol(_Symbol);
   g_last_position_count = pos_count;
   
   g_has_positions = (pos_count > 0);
   
   if(!g_has_positions)
   {
      // No positions - hide all lines
      HideAllDeadLines();
      UpdateDashboard(daily_ref_value, overall_ref_value, 
                     min_equity_daily, min_equity_overall,
                     allowed_loss_daily, allowed_loss_overall,
                     0, 0,  // long_lots, short_lots
                     "No Positions", "No Positions",
                     0, "No Positions");  // effective_dead_line, effective_rule
      return;
   }
   
   // Calculate net position and sensitivity
   double total_sensitivity = 0; // d(PnL)/d(Price) in account currency per price unit
   double net_position_lots = 0;
   double total_long_lots = 0;
   double total_short_lots = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetSymbol(i) != _Symbol) continue;
      
      double volume = PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
      
      // Get symbol properties for sensitivity calculation
      double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double point_size = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      
      if(tick_size == 0) tick_size = point_size;
      
      // DEBUG: Print symbol info for first position
      if(i == 0)
      {
         Print("PropGuard Debug - Symbol: ", _Symbol);
         Print("  Tick Value: ", tick_value, " | Tick Size: ", tick_size);
         Print("  Point Size: ", point_size);
         Print("  Volume: ", volume, " | Type: ", EnumToString(type));
      }
      
      // CORRECTED: For MT5, TickValue is the profit for TickSize movement for 1 LOT
      // ContractSize is already accounted for in TickValue
      // Sensitivity = Volume × TickValue / TickSize
      // This is the UNIVERSAL formula that works for ALL assets (Forex, Crypto, Indices, Metals)
      double currency_per_point_per_lot = tick_value / tick_size;
      
      double direction_sign = (type == POSITION_TYPE_BUY) ? 1.0 : -1.0;
      double position_sensitivity = direction_sign * volume * currency_per_point_per_lot;
      
      // DEBUG: Print sensitivity for first position
      if(i == 0)
      {
         Print("  Currency per point per lot: ", currency_per_point_per_lot);
         Print("  Position Sensitivity: ", position_sensitivity);
      }
      
      total_sensitivity += position_sensitivity;
      net_position_lots += direction_sign * volume;
      
      if(type == POSITION_TYPE_BUY)
         total_long_lots += volume;
      else
         total_short_lots += volume;
   }
   
   // Calculate dead-line prices
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   if(current_price == 0)
      current_price = (SymbolInfoDouble(_Symbol, SYMBOL_BID) + SymbolInfoDouble(_Symbol, SYMBOL_ASK)) / 2.0;
   
   // Prevent division by zero
   if(MathAbs(total_sensitivity) < 0.000001)
   {
      // Hedged or near-zero sensitivity
      HideAllDeadLines();
      UpdateDashboard(daily_ref_value, overall_ref_value,
                     min_equity_daily, min_equity_overall,
                     allowed_loss_daily, allowed_loss_overall,
                     total_long_lots, total_short_lots,  // Show actual position sizes
                     "Hedged", "Hedged",
                     0, "Hedged");  // effective_dead_line, effective_rule
      return;
   }
   
   // Calculate price movement needed to violate each rule
   double delta_price_daily = 0;
   double delta_price_overall = 0;
   
   if(allowed_loss_daily <= 0)
      delta_price_daily = 0; // Already violating
   else
      delta_price_daily = allowed_loss_daily / MathAbs(total_sensitivity);
   
   if(allowed_loss_overall <= 0)
      delta_price_overall = 0; // Already violating
   else
      delta_price_overall = allowed_loss_overall / MathAbs(total_sensitivity);
   
   // Determine direction of price movement that causes loss
   double dead_line_price_daily = 0;
   double dead_line_price_overall = 0;
   
   if(total_sensitivity > 0) // Net long - price down causes loss
   {
      dead_line_price_daily = current_price - delta_price_daily;
      dead_line_price_overall = current_price - delta_price_overall;
   }
   else // Net short - price up causes loss
   {
      dead_line_price_daily = current_price + delta_price_daily;
      dead_line_price_overall = current_price + delta_price_overall;
   }
   
   // Check for violations first
   bool daily_violated = (allowed_loss_daily <= 0);
   bool overall_violated = (allowed_loss_overall <= 0);
   bool is_violated = daily_violated || overall_violated;
   
   string status_daily = daily_violated ? "VIOLATED" : DoubleToString(dead_line_price_daily, _Digits);
   string status_overall = overall_violated ? "VIOLATED" : DoubleToString(dead_line_price_overall, _Digits);
   
   // Determine effective dead-line (stricter = closer to current price)
   double effective_dead_line = 0;
   string effective_rule = "";
   
   if(is_violated)
   {
      effective_rule = "VIOLATED";
      effective_dead_line = 0;  // No valid dead-line when violated
   }
   else if(total_sensitivity > 0) // Net long
   {
      effective_dead_line = MathMax(dead_line_price_daily, dead_line_price_overall);
      effective_rule = (effective_dead_line == dead_line_price_daily) ? "DAILY" : "OVERALL";
   }
   else // Net short
   {
      effective_dead_line = MathMin(dead_line_price_daily, dead_line_price_overall);
      effective_rule = (effective_dead_line == dead_line_price_daily) ? "DAILY" : "OVERALL";
   }
   
   // Debug print for verification
   if(g_has_positions && !is_violated)
   {
      Print("PropGuard Debug - Dead-Line Calculation:");
      Print("  Current Price: ", current_price);
      Print("  Daily Dead-Line: ", dead_line_price_daily);
      Print("  Overall Dead-Line: ", dead_line_price_overall);
      Print("  Effective: ", effective_dead_line, " (", effective_rule, ")");
   }
   
   // Draw lines
   DrawDeadLine(DEADLINE_EFFECTIVE, effective_dead_line, InpDeadLineColor, InpLineWidth, 
                "PROP DEAD-LINE (" + effective_rule + ")");
   
   if(InpShowBothLines)
   {
      DrawDeadLine(DEADLINE_DAILY, dead_line_price_daily, InpDailyLineColor, 1, "Daily Limit (" + DoubleToString(dead_line_price_daily, _Digits) + ")");
      DrawDeadLine(DEADLINE_OVERALL, dead_line_price_overall, InpOverallLineColor, 1, "Overall Limit (" + DoubleToString(dead_line_price_overall, _Digits) + ")");
   }
   else
   {
      HideLine(DEADLINE_DAILY);
      HideLine(DEADLINE_OVERALL);
   }
   
   // Update dashboard
   UpdateDashboard(daily_ref_value, overall_ref_value,
                  min_equity_daily, min_equity_overall,
                  allowed_loss_daily, allowed_loss_overall,
                  total_long_lots, total_short_lots,
                  status_daily, status_overall,
                  effective_dead_line, effective_rule);
}

//+------------------------------------------------------------------+
//| Draw dead-line on chart                                          |
//+------------------------------------------------------------------+
void DrawDeadLine(string name, double price, color line_color, int width, string label)
{
   if(price <= 0) 
   {
      HideLine(name);
      return;
   }
   
   // Print debug info
   Print("Drawing dead-line: ", name, " at ", price, " - Label: ", label);
   
   // Create or update horizontal line
   if(ObjectFind(0, name) < 0)
   {
      // Object doesn't exist, create it
      if(!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price))
      {
         Print("Failed to create dead-line object: ", name);
         return;
      }
      Print("Created new dead-line object: ", name);
   }
   else
   {
      // Object exists, just update price
      ObjectMove(0, name, 0, TimeCurrent(), price);
      Print("Updated existing dead-line object: ", name);
   }
   
   ObjectSetInteger(0, name, OBJPROP_COLOR, line_color);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetString(0, name, OBJPROP_TEXT, label);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_BACK, false); // Draw in foreground
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true); // Make selectable
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false); // Make visible in object list
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, true); // Extend to the right
}

//+------------------------------------------------------------------+
//| Hide specific line                                               |
//+------------------------------------------------------------------+
void HideLine(string name)
{
   if(ObjectFind(0, name) >= 0)
   {
      ObjectDelete(0, name);
   }
}

//+------------------------------------------------------------------+
//| Hide all dead-lines                                              |
//+------------------------------------------------------------------+
void HideAllDeadLines()
{
   HideLine(DEADLINE_EFFECTIVE);
   HideLine(DEADLINE_DAILY);
   HideLine(DEADLINE_OVERALL);
}

//+------------------------------------------------------------------+
//| Create dashboard panel                                           |
//+------------------------------------------------------------------+
void CreateDashboard()
{
   int corner = InpCorner;
   int text_size = 8;
   color text_color = clrWhite;
   color bg_color = clrBlack;
   double bg_opacity = 0.7;
   
   // Create background panel - adjust height based on content
   int panel_height = InpTrailingDrawdown ? 470 : 490; // Shorter when trailing ON (no Start Capital line)
   
   ObjectCreate(0, UI_PANEL, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, UI_PANEL, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, UI_PANEL, OBJPROP_XDISTANCE, InpDashboardXOffset);
   ObjectSetInteger(0, UI_PANEL, OBJPROP_YDISTANCE, InpDashboardYOffset);
   ObjectSetInteger(0, UI_PANEL, OBJPROP_XSIZE, 250);
   ObjectSetInteger(0, UI_PANEL, OBJPROP_YSIZE, panel_height);
   ObjectSetInteger(0, UI_PANEL, OBJPROP_COLOR, bg_color);
   ObjectSetInteger(0, UI_PANEL, OBJPROP_BGCOLOR, bg_color);
   ObjectSetInteger(0, UI_PANEL, OBJPROP_BACK, false);
   ObjectSetInteger(0, UI_PANEL, OBJPROP_BORDER_COLOR, clrDimGray);
   ObjectSetInteger(0, UI_PANEL, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, UI_PANEL, OBJPROP_SELECTABLE, true); // Make panel selectable
   ObjectSetInteger(0, UI_PANEL, OBJPROP_HIDDEN, false); // Make visible
   
   // Create text labels
   int y_offset = 25;
   int line_height = 18;
   int x_margin = 15;
   
   // Title
   CreateLabel(UI_TEXT_PREFIX + "Title", x_margin, y_offset, "PropGuard MT5 - Risk Monitor", 
               text_color, text_size + 2, corner);
   y_offset += line_height + 10;
   
   // Inputs section
   CreateLabel(UI_TEXT_PREFIX + "Sec_Inputs", x_margin, y_offset, "=== INPUTS ===", 
               clrSilver, text_size, corner);
   y_offset += line_height;
   
   CreateLabel(UI_TEXT_PREFIX + "DailyDD", x_margin, y_offset, "Daily Max DD: " + DoubleToString(InpDailyMaxDDPercent, 2) + "%", 
               text_color, text_size, corner);
   y_offset += line_height;
   
   CreateLabel(UI_TEXT_PREFIX + "OverallDD", x_margin, y_offset, "Overall Max DD: " + DoubleToString(InpOverallMaxDDPercent, 2) + "%", 
               text_color, text_size, corner);
   y_offset += line_height;
   
   CreateLabel(UI_TEXT_PREFIX + "Trailing", x_margin, y_offset, "Trailing DD: " + (InpTrailingDrawdown ? "ON" : "OFF"), 
               text_color, text_size, corner);
   y_offset += line_height;
   
   if(!InpTrailingDrawdown)
   {
      CreateLabel(UI_TEXT_PREFIX + "StartCap", x_margin, y_offset, "Start Capital: " + DoubleToString(InpStartCapital, 2), 
                  text_color, text_size, corner);
      y_offset += line_height;
   }
   y_offset += 5;
   
   // Account metrics section
   CreateLabel(UI_TEXT_PREFIX + "Sec_Account", x_margin, y_offset, "=== ACCOUNT ===", 
               clrSilver, text_size, corner);
   y_offset += line_height;
   
   CreateLabel(UI_TEXT_PREFIX + "Balance", x_margin, y_offset, "Balance: ", 
               text_color, text_size, corner);
   y_offset += line_height;
   
   CreateLabel(UI_TEXT_PREFIX + "Equity", x_margin, y_offset, "Equity: ", 
               text_color, text_size, corner);
   y_offset += line_height;
   y_offset += 5;
   
   // Limits section
   CreateLabel(UI_TEXT_PREFIX + "Sec_Limits", x_margin, y_offset, "=== LIMITS ===", 
               clrSilver, text_size, corner);
   y_offset += line_height;
   
   CreateLabel(UI_TEXT_PREFIX + "DailyMaxLoss", x_margin, y_offset, "Daily Max Loss: ", 
               text_color, text_size, corner);
   y_offset += line_height;
   
   CreateLabel(UI_TEXT_PREFIX + "DailyMinEquity", x_margin, y_offset, "Daily Min Equity: ", 
               text_color, text_size, corner);
   y_offset += line_height;
   
   CreateLabel(UI_TEXT_PREFIX + "OverallMaxLoss", x_margin, y_offset, "Overall Max Loss: ", 
               text_color, text_size, corner);
   y_offset += line_height;
   
   CreateLabel(UI_TEXT_PREFIX + "OverallMinEquity", x_margin, y_offset, "Overall Min Equity: ", 
               text_color, text_size, corner);
   y_offset += line_height;
   y_offset += 5;
   
   // Positions section
   CreateLabel(UI_TEXT_PREFIX + "Sec_Positions", x_margin, y_offset, "=== POSITIONS ===", 
               clrSilver, text_size, corner);
   y_offset += line_height;
   
   CreateLabel(UI_TEXT_PREFIX + "LongLots", x_margin, y_offset, "Long: ", 
               clrGreen, text_size, corner);
   y_offset += line_height;
   
   CreateLabel(UI_TEXT_PREFIX + "ShortLots", x_margin, y_offset, "Short: ", 
               clrRed, text_size, corner);
   y_offset += line_height;
   y_offset += 5;
   
   // Dead-line section
   CreateLabel(UI_TEXT_PREFIX + "Sec_DeadLine", x_margin, y_offset, "=== DEAD-LINE PRICE ===", 
               clrSilver, text_size, corner);
   y_offset += line_height;
   
   CreateLabel(UI_TEXT_PREFIX + "DailyDeadLine", x_margin, y_offset, "Daily: ", 
               text_color, text_size, corner);
   y_offset += line_height;
   
   CreateLabel(UI_TEXT_PREFIX + "OverallDeadLine", x_margin, y_offset, "Overall: ", 
               text_color, text_size, corner);
   y_offset += line_height;
   
   CreateLabel(UI_TEXT_PREFIX + "EffectiveDeadLine", x_margin, y_offset, "EFFECTIVE: ", 
               clrYellow, text_size + 1, corner);
   y_offset += line_height;
   
   CreateLabel(UI_TEXT_PREFIX + "BufferRemaining", x_margin, y_offset, "Remaining: ", 
               text_color, text_size, corner);
   y_offset += line_height;
   
   // Add instruction for moving panel
   CreateLabel(UI_TEXT_PREFIX + "MoveHint", x_margin, y_offset, "(Set X/Y in Inputs to move)", 
               clrSilver, text_size - 1, corner);
}

//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, color col, int size, int corner)
{
   if(ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
   {
      ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      ObjectSetInteger(0, name, OBJPROP_COLOR, col);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   }
}

//+------------------------------------------------------------------+
//| Update dashboard values                                          |
//+------------------------------------------------------------------+
void UpdateDashboard(double daily_ref_value, double overall_ref_value,
                    double min_equity_daily, double min_equity_overall,
                    double allowed_loss_daily, double allowed_loss_overall,
                    double long_lots, double short_lots,
                    string daily_deadline, string overall_deadline,
                    double effective_dead_line = 0, string effective_rule = "")
{
   // Update dynamic labels
   ObjectSetString(0, UI_TEXT_PREFIX + "Balance", OBJPROP_TEXT, 
                   "Balance: " + DoubleToString(g_current_balance, 2));
   ObjectSetString(0, UI_TEXT_PREFIX + "Equity", OBJPROP_TEXT, 
                   "Equity: " + DoubleToString(g_current_equity, 2));
   
   // Calculate and display max loss and min equity for both daily and overall
   double daily_max_loss = daily_ref_value * (InpDailyMaxDDPercent / 100.0);
   double overall_max_loss = overall_ref_value * (InpOverallMaxDDPercent / 100.0);
   
   ObjectSetString(0, UI_TEXT_PREFIX + "DailyMaxLoss", OBJPROP_TEXT, 
                   "Daily Max Loss: " + DoubleToString(daily_max_loss, 2));
   ObjectSetString(0, UI_TEXT_PREFIX + "DailyMinEquity", OBJPROP_TEXT, 
                   "Daily Min Equity: " + DoubleToString(min_equity_daily, 2));
   ObjectSetString(0, UI_TEXT_PREFIX + "OverallMaxLoss", OBJPROP_TEXT, 
                   "Overall Max Loss: " + DoubleToString(overall_max_loss, 2));
   ObjectSetString(0, UI_TEXT_PREFIX + "OverallMinEquity", OBJPROP_TEXT, 
                   "Overall Min Equity: " + DoubleToString(min_equity_overall, 2));
   
   ObjectSetString(0, UI_TEXT_PREFIX + "LongLots", OBJPROP_TEXT, 
                   "Long: " + DoubleToString(long_lots, 2) + " lots");
   ObjectSetString(0, UI_TEXT_PREFIX + "ShortLots", OBJPROP_TEXT, 
                   "Short: " + DoubleToString(short_lots, 2) + " lots");
   
   // Show absolute price levels for each dead-line
   ObjectSetString(0, UI_TEXT_PREFIX + "DailyDeadLine", OBJPROP_TEXT, 
                   "Daily: " + daily_deadline);
   ObjectSetString(0, UI_TEXT_PREFIX + "OverallDeadLine", OBJPROP_TEXT, 
                   "Overall: " + overall_deadline);
   
   if(effective_rule == "No Positions")
   {
      ObjectSetString(0, UI_TEXT_PREFIX + "EffectiveDeadLine", OBJPROP_TEXT, "EFFECTIVE: No active positions");
      ObjectSetString(0, UI_TEXT_PREFIX + "BufferRemaining", OBJPROP_TEXT, "Remaining: N/A");
   }
   else if(effective_rule == "Hedged")
   {
      ObjectSetString(0, UI_TEXT_PREFIX + "EffectiveDeadLine", OBJPROP_TEXT, "EFFECTIVE: Hedged (No dead-line)");
      ObjectSetString(0, UI_TEXT_PREFIX + "BufferRemaining", OBJPROP_TEXT, "Remaining: N/A");
   }
   else if(effective_rule == "VIOLATED")  
   {
      ObjectSetString(0, UI_TEXT_PREFIX + "EffectiveDeadLine", OBJPROP_TEXT, "EFFECTIVE: VIOLATED!");
      ObjectSetString(0, UI_TEXT_PREFIX + "BufferRemaining", OBJPROP_TEXT, 
                      "Remaining: -" + DoubleToString(MathAbs(MathMin(allowed_loss_daily, allowed_loss_overall)), 2));
      ObjectSetInteger(0, UI_TEXT_PREFIX + "BufferRemaining", OBJPROP_COLOR, clrRed);
   }
   else if(effective_rule != "")  // Check if we have a valid rule (DAILY or OVERALL)
   {
      string effective_text = "EFFECTIVE (" + effective_rule + "): " + DoubleToString(effective_dead_line, _Digits);
      ObjectSetString(0, UI_TEXT_PREFIX + "EffectiveDeadLine", OBJPROP_TEXT, effective_text);
      
      // Calculate buffer - remaining budget in currency and pips
      double current_price = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
      if(current_price == 0)
         current_price = (SymbolInfoDouble(_Symbol, SYMBOL_BID) + SymbolInfoDouble(_Symbol, SYMBOL_ASK)) / 2.0;
      
      double buffer_points = MathAbs(current_price - effective_dead_line) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double buffer_currency = MathMin(allowed_loss_daily, allowed_loss_overall);
      
      ObjectSetString(0, UI_TEXT_PREFIX + "BufferRemaining", OBJPROP_TEXT, 
                      "Remaining: " + DoubleToString(buffer_currency, 2) + " / " + 
                      DoubleToString(buffer_points, 0) + " pts");
      
      // Warning colors
      double max_allowed_loss = MathMax(allowed_loss_daily, allowed_loss_overall);
      if(max_allowed_loss > 0)
      {
         double buffer_percent = (buffer_currency / max_allowed_loss) * 100.0;
         color buffer_color = (buffer_percent <= InpWarningThresholdPercent) ? clrOrange : clrWhite;
         ObjectSetInteger(0, UI_TEXT_PREFIX + "BufferRemaining", OBJPROP_COLOR, buffer_color);
      }
   }
   else
   {
      ObjectSetString(0, UI_TEXT_PREFIX + "EffectiveDeadLine", OBJPROP_TEXT, "EFFECTIVE: Error");
      ObjectSetString(0, UI_TEXT_PREFIX + "BufferRemaining", OBJPROP_TEXT, "Remaining: N/A");
   }
}

//+------------------------------------------------------------------+
