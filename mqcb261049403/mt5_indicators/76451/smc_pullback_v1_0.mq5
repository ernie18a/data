//+------------------------------------------------------------------+
//|                                            SMC Pullback v1.0.mq5 |
//|                                Copyright 2026, Sandro Begashvili |
//|                                                                  |
//| Swing detection by the pullback (Trading Hub 3.0) rule.          |
//|                                                                  |
//| The detector looks for one side at a time. While looking for a   |
//| HIGH it tracks the highest high; the candle that made it also    |
//| supplies the reference level - its own low. A later candle that  |
//| breaks that low confirms the tracked high as a swing, and the    |
//| search flips to the LOW side, seeded from the breaking candle.   |
//| Looking for a LOW is the mirror image.                           |
//|                                                                  |
//| One candle can make a new extreme AND break the reference. It is |
//| then the swing itself, and it seeds the opposite leg as well.    |
//|                                                                  |
//| Does not repaint: the tracked extreme is never drawn, and a      |
//| swing is drawn only on the candle that confirms it, then never   |
//| moved. The cost is confirmation lag - the newest swing appears   |
//| only once the break confirming it has happened.                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Sandro Begashvili"
#property link      "https://www.mql5.com/en/users/sandrobegashvil"
#property version   "1.00"
#property description "Swing high / low detection by the pullback rule of Trading Hub 3.0. Does not repaint."

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "Pullback High"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrOrangeRed
#property indicator_width1  1

#property indicator_label2  "Pullback Low"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDodgerBlue
#property indicator_width2  1

//--- side the detector is currently searching for
enum ENUM_LOOKING_FOR
  {
   LOOK_HIGH,       // Looking for a swing high
   LOOK_LOW         // Looking for a swing low
  };

//--- what counts as breaking the reference level
enum ENUM_BREAK_MODE
  {
   BREAK_BY_WICK,   // Wick - the high / low of the candle
   BREAK_BY_CLOSE   // Close - the close of the candle
  };

input group             "Detection"
input ENUM_LOOKING_FOR  InpStartSide   = LOOK_HIGH;      // Start by looking for
input ENUM_BREAK_MODE   InpBreakMode   = BREAK_BY_WICK;  // Break confirmed by

input group             "Display"
input bool              InpShowMarkers = true;           // Draw the swing markers
input int               InpArrowHigh   = 217;            // Arrow code - swing high
input int               InpArrowLow    = 218;            // Arrow code - swing low
input int               InpArrowShift  = 10;             // Arrow distance from the bar (pixels)
input bool              InpShowLegs    = true;           // Draw the legs between swings
input color             InpLegColor    = clrSilver;      // Leg colour
input ENUM_LINE_STYLE   InpLegStyle    = STYLE_DOT;      // Leg style
input int               InpLegWidth    = 1;              // Leg width

input group             "Alerts"
input bool              InpAlertPopup  = false;          // Popup alert on a confirmed swing
input bool              InpAlertPush   = false;          // Push notification on a confirmed swing

#define SMC_EMPTY 0.0

double BufHigh[];
double BufLow[];

//+------------------------------------------------------------------+
//| One confirmed swing                                              |
//+------------------------------------------------------------------+
struct SwingPoint
  {
   int               index;     // bar index in the OnCalculate arrays (0 = oldest)
   double            price;     // extreme price of the swing candle
   bool              is_high;   // side
  };

//+------------------------------------------------------------------+
//| Detection engine                                                 |
//|                                                                  |
//| Pure logic - no buffers, no chart objects, so it can be lifted   |
//| into an EA unchanged. A swing leaves the class exactly once,     |
//| through `confirmed`, and is final at that moment.                |
//+------------------------------------------------------------------+
class CPullbackDetector
  {
private:
   ENUM_BREAK_MODE   m_break_mode;
   bool              m_looking_high;  // side being searched for
   bool              m_started;       // first leg seeded
   int               m_ext_index;     // candle holding the tracked extreme
   double            m_ext_price;     // tracked extreme: highest high or lowest low
   double            m_ref_price;     // level whose break confirms the extreme
   int               m_next_bar;      // next bar to evaluate

   //--- (re)starts a leg on bar i: that candle is both the tracked
   //--- extreme and the source of the reference level
   void              StartLeg(const bool up, const int i, const double &h[], const double &l[])
     {
      m_looking_high = up;
      m_ext_index    = i;
      m_ext_price    = up ? h[i] : l[i];
      m_ref_price    = up ? l[i] : h[i];
     }

   void              Confirm(const int i, const double price, SwingPoint &out[])
     {
      const int n = ArraySize(out);
      ArrayResize(out, n + 1);
      out[n].index   = i;
      out[n].price   = price;
      out[n].is_high = m_looking_high;
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
      m_next_bar     = 0;
     }

   bool              LookingHigh(void) const { return(m_looking_high); }
   double            Reference(void)   const { return(m_ref_price); }

   void              Update(const int rates_total, const double &h[], const double &l[],
                            const double &c[], SwingPoint &confirmed[]);
  };

//+------------------------------------------------------------------+
//| Evaluates every closed bar not seen yet and appends the swings   |
//| that became final during this call.                              |
//+------------------------------------------------------------------+
void CPullbackDetector::Update(const int rates_total, const double &h[], const double &l[],
                               const double &c[], SwingPoint &confirmed[])
  {
   ArrayResize(confirmed, 0);

   const int last_closed = rates_total - 2;   // the forming bar is never used

   for(; m_next_bar <= last_closed; m_next_bar++)
     {
      const int i = m_next_bar;

      if(!m_started)                          // seed the very first leg
        {
         StartLeg(m_looking_high, i, h, l);
         m_started = true;
         continue;
        }

      //--- both tests use the state as it stands on entry, so extending the
      //--- leg cannot hide a break of the reference that is still in force
      const bool   extreme = m_looking_high ? (h[i] > m_ext_price) : (l[i] < m_ext_price);
      const double level   = (m_break_mode == BREAK_BY_CLOSE) ? c[i]
                             : (m_looking_high ? l[i] : h[i]);
      const bool   broke   = m_looking_high ? (level < m_ref_price) : (level > m_ref_price);

      if(extreme && broke)                    // outside bar: it is the swing itself
         Confirm(i, m_looking_high ? h[i] : l[i], confirmed);
      else
         if(extreme)                          // leg extends, this candle is the new reference
           {
            StartLeg(m_looking_high, i, h, l);
            continue;
           }
         else
            if(broke)                         // the tracked extreme is confirmed
               Confirm(m_ext_index, m_ext_price, confirmed);
            else
               continue;                      // inside bar: nothing changes

      StartLeg(!m_looking_high, i, h, l);     // this candle opens the opposite leg
     }
  }

//+------------------------------------------------------------------+
//| Chart layer                                                      |
//+------------------------------------------------------------------+
CPullbackDetector Detector;

string   LegPrefix      = "";      // unique per chart, so instances cannot collide
datetime LastAlertTime  = 0;
bool     HasPrevSwing   = false;   // tail of the leg chain
datetime PrevSwingTime  = 0;
double   PrevSwingPrice = 0.0;
long     LegSerial      = 0;

//+------------------------------------------------------------------+
void ResetLegs(void)
  {
   ObjectsDeleteAll(0, LegPrefix);
   HasPrevSwing = false;
   LegSerial    = 0;
  }

//+------------------------------------------------------------------+
int OnInit(void)
  {
   LegPrefix = StringFormat("SMCPB_%I64d_", ChartID());

   SetIndexBuffer(0, BufHigh, INDICATOR_DATA);
   SetIndexBuffer(1, BufLow,  INDICATOR_DATA);

   for(int p = 0; p < 2; p++)
     {
      PlotIndexSetDouble(p, PLOT_EMPTY_VALUE, SMC_EMPTY);
      PlotIndexSetInteger(p, PLOT_DRAW_BEGIN, 0);
      //--- the buffers are filled either way, so iCustom still sees every swing
      PlotIndexSetInteger(p, PLOT_DRAW_TYPE, InpShowMarkers ? DRAW_ARROW : DRAW_NONE);
     }

   PlotIndexSetInteger(0, PLOT_ARROW, InpArrowHigh);
   PlotIndexSetInteger(1, PLOT_ARROW, InpArrowLow);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -InpArrowShift);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT,  InpArrowShift);

   IndicatorSetString(INDICATOR_SHORTNAME, "SMC Pullback");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   Detector.Configure(InpStartSide, InpBreakMode);
   LastAlertTime = 0;
   ResetLegs();

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, LegPrefix);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Draws the leg from the previous swing to this one.               |
//|                                                                  |
//| Legs cannot live in an indicator buffer: the outside-bar case    |
//| puts a high and a low on the SAME candle, and a DRAW_SECTION     |
//| plot holds one value per bar, so the second point would          |
//| overwrite the first. With trend lines that leg is just vertical. |
//+------------------------------------------------------------------+
void DrawLeg(const datetime t, const double price)
  {
   if(HasPrevSwing)
     {
      const string name = LegPrefix + (string)(++LegSerial);
      if(ObjectCreate(0, name, OBJ_TREND, 0, PrevSwingTime, PrevSwingPrice, t, price))
        {
         ObjectSetInteger(0, name, OBJPROP_COLOR,      InpLegColor);
         ObjectSetInteger(0, name, OBJPROP_STYLE,      InpLegStyle);
         ObjectSetInteger(0, name, OBJPROP_WIDTH,      InpLegWidth);
         ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT,  false);
         ObjectSetInteger(0, name, OBJPROP_RAY_LEFT,   false);
         ObjectSetInteger(0, name, OBJPROP_BACK,       true);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
        }
     }
   HasPrevSwing   = true;
   PrevSwingTime  = t;
   PrevSwingPrice = price;
  }

//+------------------------------------------------------------------+
void RaiseAlert(const SwingPoint &p, const datetime t)
  {
   if((!InpAlertPopup && !InpAlertPush) || t <= LastAlertTime)
      return;
   LastAlertTime = t;

   const string text = StringFormat("%s %s: swing %s confirmed at %s",
                                    _Symbol, EnumToString((ENUM_TIMEFRAMES)_Period),
                                    p.is_high ? "HIGH" : "LOW",
                                    DoubleToString(p.price, _Digits));
   if(InpAlertPopup)
      Alert(text);
   if(InpAlertPush)
      SendNotification(text);
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
   if(rates_total < 3)
      return(0);

//--- first call, or history reloaded / shifted: rebuild from scratch
   if(prev_calculated == 0)
     {
      ArrayInitialize(BufHigh, SMC_EMPTY);
      ArrayInitialize(BufLow,  SMC_EMPTY);
      Detector.Configure(InpStartSide, InpBreakMode);
      ResetLegs();
     }

   SwingPoint confirmed[];
   Detector.Update(rates_total, high, low, close, confirmed);

   const int count = ArraySize(confirmed);
   for(int i = 0; i < count; i++)
     {
      const int idx = confirmed[i].index;
      if(confirmed[i].is_high)
         BufHigh[idx] = confirmed[i].price;
      else
         BufLow[idx] = confirmed[i].price;

      if(InpShowLegs)
         DrawLeg(time[idx], confirmed[i].price);
     }

   if(count > 0)
     {
      if(prev_calculated > 0)                 // never alert while loading history
         RaiseAlert(confirmed[count - 1], time[confirmed[count - 1].index]);
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
