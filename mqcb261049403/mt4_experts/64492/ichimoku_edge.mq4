//+------------------------------------------------------------------+
//|                                                    Ichimoku Edge |
//|                           Copyright © 2025, Trade Smart FX Tools |
//|                                    https://tradesmartfxtools.in/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2025, Trade Smart FX Tools"
#property link      "https://tradesmartfxtools.in/"
#property version   "1.01"
#property strict

/*

Trades using Ichimoku Kinko Hyo indicator.

Implements Chikou/Price cross strategy.

Chikou crossing price (close) from below is a bullish signal.

Chikou crossing price (close) from above is a bearish signal.

No SL/TP. Positions remain open from signal to signal.

Entry confirmed by current price above/below Kumo, latest Chikou outside Kumo.

*/
// Main input parameters
input int Tenkan = 9; // Tenkan line period. The fast "moving average".
input int Kijun = 26; // Kijun line period. The slow "moving average".
input int Senkou = 52; // Senkou period. Used for Kumo (Cloud) spans.

// Money management
input double Lots = 0.1; 		// Basic lot size
input bool MM  = false;  	// If true - ATR-based position sizing
input int ATR_Period = 20;
input double ATR_Multiplier = 1;
input double Risk = 2; // Risk tolerance in percentage points
input double FixedBalance = 0; // If greater than 0, position size calculator will use it instead of actual account balance.
input double MoneyRisk = 0; // Risk tolerance in base currency
input bool UseMoneyInsteadOfPercentage = false;
input bool UseEquityInsteadOfBalance = false;
input int LotDigits = 2; // How many digits after dot supported in lot size. For example, 2 for 0.01, 1 for 0.1, 3 for 0.001, etc.

// Miscellaneous
 string OrderCommentary = "tradesmartfxtools";
input int Slippage = 100; 	// Tolerated slippage in brokers' pips
input int Magic = 2130512104; 	// Order magic number

// Global variables
// Common
int LastBars = 0;
bool HaveLongPosition;
bool HaveShortPosition;
double StopLoss; // Not actual stop-loss - just a potential loss of MM estimation.

// Entry signals
bool ChikouPriceBull = false;
bool ChikouPriceBear = false;
bool KumoBullConfirmation = false;
bool KumoBearConfirmation = false;
bool KumoChikouBullConfirmation = false;
bool KumoChikouBearConfirmation = false;



// ===== Signature Label Inputs =====
 bool  ShowSignature   = true;
 ENUM_BASE_CORNER SigCorner = CORNER_LEFT_LOWER; // choose the corner
 int   SigX            = 10;   // margin from the chosen corner (X)
 int   SigY            = 50;   // margin from the chosen corner (Y)
 int   SigFontSize     = 18;   // font size
 color SigColor        = clrYellow; // text color

// Optional background/border behind the text
 bool  SigBg           = false;      // set true to show background box
 color SigBgColor      = clrBlack;   // box fill
 color SigBorderColor  = clrYellow;  // box border
 int   SigBgWidth      = 310;        // box width (tweak as you like)
 int   SigBgHeight     = 28;         // box height
 int   SigBgPaddingX   = 8;          // left/right padding for box vs text
 int   SigBgPaddingY   = 4;          // top/bottom padding

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
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &description)
  {
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                               volume_step,ratio*volume_step);
      return(false);
     }
   description="Correct volume value";
   return(true);
  }


//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
     EnsureSignature();  
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//| Each tick                                                        |
//+------------------------------------------------------------------+
int start()
{
   if ((!IsTradeAllowed()) || (IsTradeContextBusy()) || (!IsConnected()) || ((!MarketInfo(Symbol(), MODE_TRADEALLOWED)) && (!IsTesting()))) return(0);
	
	// Trade only if new bar has arrived
	if (LastBars != Bars) LastBars = Bars;
	else return(0);
   
   if (MM)
   {
      // Getting the potential loss value based on current ATR.
      StopLoss = iATR(NULL, 0, ATR_Period, 1) * ATR_Multiplier;
   }
   
   // Chikou/Price Cross
   double ChikouSpanLatest = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_CHIKOUSPAN, Kijun + 1); // Latest closed bar with Chikou.
   double ChikouSpanPreLatest = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_CHIKOUSPAN, Kijun + 2); // Bar older than latest closed bar with Chikou.
   
   // Bullish entry condition
   if ((ChikouSpanLatest > Close[Kijun + 1]) && (ChikouSpanPreLatest <= Close[Kijun + 2]))
   {
      ChikouPriceBull = true;
      ChikouPriceBear = false;
   }
   // Bearish entry condition
   else if ((ChikouSpanLatest < Close[Kijun + 1]) && (ChikouSpanPreLatest >= Close[Kijun + 2]))
   {
      ChikouPriceBull = false;
      ChikouPriceBear = true;
   }
   else if (ChikouSpanLatest == Close[Kijun + 1]) // Voiding entry conditions if cross is ongoing.
   {
      ChikouPriceBull = false;
      ChikouPriceBear = false;
   }
   
   // Kumo confirmation. When cross is happening current price (latest close) should be above/below both Senkou Spans, or price should close above/below both Senkou Spans after a cross.
   double SenkouSpanALatestByPrice = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANA, 1); // Senkou Span A at time of latest closed price bar.
   double SenkouSpanBLatestByPrice = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANB, 1); // Senkou Span B at time of latest closed price bar.
   if ((Close[1] > SenkouSpanALatestByPrice) && (Close[1] > SenkouSpanBLatestByPrice)) KumoBullConfirmation = true;
   else KumoBullConfirmation = false;
   if ((Close[1] < SenkouSpanALatestByPrice) && (Close[1] < SenkouSpanBLatestByPrice)) KumoBearConfirmation = true;
   else KumoBearConfirmation = false;
   
   // Kumo/Chikou confirmation. When cross is happening Chikou at its latest close should be above/below both Senkou Spans at that time, or it should close above/below both Senkou Spans after a cross.
   double SenkouSpanALatestByChikou = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANA, Kijun + 1); // Senkou Span A at time of latest closed bar of Chikou span.
   double SenkouSpanBLatestByChikou = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANB, Kijun + 1); // Senkou Span B at time of latest closed bar of Chikou span.
   if ((ChikouSpanLatest > SenkouSpanALatestByChikou) && (ChikouSpanLatest > SenkouSpanBLatestByChikou)) KumoChikouBullConfirmation = true;
   else KumoChikouBullConfirmation = false;
   if ((ChikouSpanLatest < SenkouSpanALatestByChikou) && (ChikouSpanLatest < SenkouSpanBLatestByChikou)) KumoChikouBearConfirmation = true;
   else KumoChikouBearConfirmation = false;

   GetPositionStates();
   
   if (ChikouPriceBull)
   {
      if (HaveShortPosition) ClosePrevious();
      if ((KumoBullConfirmation) && (KumoChikouBullConfirmation))
      {
         ChikouPriceBull = false;
         fBuy();
      }
   }
   else if (ChikouPriceBear)
   {
      if (HaveLongPosition) ClosePrevious();
      if ((KumoBearConfirmation) && (KumoChikouBearConfirmation))
      {
         fSell();
         ChikouPriceBear = false;
      }
   }
   return(0);
}

//+------------------------------------------------------------------+
//| Check what position is currently open										|
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

//+------------------------------------------------------------------+
//| Buy                                                              |
//+------------------------------------------------------------------+
void fBuy()
{
   RefreshRates();
   double vol = LotsOptimized();
   string vdesc;
   if(!CheckVolumeValue(vol, vdesc))
     { Print("BUY blocked: ", vdesc); return; }

   int result = OrderSend(Symbol(), OP_BUY, vol, Ask, Slippage, 0, 0, OrderCommentary, Magic);
   if (result == -1) { int e = GetLastError(); Print("OrderSend Error (BUY): ", e); }
}

//+------------------------------------------------------------------+
//| Sell                                                             |
//+------------------------------------------------------------------+
void fSell()
{
   RefreshRates();
   double vol = LotsOptimized();
   string vdesc;
   if(!CheckVolumeValue(vol, vdesc))
     { Print("SELL blocked: ", vdesc); return; }

   int result = OrderSend(Symbol(), OP_SELL, vol, Bid, Slippage, 0, 0, OrderCommentary, Magic);
   if (result == -1) { int e = GetLastError(); Print("OrderSend Error (SELL): ", e); }
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
   
   if ((StopLoss != 0) && (UnitCost != 0) && (TickSize != 0)) PositionSize = NormalizeDouble(RiskMoney / (StopLoss * UnitCost / TickSize), LotDigits);
   
   if (PositionSize < MarketInfo(Symbol(), MODE_MINLOT)) PositionSize = MarketInfo(Symbol(), MODE_MINLOT);
   else if (PositionSize > MarketInfo(Symbol(), MODE_MAXLOT)) PositionSize = MarketInfo(Symbol(), MODE_MAXLOT);
   
   return(PositionSize);
} 

//+------------------------------------------------------------------+
//| Close previous position                                          |
//+------------------------------------------------------------------+
void ClosePrevious()
{
   int total = OrdersTotal();
   for (int i = total; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS) == false) continue;
      if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == Magic))
      {
         if (OrderType() == OP_BUY)
         {
            for (int j = 0; j < 10; j++)
            {
	            RefreshRates();
	            if (OrderClose(OrderTicket(), OrderLots(), Bid, Slippage)) break;
					else Print("Error closing Buy: ", GetLastError());
	         }
         }
         else if (OrderType() == OP_SELL)
         {
            for (int j = 0; j < 10; j++)
            {
	            RefreshRates();
	            if (OrderClose(OrderTicket(), OrderLots(), Ask, Slippage)) break;
					else Print("Error closing Sell: ", GetLastError());
	         }
         }
      }
   }
}
//+------------------------------------------------------------------+