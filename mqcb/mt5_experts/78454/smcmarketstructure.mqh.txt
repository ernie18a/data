//+-------------------------------------------------------------------+
//|                                            SmcMarketStructure.mqh |
//|                                Copyright 2026, Sandro Begashvili  |
//|                   https://www.mql5.com/en/users/sandrobegashvil   |
//|                                          https://t.me/rhinoquant  |
//|                                                                   |
//| The two engines of the SMC Market Structure indicator, lifted out |
//| unchanged so an EA can run the same logic the chart shows.        |
//|                                                                   |
//|   CPullbackDetector - candles  -> alternating pullback swings     |
//|   CMarketStructure  - swings   -> trend, structure chain, events  |
//|                                                                   |
//| Neither class touches a buffer, an indicator or a chart object:   |
//| they take price arrays and hand back data. That is what makes     |
//| this file a straight copy rather than a port.                     |
//|                                                                   |
//| Indicator: https://www.mql5.com/en/code/76451 (pullback layer)    |
//+-------------------------------------------------------------------+
#ifndef SMC_MARKET_STRUCTURE_MQH
#define SMC_MARKET_STRUCTURE_MQH

//--- side the pullback detector is currently searching for
enum ENUM_LOOKING_FOR
  {
   LOOK_HIGH,       // Looking for a swing high
   LOOK_LOW         // Looking for a swing low
  };

//--- what counts as breaking the pullback reference level
enum ENUM_BREAK_MODE
  {
   BREAK_BY_WICK,   // Wick - the high / low of the candle
   BREAK_BY_CLOSE   // Close - the close of the candle
  };

//--- what counts as price returning to the confirmation reference
enum ENUM_TOUCH_MODE
  {
   TOUCH_BY_WICK,   // Wick - the level is touched
   TOUCH_BY_CLOSE   // Close - the level is closed through
  };

//--- market structure trend, also published through the trend buffer
enum ENUM_MS_TREND
  {
   MS_TREND_DOWN = -1,  // Down
   MS_TREND_NONE = 0,   // No trend yet
   MS_TREND_UP   = 1    // Up
  };


//+-------------------------------------------------------------------+
//| One confirmed pullback swing                                      |
//+-------------------------------------------------------------------+
struct SwingPoint
  {
   int               index;     // bar index in the OnCalculate arrays (0 = oldest)
   double            price;     // extreme price of the swing candle
   bool              is_high;   // side
  };

//+-------------------------------------------------------------------+
//| Pullback detection engine - identical to SMC_Pullback.mq5         |
//|                                                                   |
//| While looking for a HIGH it tracks the highest high; the candle   |
//| that made it also supplies the reference level - its own low. A   |
//| later candle that breaks that low confirms the tracked high as a  |
//| swing, and the search flips to the LOW side, seeded from the      |
//| breaking candle. Looking for a LOW is the mirror image.           |
//|                                                                   |
//| One candle can make a new extreme AND break the reference. It is  |
//| then the swing itself, and it seeds the opposite leg as well, so  |
//| at most one swing is ever confirmed on a single bar.              |
//+-------------------------------------------------------------------+
class CPullbackDetector
  {
private:
   ENUM_BREAK_MODE   m_break_mode;
   bool              m_looking_high;  // side being searched for
   bool              m_started;       // first leg seeded
   int               m_ext_index;     // candle holding the tracked extreme
   double            m_ext_price;     // tracked extreme: highest high or lowest low
   double            m_ref_price;     // level whose break confirms the extreme

   //--- (re)starts a leg on bar i: that candle is both the tracked
   //--- extreme and the source of the reference level
   void              StartLeg(const bool up, const int i, const double &h[], const double &l[])
     {
      m_looking_high = up;
      m_ext_index    = i;
      m_ext_price    = up ? h[i] : l[i];
      m_ref_price    = up ? l[i] : h[i];
     }

public:
   void              Configure(const ENUM_LOOKING_FOR side, const ENUM_BREAK_MODE mode)
     {
      m_break_mode   = mode;
      m_looking_high = (side == LOOK_HIGH);
      m_started      = false;
      m_ext_index    = -1;
      m_ext_price    = 0.0;
      m_ref_price    = 0.0;
     }

   bool              LookingHigh(void) const { return(m_looking_high); }
   double            Reference(void)   const { return(m_ref_price);   }

   bool              Step(const int i, const double &h[], const double &l[],
                          const double &c[], SwingPoint &out);
  };

//+-------------------------------------------------------------------+
//| Evaluates one closed bar. Returns true when a swing became final  |
//| on this bar; `out` is then that swing, and it never moves again.  |
//+-------------------------------------------------------------------+
bool CPullbackDetector::Step(const int i, const double &h[], const double &l[],
                             const double &c[], SwingPoint &out)
  {
   if(!m_started)                             // seed the very first leg
     {
      StartLeg(m_looking_high, i, h, l);
      m_started = true;
      return(false);
     }

//--- both tests use the state as it stands on entry, so extending the
//--- leg cannot hide a break of the reference that is still in force
   const bool   extreme = m_looking_high ? (h[i] > m_ext_price) : (l[i] < m_ext_price);
   const double level   = (m_break_mode == BREAK_BY_CLOSE) ? c[i]
                          : (m_looking_high ? l[i] : h[i]);
   const bool   broke   = m_looking_high ? (level < m_ref_price) : (level > m_ref_price);

   if(extreme && broke)                       // outside bar: it is the swing itself
     {
      out.index   = i;
      out.price   = m_looking_high ? h[i] : l[i];
      out.is_high = m_looking_high;
     }
   else
      if(extreme)                             // leg extends, this candle is the new reference
        {
         StartLeg(m_looking_high, i, h, l);
         return(false);
        }
      else
         if(broke)                            // the tracked extreme is confirmed
           {
            out.index   = m_ext_index;
            out.price   = m_ext_price;
            out.is_high = m_looking_high;
           }
         else
            return(false);                    // inside bar: nothing changes

   StartLeg(!m_looking_high, i, h, l);        // this candle opens the opposite leg
   return(true);
  }

//+-------------------------------------------------------------------+
//| One point of the market structure chain                           |
//+-------------------------------------------------------------------+
struct MsPoint
  {
   int               index;     // bar index of the extreme
   double            price;     // the extreme itself
   bool              is_high;   // side - the chain always alternates
  };

//--- kinds of structure event
#define MS_EVENT_BOS    0
#define MS_EVENT_CHOCH  1
#define MS_EVENT_SWEEP  2
#define MS_EVENT_IDM    3

//+-------------------------------------------------------------------+
//| One structure event, drawn as a horizontal segment                |
//+-------------------------------------------------------------------+
struct MsEvent
  {
   int               type;      // MS_EVENT_*
   int               from;      // bar index of the level that was broken / swept
   int               to;        // bar index of the candle that broke / swept it
   double            price;     // the level itself
   bool              bullish;   // direction of the break
   bool              above;     // caption side: above the line in an uptrend
  };

//+-------------------------------------------------------------------+
//| Market structure engine                                           |
//|                                                                   |
//| Pure logic - no buffers, no chart objects, so it can be lifted    |
//| into an EA unchanged. It consumes closed bars plus the pullback   |
//| swings confirmed on them, and produces an alternating chain of    |
//| structure points and an append-only list of events.               |
//|                                                                   |
//| A point is published as soon as it is known, so the chart can     |
//| show the live structure, and `Dirty()` reports the oldest chain   |
//| slot that changed - all the chart layer has to redraw.            |
//+-------------------------------------------------------------------+
class CMarketStructure
  {
private:
   //--- configuration
   ENUM_TOUCH_MODE   m_touch_mode;
   bool              m_use_sweeps;

   //--- output
   MsPoint           m_chain[];
   int               m_dirty;         // oldest chain slot changed since the last Consume
   MsEvent           m_events[];

   //--- trend and the two live structure levels
   ENUM_MS_TREND     m_trend;
   bool              m_seeded;
   int               m_high_slot;     // chain slot of the live high, -1 when consumed
   int               m_low_slot;      // chain slot of the live low
   int               m_high_index;
   double            m_high_price;
   int               m_low_index;
   double            m_low_price;

   //--- pending extreme: the break side has no level until it is confirmed
   int               m_pending;       // 0 none, +1 waiting for a high, -1 waiting for a low
   int               m_break_bar;     // candle that broke the structure
   int               m_pend_index;    // running extreme since the break
   double            m_pend_price;
   int               m_ref_index;     // bar of that pullback, the left end of the IDM line
   double            m_ref_price;     // pullback level whose touch confirms the extreme

   //--- wick-only excursions, kept until the next break resolves them
   bool              m_swept_high;
   int               m_swept_high_index;
   double            m_swept_high_price;
   bool              m_swept_low;
   int               m_swept_low_index;
   double            m_swept_low_price;

   //--- newest confirmed pullback on each side, the source of m_ref_price
   bool              m_have_pb_high;
   int               m_pb_high_index;
   double            m_pb_high_price;
   bool              m_have_pb_low;
   int               m_pb_low_index;
   double            m_pb_low_price;

   void              Touch(const int slot)
     {
      if(slot >= 0 && slot < m_dirty)
         m_dirty = slot;
     }

   void              AddPoint(const bool is_high, const int index, const double price)
     {
      const int slot = ArraySize(m_chain);
      ArrayResize(m_chain, slot + 1);
      m_chain[slot].index   = index;
      m_chain[slot].price   = price;
      m_chain[slot].is_high = is_high;
      Touch(slot);

      //--- a wick-only excursion only counts while the structure has not
      //--- moved on. Once a new point is published the old sweep is stale,
      //--- and consuming it later would drag a point past its neighbour
      //--- and cross the zigzag.
      m_swept_high = false;
      m_swept_low  = false;

      if(is_high)
        {
         m_high_slot  = slot;
         m_high_index = index;
         m_high_price = price;
        }
      else
        {
         m_low_slot  = slot;
         m_low_index = index;
         m_low_price = price;
        }
     }

   void              MovePoint(const bool is_high, const int index, const double price)
     {
      const int slot = is_high ? m_high_slot : m_low_slot;
      if(slot < 0)
         return;
      m_chain[slot].index = index;
      m_chain[slot].price = price;
      Touch(slot);

      if(is_high)
        {
         m_high_index = index;
         m_high_price = price;
        }
      else
        {
         m_low_index = index;
         m_low_price = price;
        }
     }

   void              AddEvent(const int type, const int from, const int to,
                              const double price, const bool bullish,
                              const bool above)
     {
      const int n = ArraySize(m_events);
      ArrayResize(m_events, n + 1);
      m_events[n].type    = type;
      m_events[n].from    = from;
      m_events[n].to      = to;
      m_events[n].price   = price;
      m_events[n].bullish = bullish;
      m_events[n].above   = above;
     }

   void              FillOpposite(const bool want_high, const int bar,
                                  const double &h[], const double &l[]);
   void              Break(const bool bullish, const int bar,
                           const double &h[], const double &l[]);

public:
   void              Configure(const ENUM_TOUCH_MODE touch, const bool use_sweeps);
   void              Step(const int i, const double &h[], const double &l[], const double &c[],
                          const bool have_swing, const SwingPoint &swing);

   ENUM_MS_TREND     Trend(void)  const { return(m_trend); }
   int               Points(void) const { return(ArraySize(m_chain)); }
   void              Point(const int slot, MsPoint &out) const { out = m_chain[slot]; }
   int               Events(void) const { return(ArraySize(m_events)); }
   void              Event(const int k, MsEvent &out)    const { out = m_events[k]; }

   int               Dirty(void)        const { return(m_dirty); }
   void              ConsumeDirty(void)       { m_dirty = INT_MAX; }

   //--- live state, for a consumer that trades off the structure.
   //--- Pending() is 0 once both extremes are confirmed: while it is
   //--- non-zero the extreme on that side is still being tracked and
   //--- its IDM has not been taken yet.
   int               Pending(void)    const { return(m_pending); }
   int               HighIndex(void)  const { return(m_high_index); }
   double            HighPrice(void)  const { return(m_high_price); }
   int               LowIndex(void)   const { return(m_low_index);  }
   double            LowPrice(void)   const { return(m_low_price);  }
   int               IdmIndex(void)   const { return(m_ref_index);  }
   double            IdmPrice(void)   const { return(m_ref_price);  }
  };

//+-------------------------------------------------------------------+
void CMarketStructure::Configure(const ENUM_TOUCH_MODE touch, const bool use_sweeps)
  {
   m_touch_mode = touch;
   m_use_sweeps = use_sweeps;

   ArrayResize(m_chain,  0);
   ArrayResize(m_events, 0);
   m_dirty = INT_MAX;

   m_trend      = MS_TREND_NONE;
   m_seeded     = false;
   m_high_slot  = -1;
   m_low_slot   = -1;
   m_high_index = -1;
   m_low_index  = -1;
   m_high_price = 0.0;
   m_low_price  = 0.0;

   m_pending    = 0;
   m_break_bar  = -1;
   m_pend_index = -1;
   m_pend_price = 0.0;
   m_ref_index  = -1;
   m_ref_price  = 0.0;

   m_swept_high       = false;
   m_swept_low        = false;
   m_swept_high_index = -1;
   m_swept_low_index  = -1;
   m_swept_high_price = 0.0;
   m_swept_low_price  = 0.0;

   m_have_pb_high  = false;
   m_have_pb_low   = false;
   m_pb_high_index = -1;
   m_pb_low_index  = -1;
   m_pb_high_price = 0.0;
   m_pb_low_price  = 0.0;
  }

//+-------------------------------------------------------------------+
//| Adds the point the chain is missing before the break side can be  |
//| published, scanning the range the break travelled through.        |
//|                                                                   |
//| A bullish break is on its way to a new HIGH, so if the newest     |
//| chain point is already a high, the lowest low between that high   |
//| and the breaking candle becomes the new structure low. When the   |
//| newest point is a low the chain already alternates and nothing    |
//| happens. The bearish case is the mirror image.                    |
//+-------------------------------------------------------------------+
void CMarketStructure::FillOpposite(const bool want_high, const int bar,
                                    const double &h[], const double &l[])
  {
   const int last = ArraySize(m_chain) - 1;
   if(last < 0 || m_chain[last].is_high != want_high)
      return;

   const int from = m_chain[last].index;
   int    best_i  = from;
   double best_p  = want_high ? l[from] : h[from];

   for(int k = from + 1; k <= bar; k++)
     {
      if(want_high ? (l[k] < best_p) : (h[k] > best_p))
        {
         best_p = want_high ? l[k] : h[k];
         best_i = k;
        }
     }
   AddPoint(!want_high, best_i, best_p);
  }

//+-------------------------------------------------------------------+
//| Handles a confirmed break of the structure on bar `bar`.          |
//+-------------------------------------------------------------------+
void CMarketStructure::Break(const bool bullish, const int bar,
                             const double &h[], const double &l[])
  {
//--- a wick-only excursion on the side the move is leaving behind was a
//--- liquidity sweep: that structure point moves onto the swept candle,
//--- so the swing the break starts from is the sweep, not the old level.
//--- The point has to be the newest one in the chain, otherwise moving it
//--- forward would push it past its successor and cross the zigzag.
   const int tail = ArraySize(m_chain) - 1;
   const int swept_slot = bullish ? m_low_slot : m_high_slot;

   if((bullish ? m_swept_low : m_swept_high) && swept_slot == tail && tail >= 0)
     {
      const int    s_i = bullish ? m_swept_low_index : m_swept_high_index;
      const double s_p = bullish ? m_swept_low_price : m_swept_high_price;

      //--- the liquidity line spans the level that was taken: from the
      //--- swing that set it to the candle whose wick ran through it
      const int    old_i = m_chain[tail].index;
      const double old_p = m_chain[tail].price;
      //--- the sweep belongs to the trend that was still in force when the
      //--- wick ran through, not to the break that is about to flip it
      AddEvent(MS_EVENT_SWEEP, old_i, s_i, old_p, !bullish,
               (m_trend != MS_TREND_NONE) ? (m_trend > 0) : !bullish);

      MovePoint(!bullish, s_i, s_p);
     }
   m_swept_high = false;
   m_swept_low  = false;

//--- the level being broken, captured before the chain changes
   const int    broken_i = bullish ? m_high_index : m_low_index;
   const double broken_p = bullish ? m_high_price : m_low_price;

   FillOpposite(bullish, bar, h, l);

   const ENUM_MS_TREND want = bullish ? MS_TREND_UP : MS_TREND_DOWN;
   const bool against = (m_trend != MS_TREND_NONE && m_trend != want);
   AddEvent(against ? MS_EVENT_CHOCH : MS_EVENT_BOS, broken_i, bar, broken_p,
            bullish, bullish);
   m_trend = want;

//--- the broken level is consumed. The new extreme on this side stays
//--- pending: it is only confirmed once price comes back to the highest
//--- pullback low seen so far (mirrored for a bearish break).
   m_pending    = bullish ? +1 : -1;
   m_break_bar  = bar;
   m_pend_index = bar;
   m_pend_price = bullish ? h[bar] : l[bar];

   if(bullish)
     {
      m_high_slot = -1;
      m_ref_index = m_have_pb_low ? m_pb_low_index : m_low_index;
      m_ref_price = m_have_pb_low ? m_pb_low_price : m_low_price;
     }
   else
     {
      m_low_slot  = -1;
      m_ref_index = m_have_pb_high ? m_pb_high_index : m_high_index;
      m_ref_price = m_have_pb_high ? m_pb_high_price : m_high_price;
     }
  }

//+-------------------------------------------------------------------+
//| Evaluates one closed bar together with the pullback swing, if     |
//| any, that was confirmed on it.                                    |
//+-------------------------------------------------------------------+
void CMarketStructure::Step(const int i, const double &h[], const double &l[], const double &c[],
                            const bool have_swing, const SwingPoint &swing)
  {
//--- remember the newest pullback on each side
   if(have_swing)
     {
      if(swing.is_high)
        {
         m_have_pb_high  = true;
         m_pb_high_index = swing.index;
         m_pb_high_price = swing.price;
        }
      else
        {
         m_have_pb_low  = true;
         m_pb_low_index = swing.index;
         m_pb_low_price = swing.price;
        }

      //--- the reference only ever moves with the move: the highest
      //--- pullback low after a bullish break, and the mirror after a
      //--- bearish one
      if(m_pending > 0 && !swing.is_high && swing.price > m_ref_price)
        {
         m_ref_index = swing.index;
         m_ref_price = swing.price;
        }
      if(m_pending < 0 &&  swing.is_high && swing.price < m_ref_price)
        {
         m_ref_index = swing.index;
         m_ref_price = swing.price;
        }
     }

//--- the structure starts as the first pullback high and low, no trend
   if(!m_seeded)
     {
      if(!m_have_pb_high || !m_have_pb_low)
         return;
      if(m_pb_high_index <= m_pb_low_index)
        {
         AddPoint(true,  m_pb_high_index, m_pb_high_price);
         AddPoint(false, m_pb_low_index,  m_pb_low_price);
        }
      else
        {
         AddPoint(false, m_pb_low_index,  m_pb_low_price);
         AddPoint(true,  m_pb_high_index, m_pb_high_price);
        }
      m_seeded = true;
      return;
     }

//--- extend and possibly confirm the pending extreme. This runs before
//--- the break test, so a candle that both completes the confirmation
//--- and breaks the opposite level is read in that order - which is
//--- exactly the sweep-then-CHoCH case.
   if(m_pending != 0)
     {
      if(m_pending > 0 ? (h[i] > m_pend_price) : (l[i] < m_pend_price))
        {
         m_pend_price = (m_pending > 0) ? h[i] : l[i];
         m_pend_index = i;
        }

      //--- the IDM has to be taken by a LATER candle than the one that
      //--- set it. Without the second test a pullback low confirmed on
      //--- this very bar (the outside-bar case) would be taken by its
      //--- own low the instant it becomes the reference.
      if(i > m_break_bar && i > m_ref_index)
        {
         const double probe = (m_touch_mode == TOUCH_BY_CLOSE) ? c[i]
                              : ((m_pending > 0) ? l[i] : h[i]);
         const bool   back  = (m_pending > 0) ? (probe <= m_ref_price)
                              : (probe >= m_ref_price);
         if(back)
           {
            //--- the IDM is the reference itself: drawn from the pullback
            //--- that set it to the candle that ran through it, which is
            //--- the candle confirming the new extreme
            AddEvent(MS_EVENT_IDM, m_ref_index, i, m_ref_price,
                     m_pending < 0, m_pending > 0);
            AddPoint(m_pending > 0, m_pend_index, m_pend_price);
            m_pending = 0;
           }
        }
     }

//--- a close beyond a live level is a break, a wick alone is a sweep.
//--- While an extreme is pending its own side holds no level, so only
//--- the opposite one can be tested.
   const bool test_up   = (m_pending <= 0 && m_high_slot >= 0);
   const bool test_down = (m_pending >= 0 && m_low_slot  >= 0);

   if(test_up && c[i] > m_high_price)
     {
      if(m_pending < 0)                  // give up on the pending low: publish what we tracked
        {
         AddPoint(false, m_pend_index, m_pend_price);
         m_pending = 0;
        }
      Break(true, i, h, l);
      return;
     }
   if(test_down && c[i] < m_low_price)
     {
      if(m_pending > 0)
        {
         AddPoint(true, m_pend_index, m_pend_price);
         m_pending = 0;
        }
      Break(false, i, h, l);
      return;
     }

   if(!m_use_sweeps)
      return;

   if(test_up && h[i] > m_high_price && (!m_swept_high || h[i] > m_swept_high_price))
     {
      m_swept_high       = true;
      m_swept_high_index = i;
      m_swept_high_price = h[i];
     }
   if(test_down && l[i] < m_low_price && (!m_swept_low || l[i] < m_swept_low_price))
     {
      m_swept_low       = true;
      m_swept_low_index = i;
      m_swept_low_price = l[i];
     }
  }

#endif // SMC_MARKET_STRUCTURE_MQH
//+-------------------------------------------------------------------+
