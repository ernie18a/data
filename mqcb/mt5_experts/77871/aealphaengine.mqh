//+------------------------------------------------------------------+
//|                                                AeAlphaEngine.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23814 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23814"
#property version   "1.00"
#property strict

#include <IntrinsicTime\AeCoastlineTrader.mqh>

//--- the four base thresholds the agents live on, per AlphaEngine.java.
#define AE_NUM_SCALES 4

//+------------------------------------------------------------------+
//| CAeAlphaEngine - the ensemble of coastline agents.               |
//|                                                                  |
//|  Port of AlphaEngine.java. For each exchange rate it runs eight  |
//|  independent coastline traders: a long-only and a short-only     |
//|  agent at each of four directional-change thresholds, 0.25%,     |
//|  0.5%, 1% and 1.5%. Every quote is handed to all eight. The      |
//|  long/short split is what makes the ensemble symmetric - the     |
//|  paper's point that currencies have no inherent up or down - and |
//|  the four scales let the model harvest coastlines of different   |
//|  resolutions at once. The aggregate profit is simply the sum     |
//|  across the eight agents.                                        |
//+------------------------------------------------------------------+
class CAeAlphaEngine
  {
private:
   CAeCoastlineTrader m_long[AE_NUM_SCALES];
   CAeCoastlineTrader m_short[AE_NUM_SCALES];
   double            m_deltas[AE_NUM_SCALES];

public:
                     CAeAlphaEngine(void);

//--- build the eight agents on the paper's default thresholds.
   void              Init(void);

//--- hand one quote to every agent.
   void              Run(const SAeTick &p);

//--- aggregate read-outs for inspection and testing.
   double            TotalRealized(void);
   double            TotalPnL(const SAeTick &p);
   double            TotalInventory(void);
   double            GrossInventory(void);
   int               OpenOrders(void);

//--- per-agent access for a finer report.
   double            ScaleDelta(const int i) const { return m_deltas[i]; }
   double            LongRealized(const int i)  { return m_long[i].RealizedProfit();  }
   double            ShortRealized(const int i) { return m_short[i].RealizedProfit(); }
   double            LongInventory(const int i) { return m_long[i].Inventory();  }
   double            ShortInventory(const int i){ return m_short[i].Inventory(); }
  };

//+------------------------------------------------------------------+
//| Construct with the default threshold ladder.                     |
//+------------------------------------------------------------------+
CAeAlphaEngine::CAeAlphaEngine(void)
  {
   m_deltas[0]=0.0025;
   m_deltas[1]=0.0050;
   m_deltas[2]=0.0100;
   m_deltas[3]=0.0150;
  }

//+------------------------------------------------------------------+
//| Initialise all eight agents.                                     |
//+------------------------------------------------------------------+
void CAeAlphaEngine::Init(void)
  {
   for(int i=0;i<AE_NUM_SCALES;i++)
     {
      m_long[i].Init(m_deltas[i],1);
      m_short[i].Init(m_deltas[i],-1);
     }
  }

//+------------------------------------------------------------------+
//| Feed one quote to the ensemble.                                  |
//+------------------------------------------------------------------+
void CAeAlphaEngine::Run(const SAeTick &p)
  {
   for(int i=0;i<AE_NUM_SCALES;i++)
     {
      m_long[i].Run(p);
      m_short[i].Run(p);
     }
  }

//+------------------------------------------------------------------+
//| Sum of realised profit over all closed positions.                |
//+------------------------------------------------------------------+
double CAeAlphaEngine::TotalRealized(void)
  {
   double s=0.0;
   for(int i=0;i<AE_NUM_SCALES;i++)
      s+=m_long[i].RealizedProfit()+m_short[i].RealizedProfit();
   return s;
  }

//+------------------------------------------------------------------+
//| Realised profit plus every open position's mark-to-market.       |
//+------------------------------------------------------------------+
double CAeAlphaEngine::TotalPnL(const SAeTick &p)
  {
   double s=0.0;
   for(int i=0;i<AE_NUM_SCALES;i++)
      s+=m_long[i].TotalPnL(p)+m_short[i].TotalPnL(p);
   return s;
  }

//+------------------------------------------------------------------+
//| Net inventory across the ensemble, in units.                     |
//+------------------------------------------------------------------+
double CAeAlphaEngine::TotalInventory(void)
  {
   double s=0.0;
   for(int i=0;i<AE_NUM_SCALES;i++)
      s+=m_long[i].Inventory()+m_short[i].Inventory();
   return s;
  }

//+------------------------------------------------------------------+
//| Gross (absolute) inventory, a crude exposure gauge.              |
//+------------------------------------------------------------------+
double CAeAlphaEngine::GrossInventory(void)
  {
   double s=0.0;
   for(int i=0;i<AE_NUM_SCALES;i++)
      s+=MathAbs(m_long[i].Inventory())+MathAbs(m_short[i].Inventory());
   return s;
  }

//+------------------------------------------------------------------+
//| Total number of open cascade orders across the ensemble.         |
//+------------------------------------------------------------------+
int CAeAlphaEngine::OpenOrders(void)
  {
   int s=0;
   for(int i=0;i<AE_NUM_SCALES;i++)
      s+=m_long[i].NumImbalanced()+m_short[i].NumImbalanced();
   return s;
  }
//+------------------------------------------------------------------+
