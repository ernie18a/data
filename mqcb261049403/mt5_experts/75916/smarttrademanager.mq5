#property copyright "Waseem Shahrukh"
#property version   "1.00"
#property description "Auto structure based SL + profit trailing for manual trades & pendings. DEMO test first."

#include <Trade/Trade.mqh>
CTrade trade;

//--- cached ATR handles (avoid creating/releasing a handle every tick)
string g_atrSym[];
int    g_atrHandle[];

int GetATRHandle(const string sym)
{
   for(int i=0;i<ArraySize(g_atrSym);i++)
      if(g_atrSym[i]==sym) return g_atrHandle[i];
   int h = iATR(sym, InpStructTF, InpATRPeriod);
   if(h==INVALID_HANDLE) return INVALID_HANDLE;
   int n=ArraySize(g_atrSym);
   ArrayResize(g_atrSym,n+1); ArrayResize(g_atrHandle,n+1);
   g_atrSym[n]=sym; g_atrHandle[n]=h;
   return h;
}


input group "=== Scope ==="
input bool   InpOnlyManual      = true;   // Manage only manual trades (magic == 0)
input long   InpAlsoMagic       = -1;     // Also manage this magic (-1 = none)
input bool   InpManagePendings  = true;   // Also assign SL/TP to pending orders

input group "=== Structure / ATR (SL placement brain) ==="
input ENUM_TIMEFRAMES InpStructTF = PERIOD_M15; // Timeframe for swings + ATR
input int    InpATRPeriod       = 14;     // ATR period
input int    InpSwingLookback   = 20;     // Bars to find recent swing high/low
input double InpATRBuffer       = 0.6;    // ATR buffer beyond swing (so SL isn't clipped)
input double InpMinSL_ATR       = 1.2;    // Min SL distance = this x ATR (anti-tight floor)
input double InpMaxSL_ATR       = 4.0;    // Max SL distance = this x ATR (anti-huge cap)

input group "=== Breakeven (kill the loss early) ==="
input bool   InpUseBreakeven    = true;   // Move SL to entry once in profit
input double InpBE_TriggerR     = 1.0;    // Trigger breakeven at this many R of profit
input double InpBE_LockR        = 0.10;   // Lock this many R of profit at breakeven (covers cost)

input group "=== GOLD trailing profile (XAU*) ==="
input double InpGold_TrailStartR = 1.2;   // Start trailing after this many R profit
input double InpGold_TrailATR    = 1.3;   // Trail distance = this x ATR (give-back)

input group "=== FX trailing profile (EURUSD / USDJPY) ==="
input double InpFX_TrailStartR   = 2.0;   // FX breathe longer before trailing
input double InpFX_TrailATR      = 2.0;   // Wider give-back for chop

input group "=== Optional fixed TP (off by default) ==="
input bool   InpUseFixedTP      = false;  // Set a hard TP (caps winners - usually leave OFF)
input double InpFixedTP_R        = 3.0;   // TP = this many R if enabled

input group "=== Safety ==="
input int    InpMaxSpreadPts    = 60;     // Skip modifying if spread > this (points). 0 = ignore
input int    InpSlippagePts     = 30;     // Deviation for modify ops
input bool   InpVerboseLog      = true;   // Print actions to Experts log

input group "=== DOLLAR protection (R-independent safety) ==="
input bool   InpUseMoneyProtect = true;   // Master switch for dollar-based protection
input double InpCommissionPerLot= 7.0;    // Round-turn commission per 1.0 lot (for NET calc)
input double InpMoneySecureTrig  = 12.0;  // Once NET profit >= this $, start locking
input double InpMoneySecureLock  = 5.0;   // Guarantee at least this $ profit via SL
input double InpMoneyGiveback    = 7.0;   // If profit falls this $ from PEAK -> close at market


enum SymProfile { PROFILE_GOLD, PROFILE_FX };

int OnInit()
{
   trade.SetDeviationInPoints(InpSlippagePts);
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.LogLevel(LOG_LEVEL_ERRORS);
   EventSetTimer(1);   // manage all symbols every second, independent of chart symbol ticks
   if(InpVerboseLog) Print("SmartTradeManagerDollar started. Manages manual trades + pendings. DEMO-test first.");
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){ EventKillTimer(); }

void OnTimer()
{
   ManagePositions();
   if(InpManagePendings) ManagePendings();
}

SymProfile GetProfile(const string sym)
{
   if(StringFind(sym,"XAU")>=0 || StringFind(sym,"GOLD")>=0) return PROFILE_GOLD;
   return PROFILE_FX;   // EURUSD, USDJPY and other FX
}

double GetATR(const string sym)
{
   int h = GetATRHandle(sym);
   if(h==INVALID_HANDLE) return 0.0;
   double buf[];
   if(CopyBuffer(h,0,1,1,buf)<1) return 0.0;   // use last CLOSED bar
   return buf[0];
}

// recent swing low / high from CLOSED bars (anti-repaint)
bool GetSwing(const string sym, bool wantLow, double &outVal)
{
   double price[];
   int copied;
   if(wantLow){
      double lows[];
      copied = CopyLow(sym, InpStructTF, 1, InpSwingLookback, lows);
      if(copied<1) return false;
      outVal = lows[ArrayMinimum(lows,0,copied)];
   } else {
      double highs[];
      copied = CopyHigh(sym, InpStructTF, 1, InpSwingLookback, highs);
      if(copied<1) return false;
      outVal = highs[ArrayMaximum(highs,0,copied)];
   }
   return true;
}

bool SpreadOK(const string sym)
{
   if(InpMaxSpreadPts<=0) return true;
   long spr = SymbolInfoInteger(sym, SYMBOL_SPREAD);
   return (spr <= InpMaxSpreadPts);
}

// clamp an SL/TP so it respects broker min stop distance from the reference price
double RespectStops(const string sym, double price_ref, double level, bool isSL, bool isBuy)
{
   double point = SymbolInfoDouble(sym, SYMBOL_POINT);
   long   stops = SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL);
   double minDist = (stops+2)*point;
   if(isBuy){
      if(isSL){ if(price_ref-level < minDist) level = price_ref-minDist; }
      else    { if(level-price_ref < minDist) level = price_ref+minDist; }
   } else {
      if(isSL){ if(level-price_ref < minDist) level = price_ref+minDist; }
      else    { if(price_ref-level < minDist) level = price_ref-minDist; }
   }
   return NormalizeDouble(level, (int)SymbolInfoInteger(sym, SYMBOL_DIGITS));
}


double InitialSLDistance(const string sym, bool isBuy, double entry, double atr, double &slPriceOut)
{
   double swing;
   double structDist = InpMinSL_ATR*atr;   // fallback
   if(GetSwing(sym, isBuy, swing))          // buy -> need swing LOW; sell -> swing HIGH
   {
      double d = (isBuy ? (entry - swing) : (swing - entry)) + InpATRBuffer*atr;
      if(d > 0) structDist = d;
   }
   // bound it: not too tight, not too huge
   double minD = InpMinSL_ATR*atr;
   double maxD = InpMaxSL_ATR*atr;
   if(structDist < minD) structDist = minD;
   if(structDist > maxD) structDist = maxD;

   slPriceOut = isBuy ? (entry - structDist) : (entry + structDist);
   return structDist;
}


ulong  g_peakTicket[];
double g_peakProfit[];

double PeakUpdate(ulong ticket, double curNet)
{
   for(int i=0;i<ArraySize(g_peakTicket);i++)
      if(g_peakTicket[i]==ticket){
         if(curNet>g_peakProfit[i]) g_peakProfit[i]=curNet;
         return g_peakProfit[i];
      }
   int n=ArraySize(g_peakTicket);
   ArrayResize(g_peakTicket,n+1); ArrayResize(g_peakProfit,n+1);
   g_peakTicket[n]=ticket; g_peakProfit[n]=curNet;
   return curNet;
}

void PeakPrune()
{
   for(int i=ArraySize(g_peakTicket)-1;i>=0;i--)
      if(!PositionSelectByTicket(g_peakTicket[i])){
         int last=ArraySize(g_peakTicket)-1;
         g_peakTicket[i]=g_peakTicket[last]; g_peakProfit[i]=g_peakProfit[last];
         ArrayResize(g_peakTicket,last); ArrayResize(g_peakProfit,last);
      }
}

double DollarsToPrice(const string sym, double volume, double dollars)
{
   double tickVal = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
   double tickSz  = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
   if(tickVal<=0 || tickSz<=0 || volume<=0) return 0.0;
   double perPrice = (tickVal/tickSz)*volume;   // $ per 1.0 price unit
   if(perPrice<=0) return 0.0;
   return dollars/perPrice;
}


void OnTick()
{
   ManagePositions();
   if(InpManagePendings) ManagePendings();
}


bool IsManaged(const string sym, long magic)
{
   bool symOK = (GetProfile(sym)==PROFILE_GOLD) ||
                (StringFind(sym,"EURUSD")>=0)    ||
                (StringFind(sym,"USDJPY")>=0);
   if(!symOK) return false;
   if(InpOnlyManual){
      if(magic==0) return true;
      if(InpAlsoMagic>=0 && magic==InpAlsoMagic) return true;
      return false;
   }
   return true;
}

void ManagePositions()
{
   PeakPrune();
   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket==0) continue;
      if(!PositionSelectByTicket(ticket)) continue;

      string sym  = PositionGetString(POSITION_SYMBOL);
      long   magic= PositionGetInteger(POSITION_MAGIC);
      if(!IsManaged(sym,magic)) continue;
      if(!SpreadOK(sym)) continue;

      long   type = PositionGetInteger(POSITION_TYPE);
      bool   isBuy= (type==POSITION_TYPE_BUY);
      double entry= PositionGetDouble(POSITION_PRICE_OPEN);
      double curSL= PositionGetDouble(POSITION_SL);
      double curTP= PositionGetDouble(POSITION_TP);
      double bid  = SymbolInfoDouble(sym, SYMBOL_BID);
      double ask  = SymbolInfoDouble(sym, SYMBOL_ASK);
      double cur  = isBuy ? bid : ask;        // price we exit at
      double atr  = GetATR(sym);
      if(atr<=0) continue;

      SymProfile prof = GetProfile(sym);

      //--- STEP 1: no SL yet -> place structure-based SL (+ optional TP)
      if(curSL==0.0)
      {
         double slPrice;
         double slDist = InitialSLDistance(sym, isBuy, entry, atr, slPrice);
         slPrice = RespectStops(sym, cur, slPrice, true, isBuy);

         double tpPrice = 0.0;
         if(InpUseFixedTP){
            tpPrice = isBuy ? entry + InpFixedTP_R*slDist : entry - InpFixedTP_R*slDist;
            tpPrice = RespectStops(sym, cur, tpPrice, false, isBuy);
         }
         if(trade.PositionModify(ticket, slPrice, tpPrice)){
            if(InpVerboseLog) PrintFormat("[INIT] %s %s SL=%.5f TP=%.5f (slDist=%.5f, %s)",
                sym, (isBuy?"BUY":"SELL"), slPrice, tpPrice, slDist, (prof==PROFILE_GOLD?"GOLD":"FX"));
         }
         continue;   // next tick will start trailing logic
      }

      //--- derive original risk (R) from current SL distance to entry
      double rDist = MathAbs(entry - curSL);
      if(rDist<=0) rDist = InpMinSL_ATR*atr;   // safety fallback
      double profitDist = isBuy ? (cur - entry) : (entry - cur);  // favorable distance
      double rNow = (rDist>0) ? profitDist/rDist : 0.0;

      if(InpUseMoneyProtect)
      {
         double vol   = PositionGetDouble(POSITION_VOLUME);
         double gross = PositionGetDouble(POSITION_PROFIT);
         double swap  = PositionGetDouble(POSITION_SWAP);
         double net   = gross + swap - InpCommissionPerLot*vol;   // estimated NET $
         double peak  = PeakUpdate(ticket, net);

         // (a) peak give-back -> CLOSE at market (this answers "kab out hona hai")
         if(peak >= InpMoneySecureTrig && (peak - net) >= InpMoneyGiveback)
         {
            if(trade.PositionClose(ticket)){
               if(InpVerboseLog) PrintFormat("[$CLOSE] %s net=%.2f peak=%.2f giveback>=%.2f -> closed",
                   sym, net, peak, InpMoneyGiveback);
               continue;   // done with this position
            }
         }

         // (b) secure-lock: once net >= trigger, force SL to lock >= SecureLock $
         if(net >= InpMoneySecureTrig)
         {
            double lockDist = DollarsToPrice(sym, vol, InpMoneySecureLock);
            if(lockDist>0){
               double lockSL = isBuy ? (entry + lockDist) : (entry - lockDist);
               lockSL = RespectStops(sym, cur, lockSL, true, isBuy);
               bool better = isBuy ? (lockSL > curSL) : (lockSL < curSL);
               if(better && trade.PositionModify(ticket, lockSL, curTP)){
                  curSL = lockSL;
                  if(InpVerboseLog) PrintFormat("[$LOCK] %s SL->%.5f (lock $%.2f)", sym, lockSL, InpMoneySecureLock);
               }
            }
         }
      }

      if(InpUseBreakeven && rNow >= InpBE_TriggerR)
      {
         double bePrice = isBuy ? entry + InpBE_LockR*rDist : entry - InpBE_LockR*rDist;
         bePrice = RespectStops(sym, cur, bePrice, true, isBuy);
         bool better = isBuy ? (bePrice > curSL) : (bePrice < curSL);
         if(better){
            if(trade.PositionModify(ticket, bePrice, curTP)){
               curSL = bePrice;
               if(InpVerboseLog) PrintFormat("[BE] %s SL->%.5f (locked %.2fR)", sym, bePrice, InpBE_LockR);
            }
         }
      }

      //--- STEP 3: trailing (profile-specific start + distance)
      double trailStartR = (prof==PROFILE_GOLD) ? InpGold_TrailStartR : InpFX_TrailStartR;
      double trailATR    = (prof==PROFILE_GOLD) ? InpGold_TrailATR    : InpFX_TrailATR;

      if(rNow >= trailStartR)
      {
         double trailDist = trailATR*atr;
         double newSL = isBuy ? (cur - trailDist) : (cur + trailDist);
         newSL = RespectStops(sym, cur, newSL, true, isBuy);
         bool better = isBuy ? (newSL > curSL) : (newSL < curSL);
         if(better){
            if(trade.PositionModify(ticket, newSL, curTP)){
               if(InpVerboseLog) PrintFormat("[TRAIL] %s SL->%.5f (%.2fR, %s)", sym, newSL, rNow, (prof==PROFILE_GOLD?"GOLD":"FX"));
            }
         }
      }
   }
}


void ManagePendings()
{
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket==0) continue;
      if(!OrderSelect(ticket)) continue;

      string sym  = OrderGetString(ORDER_SYMBOL);
      long   magic= OrderGetInteger(ORDER_MAGIC);
      if(!IsManaged(sym,magic)) continue;
      if(!SpreadOK(sym)) continue;

      long type = OrderGetInteger(ORDER_TYPE);
      bool isBuy = (type==ORDER_TYPE_BUY_LIMIT || type==ORDER_TYPE_BUY_STOP);
      bool isPend= (type==ORDER_TYPE_BUY_LIMIT||type==ORDER_TYPE_SELL_LIMIT||
                    type==ORDER_TYPE_BUY_STOP ||type==ORDER_TYPE_SELL_STOP);
      if(!isPend) continue;

      double curSL = OrderGetDouble(ORDER_SL);
      double curTP = OrderGetDouble(ORDER_TP);
      if(curSL!=0.0) continue;   // already protected

      double entry = OrderGetDouble(ORDER_PRICE_OPEN);
      double atr   = GetATR(sym);
      if(atr<=0) continue;

      double slPrice;
      double slDist = InitialSLDistance(sym, isBuy, entry, atr, slPrice);
      // for pendings, clamp relative to the order's own entry price
      slPrice = NormalizeDouble(slPrice,(int)SymbolInfoInteger(sym,SYMBOL_DIGITS));

      double tpPrice = 0.0;
      if(InpUseFixedTP)
         tpPrice = NormalizeDouble(isBuy ? entry+InpFixedTP_R*slDist : entry-InpFixedTP_R*slDist,
                                   (int)SymbolInfoInteger(sym,SYMBOL_DIGITS));

      if(trade.OrderModify(ticket, entry, slPrice, tpPrice, ORDER_TIME_GTC, 0)){
         if(InpVerboseLog) PrintFormat("[PEND] %s %s SL=%.5f TP=%.5f assigned",
             sym, (isBuy?"BUY":"SELL"), slPrice, tpPrice);
      }
   }
}

