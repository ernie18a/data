//+-------------------------------------------------------------------+
//|                                               PositionManager.mqh |
//|                                Copyright 2026, Sandro Begashvili  |
//|                   https://www.mql5.com/en/users/sandrobegashvil   |
//|                                          https://t.me/rhinoquant  |
//|                                                                   |
//| Break even and trailing stop for open positions.                  |
//|                                                                   |
//| Self-contained: it knows nothing about why a position was opened, |
//| only its symbol and magic number, so it can be dropped into any   |
//| EA unchanged. Configure it once, then call Manage() on every tick.|
//|                                                                   |
//| One rule governs everything here: a stop may only ever move       |
//| FORWARD. Break even and trailing both propose a level, the best   |
//| of the two wins, and the result is discarded unless it is an      |
//| improvement on the stop already in place. A stop that can retreat |
//| is not a stop.                                                    |
//+-------------------------------------------------------------------+
#ifndef POSITION_MANAGER_MQH
#define POSITION_MANAGER_MQH

#include <Trade/Trade.mqh>

//+-------------------------------------------------------------------+
class CPositionManager
  {
private:
   CTrade            m_trade;
   string            m_symbol;
   ulong             m_magic;
   double            m_unit;        // price value of one input unit
   int               m_digits;
   double            m_point;

   //--- break even
   bool              m_be_on;
   double            m_be_trigger;  // profit needed to arm it
   double            m_be_offset;   // how far beyond entry the stop lands

   //--- trailing
   bool              m_tr_on;
   double            m_tr_trigger;  // profit needed before trailing starts
   double            m_tr_step;     // smallest move worth making
   double            m_tr_dist;     // distance held behind price

   //--- the closest a stop is allowed to sit to the current price
   double            StopsLimit(void) const
     {
      return((double)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL) * m_point);
     }

public:
                     CPositionManager(void) : m_symbol(""), m_magic(0), m_unit(0.0),
                     m_digits(0), m_point(0.0), m_be_on(false), m_be_trigger(0.0), m_be_offset(0.0),
                     m_tr_on(false), m_tr_trigger(0.0), m_tr_step(0.0), m_tr_dist(0.0) {}

   //--- unit is the price value of one trigger / distance unit, so the
   //--- caller decides whether it is talking in points or in pips
   void              Configure(const string symbol, const ulong magic, const double unit,
                               const ulong slippage = 20)
     {
      m_symbol = symbol;
      m_magic  = magic;
      m_unit   = unit;
      m_digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      m_point  = SymbolInfoDouble(symbol, SYMBOL_POINT);
      m_trade.SetExpertMagicNumber(magic);
      m_trade.SetDeviationInPoints(slippage);
      m_trade.SetTypeFillingBySymbol(symbol);
     }

   void              SetBreakEven(const bool on, const double trigger, const double offset)
     {
      m_be_on      = on;
      m_be_trigger = trigger;
      m_be_offset  = offset;
     }

   void              SetTrailing(const bool on, const double trigger, const double step,
                                 const double distance)
     {
      m_tr_on      = on;
      m_tr_trigger = trigger;
      m_tr_step    = step;
      m_tr_dist    = distance;
     }

   bool              Active(void) const { return(m_be_on || m_tr_on); }

   void              Manage(void);
  };

//+-------------------------------------------------------------------+
//| Walks every position this EA owns and moves its stop if either     |
//| rule now asks for a better one.                                    |
//+-------------------------------------------------------------------+
void CPositionManager::Manage(void)
  {
   if(!Active())
      return;

   const double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   const double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
   if(bid <= 0.0 || ask <= 0.0)
      return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      const ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != m_symbol ||
         PositionGetInteger(POSITION_MAGIC) != (long)m_magic)
         continue;

      const long   type = PositionGetInteger(POSITION_TYPE);
      const bool   buy  = (type == POSITION_TYPE_BUY);
      const double open = PositionGetDouble(POSITION_PRICE_OPEN);
      const double tp   = PositionGetDouble(POSITION_TP);
      const double cur  = PositionGetDouble(POSITION_SL);

      //--- the side of the book the position would close on
      const double price = buy ? bid : ask;
      const double gain  = buy ? (price - open) : (open - price);
      if(gain <= 0.0)
         continue;                           // nothing is in profit yet

      const bool   have_sl = (cur != 0.0);
      double       best    = cur;
      bool         propose = false;

      //--- break even: park the stop at entry, plus an offset that can
      //--- lock a little profit rather than leaving a true scratch
      if(m_be_on && gain >= m_be_trigger * m_unit)
        {
         const double be = buy ? open + m_be_offset * m_unit
                           : open - m_be_offset * m_unit;
         if(!have_sl || (buy ? (be > best) : (be < best)))
           {
            best = be;
            propose = true;
           }
        }

      //--- trailing: hold a fixed distance behind price, but only step
      //--- when the improvement is worth the modify
      if(m_tr_on && gain >= m_tr_trigger * m_unit)
        {
         const double tr = buy ? price - m_tr_dist * m_unit
                           : price + m_tr_dist * m_unit;
         const double gate = m_tr_step * m_unit;
         const bool   better = !have_sl ? true
                               : (buy ? (tr - best >= gate) : (best - tr >= gate));
         if(better && (!have_sl || (buy ? (tr > best) : (tr < best))))
           {
            best = tr;
            propose = true;
           }
        }

      if(!propose)
         continue;

      //--- forward only. Whatever the rules asked for, a stop never
      //--- retreats and never crosses to the wrong side of entry.
      if(have_sl && (buy ? (best <= cur) : (best >= cur)))
         continue;

      //--- and it has to be a level the broker will accept
      const double limit = StopsLimit();
      if(buy ? (best >= price - limit) : (best <= price + limit))
         continue;

      const double sl = NormalizeDouble(best, m_digits);
      if(have_sl && MathAbs(sl - cur) < m_point / 2.0)
         continue;                           // already there

      if(!m_trade.PositionModify(ticket, sl, tp))
         PrintFormat("Stop move failed on #%I64u: retcode %d, %s", ticket,
                     m_trade.ResultRetcode(), m_trade.ResultRetcodeDescription());
     }
  }

#endif // POSITION_MANAGER_MQH
//+-------------------------------------------------------------------+
