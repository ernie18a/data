//+------------------------------------------------------------------+
//|                                                 RiskLotPanel.mq5 |
//|                        Copyright 2026, Lee De Tai (LeeLabs)      |
//|                     https://www.mql5.com/en/users/leelabs        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Lee De Tai (LeeLabs)"
#property link      "https://www.mql5.com/en/users/leelabs"
#property version   "1.00"
#property description "On-chart panel: position size for a fixed risk, and what the broker's"
#property description "volume constraints do to it. Shows the raw lot, the lot after rounding"
#property description "down to the volume step, and the money you actually risk with that lot."
#property description "Warns when the risk cannot be respected: the raw lot is below the broker"
#property description "minimum, or the minimum lot risks more than you asked for."
#property description "Display only - it never places, modifies or closes an order."
#property indicator_chart_window
#property indicator_plots 0

//--- how the risk is expressed
enum ENUM_RISK_MODE
  {
   RISK_PERCENT_BALANCE,   // percent of balance
   RISK_PERCENT_EQUITY,    // percent of equity
   RISK_MONEY              // fixed amount in account currency
  };

input group                "Risk"
input ENUM_RISK_MODE InpRiskMode      = RISK_PERCENT_BALANCE; // Risk mode
input double         InpRiskValue     = 1.0;                  // Risk (percent, or amount if mode is fixed)
input int            InpStopPoints    = 200;                  // Stop loss distance (points)
input group                "Panel"
input ENUM_BASE_CORNER InpCorner      = CORNER_LEFT_UPPER;    // Anchor corner
input int            InpX             = 12;                   // X distance (px)
input int            InpY             = 22;                   // Y distance (px)
input int            InpFontSize      = 9;                    // Font size
input string         InpFont          = "Consolas";           // Font
input color          InpColorText     = clrGainsboro;         // Normal text
input color          InpColorWarn     = clrGold;              // Warning text
input color          InpColorBad      = clrTomato;            // Blocking problem

#define PANEL_PREFIX "RiskLotPanel_"
#define PANEL_LINES  9

//+------------------------------------------------------------------+
//| Create (once) the labels the panel is made of                    |
//+------------------------------------------------------------------+
void PanelCreate(void)
  {
   for(int i = 0; i < PANEL_LINES; i++)
     {
      string name = PANEL_PREFIX + IntegerToString(i);
      if(ObjectFind(0, name) < 0)
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, InpCorner);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, InpX);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, InpY + i * (InpFontSize * 2));
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetInteger(0, name, OBJPROP_COLOR, InpColorText);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetString(0, name, OBJPROP_FONT, InpFont);
      ObjectSetString(0, name, OBJPROP_TEXT, "");
     }
  }

//+------------------------------------------------------------------+
//| Write one line of the panel                                      |
//+------------------------------------------------------------------+
void PanelSet(const int line, const string text, const color clr)
  {
   if(line < 0 || line >= PANEL_LINES)
      return;
   string name = PANEL_PREFIX + IntegerToString(line);
   // an empty string makes the terminal draw the object's default caption, so blank lines are a space
   ObjectSetString(0, name, OBJPROP_TEXT, (StringLen(text) > 0) ? text : " ");
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//| Money lost per 1.00 lot when price moves one point against you.  |
//| Returns 0 when the broker does not supply the tick data.         |
//+------------------------------------------------------------------+
double MoneyPerPointPerLot(const string symbol)
  {
   double tick_size  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   if(tick_value <= 0.0)                                   // some brokers fill only the generic field
      tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(tick_size <= 0.0 || tick_value <= 0.0 || point <= 0.0)
      return(0.0);
   return(tick_value * point / tick_size);
  }

//+------------------------------------------------------------------+
//| Round a volume DOWN to the broker's volume step                  |
//+------------------------------------------------------------------+
double VolumeFloorToStep(const string symbol, const double volume)
  {
   double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   if(step <= 0.0)
      return(volume);
   double steps = MathFloor(volume / step + 1e-8);
   return(NormalizeDouble(steps * step, 8));
  }

//+------------------------------------------------------------------+
//| Digits needed to print a volume without losing the step          |
//+------------------------------------------------------------------+
int VolumeDigits(const string symbol)
  {
   double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   if(step <= 0.0)
      return(2);
   int digits = 0;
   while(digits < 8 && MathAbs(step * MathPow(10, digits) - MathRound(step * MathPow(10, digits))) > 1e-9)
      digits++;
   return(digits);
  }

//+------------------------------------------------------------------+
//| Risk budget in account currency                                  |
//+------------------------------------------------------------------+
double RiskMoney(void)
  {
   if(InpRiskMode == RISK_MONEY)
      return(InpRiskValue);
   double base = (InpRiskMode == RISK_PERCENT_EQUITY)
                 ? AccountInfoDouble(ACCOUNT_EQUITY)
                 : AccountInfoDouble(ACCOUNT_BALANCE);
   return(base * InpRiskValue / 100.0);
  }

//+------------------------------------------------------------------+
//| Rebuild the whole panel from current market / account state      |
//+------------------------------------------------------------------+
void PanelRefresh(void)
  {
   string   symbol   = _Symbol;
   string   currency = AccountInfoString(ACCOUNT_CURRENCY);
   double   point    = SymbolInfoDouble(symbol, SYMBOL_POINT);
   double   vol_min  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double   vol_max  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double   vol_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   long     spread   = SymbolInfoInteger(symbol, SYMBOL_SPREAD);
   int      vdigits  = VolumeDigits(symbol);
   double   per_point = MoneyPerPointPerLot(symbol);

   PanelSet(0, StringFormat("%s   %d digits   point %s", symbol, _Digits,
                            DoubleToString(point, _Digits)), InpColorText);

   if(per_point <= 0.0)
     {
      PanelSet(1, "Broker did not supply tick value / tick size for this symbol.", InpColorBad);
      PanelSet(2, "Open the symbol in Market Watch and try again.", InpColorBad);
      for(int i = 3; i < PANEL_LINES; i++)
         PanelSet(i, "", InpColorText);
      ChartRedraw();
      return;
     }

   double risk_money = RiskMoney();
   double loss_per_lot = InpStopPoints * per_point;         // money lost per 1.00 lot at the stop
   double raw_lot = (loss_per_lot > 0.0) ? risk_money / loss_per_lot : 0.0;
   double lot = VolumeFloorToStep(symbol, raw_lot);
   if(lot > vol_max)
      lot = VolumeFloorToStep(symbol, vol_max);

   PanelSet(1, StringFormat("spread %d points = %s %s per 1.00 lot",
                            (int)spread, DoubleToString(spread * per_point, 2), currency), InpColorText);
   PanelSet(2, StringFormat("1 point per 1.00 lot = %s %s", DoubleToString(per_point, 5), currency), InpColorText);
   PanelSet(3, StringFormat("volume  min %s   step %s   max %s",
                            DoubleToString(vol_min, vdigits), DoubleToString(vol_step, vdigits),
                            DoubleToString(vol_max, vdigits)), InpColorText);

   string risk_src = (InpRiskMode == RISK_MONEY) ? "fixed"
                     : StringFormat("%s%% of %s", DoubleToString(InpRiskValue, 2),
                                    (InpRiskMode == RISK_PERCENT_EQUITY) ? "equity" : "balance");
   PanelSet(4, StringFormat("risk  %s %s  (%s)", DoubleToString(risk_money, 2), currency, risk_src), InpColorText);
   PanelSet(5, StringFormat("stop  %d points = %s %s per 1.00 lot",
                            InpStopPoints, DoubleToString(loss_per_lot, 2), currency), InpColorText);

   if(raw_lot < vol_min)
     {
      // The classic silent failure: rounding up to the minimum lot breaks the risk cap.
      double min_risk = vol_min * loss_per_lot;
      double balance  = AccountInfoDouble(ACCOUNT_BALANCE);
      string pct = (balance > 0.0) ? StringFormat(" (%s%% of balance)", DoubleToString(min_risk / balance * 100.0, 2)) : "";
      PanelSet(6, StringFormat("lot   %s -> below the broker minimum %s",
                               DoubleToString(raw_lot, vdigits + 2), DoubleToString(vol_min, vdigits)), InpColorBad);
      PanelSet(7, StringFormat("minimum lot would risk %s %s%s - widen the stop, lower it,",
                               DoubleToString(min_risk, 2), currency, pct), InpColorBad);
      PanelSet(8, "or skip the trade. Rounding up is not a way to respect the cap.", InpColorBad);
      ChartRedraw();
      return;
     }

   double real_risk = lot * loss_per_lot;
   PanelSet(6, StringFormat("lot   %s  (raw %s, rounded down to the step)",
                            DoubleToString(lot, vdigits), DoubleToString(raw_lot, vdigits + 2)), InpColorText);

   color risk_color = (MathAbs(real_risk - risk_money) > risk_money * 0.10) ? InpColorWarn : InpColorText;
   PanelSet(7, StringFormat("actual risk with that lot: %s %s of the %s asked for",
                            DoubleToString(real_risk, 2), currency, DoubleToString(risk_money, 2)), risk_color);

   PanelSet(8, "", InpColorText);        // line 8 is only used by the below-minimum warning

   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   if(InpStopPoints <= 0)
     {
      Print("RiskLotPanel: stop loss distance must be greater than zero.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpRiskValue <= 0.0)
     {
      Print("RiskLotPanel: risk must be greater than zero.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   IndicatorSetString(INDICATOR_SHORTNAME, "RiskLotPanel");
   PanelCreate();
   PanelRefresh();
   EventSetTimer(1);            // account values change without ticks (deposits, other trades)
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, PANEL_PREFIX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Timer: keep the panel in step with the account, not just ticks   |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   PanelRefresh();
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   PanelRefresh();
   return(rates_total);
  }
//+------------------------------------------------------------------+
