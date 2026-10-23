//+-------------------------------------------------------------------+
//|                                          SMC_MarketStructure.mq5  |
//|                                Copyright 2026, Sandro Begashvili  |
//|                   https://www.mql5.com/en/users/sandrobegashvil   |
//|                                          https://t.me/rhinoquant  |
//|                                                                   |
//| Market structure - trend, BoS, CHoCH and liquidity sweeps - built |
//| on top of the pullback swing detector of SMC_Pullback.mq5.        |
//|                                                                   |
//| Two layers run one after another on every closed bar:             |
//|                                                                   |
//| 1. CPullbackDetector - unchanged from SMC_Pullback. It turns raw  |
//|    candles into an alternating chain of pullback swings. It is    |
//|    included here verbatim so this file stands alone; it is        |
//|    documented on its own at                                       |
//|    https://www.mql5.com/en/code/76451                             |
//|                                                                   |
//| 2. CMarketStructure - keeps ONE high and ONE low as the current   |
//|    structure. A close beyond one of them is a break: with the     |
//|    trend it is a BoS, against it a CHoCH. The opposite side of    |
//|    the structure is then taken from the range the break swept,    |
//|    and the new extreme on the break side is confirmed later, when |
//|    price returns to a reference pullback level.                   |
//|                                                                   |
//| Only a close counts as a break. A candle whose wick alone goes    |
//| past the level is remembered as a liquidity sweep: if the next    |
//| break happens on the OTHER side, the structure point is first     |
//| moved onto the swept candle, so the sweep - not the old level -   |
//| becomes the origin of the move.                                   |
//|                                                                   |
//| The structure repaints by design: the newest point moves while it |
//| is still being confirmed, and a sweep relocates it backwards. The |
//| pullback layer underneath never repaints.                         |
//+-------------------------------------------------------------------+
#property copyright "Copyright 2026, Sandro Begashvili"
#property link      "https://www.mql5.com/en/users/sandrobegashvil"
#property version   "1.00"
#property description "Market structure on pullback swings: trend, BoS, CHoCH, IDM and liquidity sweeps."
#property description "Smart Money Concepts. Evaluated on closed bars."
#property description "Telegram: https://t.me/rhinoquant"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5

#property indicator_label1  "MS High"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrOrangeRed
#property indicator_width1  2

#property indicator_label2  "MS Low"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDodgerBlue
#property indicator_width2  2

#property indicator_label3  "MS Trend"
#property indicator_type3   DRAW_NONE

#property indicator_label4  "Pullback High"
#property indicator_type4   DRAW_NONE

#property indicator_label5  "Pullback Low"
#property indicator_type5   DRAW_NONE

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

input group             "Pullback layer"
input ENUM_LOOKING_FOR  InpStartSide    = LOOK_HIGH;         // Start by looking for
input ENUM_BREAK_MODE   InpBreakMode    = BREAK_BY_WICK;     // Pullback break confirmed by

input group             "Market structure"
input ENUM_TOUCH_MODE   InpTouchMode    = TOUCH_BY_WICK;     // Extreme confirmed when reference is
input bool              InpUseSweeps    = true;              // Detect liquidity sweeps

input group             "Display - pullback zigzag"
input bool              InpShowPbLegs   = true;              // Draw the pullback zigzag
input color             InpPbLegColor   = clrGainsboro;      // Pullback zigzag colour
input ENUM_LINE_STYLE   InpPbLegStyle   = STYLE_SOLID;       // Pullback zigzag style
input int               InpPbLegWidth   = 1;                 // Pullback zigzag width

input group             "Display - structure zigzag"
input bool              InpShowMsLegs   = true;              // Draw the structure zigzag
input color             InpMsLegColor   = clrGoldenrod;      // Structure zigzag colour
input ENUM_LINE_STYLE   InpMsLegStyle   = STYLE_SOLID;       // Structure zigzag style
input int               InpMsLegWidth   = 2;                 // Structure zigzag width

input group             "Display - structure markers"
input bool              InpShowMarkers  = true;              // Draw the structure markers
input int               InpArrowHigh    = 217;               // Arrow code - structure high
input int               InpArrowLow     = 218;               // Arrow code - structure low
input int               InpArrowShift   = 14;                // Arrow distance from the bar (pixels)

input group             "Display - break lines"
input bool              InpShowBreaks   = true;              // Draw BoS / CHoCH / sweep lines
input color             InpBosColor     = clrMediumSeaGreen; // BoS colour
input color             InpChochColor   = clrTomato;         // CHoCH colour
input color             InpSweepColor   = clrMediumOrchid;   // Liquidity sweep colour
input color             InpIdmColor     = clrSteelBlue;      // IDM colour
input int               InpBreakWidth   = 1;                 // Break line width
input bool              InpShowLabels   = true;              // Draw the break captions
input int               InpLabelSize    = 8;                 // Break caption font size

input group             "Alerts"
input bool              InpAlertPopup   = false;             // Popup alert on a break
input bool              InpAlertPush    = false;             // Push notification on a break

#define SMC_EMPTY 0.0

double BufMsHigh[];
double BufMsLow[];
double BufTrend[];
double BufPbHigh[];
double BufPbLow[];

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

//+-------------------------------------------------------------------+
//| Chart layer                                                       |
//+-------------------------------------------------------------------+
CPullbackDetector Detector;
CMarketStructure  Structure;

string   ObjPrefix     = "";     // unique per chart, so instances cannot collide
int      NextBar       = 0;      // next closed bar to evaluate
datetime LastAlertTime = 0;

//--- pullback zigzag: append only, that layer never repaints
long     PbSerial      = 0;
bool     HasPbPrev     = false;
datetime PbPrevTime    = 0;
double   PbPrevPrice   = 0.0;

//--- structure zigzag and markers: rebuilt from the oldest dirty slot
int      MsDrawn       = 0;      // chain slots currently on the chart
int      MsDrawnBar[];           // bar each drawn slot used, so its cell can be cleared
int      EvDrawn       = 0;      // events currently on the chart

//+-------------------------------------------------------------------+
string MsLegName(const int k) { return(ObjPrefix + "MZ" + (string)k); }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string EvLineName(const int k) { return(ObjPrefix + "EV" + (string)k); }
string EvTextName(const int k) { return(ObjPrefix + "EL" + (string)k); }

//+-------------------------------------------------------------------+
void ResetChart(void)
  {
   ObjectsDeleteAll(0, ObjPrefix);
   PbSerial    = 0;
   HasPbPrev   = false;
   PbPrevTime  = 0;
   PbPrevPrice = 0.0;
   MsDrawn     = 0;
   EvDrawn     = 0;
   ArrayResize(MsDrawnBar, 0);
   NextBar     = 0;
  }

//+-------------------------------------------------------------------+
int OnInit(void)
  {
   ObjPrefix = StringFormat("SMCMS_%I64d_", ChartID());

   SetIndexBuffer(0, BufMsHigh, INDICATOR_DATA);
   SetIndexBuffer(1, BufMsLow,  INDICATOR_DATA);
   SetIndexBuffer(2, BufTrend,  INDICATOR_DATA);
   SetIndexBuffer(3, BufPbHigh, INDICATOR_DATA);
   SetIndexBuffer(4, BufPbLow,  INDICATOR_DATA);

   for(int p = 0; p < 5; p++)
     {
      PlotIndexSetDouble(p, PLOT_EMPTY_VALUE, SMC_EMPTY);
      PlotIndexSetInteger(p, PLOT_DRAW_BEGIN, 0);
     }

//--- the buffers are filled either way, so iCustom still sees everything
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, InpShowMarkers ? DRAW_ARROW : DRAW_NONE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, InpShowMarkers ? DRAW_ARROW : DRAW_NONE);
   PlotIndexSetInteger(0, PLOT_ARROW, InpArrowHigh);
   PlotIndexSetInteger(1, PLOT_ARROW, InpArrowLow);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -InpArrowShift);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT,  InpArrowShift);

   IndicatorSetString(INDICATOR_SHORTNAME, "SMC Market Structure");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   Detector.Configure(InpStartSide, InpBreakMode);
   Structure.Configure(InpTouchMode, InpUseSweeps);
   LastAlertTime = 0;
   ResetChart();

   return(INIT_SUCCEEDED);
  }

//+-------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, ObjPrefix);
   ChartRedraw();
  }

//+-------------------------------------------------------------------+
void StyleLine(const string name, const color clr, const ENUM_LINE_STYLE style,
               const int width, const bool back)
  {
   ObjectSetInteger(0, name, OBJPROP_COLOR,      clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE,      style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH,      width);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT,  false);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT,   false);
   ObjectSetInteger(0, name, OBJPROP_BACK,       back);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
  }

//+-------------------------------------------------------------------+
//| Draws the pullback leg from the previous swing to this one.       |
//|                                                                   |
//| Legs cannot live in an indicator buffer: the outside-bar case     |
//| puts a high and a low on the SAME candle, and a DRAW_SECTION      |
//| plot holds one value per bar, so the second point would overwrite |
//| the first. With trend lines that leg is just vertical.            |
//+-------------------------------------------------------------------+
void DrawPbLeg(const datetime t, const double price)
  {
   if(HasPbPrev && InpShowPbLegs)
     {
      const string name = ObjPrefix + "PZ" + (string)(++PbSerial);
      if(ObjectCreate(0, name, OBJ_TREND, 0, PbPrevTime, PbPrevPrice, t, price))
         StyleLine(name, InpPbLegColor, InpPbLegStyle, InpPbLegWidth, true);
     }
   HasPbPrev   = true;
   PbPrevTime  = t;
   PbPrevPrice = price;
  }

//+-------------------------------------------------------------------+
//| Brings the structure markers and zigzag in line with the chain.   |
//|                                                                   |
//| Everything from the oldest changed slot onwards is thrown away and|
//| drawn again. That is what makes a moved point - a sweep, or an    |
//| extreme that is still being confirmed - update its marker and its |
//| legs together instead of leaving a stale copy behind.             |
//+-------------------------------------------------------------------+
void RefreshStructure(const datetime &time[])
  {
   const int total = Structure.Points();
   int from = Structure.Dirty();
   if(from >= total && from >= MsDrawn)
      return;                                  // nothing changed
   if(from > MsDrawn)
      from = MsDrawn;
   Structure.ConsumeDirty();

//--- drop the stale tail, markers included
   for(int k = from; k < MsDrawn; k++)
     {
      ObjectDelete(0, MsLegName(k));
      const int bar = MsDrawnBar[k];
      if(bar >= 0)
        {
         BufMsHigh[bar] = SMC_EMPTY;
         BufMsLow[bar]  = SMC_EMPTY;
        }
     }

   ArrayResize(MsDrawnBar, total);

   MsPoint p, prev;
   for(int k = from; k < total; k++)
     {
      Structure.Point(k, p);
      MsDrawnBar[k] = p.index;

      if(p.is_high)
         BufMsHigh[p.index] = p.price;
      else
         BufMsLow[p.index] = p.price;

      if(InpShowMsLegs && k > 0)
        {
         Structure.Point(k - 1, prev);
         const string name = MsLegName(k);
         ObjectDelete(0, name);
         if(ObjectCreate(0, name, OBJ_TREND, 0, time[prev.index], prev.price,
                         time[p.index], p.price))
            StyleLine(name, InpMsLegColor, InpMsLegStyle, InpMsLegWidth, false);
        }
     }
   MsDrawn = total;
  }

//+-------------------------------------------------------------------+
//| Draws the structure events that appeared since the last call.     |
//| Events never move, so they are append only.                       |
//+-------------------------------------------------------------------+
void RefreshEvents(const datetime &time[])
  {
   const int total = Structure.Events();
   if(!InpShowBreaks)
     {
      EvDrawn = total;
      return;
     }

   MsEvent e;
   for(; EvDrawn < total; EvDrawn++)
     {
      Structure.Event(EvDrawn, e);
      if(e.from < 0 || e.to < 0)
         continue;

      color           clr   = InpSweepColor;
      string          text  = "x";
      ENUM_LINE_STYLE style = STYLE_SOLID;

      if(e.type == MS_EVENT_BOS)
        {
         clr   = InpBosColor;
         text  = "BoS";
         style = STYLE_DASH;
        }
      else
         if(e.type == MS_EVENT_CHOCH)
           {
            clr   = InpChochColor;
            text  = "CHoCH";
            style = STYLE_DASH;
           }
         else
            if(e.type == MS_EVENT_IDM)
              {
               clr   = InpIdmColor;
               text  = "IDM";
               style = STYLE_DOT;
              }

      const string line = EvLineName(EvDrawn);
      if(ObjectCreate(0, line, OBJ_TREND, 0, time[e.from], e.price, time[e.to], e.price))
         StyleLine(line, clr, style, InpBreakWidth, false);

      if(InpShowLabels)
        {
         //--- the caption sits over the middle of its own line, on the side
         //--- the trend points: above in an uptrend, below in a downtrend
         const int    mid = (e.from + e.to) / 2;
         const string lbl = EvTextName(EvDrawn);
         if(ObjectCreate(0, lbl, OBJ_TEXT, 0, time[mid], e.price))
           {
            ObjectSetString(0, lbl, OBJPROP_TEXT, text);
            ObjectSetString(0, lbl, OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, lbl, OBJPROP_FONTSIZE,   InpLabelSize);
            ObjectSetInteger(0, lbl, OBJPROP_COLOR,      clr);
            ObjectSetInteger(0, lbl, OBJPROP_ANCHOR,     e.above ? ANCHOR_LOWER
                             : ANCHOR_UPPER);
            ObjectSetInteger(0, lbl, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, lbl, OBJPROP_HIDDEN,     true);
           }
        }
     }
  }

//+-------------------------------------------------------------------+
void RaiseAlert(const MsEvent &e, const datetime t)
  {
   if((!InpAlertPopup && !InpAlertPush) || t <= LastAlertTime)
      return;
   LastAlertTime = t;

   string kind = "Liquidity sweep";
   if(e.type == MS_EVENT_BOS)
      kind = "BoS";
   else
     {
      if(e.type == MS_EVENT_CHOCH)
         kind = "CHoCH";
      else
        {
         if(e.type == MS_EVENT_IDM)
            kind = "IDM";
        }
     }

   const string text = StringFormat("%s %s: %s %s at %s",
                                    _Symbol, EnumToString((ENUM_TIMEFRAMES)_Period),
                                    kind, e.bullish ? "up" : "down",
                                    DoubleToString(e.price, _Digits));
   if(InpAlertPopup)
      Alert(text);
   if(InpAlertPush)
      SendNotification(text);
  }

//+-------------------------------------------------------------------+
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
   if(rates_total < 3)
      return(0);

//--- first call, or history reloaded / shifted: rebuild from scratch
   if(prev_calculated == 0)
     {
      ArrayInitialize(BufMsHigh, SMC_EMPTY);
      ArrayInitialize(BufMsLow,  SMC_EMPTY);
      ArrayInitialize(BufTrend,  SMC_EMPTY);
      ArrayInitialize(BufPbHigh, SMC_EMPTY);
      ArrayInitialize(BufPbLow,  SMC_EMPTY);
      Detector.Configure(InpStartSide, InpBreakMode);
      Structure.Configure(InpTouchMode, InpUseSweeps);
      ResetChart();
     }

   const int last_closed = rates_total - 2;    // the forming bar is never used
   const int first_event = Structure.Events();

//--- one pass per closed bar: the pullback layer first, then the
//--- structure, so the structure already sees the swing of that bar
   for(; NextBar <= last_closed; NextBar++)
     {
      const int  i = NextBar;
      SwingPoint swing;
      const bool have = Detector.Step(i, high, low, close, swing);

      if(have)
        {
         if(swing.is_high)
            BufPbHigh[swing.index] = swing.price;
         else
            BufPbLow[swing.index] = swing.price;
         DrawPbLeg(time[swing.index], swing.price);
        }

      Structure.Step(i, high, low, close, have, swing);
      BufTrend[i] = (double)Structure.Trend();
     }

//--- the forming bar carries the latest known trend, so a reader of the
//--- buffer at shift 0 never sees an empty value
   BufTrend[rates_total - 1] = (double)Structure.Trend();

   RefreshStructure(time);
   RefreshEvents(time);

   const int total_events = Structure.Events();
   if(total_events > first_event && prev_calculated > 0)
     {
      MsEvent e;
      Structure.Event(total_events - 1, e);
      RaiseAlert(e, time[e.to]);
     }

   return(rates_total);
  }
//+-------------------------------------------------------------------+
