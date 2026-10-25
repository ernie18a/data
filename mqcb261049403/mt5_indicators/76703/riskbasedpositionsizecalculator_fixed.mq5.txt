//+------------------------------------------------------------------+
//| RiskBasedPositionSizeCalculator.mq5                              |
//| Draggable broker-aware position size calculator for MT5          |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property version   "1.01"
#property description "Calculates risk-based volume from draggable entry and stop lines."

enum ENUM_CALCULATOR_RISK_MODE
{
   RISK_PERCENT_BALANCE = 0,
   RISK_PERCENT_EQUITY  = 1,
   RISK_FIXED_MONEY     = 2
};

input ENUM_CALCULATOR_RISK_MODE InpRiskMode       = RISK_PERCENT_EQUITY;
input double                    InpRiskValue      = 1.00;   // Percent or account money
input int                       InpInitialSLPoints = 500;    // Initial line distance
input double                    InpRewardRisk     = 2.00;   // Target reward-to-risk
input double                    InpCommissionLot  = 0.00;   // Round-turn commission per lot
input color                     InpEntryColor     = clrDodgerBlue;
input color                     InpStopColor      = clrTomato;
input color                     InpTargetColor    = clrMediumSeaGreen;
input color                     InpPanelColor     = clrWhite;
input ENUM_BASE_CORNER          InpCorner         = CORNER_LEFT_UPPER;
input int                       InpPanelX          = 12;
input int                       InpPanelY          = 24;

string g_prefix;
string g_entry_name;
string g_stop_name;
string g_target_name;
string g_panel_name;

int VolumeDigits(const double step)
{
   for(int digits = 0; digits <= 8; ++digits)
      if(MathAbs(step - NormalizeDouble(step, digits)) < 1e-12)
         return digits;
   return 8;
}

double RiskMoney()
{
   if(InpRiskValue <= 0.0)
      return 0.0;
   if(InpRiskMode == RISK_PERCENT_BALANCE)
      return AccountInfoDouble(ACCOUNT_BALANCE) * InpRiskValue / 100.0;
   if(InpRiskMode == RISK_PERCENT_EQUITY)
      return AccountInfoDouble(ACCOUNT_EQUITY) * InpRiskValue / 100.0;
   return InpRiskValue;
}

bool CreateHLine(const string name, const double price, const color line_color,
                 const ENUM_LINE_STYLE style, const bool selectable)
{
   if(!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price))
      return false;
   ObjectSetInteger(0, name, OBJPROP_COLOR, line_color);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, selectable);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   return true;
}

bool CreatePanel()
{
   if(!ObjectCreate(0, g_panel_name, OBJ_LABEL, 0, 0, 0))
      return false;
   ObjectSetInteger(0, g_panel_name, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(0, g_panel_name, OBJPROP_XDISTANCE, InpPanelX);
   ObjectSetInteger(0, g_panel_name, OBJPROP_YDISTANCE, InpPanelY);
   ObjectSetInteger(0, g_panel_name, OBJPROP_COLOR, InpPanelColor);
   ObjectSetInteger(0, g_panel_name, OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, g_panel_name, OBJPROP_FONT, "Consolas");
   ObjectSetInteger(0, g_panel_name, OBJPROP_SELECTABLE, false);
   return true;
}

double NormalizeVolumeDown(const double raw_volume, bool &below_minimum)
{
   below_minimum = false;
   const double minimum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   const double maximum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   const double step    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(raw_volume <= 0.0 || minimum <= 0.0 || maximum <= 0.0 || step <= 0.0)
      return 0.0;
   if(raw_volume + 1e-12 < minimum)
   {
      below_minimum = true;
      return 0.0;
   }
   double volume = MathFloor((MathMin(raw_volume, maximum) + 1e-12) / step) * step;
   volume = MathMax(minimum, MathMin(volume, maximum));
   return NormalizeDouble(volume, VolumeDigits(step));
}

void UpdateCalculator()
{
   if(ObjectFind(0, g_entry_name) < 0 || ObjectFind(0, g_stop_name) < 0)
      return;

   const double entry      = ObjectGetDouble(0, g_entry_name, OBJPROP_PRICE);
   const double stop       = ObjectGetDouble(0, g_stop_name, OBJPROP_PRICE);
   const double distance   = MathAbs(entry - stop);
   const double tick_size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   const double tick_loss  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   const double risk_money = RiskMoney();
   const int    digits     = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   const double point      = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   const double step       = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   string status = "READY";
   double risk_one_lot = 0.0;
   double raw_volume   = 0.0;
   double volume       = 0.0;
   bool below_minimum  = false;

   if(distance <= 0.0 || tick_size <= 0.0 || tick_loss <= 0.0 || risk_money <= 0.0)
      status = "CHECK SYMBOL DATA / INPUTS";
   else
   {
      risk_one_lot = (distance / tick_size) * tick_loss + MathMax(InpCommissionLot, 0.0);
      if(risk_one_lot > 0.0)
      {
         raw_volume = risk_money / risk_one_lot;
         volume = NormalizeVolumeDown(raw_volume, below_minimum);
         if(below_minimum)
            status = "RISK BELOW BROKER MINIMUM LOT";
      }
   }

   const bool   is_buy = (stop < entry);
   const double target = is_buy ? entry + distance * MathMax(InpRewardRisk, 0.0)
                                : entry - distance * MathMax(InpRewardRisk, 0.0);
   ObjectSetDouble(0, g_target_name, OBJPROP_PRICE, target);

   string direction = is_buy ? "BUY PLAN" : "SELL PLAN";
   string volume_text = (volume > 0.0 ? DoubleToString(volume, VolumeDigits(step)) : "0");
   string text = "RISK POSITION SIZE CALCULATOR\n";
   text += "Symbol: " + _Symbol + "   " + direction + "\n";
   text += "Entry: " + DoubleToString(entry, digits) + "\n";
   text += "Stop:  " + DoubleToString(stop, digits) + "\n";
   text += "Target:" + DoubleToString(target, digits) + "\n";
   text += "Distance: " + DoubleToString(point > 0.0 ? distance / point : 0.0, 1) + " points\n";
   text += "Risk money: " + DoubleToString(risk_money, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY) + "\n";
   text += "Risk per 1 lot: " + DoubleToString(risk_one_lot, 2) + "\n";
   text += "Raw lot: " + DoubleToString(raw_volume, 4) + "\n";
   text += "Broker-safe lot: " + volume_text + "\n";
   text += "Reward/Risk: " + DoubleToString(MathMax(InpRewardRisk, 0.0), 2) + "\n";
   text += "Status: " + status;
   ObjectSetString(0, g_panel_name, OBJPROP_TEXT, text);
   ChartRedraw(0);
}

int OnInit()
{
   if(InpRiskValue <= 0.0 || InpInitialSLPoints <= 0 || InpRewardRisk < 0.0)
      return INIT_PARAMETERS_INCORRECT;

   g_prefix      = "RiskCalc_" + StringFormat("%I64d", ChartID()) + "_";
   g_entry_name  = g_prefix + "Entry";
   g_stop_name   = g_prefix + "Stop";
   g_target_name = g_prefix + "Target";
   g_panel_name  = g_prefix + "Panel";

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return INIT_FAILED;
   const double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point <= 0.0)
      return INIT_FAILED;

   const double entry = tick.bid;
   const double stop  = entry - InpInitialSLPoints * point;
   const double target = entry + InpInitialSLPoints * point * InpRewardRisk;
   if(!CreateHLine(g_entry_name, entry, InpEntryColor, STYLE_SOLID, true) ||
      !CreateHLine(g_stop_name, stop, InpStopColor, STYLE_DASH, true) ||
      !CreateHLine(g_target_name, target, InpTargetColor, STYLE_DOT, false) ||
      !CreatePanel())
      return INIT_FAILED;

   EventSetTimer(1);
   UpdateCalculator();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectsDeleteAll(0, g_prefix);
   ChartRedraw(0);
}

void OnTimer()
{
   UpdateCalculator();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_DRAG && (sparam == g_entry_name || sparam == g_stop_name))
      UpdateCalculator();
}

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
   if(rates_total > 0 && prev_calculated == 0)
      UpdateCalculator();
   return rates_total;
}
