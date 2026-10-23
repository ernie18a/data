//+------------------------------------------------------------------+
//| Prop Firm Risk Calculator                                        |
//| Position size and loss-limit planner for funded accounts.        |
//| Calculator only: no signals, no orders, no profit claims.        |
//+------------------------------------------------------------------+
#property version   "1.00"
#property description "Position size and loss-limit planner for funded / prop firm accounts."
#property description "Calculator only: it draws on the chart, gives no signals and places no orders."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

enum ENUM_STOP_MODE
{
   STOP_MANUAL = 0,  // Manual (price units)
   STOP_ATR    = 1   // ATR based
};

enum ENUM_BAL_MODE
{
   BAL_INPUT   = 0,  // Use the account size below
   BAL_ACCOUNT = 1   // Use the current account balance
};

input group "Account"
input ENUM_BAL_MODE BalanceSource    = BAL_INPUT;  // Account size source
input double        AccountSize      = 100000.0;   // Account size (if source is input)
input double        RiskPercent      = 0.5;        // Risk per trade (%)
input double        DailyLossPercent = 5.0;        // Daily loss limit (%)
input double        MaxLossPercent   = 10.0;       // Max total loss limit (%)

input group "Stop distance"
input ENUM_STOP_MODE StopMode        = STOP_MANUAL; // Stop distance mode
input double         ManualStopPrice = 10.0;        // Manual stop distance (price units)
input int            ATRPeriod       = 14;          // ATR period (ATR mode)
input double         ATRMultiplier   = 1.5;         // ATR multiplier (ATR mode)

input group "Display"
input ENUM_BASE_CORNER Corner        = CORNER_RIGHT_LOWER; // Panel corner
input int              FontSize      = 9;                  // Font size
input color            TextColor     = clrGray;            // Text color

int    g_atrHandle = INVALID_HANDLE;
string g_prefix    = "PFRC_";

//+------------------------------------------------------------------+
int LotDigits(const double step)
{
   int d = 0;
   double s = step;
   while(d < 8 && MathAbs(s - MathRound(s)) > 1e-9)
   {
      s *= 10.0;
      d++;
   }
   return(d);
}

//+------------------------------------------------------------------+
void SetRow(const int index, const int total, const string text, const color clr)
{
   string name = g_prefix + IntegerToString(index);
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   }

   bool lower = (Corner == CORNER_LEFT_LOWER || Corner == CORNER_RIGHT_LOWER);
   bool right = (Corner == CORNER_RIGHT_UPPER || Corner == CORNER_RIGHT_LOWER);
   int lineH = FontSize + 8;
   int baseY = lower ? 35 : 10;
   int y = baseY + (lower ? (total - 1 - index) : index) * lineH;

   ENUM_ANCHOR_POINT anchor;
   if(right)
      anchor = lower ? ANCHOR_RIGHT_LOWER : ANCHOR_RIGHT_UPPER;
   else
      anchor = lower ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER;

   ObjectSetInteger(0, name, OBJPROP_CORNER, Corner);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
}

//+------------------------------------------------------------------+
void Update()
{
   string cur = AccountInfoString(ACCOUNT_CURRENCY);
   double balance = (BalanceSource == BAL_ACCOUNT) ? AccountInfoDouble(ACCOUNT_BALANCE) : AccountSize;

   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   if(tickValue <= 0.0)
      tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double valuePerUnit = (tickSize > 0.0) ? tickValue / tickSize : 0.0;

   double stopDist = 0.0;
   bool stopOk = true;
   if(StopMode == STOP_MANUAL)
      stopDist = ManualStopPrice;
   else
   {
      double atr[];
      ArraySetAsSeries(atr, true);
      if(CopyBuffer(g_atrHandle, 0, 1, 1, atr) == 1 && atr[0] > 0.0)
         stopDist = atr[0] * ATRMultiplier;
      else
         stopOk = false;
   }

   double riskAmt  = balance * RiskPercent / 100.0;
   double dailyAmt = balance * DailyLossPercent / 100.0;
   double maxAmt   = balance * MaxLossPercent / 100.0;

   string lotText;
   color  lotClr = clrLimeGreen;
   if(!stopOk || valuePerUnit <= 0.0 || stopDist <= 0.0)
   {
      lotText = "n/a (no data yet)";
      lotClr  = clrOrange;
   }
   else
   {
      double step   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      double raw    = riskAmt / (stopDist * valuePerUnit);
      double lots   = (step > 0.0) ? MathFloor(raw / step + 1e-9) * step : raw;
      if(lots > maxLot)
         lots = maxLot;
      int dg = LotDigits(step);
      if(lots < minLot)
      {
         lotText = "stop too wide (min lot " + DoubleToString(minLot, dg) + ")";
         lotClr  = clrRed;
      }
      else
         lotText = DoubleToString(lots, dg) + " lots";
   }

   long lossesDaily = (riskAmt > 0.0) ? (long)MathFloor(dailyAmt / riskAmt + 1e-9) : 0;
   long lossesMax   = (riskAmt > 0.0) ? (long)MathFloor(maxAmt / riskAmt + 1e-9) : 0;
   color dailyClr   = (lossesDaily < 3) ? clrOrange : TextColor;

   int total = 9;
   SetRow(0, total, "Prop Firm Risk Calculator", TextColor);
   SetRow(1, total, "Risk per trade: " + DoubleToString(riskAmt, 2) + " " + cur + " (" + DoubleToString(RiskPercent, 2) + "%)", TextColor);
   SetRow(2, total, "Stop distance: " + DoubleToString(stopDist, _Digits) + " price units", TextColor);
   SetRow(3, total, "Position size: " + lotText, lotClr);
   SetRow(4, total, "Daily loss limit: " + DoubleToString(dailyAmt, 2) + " " + cur, TextColor);
   SetRow(5, total, "Max loss limit: " + DoubleToString(maxAmt, 2) + " " + cur, TextColor);
   SetRow(6, total, "Losses to daily limit: " + IntegerToString((int)lossesDaily), dailyClr);
   SetRow(7, total, "Losses to max limit: " + IntegerToString((int)lossesMax), TextColor);
   SetRow(8, total, "Value of 1 price unit, 1 lot: " + DoubleToString(valuePerUnit, 2) + " " + cur, TextColor);
   ChartRedraw();
}

//+------------------------------------------------------------------+
int OnInit()
{
   if(RiskPercent <= 0.0 || RiskPercent > 100.0)
   {
      Print("Risk per trade must be between 0 and 100 percent.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(DailyLossPercent <= 0.0 || MaxLossPercent <= 0.0)
   {
      Print("Loss limits must be greater than zero.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(BalanceSource == BAL_INPUT && AccountSize <= 0.0)
   {
      Print("Account size must be greater than zero.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(StopMode == STOP_MANUAL && ManualStopPrice <= 0.0)
   {
      Print("Manual stop distance must be greater than zero.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(StopMode == STOP_ATR)
   {
      if(ATRPeriod < 1 || ATRMultiplier <= 0.0)
      {
         Print("ATR period and multiplier must be positive.");
         return(INIT_PARAMETERS_INCORRECT);
      }
      g_atrHandle = iATR(_Symbol, _Period, ATRPeriod);
      if(g_atrHandle == INVALID_HANDLE)
      {
         Print("Could not create the ATR handle.");
         return(INIT_FAILED);
      }
   }
   IndicatorSetString(INDICATOR_SHORTNAME, "Prop Firm Risk Calculator");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, g_prefix);
   if(g_atrHandle != INVALID_HANDLE)
      IndicatorRelease(g_atrHandle);
   ChartRedraw();
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
   Update();
   return(rates_total);
}
//+------------------------------------------------------------------+
