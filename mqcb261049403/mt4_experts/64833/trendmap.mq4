//+------------------------------------------------------------------+
//|                                             Heikin Ashi TrendMap |
//|                            Copyright © 2025 Trade Smart FX Tools |
//|                               https://tradesmartfxtools.in/      |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2025, Trade Smart FX Tools"
#property link      "https://tradesmartfxtools.in/"
#property version   "1.03"
#property strict

#property description "Uses Heiken Ashi candles."
#property description "Buy: Bullish HA candle, no lower wick, body longer than prev. body, prev. candle bullish."
#property description "Sell: Bearish HA candle, no upper wick, body longer than prev. body, prev. candle bearish."
#property description "Exit buy: Bearish HA candle, current candle has no upper wick, previous also bearish."
#property description "Exit sell: Bullish HA candle, current candle has no lower wick, previous also bullish."
#property description "You can choose either direct trading (buy on bullish) or inverted (sell on bullish)."

// Main:
input bool Inverted = true; // Inversion: If true, sells on Bullish signals, buys on Bearish.

// Money management:
input double Lots = 0.1; // Lots: Basic lot size
input bool MM  = false; // MM: If true - ATR-based position sizing
input int ATR_Period = 20;
input double ATR_Multiplier = 1;
input double Risk = 2; // Risk: Risk tolerance in percentage points
input double FixedBalance = 0; // FixedBalance: If >= 0, will use it instead of actual balance.
input double MoneyRisk = 0; // MoneyRisk: Risk tolerance in base currency
input bool UseMoneyInsteadOfPercentage = false;
input bool UseEquityInsteadOfBalance = false;

// Miscellaneous:
input string OrderCommentary = "Trade Smart FX Tools";
input int Slippage = 100;  // Slippage: Tolerated slippage in points
input int Magic = 1520122013;  // Magic: Order magic number

// Global variables:
int LastBars = 0;
bool HaveLongPosition;
bool HaveShortPosition;
double StopLoss; // Not the actual stop-loss - just a potential loss of MM estimation.

 bool  ShowSignature   = true;
 ENUM_BASE_CORNER SigCorner = CORNER_LEFT_LOWER; 
 int   SigX            = 10;  
 int   SigY            = 50; 
 int   SigFontSize     = 18;  
 color SigColor        = clrYellow; 

 bool  SigBg           = false;     
 color SigBgColor      = clrBlack;  
 color SigBorderColor  = clrYellow;  
 int   SigBgWidth      = 310;        
 int   SigBgHeight     = 28;         
 int   SigBgPaddingX   = 8;          
 int   SigBgPaddingY   = 4;         

#define SIG_LABEL "TSFXT_Signature_Label"
#define SIG_BG    "TSFXT_Signature_BG"

// Create/update the signature objects
void EnsureSignature()
{
   if(!ShowSignature)
   {
      ObjectDelete(0, SIG_LABEL);
      ObjectDelete(0, SIG_BG);
      return;
   }

   // Background box (optional)
   if(SigBg)
   {
      if(ObjectFind(0, SIG_BG) != 0)
         ObjectCreate(0, SIG_BG, OBJ_RECTANGLE_LABEL, 0, 0, 0);

      ObjectSetInteger(0, SIG_BG, OBJPROP_CORNER,     SigCorner);
      ObjectSetInteger(0, SIG_BG, OBJPROP_XDISTANCE,  MathMax(0, SigX - SigBgPaddingX));
      ObjectSetInteger(0, SIG_BG, OBJPROP_YDISTANCE,  MathMax(0, SigY - SigBgPaddingY));
      ObjectSetInteger(0, SIG_BG, OBJPROP_BGCOLOR,    SigBgColor);
      ObjectSetInteger(0, SIG_BG, OBJPROP_COLOR,      SigBorderColor);
      ObjectSetInteger(0, SIG_BG, OBJPROP_BACK,       true);
      ObjectSetInteger(0, SIG_BG, OBJPROP_WIDTH,      SigBgWidth);
      ObjectSetInteger(0, SIG_BG, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, SIG_BG, OBJPROP_HIDDEN,     true);
   }
   else
   {
      ObjectDelete(0, SIG_BG);
   }

   // Text label
   if(ObjectFind(0, SIG_LABEL) != 0)
      ObjectCreate(0, SIG_LABEL, OBJ_LABEL, 0, 0, 0);

   ObjectSetInteger(0, SIG_LABEL, OBJPROP_CORNER,     SigCorner);
   ObjectSetInteger(0, SIG_LABEL, OBJPROP_XDISTANCE,  SigX);
   ObjectSetInteger(0, SIG_LABEL, OBJPROP_YDISTANCE,  SigY);
   ObjectSetString (0, SIG_LABEL, OBJPROP_TEXT,       "created by tradesmartfxtools.in");
   ObjectSetInteger(0, SIG_LABEL, OBJPROP_FONTSIZE,   SigFontSize);
   ObjectSetString (0, SIG_LABEL, OBJPROP_FONT,       "Arial");
   ObjectSetInteger(0, SIG_LABEL, OBJPROP_COLOR,      SigColor);
   ObjectSetInteger(0, SIG_LABEL, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, SIG_LABEL, OBJPROP_HIDDEN,     true);
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
     EnsureSignature();  
//---
   return(INIT_SUCCEEDED);
  }

void OnTick()
{
    if ((!IsTradeAllowed()) || (IsTradeContextBusy()) || (!IsConnected()) || ((!MarketInfo(Symbol(), MODE_TRADEALLOWED)) && (!IsTesting()))) return;

    // Trade only if a new bar has arrived.
    if (LastBars != Bars) LastBars = Bars;
    else return;

    if (MM)
    {
        // Getting the potential loss value based on current ATR.
        StopLoss = iATR(NULL, 0, ATR_Period, 1) * ATR_Multiplier;
    }

    // Close conditions.
    bool BearishClose = false;
    bool BullishClose = false;

    // Signals.
    bool Bullish = false;
    bool Bearish = false;

    // Heiken Ashi indicator values.
    double HAOpenLatest, HAOpenPrevious, HACloseLatest, HAClosePrevious, HAHighLatest, HALowLatest;

    HAOpenLatest = iCustom(NULL, 0, "Heiken Ashi", 2, 1);
    HAOpenPrevious = iCustom(NULL, 0, "Heiken Ashi", 2, 2);
    HACloseLatest = iCustom(NULL, 0, "Heiken Ashi", 3, 1);
    HAClosePrevious = iCustom(NULL, 0, "Heiken Ashi", 3, 2);
    if (HAOpenLatest >= HACloseLatest) HAHighLatest = iCustom(NULL, 0, "Heiken Ashi", 0, 1);
    else HAHighLatest = iCustom(NULL, 0, "Heiken Ashi", 1, 1);
    if (HAOpenLatest >= HACloseLatest) HALowLatest = iCustom(NULL, 0, "Heiken Ashi", 1, 1);
    else HALowLatest = iCustom(NULL, 0, "Heiken Ashi", 0, 1);

    // Close signals.
    // Bullish HA candle, current has no lower wick, previous also bullish.
    if ((HAOpenLatest < HACloseLatest) && (HALowLatest == HAOpenLatest) && (HAOpenPrevious < HAClosePrevious))
    {
        if (Inverted) BullishClose = true;
        else BearishClose = true;
    }
    // Bearish HA candle, current has no upper wick, previous also bearish.
    else if ((HAOpenLatest > HACloseLatest) && (HAHighLatest == HAOpenLatest) && (HAOpenPrevious > HAClosePrevious))
    {
        if (Inverted) BearishClose = true;
        else BullishClose = true;
    }

    // First entry condition
    // Bullish HA candle, and body is longer than previous body, previous also bullish, current has no lower wick.
    if ((HAOpenLatest < HACloseLatest) && (HACloseLatest - HAOpenLatest > MathAbs(HAClosePrevious - HAOpenPrevious)) && (HAOpenPrevious < HAClosePrevious) && (HALowLatest == HAOpenLatest))
    {
        if (Inverted)
        {
            Bullish = false;
            Bearish = true;
        }
        else
        {
            Bullish = true;
            Bearish = false;
        }
    }
    // Second entry condition
    // Bearish HA candle, and body is longer than previous body, previous also bearish, current has no upper wick.
    else if ((HAOpenLatest > HACloseLatest) && (HAOpenLatest - HACloseLatest > MathAbs(HAClosePrevious - HAOpenPrevious)) && (HAOpenPrevious > HAClosePrevious) && (HAHighLatest == HAOpenLatest))
    {
        if (Inverted)
        {
            Bullish = true;
            Bearish = false;
        }
        else
        {
            Bullish = false;
            Bearish = true;
        }
    }
    else
    {
        Bullish = false;
        Bearish = false;
    }

    GetPositionStates();

    if ((HaveShortPosition) && (BearishClose)) ClosePrevious();
    if ((HaveLongPosition) && (BullishClose)) ClosePrevious();

    if (Bullish)
    {
        if (!HaveLongPosition) fBuy();
    }
    else if (Bearish)
    {
        if (!HaveShortPosition) fSell();
    }
}

//+------------------------------------------------------------------+
//| Check what position is currently open.                           |
//+------------------------------------------------------------------+
void GetPositionStates()
{
    int total = OrdersTotal();
    for (int cnt = 0; cnt < total; cnt++)
    {
        if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES) == false) continue;
        if (OrderMagicNumber() != Magic) continue;
        if (OrderSymbol() != Symbol()) continue;

        if (OrderType() == OP_BUY)
        {
            HaveLongPosition = true;
            HaveShortPosition = false;
            return;
        }
        else if (OrderType() == OP_SELL)
        {
            HaveLongPosition = false;
            HaveShortPosition = true;
            return;
        }
    }
    HaveLongPosition = false;
    HaveShortPosition = false;
}


void fBuy()
{
   RefreshRates();

   double vol = LotsOptimized();
   string vdesc;

   // Normalize + validate lot size
   vol = NormalizeVolume(vol);
   if(!CheckVolumeValue(vol, vdesc))
   {
      Print("BUY blocked: invalid volume. ", vdesc);
      return;
   }

   // Check if enough margin
   if(!CheckMoneyForTrade(Symbol(), vol, OP_BUY))
   {
      Print("BUY blocked: Not enough free margin.");
      return;
   }

   int result = OrderSend(Symbol(), OP_BUY, vol, Ask, Slippage, 0, 0, OrderCommentary, Magic);
   if(result == -1)
   {
      int e = GetLastError();
      Print("OrderSend BUY Error: ", e, " | Vol=", DoubleToString(vol, 2));
   }
}

void fSell()
{
   RefreshRates();

   double vol = LotsOptimized();
   string vdesc;

   // Normalize + validate lot size
   vol = NormalizeVolume(vol);
   if(!CheckVolumeValue(vol, vdesc))
   {
      Print("SELL blocked: invalid volume. ", vdesc);
      return;
   }

   // Check if enough margin
   if(!CheckMoneyForTrade(Symbol(), vol, OP_SELL))
   {
      Print("SELL blocked: Not enough free margin.");
      return;
   }

   int result = OrderSend(Symbol(), OP_SELL, vol, Bid, Slippage, 0, 0, OrderCommentary, Magic);
   if(result == -1)
   {
      int e = GetLastError();
      Print("OrderSend SELL Error: ", e, " | Vol=", DoubleToString(vol, 2));
   }
}


//+------------------------------------------------------------------+
//| Calculate position size depending on money management parameters.|
//+------------------------------------------------------------------+
double LotsOptimized()
{
    if (!MM) return (Lots);

    double Size, RiskMoney, PositionSize = 0;

    if (AccountCurrency() == "") return(0);

    if (FixedBalance > 0)
    {
        Size = FixedBalance;
    }
    else if (UseEquityInsteadOfBalance)
    {
        Size = AccountEquity();
    }
    else
    {
        Size = AccountBalance();
    }

    if (!UseMoneyInsteadOfPercentage) RiskMoney = Size * Risk / 100;
    else RiskMoney = MoneyRisk;

    double UnitCost = MarketInfo(Symbol(), MODE_TICKVALUE);
    double TickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
    int LotStep_digits = CountDecimalPlaces(MarketInfo(Symbol(), MODE_LOTSTEP));

    if ((StopLoss != 0) && (UnitCost != 0) && (TickSize != 0)) PositionSize = NormalizeDouble(RiskMoney / (StopLoss * UnitCost / TickSize), LotStep_digits);

    if (PositionSize < MarketInfo(Symbol(), MODE_MINLOT)) PositionSize = MarketInfo(Symbol(), MODE_MINLOT);
    else if (PositionSize > MarketInfo(Symbol(), MODE_MAXLOT)) PositionSize = MarketInfo(Symbol(), MODE_MAXLOT);

    return PositionSize;
}

//+------------------------------------------------------------------+
//| Close previous position.                                         |
//+------------------------------------------------------------------+
void ClosePrevious()
{
    int total = OrdersTotal();
    for (int i = 0; i < total; i++)
    {
        if (OrderSelect(i, SELECT_BY_POS) == false) continue;
        if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == Magic))
        {
            if (OrderType() == OP_BUY)
            {
                RefreshRates();
                if (!OrderClose(OrderTicket(), OrderLots(), Bid, Slippage))
                {
                    int e = GetLastError();
                    Print("OrderClose Error: ", e);
                }
            }
            else if (OrderType() == OP_SELL)
            {
                RefreshRates();
                if (!OrderClose(OrderTicket(), OrderLots(), Ask, Slippage))
                {
                    int e = GetLastError();
                    Print("OrderClose Error: ", e);
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Counts decimal places.                                           |
//+------------------------------------------------------------------+
int CountDecimalPlaces(double number)
{
    // 100 as maximum length of number.
    for (int i = 0; i < 100; i++)
    {
        double pwr = MathPow(10, i);
        if (MathRound(number * pwr) / pwr == number) return i;
    }
    return -1;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Normalize volume to broker step & bounds                         |
//+------------------------------------------------------------------+
double NormalizeVolume(double volume)
{
   double min_volume  = MarketInfo(Symbol(), MODE_MINLOT);
   double max_volume  = MarketInfo(Symbol(), MODE_MAXLOT);
   double volume_step = MarketInfo(Symbol(), MODE_LOTSTEP);

   // Clamp to broker bounds first
   volume = MathMax(min_volume, MathMin(max_volume, volume));

   // Snap to nearest step
   int steps = (int)MathRound(volume / volume_step);
   double snapped = steps * volume_step;

   int step_digits = CountDecimalPlaces(volume_step);
   return NormalizeDouble(snapped, step_digits);
}

//+------------------------------------------------------------------+
//| Check the correctness of the order volume (MQL4 version)         |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume, string &description)
{
   double min_volume  = MarketInfo(Symbol(), MODE_MINLOT);
   double max_volume  = MarketInfo(Symbol(), MODE_MAXLOT);
   double volume_step = MarketInfo(Symbol(), MODE_LOTSTEP);

   if(volume < min_volume)
   {
      description = StringFormat("Volume %.2f < min %.2f", volume, min_volume);
      return(false);
   }
   if(volume > max_volume)
   {
      description = StringFormat("Volume %.2f > max %.2f", volume, max_volume);
      return(false);
   }

   // check multiple of step
   int steps = (int)MathRound(volume / volume_step);
   double rebuilt = steps * volume_step;
   if(MathAbs(rebuilt - volume) > 0.0000001)
   {
      description = StringFormat("Volume %.2f not aligned to step %.2f (closest %.2f)",
                                 volume, volume_step, rebuilt);
      return(false);
   }

   description = "Correct volume value";
   return(true);
}

//+------------------------------------------------------------------+
//| Check if there is enough free margin for trade                   |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb, double lots, int type)
{
   double free_margin = AccountFreeMarginCheck(symb, type, lots);

   // If margin is negative, not enough funds
   if(free_margin < 0)
   {
      string oper = (type == OP_BUY) ? "Buy" : "Sell";
      Print("❌ Not enough margin for ", oper, " ", DoubleToString(lots, 2),
            " ", symb, ". Error code=", GetLastError());
      return false;
   }

   // Enough margin
   return true;
}
