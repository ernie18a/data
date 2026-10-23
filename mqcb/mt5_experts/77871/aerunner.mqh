//+------------------------------------------------------------------+
//|                                                     AeRunner.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23814 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23814"
#property version   "1.00"
#property strict

#include <IntrinsicTime\AeTypes.mqh>

//+------------------------------------------------------------------+
//| CAeRunner - the Alpha Engine's directional-change runner.        |
//|                                                                  |
//|  A line-for-line port of Runner.java. It differs from the        |
//|  scaling-law operator in three ways that matter to the trader:   |
//|                                                                  |
//|    - thresholds live in log-price, so a level is reached exactly |
//|      when log(price/extreme) crosses +/-delta; the levels are    |
//|      pre-computed as prices (expectedDcLevel, expectedOsLevel)   |
//|      so the trader can post limit orders there;                  |
//|    - the up and down thresholds are separate (deltaUp,           |
//|      deltaDown), and so are the overshoot thresholds (dStarUp,   |
//|      dStarDown), which is what lets the engine skew its trading  |
//|      against a trend;                                            |
//|    - besides the directional change (+/-1) it also emits an      |
//|      overshoot event (+/-2) every time the trend extends by      |
//|      dStar, the extra intrinsic-time ticks the coastline trader  |
//|      cascades on.                                                |
//|                                                                  |
//|  Bid/ask enter asymmetrically, exactly as in the reference: an   |
//|  up move is confirmed on the bid and a down move on the ask, so  |
//|  the level a trade is booked against is always the executable    |
//|  side of the quote.                                              |
//+------------------------------------------------------------------+
class CAeRunner
  {
private:
   double            m_delta_up;       // up directional-change threshold, log
   double            m_delta_down;     // down directional-change threshold, log
   double            m_dstar_up;       // up overshoot threshold, log
   double            m_dstar_down;     // down overshoot threshold, log
   int               m_mode;           // +1 up (awaiting downturn), -1 down
   bool              m_initialized;    // has the first price seeded the state
   double            m_extreme;        // running extreme since the last change
   double            m_reference;      // anchor the overshoot level is set from
   double            m_expected_dc;    // price at which the next change confirms
   double            m_expected_os;    // price at which the next overshoot ticks

   void              FindExpectedDc(void);
   void              FindExpectedOs(void);

public:
                     CAeRunner(void);

//--- set the four thresholds (log-returns) and clear the state.
   void              Init(const double dUp,const double dDown,const double dStarUp,const double dStarDown);

//--- feed one quote. Returns an AE_EVENT_* code.
   int               Run(const SAeTick &p);

//--- the two levels the trader posts orders at, and their types.
   double            ExpectedDc(void)      const { return m_expected_dc; }
   double            ExpectedOs(void)      const { return m_expected_os; }
   double            ExpectedUpperIE(void) const { return (m_expected_dc>m_expected_os)?m_expected_dc:m_expected_os; }
   double            ExpectedLowerIE(void) const { return (m_expected_dc<m_expected_os)?m_expected_dc:m_expected_os; }
   int               UpperIEType(void)     const { return (m_expected_dc>m_expected_os)?1:2; }
   int               LowerIEType(void)     const { return (m_expected_dc<m_expected_os)?1:2; }

   int               Mode(void)      const { return m_mode;        }
   double            DeltaUp(void)   const { return m_delta_up;    }
   double            DeltaDown(void) const { return m_delta_down;  }
   double            DstarUp(void)   const { return m_dstar_up;    }
   double            DstarDown(void) const { return m_dstar_down;  }
  };

//+------------------------------------------------------------------+
//| Construct in the reference's initial up mode, uninitialized.     |
//+------------------------------------------------------------------+
CAeRunner::CAeRunner(void)
  {
   m_delta_up   =0.0;
   m_delta_down =0.0;
   m_dstar_up   =0.0;
   m_dstar_down =0.0;
   m_mode       =1;
   m_initialized=false;
   m_extreme    =0.0;
   m_reference  =0.0;
   m_expected_dc=0.0;
   m_expected_os=0.0;
  }

//+------------------------------------------------------------------+
//| Set thresholds and reset to await the first price.               |
//+------------------------------------------------------------------+
void CAeRunner::Init(const double dUp,const double dDown,const double dStarUp,const double dStarDown)
  {
   m_delta_up   =dUp;
   m_delta_down =dDown;
   m_dstar_up   =dStarUp;
   m_dstar_down =dStarDown;
   m_mode       =1;
   m_initialized=false;
  }

//+------------------------------------------------------------------+
//| Price at which the next directional change would confirm.        |
//|  In down mode we watch for an up move of deltaUp above the       |
//|  extreme; in up mode a down move of deltaDown below it.          |
//+------------------------------------------------------------------+
void CAeRunner::FindExpectedDc(void)
  {
   if(m_mode==-1)
      m_expected_dc=MathExp(MathLog(m_extreme)+m_delta_up);
   else
      m_expected_dc=MathExp(MathLog(m_extreme)-m_delta_down);
  }

//+------------------------------------------------------------------+
//| Price at which the trend's next overshoot tick would register.   |
//+------------------------------------------------------------------+
void CAeRunner::FindExpectedOs(void)
  {
   if(m_mode==-1)
      m_expected_os=MathExp(MathLog(m_reference)-m_dstar_down);
   else
      m_expected_os=MathExp(MathLog(m_reference)+m_dstar_up);
  }

//+------------------------------------------------------------------+
//| Advance the runner by one quote.                                 |
//+------------------------------------------------------------------+
int CAeRunner::Run(const SAeTick &p)
  {
   if(!m_initialized)
     {
      m_initialized=true;
      m_extreme=m_reference=p.Mid();
      FindExpectedDc();
      FindExpectedOs();
      return AE_EVENT_NONE;
     }

   if(m_mode==-1)
     {
      if(p.bid>=m_expected_dc)
        {
         m_mode=1;                      // upturn confirmed
         m_extreme=m_reference=p.bid;
         FindExpectedDc();
         FindExpectedOs();
         return AE_EVENT_DC_UP;
        }
      if(p.ask<m_extreme)
        {
         m_extreme=p.ask;               // the low runs lower
         FindExpectedDc();
         if(p.ask<m_expected_os)
           {
            m_reference=m_extreme;       // one more downward overshoot tick
            FindExpectedOs();
            return AE_EVENT_OS_DOWN;
           }
        }
     }
   else
     {
      if(p.ask<=m_expected_dc)
        {
         m_mode=-1;                     // downturn confirmed
         m_extreme=m_reference=p.ask;
         FindExpectedDc();
         FindExpectedOs();
         return AE_EVENT_DC_DOWN;
        }
      if(p.bid>m_extreme)
        {
         m_extreme=p.bid;               // the high runs higher
         FindExpectedDc();
         if(p.bid>m_expected_os)
           {
            m_reference=m_extreme;       // one more upward overshoot tick
            FindExpectedOs();
            return AE_EVENT_OS_UP;
           }
        }
     }
   return AE_EVENT_NONE;
  }
//+------------------------------------------------------------------+
