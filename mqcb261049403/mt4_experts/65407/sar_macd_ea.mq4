//+------------------------------------------------------------------+
//|                                     SAR_MACD_EA 28-10-2025 15:23 |
//|Entry: SAR+SMA within window (strict) + MACD confirming direction |
//|  Updated: 2025-10-24 14:15 (Africa/Johannesburg)                 |
//| Notes: SAR[2]/SAR[1] flip logic, SMA1 cross, MACD direction-only |
//|         SignalWindowBars tolerance, armed-state waiting for MACD |
//|  Debug labels/messages enabled                                   |
//+------------------------------------------------------------------+
#property strict

//--- Inputs
input double Lots = 0.10;
input int MagicNumber = 12345;
input double StepSAR = 0.02;
input double MaxSAR = 0.2;
input int SMA_Period = 40;
input int SMA_Shift = 3;
input int SignalWindowBars = 5;
input double MinFreeMargin = 100;
input bool Debug = true;               // debug output / labels
input double TakeProfitPips = 0.0;
input bool UseRiskPercent = true;
input double RiskPercent = 1.0;
input int MaxArmedBars = 15;           // maximum bars to wait while armed for MACD confirmation

//--- Signal control flags
bool BuySignalAllowed = true;
bool SellSignalAllowed = true;

//--- Armed state
bool BuyArmed = false;
bool SellArmed = false;
// STORE the *bar time* (datetime) where flip was detected — this is stable across ticks
datetime BuyArmedBarTime = 0;   // store the bar time where SAR flip was detected
datetime SellArmedBarTime = 0;

//--- Trackers
datetime lastTradeBarTime = 0;

//--- Last found flip shifts (global trackers for diagnostics)
int LastBuyFlipShift = -1;
int LastSellFlipShift = -1;

//+------------------------------------------------------------------+
//| Helper functions                                                 |
//+------------------------------------------------------------------+
// convert "pips" to price points depending on broker digits
double PipValue() { if (Digits == 3 || Digits == 5) return (Point * 10); return (Point); }

// convert desired money risk and SL distance to lot size (per-lot value calculation)
double CalculateLotsByRisk(double riskAmount, double stopLossPriceDiff)
  {
   if (stopLossPriceDiff <= 0.0)
      return (0.0);
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double tickSize  = MarketInfo(Symbol(), MODE_TICKSIZE);
   if (tickValue <= 0.0 || tickSize <= 0.0)
      return (0.0);
   double valuePerPriceUnit = tickValue / tickSize;
   double moneyRiskPerLot = stopLossPriceDiff * valuePerPriceUnit;
   if (moneyRiskPerLot <= 0.0)
      return (0.0);
   double rawLots = riskAmount / moneyRiskPerLot;
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   if (lotStep <= 0)
      lotStep = 0.01;
   double lots = MathFloor(rawLots / lotStep) * lotStep;
   if (lots < minLot) lots = minLot;
   if (lots > maxLot) lots = maxLot;

   // Note: many brokers use 2 decimals for lots; adjust if your broker uses different precision.
   return NormalizeDouble(lots, 2);
  }

//+------------------------------------------------------------------+
//| Create or update debug label using typed ObjectSet* API         |
//+------------------------------------------------------------------+
void CreateDebugLabel(string name, string text, int x, int y, color col)
  {
   // Print to Experts as well (guarantee logs visible)
   if (Debug) Print(text);

   // typed object API — create or update label on chart (chart id 0)
   if (ObjectFind(0, name) >= 0)
     {
      ObjectDelete(0, name);
     }

   if (!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
     {
      if (Debug) Print("CreateDebugLabel: ObjectCreate failed err=", GetLastError());
      return;
     }

   // Top-left corner
   ObjectSetInteger(0, name, OBJPROP_CORNER, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);

   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   Print("SAR_MACD_EA 24-10-2025 14:15 initialized - debug=", Debug);
   return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnTick()
{
   ManageTrailingStopAndReverseClose();

   // process signals once per closed bar
   static datetime lastProcessedBarTime = 0;
   datetime thisBarTime = Time[1]; // last closed bar
   if(thisBarTime == lastProcessedBarTime)
      return;
   lastProcessedBarTime = thisBarTime;

   if(AccountFreeMargin() < MinFreeMargin) return;

   int totalBars = iBars(NULL,0);

   // --- MACD direction (last closed bar only)
   double macdMain = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double macdSignal = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   bool macdBullish = (macdMain > macdSignal);
   bool macdBearish = (macdMain < macdSignal);

   // --- scan recent bars for SAR flip (strict)
   bool foundBuyFlip = false;
   int buyFlipShift = -1;
   bool foundSellFlip = false;
   int sellFlipShift = -1;

   for(int j=1; j<=SignalWindowBars; j++)
   {
      if(totalBars <= j+1) break;

      double sar_1 = iSAR(NULL,0,StepSAR,MaxSAR,j);
      double sar_2 = iSAR(NULL,0,StepSAR,MaxSAR,j+1);
      double close_1 = Close[j];
      double close_2 = Close[j+1];
      double sma40_at = iMA(NULL,0,SMA_Period,SMA_Shift,MODE_SMA,PRICE_CLOSE,j);

      // Buy flip: SAR moves from above price to below
      if(sar_2 > close_2 && sar_1 < close_1 && sar_1 < sma40_at)
      {
         foundBuyFlip = true;
         buyFlipShift = j;
         break;
      }

      // Sell flip: SAR moves from below price to above
      if(sar_2 < close_2 && sar_1 > close_1 && sar_1 > sma40_at)
      {
         foundSellFlip = true;
         sellFlipShift = j;
         break;
      }
   }

   // --- Armed state logic
   if(foundBuyFlip && !BuyArmed)
   {
      int idx = buyFlipShift;
      if(totalBars > idx+1)
      {
         double sma1_prev = iMA(NULL,0,1,0,MODE_SMA,PRICE_CLOSE,idx+1);
         double sma1_now  = iMA(NULL,0,1,0,MODE_SMA,PRICE_CLOSE,idx);
         double close_prev = Close[idx+1];
         double close_now  = Close[idx];

         if(close_prev < sma1_prev && close_now > sma1_now)
         {
            BuyArmed = true;
            BuyArmedBarTime = Time[idx];
            if(Debug) PrintFormat("Buy armed at shift=%d time=%s", idx, TimeToString(BuyArmedBarTime, TIME_DATE|TIME_MINUTES));
         }
      }
   }

   if(foundSellFlip && !SellArmed)
   {
      int idx = sellFlipShift;
      if(totalBars > idx+1)
      {
         double sma1_prev = iMA(NULL,0,1,0,MODE_SMA,PRICE_CLOSE,idx+1);
         double sma1_now  = iMA(NULL,0,1,0,MODE_SMA,PRICE_CLOSE,idx);
         double close_prev = Close[idx+1];
         double close_now  = Close[idx];

         if(close_prev > sma1_prev && close_now < sma1_now)
         {
            SellArmed = true;
            SellArmedBarTime = Time[idx];
            if(Debug) PrintFormat("Sell armed at shift=%d time=%s", idx, TimeToString(SellArmedBarTime, TIME_DATE|TIME_MINUTES));
         }
      }
   }

   // --- Clear armed if opposite flip appears or timeout
   if(BuyArmed && (foundSellFlip || (BuyArmedBarTime!=0 && BarsSince(BuyArmedBarTime) > MaxArmedBars)))
   {
      BuyArmed = false; BuyArmedBarTime = 0;
      if(Debug) Print("BuyArmed cleared");
   }

   if(SellArmed && (foundBuyFlip || (SellArmedBarTime!=0 && BarsSince(SellArmedBarTime) > MaxArmedBars)))
   {
      SellArmed = false; SellArmedBarTime = 0;
      if(Debug) Print("SellArmed cleared");
   }

   // --- Count EA trades
   int openCount = 0;
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
            openCount++;
   }

   // --- Entry
   if(openCount==0 && Time[1] != lastTradeBarTime)
   {
      double sar_now = iSAR(NULL,0,StepSAR,MaxSAR,1);
      double sma40_now = iMA(NULL,0,SMA_Period,SMA_Shift,MODE_SMA,PRICE_CLOSE,1);
      double close_now = Close[1];

      // Buy
      if(BuyArmed && macdBullish && BuySignalAllowed)
      {
         if(sar_now < sma40_now && close_now > sar_now && close_now > sma40_now)
            OpenBuy();
      }

      // Sell
      if(SellArmed && macdBearish && SellSignalAllowed)
      {
         if(sar_now > sma40_now && close_now < sar_now && close_now < sma40_now)
            OpenSell();
      }
   }
}

// Helper to calculate bars since armed bar
int BarsSince(datetime barTime)
{
   for(int s=1; s<iBars(NULL,0); s++)
      if(Time[s] == barTime)
         return s-1;
   return MaxArmedBars+1; // expired
}

// Separate functions for cleaner entry
void OpenBuy()
{
   double initialSL = NormalizeDouble(iSAR(NULL,0,StepSAR,MaxSAR,1),Digits);
   double orderLots = Lots;
   if(UseRiskPercent)
   {
      double riskAmount = AccountFreeMargin()*(RiskPercent/100.0);
      double stopDiff = MathAbs(Ask - initialSL);
      double calcLots = CalculateLotsByRisk(riskAmount, stopDiff);
      if(calcLots>0) orderLots = calcLots;
   }

   double tpPrice = TakeProfitPips>0 ? NormalizeDouble(Ask + TakeProfitPips*PipValue(),Digits) : 0.0;
   int ticket = OrderSend(Symbol(), OP_BUY, orderLots, NormalizeDouble(Ask,Digits), 10, initialSL, tpPrice, "SAR_MACD_Buy", MagicNumber,0,clrLime);
   if(ticket>0)
   {
      Print("BUY opened ticket=",ticket);
      BuySignalAllowed=false; SellSignalAllowed=true;
      lastTradeBarTime=Time[1]; BuyArmed=false; BuyArmedBarTime=0;
   } else Print("BUY failed err=",GetLastError());
}

void OpenSell()
{
   double initialSL = NormalizeDouble(iSAR(NULL,0,StepSAR,MaxSAR,1),Digits);
   double orderLots = Lots;
   if(UseRiskPercent)
   {
      double riskAmount = AccountFreeMargin()*(RiskPercent/100.0);
      double stopDiff = MathAbs(Bid - initialSL);
      double calcLots = CalculateLotsByRisk(riskAmount, stopDiff);
      if(calcLots>0) orderLots = calcLots;
   }

   double tpPrice = TakeProfitPips>0 ? NormalizeDouble(Bid - TakeProfitPips*PipValue(),Digits) : 0.0;
   int ticket = OrderSend(Symbol(), OP_SELL, orderLots, NormalizeDouble(Bid,Digits), 10, initialSL, tpPrice, "SAR_MACD_Sell", MagicNumber,0,clrRed);
   if(ticket>0)
   {
      Print("SELL opened ticket=",ticket);
      SellSignalAllowed=false; BuySignalAllowed=true;
      lastTradeBarTime=Time[1]; SellArmed=false; SellArmedBarTime=0;
   } else Print("SELL failed err=",GetLastError());
}

//+------------------------------------------------------------------+
void ManageTrailingStopAndReverseClose()
{
   RefreshRates();

   int totalOrders = OrdersTotal();
   for(int i = totalOrders-1; i >= 0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;

      int type = OrderType();
      double openPrice = OrderOpenPrice();
      double curSL = OrderStopLoss();
      double sarLast = iSAR(NULL,0,StepSAR,MaxSAR,1); // SAR from last closed candle

      // --- MACD direction check (last closed bar)
      double macdMain = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
      double macdSignal = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
      bool macdBullish = (macdMain > macdSignal);
      bool macdBearish = (macdMain < macdSignal);

      // Close on MACD direction flip
      if(type == OP_BUY && macdBearish)
      {
         if(OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid,Digits), 10, clrRed))
            Print("BUY closed on MACD bearish flip #", OrderTicket());
         else
            Print("BUY close failed err=", GetLastError());
         continue;
      }
      if(type == OP_SELL && macdBullish)
      {
         if(OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask,Digits), 10, clrBlue))
            Print("SELL closed on MACD bullish flip #", OrderTicket());
         else
            Print("SELL close failed err=", GetLastError());
         continue;
      }

      // --- Trailing via SAR[1]
      if(type == OP_BUY)
      {
         double newSL = NormalizeDouble(sarLast, Digits);
         if(newSL < Bid && (curSL == 0.0 || newSL > curSL))
         {
            if(!OrderModify(OrderTicket(), openPrice, newSL, OrderTakeProfit(), 0, clrBlue))
               Print("OrderModify BUY failed #", OrderTicket(), " err=", GetLastError());
         }
      }
      if(type == OP_SELL)
      {
         double newSL = NormalizeDouble(sarLast, Digits);
         if(newSL > Ask && (curSL == 0.0 || newSL < curSL))
         {
            if(!OrderModify(OrderTicket(), openPrice, newSL, OrderTakeProfit(), 0, clrRed))
               Print("OrderModify SELL failed #", OrderTicket(), " err=", GetLastError());
         }
      }
   }
}
