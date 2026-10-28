//+------------------------------------------------------------------+
//|                                        BEC_Combined_BE_Trail.mq5 |
//|                                  BEC - Breakeven & Trail Manager |
//|                            Combines Single BE + Trailing Stop EA |
//+------------------------------------------------------------------+
#property link          "https://mrshafaq.com"
#property version       "1.00"
#property copyright     "BEC Trading Systems - 2026"
#property description   "BEC Combined Breakeven & Trailing Stop Manager"
#property description   "Automatically manages breakeven and trailing stops."
#property description   "mrshafaq@gmail.com"
#property description   "WARNING: Use this software at your own risk."

#include <Trade/Trade.mqh>

//--- Enums
enum ENUM_CONSIDER
  {
   All  = -1,                  // ALL ORDERS
   Buy  = POSITION_TYPE_BUY,   // BUY ONLY
   Sell = POSITION_TYPE_SELL   // SELL ONLY
  };

enum ENUM_ADJUST_TO
  {
   ADJUST_DONT,    // Don't adjust
   ADJUST_TO_ASK,  // Adjust to Ask price
   ADJUST_TO_BID   // Adjust to Bid price
  };

enum mode_of_operation { Risk, Reward };

//============================================================
//  INPUT PARAMETERS
//============================================================
input group "=== BEC SINGLE BREAKEVEN ==="
input int    ProfitCurToTrigger      = 5;              // Total profit (currency) to trigger BE
input int    AdditionalProfitCur     = 5;               // Additional profit (currency) for BE
input ENUM_ADJUST_TO AdjustToPrice   = ADJUST_TO_BID;  // Adjust single BE to which price?
input int    DelayBetweenAdjustments = 1;               // Delay (sec) between adjustments
input bool   AdjustForSwapsCommission= false;           // Adjust for swaps & commission?

input group "=== BEC TRAILING STOP ==="
input int    TrailingStop            = 30;              // Trailing Stop (points)
input int    TrailingProfit          = 30;              // Profit in points to activate trailing
//=== SCALPING ===
input double ScalpingLot = 0.01;
input int    ScalpingTrailPips = 30;
input int ScalpingStartPips = 30;   // start trailing after profit

input group "=== ORDERS FILTERING ==="
input ENUM_CONSIDER OnlyType         = All;             // Apply to
input bool   UseMagic                = false;           // Filter by magic number
input int    MagicNumber             = 0;               // Magic number
input bool   UseComment              = false;           // Filter by comment
input string CommentFilter           = "";              // Comment filter string

input group "=== ENABLE / DISABLE ==="
input bool   EnableBEParam           = false;            // Enable Breakeven EA
input bool   EnableTrailParam        = false;            // Enable Trailing Stop

input group "=== NOTIFICATIONS ==="
input bool   EnableNotify            = false;           // Enable notifications
input bool   SendAlert               = false;           // Send alert
input bool   SendApp                 = false;           // Send mobile notification
input bool   SendEmail               = false;           // Send email

input group "=== DASHBOARD ==="
input bool   ShowPanel               = true;            // Show dashboard panel
input int    Xoff                    = 15;              // Horizontal offset
input int    Yoff                    = 30;              // Vertical offset
input ENUM_BASE_CORNER ChartCorner   = CORNER_LEFT_LOWER; // Chart corner
input int    FontSize                = 9;               // Font size

//============================================================
//  GLOBALS
//============================================================
string ExpertName   = "BEC";
string AccCurrency;
double DPIScale;
int    PanelMovY, PanelLabX, PanelLabY, PanelRecX;

bool     EnableBE      = EnableBEParam;
bool     EnableTrail   = EnableTrailParam;
datetime LastAdjustment;

CTrade *Trade;

// Panel object name constants
string PanelBase          = "BEC-P-BASE";
string PanelTitle         = "BEC-P-TITLE";
string PanelPrice         = "BEC-P-PRICE";
string PanelEquity        = "BEC-P-EQUITY";
string PanelFloating      = "BEC-P-FLOAT";
string PanelDayProfit     = "BEC-P-DAYP";
string PanelBEToggle      = "BEC-P-BETOG";
string PanelTSToggle      = "BEC-P-TSTOG";
string PanelBtn1          = "BEC-P-BTN1";
string PanelBtn2          = "BEC-P-BTN2";
string PanelBtn3          = "BEC-P-BTN3";
string PanelScalpBuy  = "BEC-P-SBUY";
string PanelScalpSell = "BEC-P-SSELL";

int    PositionsLong, PositionsShort;
double ProfitTotal;

//============================================================
//  INIT
//============================================================
int OnInit()
  {
   CleanPanel();
   EnableBE    = EnableBEParam;
   EnableTrail = EnableTrailParam;

   DPIScale   = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI) / 96.0;
   PanelMovY  = (int)MathRound(18 * DPIScale);
   PanelLabX  = (int)MathRound(200 * DPIScale);
   PanelLabY  = PanelMovY;
   PanelRecX  = PanelLabX + 4;
   LastAdjustment = 0;

   Trade = new CTrade;
   if(ShowPanel)
      DrawPanel();
   return INIT_SUCCEEDED;
  }

//============================================================
//  DEINIT
//============================================================
void OnDeinit(const int reason)
  {
   CleanPanel();
   delete Trade;
  }

//============================================================
//  TICK
//============================================================
void OnTick()
  {
   if(EnableBE)
      DoSingleBE();
   if(EnableTrail)
      DoTrailingStop();
   DoScalpTrailing();
   if(ShowPanel)
      DrawPanel();
  }

//============================================================
//  CHART EVENTS
//============================================================
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam == PanelBEToggle)
        {
         ToggleBE();
         DrawPanel();
        }
      if(sparam == PanelTSToggle)
        {
         ToggleTrail();
         DrawPanel();
        }
      if(sparam == PanelBtn1)
        {
         CloseSmallestProfitTrade();
        }
      if(sparam == PanelBtn2)
        {
         CloseHalfAndSetBreakeven();
        }
      if(sparam == PanelBtn3)
        {
         CloseAllTradesAndOrders();
        }
      if(sparam == PanelScalpBuy)
        {
         OpenScalpTrade(true);
        }
      if(sparam == PanelScalpSell)
        {
         OpenScalpTrade(false);
        }
     }
   if(id == CHARTEVENT_KEYDOWN)
     {
      if(lparam == 27)
        {
         if(MessageBox("Close BEC EA?", "EXIT?", MB_YESNO) == IDYES)
            ExpertRemove();
        }
     }
  }

//============================================================
//  TOGGLE FUNCTIONS
//============================================================
void ToggleBE()
  {
   if(!EnableBE)
     {
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
        {
         MessageBox("Enable Algo Trading in platform settings.", "WARNING", MB_OK);
         return;
        }
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         MessageBox("Enable Algo Trading in EA Common tab.", "WARNING", MB_OK);
         return;
        }
     }
   EnableBE = !EnableBE;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ToggleTrail()
  {
   if(!EnableTrail)
     {
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
        {
         MessageBox("Enable Algo Trading in platform settings.", "WARNING", MB_OK);
         return;
        }
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         MessageBox("Enable Algo Trading in EA Common tab.", "WARNING", MB_OK);
         return;
        }
     }
   EnableTrail = !EnableTrail;
  }

//============================================================
//  BUTTON 1 — Close only the latest smallest-profit trade
//============================================================
void CloseSmallestProfitTrade()
  {
   double   minProfit  = DBL_MAX;
   ulong    minTicket  = 0;
   datetime latestTime = 0;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;
      if(!ApplyFilters())
         continue;

      double   profit = PositionGetDouble(POSITION_PROFIT);
      datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);

      // Only consider profitable trades; pick smallest profit among most recent
      if(profit > 0)
        {
         if(profit < minProfit || (profit == minProfit && openTime > latestTime))
           {
            minProfit  = profit;
            minTicket  = ticket;
            latestTime = openTime;
           }
        }
     }

   if(minTicket > 0)
     {
      if(Trade.PositionClose(minTicket))
         Print("BEC BTN1: Closed smallest profit trade #", minTicket, " profit=", DoubleToString(minProfit, 2));
      else
         Print("BEC BTN1: Failed to close trade #", minTicket, " error=", GetLastError());
     }
   else
     {
      Alert("BEC: No profitable trades found to close.");
     }
   DrawPanel();
  }

//============================================================
//  BUTTON 2 — Close 1:2 (50%) volume from all trades, then set SL to breakeven
//============================================================
void CloseHalfAndSetBreakeven()
  {
   int total = PositionsTotal();
   for(int i = total - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;
      if(!ApplyFilters())
         continue;

      double volume     = PositionGetDouble(POSITION_VOLUME);
      double openPrice  = PositionGetDouble(POSITION_PRICE_OPEN);
      double halfVolume = NormalizeDouble(volume / 2.0, 2);
      double minLot     = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
      double lotStep    = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);

      if(halfVolume < minLot)
         halfVolume = minLot;
      halfVolume = NormalizeDouble(MathFloor(halfVolume / lotStep) * lotStep, 2);

      // Partial close
      if(halfVolume >= minLot && halfVolume < volume)
        {
         if(Trade.PositionClosePartial(ticket, halfVolume))
            Print("BEC BTN2: Partial close #", ticket, " volume=", halfVolume);
        }

      // Re-select after partial close to get updated data
      if(!PositionSelectByTicket(ticket))
         continue;

      // Set SL to open price (breakeven)
      double currentTP = PositionGetDouble(POSITION_TP);
      double tickSize  = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
      double bePrice   = openPrice;
      if(tickSize > 0)
         bePrice = NormalizeDouble(MathRound(bePrice / tickSize) * tickSize, _Digits);

      if(Trade.PositionModify(ticket, bePrice, currentTP))
         Print("BEC BTN2: Set SL to BE for #", ticket, " BE=", DoubleToString(bePrice, _Digits));
     }
   DrawPanel();
  }

//============================================================
//  BUTTON 3 — Close ALL trades and delete ALL pending orders
//============================================================
void CloseAllTradesAndOrders()
  {
//if (MessageBox("Close ALL trades and delete ALL pending orders on " + Symbol() + "?", "BEC - CONFIRM CLOSE ALL", MB_YESNO) != IDYES) return;

// Close all positions on current symbol
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;

      if(Trade.PositionClose(ticket))
         Print("BEC BTN3: Closed position #", ticket);
      else
         Print("BEC BTN3: Failed to close #", ticket, " error=", GetLastError());
     }

// Delete all pending orders on current symbol
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != Symbol())
         continue;

      if(Trade.OrderDelete(ticket))
         Print("BEC BTN3: Deleted order #", ticket);
      else
         Print("BEC BTN3: Failed to delete order #", ticket, " error=", GetLastError());
     }
   DrawPanel();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenScalpTrade(bool isBuy)
  {
   string sym = Symbol();
   double lot = ScalpingLot;

   double price = isBuy ? SymbolInfoDouble(sym, SYMBOL_ASK)
                  : SymbolInfoDouble(sym, SYMBOL_BID);

   bool result;

   if(isBuy)
      result = Trade.Buy(lot, sym, price, 0, 0, "SCALP");
   else
      result = Trade.Sell(lot, sym, price, 0, 0, "SCALP");

   if(!result)
      Print("Scalp trade failed: ", GetLastError());
  }

//============================================================
//  FILTER HELPER
//============================================================
bool ApplyFilters()
  {
   if((UseMagic)   && (PositionGetInteger(POSITION_MAGIC) != MagicNumber))
      return false;
   if((UseComment) && (StringFind(PositionGetString(POSITION_COMMENT), CommentFilter) < 0))
      return false;
   if((OnlyType != All) && (PositionGetInteger(POSITION_TYPE) != OnlyType))
      return false;
   return true;
  }

//============================================================
//  SINGLE BREAKEVEN LOGIC
//============================================================
void DoSingleBE()
  {
   if(TimeCurrent() < LastAdjustment + DelayBetweenAdjustments)
      return;
   double BE_Price = CalculateSingleBreakeven();
   if(BE_Price <= 0)
      return;
   if(ProfitTotal < ProfitCurToTrigger)
      return;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      string Instrument = PositionGetSymbol(i);
      if(Instrument == "" || Instrument != Symbol())
         continue;
      if(!ApplyFilters())
         continue;

      double BE_Price_Current = BE_Price;
      double OpenPrice  = PositionGetDouble(POSITION_PRICE_OPEN);
      double SLPrice    = PositionGetDouble(POSITION_SL);
      double TPPrice    = PositionGetDouble(POSITION_TP);
      double TickSize   = SymbolInfoDouble(Instrument, SYMBOL_TRADE_TICK_SIZE);
      double StopLevel  = SymbolInfoInteger(Instrument, SYMBOL_TRADE_STOPS_LEVEL) * _Point;

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         if((AdjustToPrice == ADJUST_TO_ASK) && (PositionsShort > 0))
            BE_Price_Current -= SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) * _Point;
        }
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
         if((AdjustToPrice == ADJUST_TO_BID) && (PositionsLong > 0))
            BE_Price_Current += SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) * _Point;
        }

      if(TickSize > 0)
         BE_Price_Current = NormalizeDouble(MathRound(BE_Price_Current / TickSize) * TickSize, _Digits);

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         if(BE_Price_Current < SymbolInfoDouble(Instrument, SYMBOL_BID) - StopLevel)
           {
            double NewSL = NormalizeDouble(BE_Price_Current, _Digits);
            if(MathAbs(NewSL - SLPrice) > _Point / 2)
              {
               if(Trade.PositionModify(PositionGetInteger(POSITION_TICKET), NewSL, TPPrice))
                 {
                  Print("BEC-BE: Buy #", PositionGetInteger(POSITION_TICKET), " SL→", DoubleToString(NewSL, _Digits));
                  SendBENotification(PositionGetInteger(POSITION_TICKET), NewSL, Symbol());
                 }
              }
           }
         else
            if(BE_Price_Current > SymbolInfoDouble(Symbol(), SYMBOL_ASK) + StopLevel)
              {
               double NewTP = NormalizeDouble(BE_Price_Current, _Digits);
               if(MathAbs(NewTP - TPPrice) > _Point / 2)
                  Trade.PositionModify(PositionGetInteger(POSITION_TICKET), SLPrice, NewTP);
              }
        }
      else
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            if(BE_Price_Current > SymbolInfoDouble(Symbol(), SYMBOL_ASK) + StopLevel)
              {
               double NewSL = NormalizeDouble(BE_Price_Current, _Digits);
               if(MathAbs(NewSL - SLPrice) > _Point / 2)
                 {
                  if(Trade.PositionModify(PositionGetInteger(POSITION_TICKET), NewSL, TPPrice))
                    {
                     Print("BEC-BE: Sell #", PositionGetInteger(POSITION_TICKET), " SL→", DoubleToString(NewSL, _Digits));
                     SendBENotification(PositionGetInteger(POSITION_TICKET), NewSL, Symbol());
                    }
                 }
              }
            else
               if(BE_Price_Current < SymbolInfoDouble(Symbol(), SYMBOL_BID) - StopLevel)
                 {
                  double NewTP = NormalizeDouble(BE_Price_Current, _Digits);
                  if(MathAbs(NewTP - TPPrice) > _Point / 2)
                     Trade.PositionModify(PositionGetInteger(POSITION_TICKET), SLPrice, NewTP);
                 }
           }
     }
   LastAdjustment = TimeCurrent();
  }

//============================================================
//  TRAILING STOP LOGIC
//============================================================
void DoTrailingStop()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket <= 0)
         continue;
      if(SymbolInfoInteger(PositionGetString(POSITION_SYMBOL), SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_DISABLED)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;
      if(!ApplyFilters())
         continue;

      string sym   = PositionGetString(POSITION_SYMBOL);
      double point = SymbolInfoDouble(sym, SYMBOL_POINT);
      double TSTP  = TrailingStop * point;
      double P     = TrailingProfit * point;
      double Bid   = SymbolInfoDouble(sym, SYMBOL_BID);
      double Ask   = SymbolInfoDouble(sym, SYMBOL_ASK);
      double OpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double StopLoss  = PositionGetDouble(POSITION_SL);
      double TakeProfit= PositionGetDouble(POSITION_TP);
      int    eDigits   = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
      double TickSize  = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         if(NormalizeDouble(Bid - OpenPrice, eDigits) >= NormalizeDouble(P, eDigits))
           {
            double new_sl = NormalizeDouble(Bid - TSTP, eDigits);
            if(TickSize > 0)
               new_sl = NormalizeDouble(MathRound(new_sl / TickSize) * TickSize, eDigits);
            if((TSTP != 0) && (StopLoss < new_sl))
              {
               if(Trade.PositionModify(ticket, new_sl, TakeProfit))
                 {
                  Print("BEC-TS: Buy #", ticket, " SL→", DoubleToString(new_sl, eDigits));
                  SendTSNotification(ticket, new_sl, sym);
                 }
              }
           }
        }
      else
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            if(NormalizeDouble(OpenPrice - Ask, eDigits) >= NormalizeDouble(P, eDigits))
              {
               double new_sl = NormalizeDouble(Ask + TSTP, eDigits);
               if(TickSize > 0)
                  new_sl = NormalizeDouble(MathRound(new_sl / TickSize) * TickSize, eDigits);
               if((TSTP != 0) && ((StopLoss > new_sl) || (StopLoss == 0)))
                 {
                  if(Trade.PositionModify(ticket, new_sl, TakeProfit))
                    {
                     Print("BEC-TS: Sell #", ticket, " SL→", DoubleToString(new_sl, eDigits));
                     SendTSNotification(ticket, new_sl, sym);
                    }
                 }
              }
           }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DoScalpTrailing()
  {
   string sym = Symbol();
   double point = SymbolInfoDouble(sym, SYMBOL_POINT);
   int digits   = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);

   double pip = (digits == 3 || digits == 5) ? 10 * point : point;
   double trail = ScalpingTrailPips * pip;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;

      if(PositionGetString(POSITION_SYMBOL) != sym)
         continue;
      if(PositionGetString(POSITION_COMMENT) != "SCALP")
         continue;

      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl   = PositionGetDouble(POSITION_SL);
      double tp   = PositionGetDouble(POSITION_TP);

      double bid = SymbolInfoDouble(sym, SYMBOL_BID);
      double ask = SymbolInfoDouble(sym, SYMBOL_ASK);

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         double profitDistance = bid - open;

         if(profitDistance >= ScalpingStartPips * pip)
           {
            double newSL = NormalizeDouble(bid - trail, digits);

            if(sl == 0 || newSL > sl)
               Trade.PositionModify(ticket, newSL, tp);
           }
        }

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
         double profitDistance = open - ask;

         if(profitDistance >= ScalpingStartPips * pip)
           {
            double newSL = NormalizeDouble(ask + trail, digits);

            if(sl == 0 || newSL < sl)
               Trade.PositionModify(ticket, newSL, tp);
           }
        }
     }
  }

//============================================================
//  BREAKEVEN CALCULATION
//============================================================
double CalculateSingleBreakeven()
  {
   PositionsLong  = 0;
   double VolumeLong  = 0, PriceLong  = 0, ProfitLong  = 0;
   PositionsShort = 0;
   double VolumeShort = 0, PriceShort = 0, ProfitShort = 0;
   int PosTotal = 0;
   ProfitTotal = 0;

   AccCurrency = AccountInfoString(ACCOUNT_CURRENCY);
   double point_value_risk = CalculatePointValue(Risk);
   if(point_value_risk == 0)
      return 0;

   int total = PositionsTotal();
   for(int i = 0; i < total; i++)
     {
      string Instrument = PositionGetSymbol(i);
      if(Instrument == "" || Instrument != Symbol())
         continue;
      if(!ApplyFilters())
         continue;

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         PositionsLong++;
         VolumeLong += PositionGetDouble(POSITION_VOLUME);
         PriceLong  += PositionGetDouble(POSITION_PRICE_OPEN) * PositionGetDouble(POSITION_VOLUME);
         ProfitLong += PositionGetDouble(POSITION_PROFIT);
         if(AdjustForSwapsCommission)
            ProfitLong += PositionGetDouble(POSITION_SWAP) + CalculateCommission();
         if((PositionsShort > 0) && (AdjustToPrice == ADJUST_TO_ASK))
            ProfitLong -= SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) * _Point * PositionGetDouble(POSITION_VOLUME) * point_value_risk;
        }
      else
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            PositionsShort++;
            VolumeShort += PositionGetDouble(POSITION_VOLUME);
            PriceShort  += PositionGetDouble(POSITION_PRICE_OPEN) * PositionGetDouble(POSITION_VOLUME);
            ProfitShort += PositionGetDouble(POSITION_PROFIT);
            if(AdjustForSwapsCommission)
               ProfitShort += PositionGetDouble(POSITION_SWAP) + CalculateCommission();
            if((PositionsLong > 0) && (AdjustToPrice == ADJUST_TO_BID))
               ProfitShort -= SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) * _Point * PositionGetDouble(POSITION_VOLUME) * point_value_risk;
           }
     }

   if(VolumeLong  > 0)
      PriceLong  /= VolumeLong;
   if(VolumeShort > 0)
      PriceShort /= VolumeShort;

   PosTotal    = PositionsLong + PositionsShort;
   double VolumeTotal = VolumeLong - VolumeShort;
   ProfitTotal = ProfitLong + ProfitShort;

   if(PosTotal == 0)
      return 0;

   double DistancePoints = 0;
   double BE_Price = 0;

   if(VolumeTotal != 0)
     {
      if((ProfitTotal > 0) && (ProfitTotal > AdditionalProfitCur))
         DistancePoints = (ProfitTotal - AdditionalProfitCur) / MathAbs(VolumeTotal * point_value_risk);
      else
         return 0;

      if(VolumeTotal > 0)
         BE_Price = SymbolInfoDouble(Symbol(), SYMBOL_BID) - DistancePoints;
      else
         BE_Price = SymbolInfoDouble(Symbol(), SYMBOL_ASK) + DistancePoints;
     }
   return BE_Price;
  }

//============================================================
//  COMMISSION CALCULATOR
//============================================================
double CalculateCommission()
  {
   double commission_sum = 0;
   if(!HistorySelectByPosition(PositionGetInteger(POSITION_IDENTIFIER)))
      return 0;
   int deals_total = HistoryDealsTotal();
   for(int i = 0; i < deals_total; i++)
     {
      ulong deal_ticket = HistoryDealGetTicket(i);
      if(deal_ticket == 0)
         continue;
      if((HistoryDealGetInteger(deal_ticket, DEAL_TYPE) != DEAL_TYPE_BUY) &&
         (HistoryDealGetInteger(deal_ticket, DEAL_TYPE) != DEAL_TYPE_SELL))
         continue;
      if(HistoryDealGetInteger(deal_ticket, DEAL_ENTRY) != DEAL_ENTRY_IN)
         continue;
      commission_sum += HistoryDealGetDouble(deal_ticket, DEAL_COMMISSION);
     }
   return commission_sum;
  }

//============================================================
//  POINT VALUE CALCULATION
//============================================================
double CalculatePointValue(mode_of_operation mode)
  {
   string cp = Symbol();
   double UnitCost = CalculateUnitCost(cp, mode);
   double OnePoint = SymbolInfoDouble(cp, SYMBOL_POINT);
   if(OnePoint == 0)
      return 0;
   return (UnitCost / OnePoint);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateUnitCost(const string cp, const mode_of_operation mode)
  {
   ENUM_SYMBOL_CALC_MODE CalcMode = (ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(cp, SYMBOL_TRADE_CALC_MODE);
   if((CalcMode != SYMBOL_CALC_MODE_FOREX) && (CalcMode != SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE) &&
      (CalcMode != SYMBOL_CALC_MODE_FUTURES) && (CalcMode != SYMBOL_CALC_MODE_EXCH_FUTURES) &&
      (CalcMode != SYMBOL_CALC_MODE_EXCH_FUTURES_FORTS))
     {
      double TickSize = SymbolInfoDouble(cp, SYMBOL_TRADE_TICK_SIZE);
      double UnitCost = TickSize * SymbolInfoDouble(cp, SYMBOL_TRADE_CONTRACT_SIZE);
      string ProfitCurrency = SymbolInfoString(cp, SYMBOL_CURRENCY_PROFIT);
      if(ProfitCurrency == "RUR")
         ProfitCurrency = "RUB";
      if(ProfitCurrency != AccCurrency)
         return (UnitCost * CalculateAdjustment(ProfitCurrency, mode));
      return UnitCost;
     }
   else
     {
      if(mode == Risk)
         return SymbolInfoDouble(cp, SYMBOL_TRADE_TICK_VALUE_LOSS);
      else
         return SymbolInfoDouble(cp, SYMBOL_TRADE_TICK_VALUE_PROFIT);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateAdjustment(const string ProfitCurrency, const mode_of_operation mode)
  {
   string ReferenceSymbol = GetSymbolByCurrencies(ProfitCurrency, AccCurrency);
   bool   ReferenceSymbolMode = true;
   if(ReferenceSymbol == NULL)
     {
      ReferenceSymbol = GetSymbolByCurrencies(AccCurrency, ProfitCurrency);
      ReferenceSymbolMode = false;
     }
   if(ReferenceSymbol == NULL)
     {
      Print("BEC: Cannot detect adjustment currency pair.");
      return 1;
     }
   MqlTick tick;
   SymbolInfoTick(ReferenceSymbol, tick);
   return GetCurrencyCorrectionCoefficient(tick, mode, ReferenceSymbolMode);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetSymbolByCurrencies(string base_currency, string profit_currency)
  {
   for(int s = 0; s < SymbolsTotal(false); s++)
     {
      string symbolname = SymbolName(s, false);
      if((SymbolInfoInteger(symbolname, SYMBOL_TRADE_CALC_MODE) != SYMBOL_CALC_MODE_FOREX) &&
         (SymbolInfoInteger(symbolname, SYMBOL_TRADE_CALC_MODE) != SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE))
         continue;
      string b_cur = SymbolInfoString(symbolname, SYMBOL_CURRENCY_BASE);
      string p_cur = SymbolInfoString(symbolname, SYMBOL_CURRENCY_PROFIT);
      if(b_cur == "RUR")
         b_cur = "RUB";
      if(p_cur == "RUR")
         p_cur = "RUB";
      if((b_cur == base_currency) && (p_cur == profit_currency))
        {
         if(!(bool)SymbolInfoInteger(symbolname, SYMBOL_SELECT))
            SymbolSelect(symbolname, true);
         return symbolname;
        }
     }
   return NULL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetCurrencyCorrectionCoefficient(MqlTick &tick, const mode_of_operation mode, const bool ReferenceSymbolMode)
  {
   if((tick.ask == 0) || (tick.bid == 0))
      return -1;
   if(mode == Risk)
     {
      if(ReferenceSymbolMode)
         return tick.ask;
      else
         return (1 / tick.bid);
     }
   else
     {
      if(ReferenceSymbolMode)
         return tick.bid;
      else
         return (1 / tick.ask);
     }
  }

//============================================================
//  NOTIFICATIONS
//============================================================
void SendBENotification(long Ticket, double Price, string Instrument)
  {
   if(!EnableNotify || (!SendAlert && !SendApp && !SendEmail))
      return;
   string msg = "BEC Single Breakeven: SL for position #" + IntegerToString(Ticket) + " → " + DoubleToString(Price, _Digits);
   if(SendAlert)
      Alert(msg);
   if(SendEmail)
      SendMail("BEC " + Instrument + " BE Notification", msg);
   if(SendApp)
      SendNotification(msg);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendTSNotification(ulong Ticket, double Price, string Instrument)
  {
   if(!EnableNotify || (!SendAlert && !SendApp && !SendEmail))
      return;
   string msg = "BEC Trailing Stop: SL for position #" + IntegerToString(Ticket) + " → " + DoubleToString(Price, _Digits);
   if(SendAlert)
      Alert(msg);
   if(SendEmail)
      SendMail("BEC " + Instrument + " TS Notification", msg);
   if(SendApp)
      SendNotification(msg);
  }

//============================================================
//  DASHBOARD — GET TODAY'S PROFIT FROM HISTORY
//============================================================
double GetTodayProfit()
  {
   datetime today_start = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
   HistorySelect(today_start, TimeCurrent());
   double dayProfit = 0;
   int deals = HistoryDealsTotal();
   for(int i = 0; i < deals; i++)
     {
      ulong deal = HistoryDealGetTicket(i);
      if(deal == 0)
         continue;
      if(HistoryDealGetString(deal, DEAL_SYMBOL) != Symbol())
         continue;
      if((HistoryDealGetInteger(deal, DEAL_TYPE) == DEAL_TYPE_BUY) ||
         (HistoryDealGetInteger(deal, DEAL_TYPE) == DEAL_TYPE_SELL))
        {
         dayProfit += HistoryDealGetDouble(deal, DEAL_PROFIT)
                      + HistoryDealGetDouble(deal, DEAL_SWAP)
                      + HistoryDealGetDouble(deal, DEAL_COMMISSION);
        }
     }
   return dayProfit;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetFloatingProfit()
  {
   double floating = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;
      floating += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
     }
   return floating;
  }

//============================================================
//  DRAW PANEL HELPER
//============================================================
void CreateLabel(string name, int x, int y, int w, int h, string text,
                 color fg, color bg, int fsize, bool bold = false,
                 ENUM_ALIGN_MODE align = ALIGN_CENTER, bool selectable = false)
  {
   if(ObjectFind(ChartID(), name) < 0)
      ObjectCreate(ChartID(), name, OBJ_BUTTON, 0, 0, 0);

   ObjectSetInteger(ChartID(), name, OBJPROP_CORNER,      ChartCorner);
   ObjectSetInteger(ChartID(), name, OBJPROP_XDISTANCE,   x);
   ObjectSetInteger(ChartID(), name, OBJPROP_YDISTANCE,   y);
   ObjectSetInteger(ChartID(), name, OBJPROP_XSIZE,       w);
   ObjectSetInteger(ChartID(), name, OBJPROP_YSIZE,       h);
   ObjectSetString(ChartID(), name, OBJPROP_TEXT,        text);
   ObjectSetInteger(ChartID(), name, OBJPROP_COLOR,       fg);
   ObjectSetInteger(ChartID(), name, OBJPROP_BGCOLOR,     bg);
   ObjectSetInteger(ChartID(), name, OBJPROP_BORDER_COLOR,clrNONE);
   ObjectSetInteger(ChartID(), name, OBJPROP_FONTSIZE,    fsize);
   ObjectSetString(ChartID(), name, OBJPROP_FONT,        bold ? "Consolas" : "Consolas");
   ObjectSetInteger(ChartID(), name, OBJPROP_ALIGN,       align);
   ObjectSetInteger(ChartID(), name, OBJPROP_HIDDEN,      true);
   ObjectSetInteger(ChartID(), name, OBJPROP_READONLY,    !selectable);
   ObjectSetInteger(ChartID(), name, OBJPROP_SELECTABLE, true);
  }

//============================================================
//  DRAW PANEL — BEC BRANDED DASHBOARD
//============================================================
void DrawPanel()
  {
   int x = Xoff;
   int y = Yoff;
   int w = 310;       // panel width
   int rowH = 30;     // standard row height
   int gap  = 10;
   int padY = y;

// ── BEC Brand colors ──
   color cDark      = C'30,33,37';      // --dark
   color cDark2     = C'44,48,53';      // --dark2
   color cGreen     = C'76,174,76';     // --g
   color cGreenDark = C'61,158,61';     // --gd
   color cGreenLight= C'232,245,232';   // --gl
   color cWhite     = clrWhite;
   color cGold      = C'255,170,6';     // primary accent
   color cRed       = C'220,60,60';

// Floating profit
   double floating   = GetFloatingProfit();
   double equity     = AccountInfoDouble(ACCOUNT_EQUITY);
   double dayProfit  = GetTodayProfit();
   double bid        = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   color  floatColor = (floating >= 0) ? cGreen : cRed;
   color  dayColor   = (dayProfit >= 0) ? cGreen : cRed;

// ── Background panel ──
   if(ObjectFind(ChartID(), PanelBase) < 0)
      ObjectCreate(ChartID(), PanelBase, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_CORNER,    ChartCorner);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_YDISTANCE, padY);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_XSIZE,     w + 4);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_YSIZE,     230);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_BGCOLOR,   cDark);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_COLOR,     cGold);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_HIDDEN,    true);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_SELECTABLE,false);

// ── Title bar ──
 CreateLabel(PanelTitle, x+2, padY+2, w, rowH, "BEC  TRADE MANAGER", cGold, cDark2, FontSize+1, true, ALIGN_LEFT);
padY += rowH + gap;

// ── Big current price ──
   string priceStr = DoubleToString(bid, _Digits);
   CreateLabel(PanelPrice, x+2, padY, w, rowH, priceStr, cWhite, cDark2, FontSize+6, true, ALIGN_CENTER);
   padY += rowH + gap;

// ── Equity row ──
   string eqStr = "Equity: " + DoubleToString(equity, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY);
   CreateLabel(PanelEquity, x+2, padY, w, rowH, eqStr, cWhite, cDark, FontSize, false, ALIGN_CENTER);
   padY += rowH + gap;

// ── Floating P/L ──
   string floatStr = "Float: " + (floating >= 0 ? "+" : "") + DoubleToString(floating, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY);
   CreateLabel(PanelFloating, x+2, padY, w, rowH, floatStr, floatColor, cDark, FontSize, false, ALIGN_CENTER);
   padY += rowH + gap;

// ── Today's profit ──
   string dayStr = "Today: " + (dayProfit >= 0 ? "+" : "") + DoubleToString(dayProfit, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY);
   CreateLabel(PanelDayProfit, x+2, padY, w, rowH, dayStr, dayColor, cDark, FontSize, false, ALIGN_CENTER);
   padY += rowH + gap + 2;

// ── BE toggle button ──
   string beText  = EnableBE    ? "BREAKEVEN  ON" : "BREAKEVEN OFF";
   color  beBg    = EnableBE    ? cGreenDark : C'100,30,30';
   CreateLabel(PanelBEToggle, x+2, padY, w/2-1, rowH, beText, cWhite, beBg, FontSize-1, false, ALIGN_CENTER, true);

// ── Trail toggle button ──
   string tsText  = EnableTrail ? "TRAIL  ON" : "TRAIL OFF";
   color  tsBg    = EnableTrail ? cGreenDark : C'100,30,30';
   CreateLabel(PanelTSToggle, x+2+(w/2)+1, padY, w/2-1, rowH, tsText, cWhite, tsBg, FontSize-1, false, ALIGN_CENTER, true);
   padY += rowH + gap + 2;

// ── ACTION BUTTON 1 ──
   CreateLabel(PanelBtn1, x+2, padY, w, rowH+2, "Close Smallest Profit Trade", cDark, cGold, FontSize-1, true, ALIGN_CENTER, true);
   padY += rowH + gap;

// ── ACTION BUTTON 2 ──
   CreateLabel(PanelBtn2, x+2, padY, w, rowH+2, "Close 50% + Set BE (All)", cWhite, C'0,100,180', FontSize-1, true, ALIGN_CENTER, true);
   padY += rowH + gap;

// ── ACTION BUTTON 3 ──
   CreateLabel(PanelBtn3, x+2, padY, w, rowH+2, "CLOSE ALL + DELETE ORDERS", cWhite, cRed, FontSize-1, true, ALIGN_CENTER, true);
   padY += rowH + gap;

// ── SCALPING BUTTONS ──

   CreateLabel(PanelScalpSell, x+2, padY, w/2-1, rowH+2, "SCALP SELL 0.01", clrWhite, C'180,0,0', FontSize, true, ALIGN_CENTER, true);
//CreateLabel(PanelScalpBuy, x+2, padY, w/2-1, rowH+2, "SCALP BUY 0.01", clrWhite, C'0,150,0', FontSize, true, ALIGN_CENTER, true);
   CreateLabel(PanelScalpBuy, x+2+(w/2)+1, padY, w/2-1, rowH+2, "SCALP BUY 0.01", clrWhite, C'0,150,0', FontSize, true, ALIGN_CENTER, true);


   ChartRedraw();
  }

//============================================================
//  CLEAN PANEL
//============================================================
void CleanPanel()
  {
   ObjectsDeleteAll(ChartID(), "BEC-P-");
   ChartRedraw();
  }
//+------------------------------------------------------------------+
