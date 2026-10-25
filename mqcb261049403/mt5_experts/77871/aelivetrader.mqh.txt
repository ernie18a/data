//+------------------------------------------------------------------+
//|                                                 AeLiveTrader.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23814 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23814"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <IntrinsicTime\AeRunner.mqh>
#include <IntrinsicTime\AeLiquidity.mqh>

//+------------------------------------------------------------------+
//| CAeLiveTrader - one coastline agent, trading real limit orders.  |
//|                                                                  |
//|  This is the live execution of one CoastlineTrader from the      |
//|  paper, for a hedging account. The decision core is ported       |
//|  verbatim - the three inventory-skewed runners and the liquidity |
//|  indicator - and only the order handling is adapted to the       |
//|  terminal.                                                       |
//|                                                                  |
//|  Every step of the cascade is a limit order, so nothing crosses  |
//|  the spread, exactly as the paper intends. A long agent keeps a  |
//|  single buy-limit resting at the next downward intrinsic-event   |
//|  level, ExpectedLowerIE; when it fills, that position carries a  |
//|  take-profit delta above its entry, which is the de-cascade -    |
//|  the trim happens as its own limit exit. As the price runs down  |
//|  the ladder of buy limits fills (cascading); as it recovers the  |
//|  take-profits fire one by one (de-cascading). A short agent is   |
//|  the mirror image on ExpectedUpperIE. Because the account is     |
//|  hedging, each cascade step is its own position, which is the    |
//|  natural home for the reference's list of imbalanced orders.     |
//|                                                                  |
//|  The volume of each add follows the paper: a base unit halved,   |
//|  then quartered, as the inventory grows past 15 and 30 units,    |
//|  and shrunk again by the liquidity indicator. Abstract units are |
//|  turned into lots by LotPerUnit; a MaxUnits cap - a small piece  |
//|  of risk control the paper deliberately omits - stops the        |
//|  inventory from running away in a persistent trend.              |
//+------------------------------------------------------------------+
class CAeLiveTrader
  {
private:
   CAeRunner         m_runners[3];     // symmetric, then two skewed runners
   CAeLocalLiquidity m_liq;            // probability indicator L
   CTrade            m_trade;          // order execution helper

   string            m_symbol;
   long              m_magic;          // owns this agent's orders/positions
   int               m_long_short;     // +1 long-only, -1 short-only
   double            m_delta;          // base threshold
   double            m_lot_per_unit;   // lots per one abstract unit
   double            m_max_units;      // inventory cap (safety)
   int               m_last_idx;       // active runner last tick, for refresh
   bool              m_money_short;    // entry paused for lack of margin

//--- last margin check and the account state it was made in.
   bool              m_chk_ok;
   int               m_chk_pos;
   int               m_chk_ord;
   double            m_chk_bal;
   double            m_chk_osum;
   double            m_chk_lots;
   double            m_chk_price;
   datetime          m_chk_time;

//--- symbol trading specs, cached at Init.
   double            m_lot_min;
   double            m_lot_max;
   double            m_lot_step;
   int               m_digits;
   double            m_point;
   double            m_stop_dist;      // minimum order distance, price units

   int               ProperRunnerIndex(const double inv_units);
   double            UnitFromInventory(const double inv_units);
   double            LiqCoef(const double liq);
   double            NormalizeLots(const double v);
   double            InventoryUnitsAbs(void);
   ulong             MyEntryTicket(void);
   bool              MyEntryInfo(double &level,double &volume,double &tp);
   bool              EntryFrozen(const double level);
   bool              EnoughMoney(const double lots,const double price);
   bool              CanAfford(const double lots,const double price,const datetime time);
   void              PlaceOrRefreshEntry(const double level,const double lots,const double tp);
   void              CancelEntry(void);

public:
                     CAeLiveTrader(void);

//--- one side (+1/-1) at one base threshold, mapped to lots.
   bool              Init(const string symbol,const long magic,const int long_short,
                          const double delta,const double lot_per_unit,const double max_units);

//--- drive the agent with the current quote.
   void              OnTickUpdate(const double bid,const double ask,const datetime time);

//--- cancel this agent's resting order (positions are left in place).
   void              Shutdown(void);

   long              Magic(void)     const { return m_magic; }
   double            Liquidity(void)       { return m_liq.Liq(); }
  };

//+------------------------------------------------------------------+
//| Construct empty.                                                 |
//+------------------------------------------------------------------+
CAeLiveTrader::CAeLiveTrader(void)
  {
   m_symbol="";
   m_magic=0;
   m_long_short=1;
   m_delta=0.0;
   m_lot_per_unit=0.0;
   m_max_units=0.0;
   m_last_idx=-1;
   m_money_short=false;
   m_chk_ok=false;
   m_chk_pos=-1;
   m_chk_ord=-1;
   m_chk_bal=0.0;
   m_chk_osum=0.0;
   m_chk_lots=0.0;
   m_chk_price=0.0;
   m_chk_time=0;
   m_lot_min=0.0;
   m_lot_max=0.0;
   m_lot_step=0.0;
   m_digits=5;
   m_point=0.0;
   m_stop_dist=0.0;
  }

//+------------------------------------------------------------------+
//| Configure the agent, its runners and its symbol specs.           |
//+------------------------------------------------------------------+
bool CAeLiveTrader::Init(const string symbol,const long magic,const int long_short,
                         const double delta,const double lot_per_unit,const double max_units)
  {
   m_symbol=symbol;
   m_magic=magic;
   m_long_short=long_short;
   m_delta=delta;
   m_lot_per_unit=lot_per_unit;
   m_max_units=max_units;
   m_last_idx=-1;
   m_money_short=false;
   m_chk_ok=false;
   m_chk_pos=-1;
   m_chk_ord=-1;
   m_chk_bal=0.0;
   m_chk_osum=0.0;
   m_chk_lots=0.0;
   m_chk_price=0.0;
   m_chk_time=0;

//--- the three runners, skewed by side exactly as the reference.
   double d=delta;
   m_runners[0].Init(d,d,d,d);
   if(long_short==1)
     {
      m_runners[1].Init(0.75*d,1.50*d,0.75*d,0.75*d);
      m_runners[2].Init(0.50*d,2.00*d,0.50*d,0.50*d);
     }
   else
     {
      m_runners[1].Init(1.50*d,0.75*d,0.75*d,0.75*d);
      m_runners[2].Init(2.00*d,0.50*d,0.50*d,0.50*d);
     }
   m_liq.Init(delta,delta*2.525729,50.0);

//--- symbol specs.
   m_lot_min =SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   m_lot_max =SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   m_lot_step=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   m_digits  =(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   m_point   =SymbolInfoDouble(symbol,SYMBOL_POINT);
   long slevel=SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL);
   m_stop_dist=(double)slevel*m_point;

   m_trade.SetExpertMagicNumber(magic);
   m_trade.SetTypeFillingBySymbol(symbol);
   m_trade.LogLevel(LOG_LEVEL_NO);
   return true;
  }

//+------------------------------------------------------------------+
//| Runner tier by absolute inventory, per the paper.                |
//+------------------------------------------------------------------+
int CAeLiveTrader::ProperRunnerIndex(const double inv_units)
  {
   if(inv_units<15.0)
      return 0;
   if(inv_units<30.0)
      return 1;
   return 2;
  }

//+------------------------------------------------------------------+
//| Unit haircut by absolute inventory (1, then 1/2, then 1/4).      |
//+------------------------------------------------------------------+
double CAeLiveTrader::UnitFromInventory(const double inv_units)
  {
   if(inv_units<15.0)
      return 1.0;
   if(inv_units<30.0)
      return 0.5;
   return 0.25;
  }

//+------------------------------------------------------------------+
//| Liquidity haircut on the unit (paper, page 15).                  |
//+------------------------------------------------------------------+
double CAeLiveTrader::LiqCoef(const double liq)
  {
   if(liq>=0.5)
      return 1.0;
   if(liq>=0.1)
      return 0.5;
   return 0.1;
  }

//+------------------------------------------------------------------+
//| Round a lot request to the symbol step and clamp to its bounds.  |
//+------------------------------------------------------------------+
double CAeLiveTrader::NormalizeLots(const double v)
  {
   if(m_lot_step<=0.0)
      return v;
   double r=MathRound(v/m_lot_step)*m_lot_step;
   if(r<m_lot_min)
      r=m_lot_min;
   if(r>m_lot_max)
      r=m_lot_max;
   return r;
  }

//+------------------------------------------------------------------+
//| Absolute inventory of this agent, in units, read from positions. |
//+------------------------------------------------------------------+
double CAeLiveTrader::InventoryUnitsAbs(void)
  {
   double lots=0.0;
   int total=PositionsTotal();
   for(int i=0;i<total;i++)
     {
      ulong tk=PositionGetTicket(i);
      if(tk==0)
         continue;
      if(PositionGetInteger(POSITION_MAGIC)!=m_magic)
         continue;
      if(PositionGetString(POSITION_SYMBOL)!=m_symbol)
         continue;
      lots+=PositionGetDouble(POSITION_VOLUME);
     }
   if(m_lot_per_unit<=0.0)
      return 0.0;
   return lots/m_lot_per_unit;
  }

//+------------------------------------------------------------------+
//| Ticket of this agent's resting entry order, 0 if none.           |
//+------------------------------------------------------------------+
ulong CAeLiveTrader::MyEntryTicket(void)
  {
   int want=(m_long_short==1)?ORDER_TYPE_BUY_LIMIT:ORDER_TYPE_SELL_LIMIT;
   int total=OrdersTotal();
   for(int i=0;i<total;i++)
     {
      ulong tk=OrderGetTicket(i);
      if(tk==0)
         continue;
      if(OrderGetInteger(ORDER_MAGIC)!=m_magic)
         continue;
      if(OrderGetString(ORDER_SYMBOL)!=m_symbol)
         continue;
      if((int)OrderGetInteger(ORDER_TYPE)==want)
         return tk;
     }
   return 0;
  }

//+------------------------------------------------------------------+
//| Read the resting entry's level, volume and take-profit.          |
//+------------------------------------------------------------------+
bool CAeLiveTrader::MyEntryInfo(double &level,double &volume,double &tp)
  {
   ulong tk=MyEntryTicket();
   if(tk==0)
      return false;
   if(!OrderSelect(tk))
      return false;
   level =OrderGetDouble(ORDER_PRICE_OPEN);
   volume=OrderGetDouble(ORDER_VOLUME_CURRENT);
   tp    =OrderGetDouble(ORDER_TP);
   return true;
  }

//+------------------------------------------------------------------+
//| Is a resting entry at 'level' inside the freeze level, where the |
//| server refuses to modify or delete it.                           |
//+------------------------------------------------------------------+
bool CAeLiveTrader::EntryFrozen(const double level)
  {
   MqlTick t;
   if(!SymbolInfoTick(m_symbol,t))
      return true;
   long flevel=SymbolInfoInteger(m_symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   double freeze=(double)flevel*m_point;
   if(m_long_short==1)
      return (t.ask-level<=freeze);
   return (level-t.bid<=freeze);
  }

//+------------------------------------------------------------------+
//| Can the account pay the margin of 'lots' filled at 'price'.      |
//|  A limit order takes its margin when it fills, not when it is    |
//|  placed, so a fill the account cannot afford is refused as "not  |
//|  enough money". The worst case is a gap straight to 'price': on  |
//|  that one tick every same-side limit on the way fills too, the   |
//|  open same-side positions lose the move, and opposite positions  |
//|  closed by their take-profits on the way stop hedging. All of it |
//|  must fit in today's free margin. The pause is reported once,    |
//|  not on every tick.                                              |
//+------------------------------------------------------------------+
bool CAeLiveTrader::EnoughMoney(const double lots,const double price)
  {
   ENUM_ORDER_TYPE type=(m_long_short==1)?ORDER_TYPE_BUY:ORDER_TYPE_SELL;
   ENUM_POSITION_TYPE ptype=(m_long_short==1)?POSITION_TYPE_BUY:POSITION_TYPE_SELL;
   ENUM_ORDER_TYPE ltype=(m_long_short==1)?ORDER_TYPE_BUY_LIMIT:ORDER_TYPE_SELL_LIMIT;
   double need=0.0;
   bool ok=OrderCalcMargin(type,m_symbol,lots,price,need);

//--- open same-side positions: what they lose if price gaps there;
//--- opposite positions whose take-profit fires on the way: they stop
//--- hedging this side, so their volume needs margin of its own.
   int total=PositionsTotal();
   for(int i=0;i<total && ok;i++)
     {
      if(PositionGetTicket(i)==0)
         continue;
      if(PositionGetString(POSITION_SYMBOL)!=m_symbol)
         continue;
      double vol=PositionGetDouble(POSITION_VOLUME);
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==ptype)
        {
         double pnl=0.0;
         ok=OrderCalcProfit(type,m_symbol,vol,PositionGetDouble(POSITION_PRICE_CURRENT),
                            price,pnl);
         if(pnl<0.0)
            need-=pnl;
         continue;
        }
      double tp=PositionGetDouble(POSITION_TP);
      if(tp<=0.0 || ((m_long_short==1)?(tp<price):(tp>price)))
         continue;
      double m=0.0;
      ok=OrderCalcMargin(type,m_symbol,vol,tp,m);
      need+=m;
     }

//--- other same-side limits the gap would fill on its way here.
   ulong own=MyEntryTicket();
   total=OrdersTotal();
   for(int i=0;i<total && ok;i++)
     {
      ulong tk=OrderGetTicket(i);
      if(tk==0 || tk==own)
         continue;
      if(OrderGetString(ORDER_SYMBOL)!=m_symbol)
         continue;
      if((ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE)!=ltype)
         continue;
      double lvl=OrderGetDouble(ORDER_PRICE_OPEN);
      if((m_long_short==1)?(lvl<price):(lvl>price))
         continue;
      double vol=OrderGetDouble(ORDER_VOLUME_CURRENT);
      double m=0.0,pnl=0.0;
      ok=OrderCalcMargin(type,m_symbol,vol,lvl,m) &&
         OrderCalcProfit(type,m_symbol,vol,lvl,price,pnl);
      need+=m;
      if(pnl<0.0)
         need-=pnl;
     }

   double free=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   ok=ok && (need<=free);
   if(!ok && !m_money_short)
      PrintFormat("AlphaEngine %I64d: entry paused, %.2f lots need %.2f, %.2f free",
                  m_magic,lots,need,free);
   m_money_short=!ok;
   return ok;
  }

//+------------------------------------------------------------------+
//| EnoughMoney, rerun only when its answer can have changed.        |
//|  The full check walks every position and order, too slow for     |
//|  every tick of every agent. Price drifting toward the level only |
//|  makes it easier to pass, since the loss it reserves is paid out |
//|  of equity as it happens. It is redone when a fill, a close, a   |
//|  balance change or any order moving changes the account, and at  |
//|  least once a minute.                                            |
//+------------------------------------------------------------------+
bool CAeLiveTrader::CanAfford(const double lots,const double price,const datetime time)
  {
   int npos=PositionsTotal();
   int nord=OrdersTotal();
   double bal=AccountInfoDouble(ACCOUNT_BALANCE);
   double osum=0.0;
   for(int i=0;i<nord;i++)
      if(OrderGetTicket(i)!=0)
         osum+=OrderGetDouble(ORDER_PRICE_OPEN)*OrderGetDouble(ORDER_VOLUME_CURRENT);

   bool same=(npos==m_chk_pos && nord==m_chk_ord && bal==m_chk_bal && osum==m_chk_osum &&
              lots==m_chk_lots && price==m_chk_price && time-m_chk_time<60);
   if(same)
      return m_chk_ok;

   m_chk_ok   =EnoughMoney(lots,price);
   m_chk_pos  =npos;
   m_chk_ord  =nord;
   m_chk_bal  =bal;
   m_chk_osum =osum;
   m_chk_lots =lots;
   m_chk_price=price;
   m_chk_time =time;
   return m_chk_ok;
  }

//+------------------------------------------------------------------+
//| Put a limit entry at 'level' with take-profit 'tp', or update    |
//| the resting one if the level, take-profit or size has moved.     |
//+------------------------------------------------------------------+
void CAeLiveTrader::PlaceOrRefreshEntry(const double level,const double lots,const double tp)
  {
   double lvl=NormalizeDouble(level,m_digits);
   double take=NormalizeDouble(tp,m_digits);

   double cur_lvl,cur_vol,cur_tp;
   if(!MyEntryInfo(cur_lvl,cur_vol,cur_tp))
     {
      if(m_long_short==1)
         m_trade.BuyLimit(lots,lvl,m_symbol,0.0,take,ORDER_TIME_GTC,0,"AE");
      else
         m_trade.SellLimit(lots,lvl,m_symbol,0.0,take,ORDER_TIME_GTC,0,"AE");
      return;
     }

//--- about to fill: leave it alone, the refresh comes on a later tick.
   if(EntryFrozen(cur_lvl))
      return;

//--- volume cannot be modified on a pending order: replace it.
   if(MathAbs(cur_vol-lots)>=m_lot_step*0.5)
     {
      ulong tk=MyEntryTicket();
      if(tk!=0)
         m_trade.OrderDelete(tk);
      if(m_long_short==1)
         m_trade.BuyLimit(lots,lvl,m_symbol,0.0,take,ORDER_TIME_GTC,0,"AE");
      else
         m_trade.SellLimit(lots,lvl,m_symbol,0.0,take,ORDER_TIME_GTC,0,"AE");
      return;
     }

//--- otherwise nudge the level / take-profit if they drifted.
   if(MathAbs(cur_lvl-lvl)>=m_point || MathAbs(cur_tp-take)>=m_point)
     {
      ulong tk=MyEntryTicket();
      if(tk!=0)
         m_trade.OrderModify(tk,lvl,0.0,take,ORDER_TIME_GTC,0);
     }
  }

//+------------------------------------------------------------------+
//| Remove this agent's resting entry order.                         |
//+------------------------------------------------------------------+
void CAeLiveTrader::CancelEntry(void)
  {
   double cur_lvl,cur_vol,cur_tp;
   if(!MyEntryInfo(cur_lvl,cur_vol,cur_tp))
      return;
   if(EntryFrozen(cur_lvl))
      return;
   ulong tk=MyEntryTicket();
   if(tk!=0)
      m_trade.OrderDelete(tk);
  }

//+------------------------------------------------------------------+
//| Drive the agent one quote forward.                               |
//+------------------------------------------------------------------+
void CAeLiveTrader::OnTickUpdate(const double bid,const double ask,const datetime time)
  {
   SAeTick t=AeTick(bid,ask,time);
   m_liq.Computation(t);

   int ev[3];
   ev[0]=m_runners[0].Run(t);
   ev[1]=m_runners[1].Run(t);
   ev[2]=m_runners[2].Run(t);

   double inv=InventoryUnitsAbs();
   int idx=ProperRunnerIndex(inv);

//--- safety cap: stop adding once the inventory is large; the resting
//--- take-profits still unwind what is open.
   if(inv>=m_max_units)
     {
      CancelEntry();
      m_last_idx=idx;
      return;
     }

//--- pull a resting entry the account could no longer pay for if it
//--- filled now; the free margin moves with every tick.
   double cur_lvl,cur_vol,cur_tp;
   if(MyEntryInfo(cur_lvl,cur_vol,cur_tp) && !CanAfford(cur_vol,cur_lvl,time))
     {
      CancelEntry();
      m_last_idx=idx;
      return;
     }

//--- re-place the entry only when something changed: an intrinsic
//--- event on the active runner, a tier switch, or no order resting.
   bool refresh=(ev[idx]!=AE_EVENT_NONE) || (idx!=m_last_idx) || (MyEntryTicket()==0);
   m_last_idx=idx;
   if(!refresh)
      return;

   double unit=UnitFromInventory(inv);
   double vol_units=unit*LiqCoef(m_liq.Liq());
   double lots=NormalizeLots(vol_units*m_lot_per_unit);
   if(lots<m_lot_min)
      return;

   double level,tp;
   if(m_long_short==1)
     {
      level=m_runners[idx].ExpectedLowerIE();
      tp=level*(1.0+m_delta);
      if(ask-level<=m_stop_dist)          // too close to place a buy limit
         return;
     }
   else
     {
      level=m_runners[idx].ExpectedUpperIE();
      tp=level*(1.0-m_delta);
      if(level-bid<=m_stop_dist)          // too close to place a sell limit
         return;
     }

   if(!CanAfford(lots,level,time))
      return;

   PlaceOrRefreshEntry(level,lots,tp);
  }

//+------------------------------------------------------------------+
//| Cancel the resting order; leave open positions to their exits.   |
//+------------------------------------------------------------------+
void CAeLiveTrader::Shutdown(void)
  {
   CancelEntry();
  }
//+------------------------------------------------------------------+
