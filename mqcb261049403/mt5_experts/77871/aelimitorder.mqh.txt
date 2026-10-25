//+------------------------------------------------------------------+
//|                                                 AeLimitOrder.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23814 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23814"
#property version   "1.00"
#property strict

#include <IntrinsicTime\AeTypes.mqh>

//+------------------------------------------------------------------+
//| CAeLimitOrder - one resting limit order, and the book-keeping    |
//| that turns a de-cascade into realised profit.                    |
//|                                                                  |
//|  Port of LimitOrder.java. A buy carries type +1, a sell -1. The  |
//|  order rests at 'level'; 'dcOrOs' records whether that level is  |
//|  a directional-change (1) or overshoot (2) intrinsic event, and  |
//|  'delta' the threshold it was derived from.                      |
//|                                                                  |
//|  A de-cascading order closes one or more open cascade orders. It |
//|  keeps non-owning references to them in m_compensated - they are |
//|  owned by the trader's imbalanced list - and takes its volume    |
//|  from their combined size, so the trim exactly offsets what it   |
//|  compensates. RelativePnL then books the profit of closing them  |
//|  at this order's level.                                          |
//+------------------------------------------------------------------+
class CAeLimitOrder
  {
private:
   int               m_type;           // +1 buy, -1 sell
   SAeTick           m_price_opened;   // quote the order was placed against
   double            m_level;          // resting price of the order
   double            m_volume;         // order size, in abstract units
   double            m_delta;          // threshold the level came from
   int               m_dc_or_os;       // 1 for a DC level, 2 for an OS level
   CAeLimitOrder    *m_compensated[];  // orders this one closes (not owned)

public:
                     CAeLimitOrder(void);

//--- set every field; compensated list starts empty.
   void              Init(const int type,const SAeTick &opened,const double level,
                          const double volume,const int dc_or_os,const double delta);

   int               Type(void)   const { return m_type;   }
   double            Level(void)  const { return m_level;  }
   void              SetLevel(const double level) { m_level=level; }
   double            Volume(void) const { return m_volume; }
   int               DcOrOs(void) const { return m_dc_or_os; }
   double            Delta(void)  const { return m_delta;  }

//--- adopt a list of orders to compensate and size to match them.
   void              SetCompensatedOrders(CAeLimitOrder *&list[]);
   int               CompensatedCount(void) const { return ArraySize(m_compensated); }
   CAeLimitOrder    *Compensated(const int i) const { return m_compensated[i]; }

//--- combined size of the compensated orders.
   double            ComputeCompensatedVolume(void) const;

//--- profit of closing the compensated orders at this order's level.
   double            RelativePnL(void) const;
  };

//+------------------------------------------------------------------+
//| Construct empty.                                                 |
//+------------------------------------------------------------------+
CAeLimitOrder::CAeLimitOrder(void)
  {
   m_type=0;
   m_price_opened.bid=0.0;
   m_price_opened.ask=0.0;
   m_price_opened.time=0;
   m_level=0.0;
   m_volume=0.0;
   m_delta=0.0;
   m_dc_or_os=0;
   ArrayResize(m_compensated,0);
  }

//+------------------------------------------------------------------+
//| Populate the order.                                              |
//+------------------------------------------------------------------+
void CAeLimitOrder::Init(const int type,const SAeTick &opened,const double level,
                         const double volume,const int dc_or_os,const double delta)
  {
   m_type        =type;
   m_price_opened=opened;
   m_level       =level;
   m_volume      =volume;
   m_dc_or_os    =dc_or_os;
   m_delta       =delta;
   ArrayResize(m_compensated,0);
  }

//+------------------------------------------------------------------+
//| Adopt the compensated list and take volume from its total.       |
//+------------------------------------------------------------------+
void CAeLimitOrder::SetCompensatedOrders(CAeLimitOrder *&list[])
  {
   int n=ArraySize(list);
   ArrayResize(m_compensated,n);
   for(int i=0;i<n;i++)
      m_compensated[i]=list[i];
   m_volume=ComputeCompensatedVolume();
  }

//+------------------------------------------------------------------+
//| Sum the volumes of the compensated orders.                       |
//+------------------------------------------------------------------+
double CAeLimitOrder::ComputeCompensatedVolume(void) const
  {
   double v=0.0;
   int n=ArraySize(m_compensated);
   for(int i=0;i<n;i++)
      v+=m_compensated[i].Volume();
   return v;
  }

//+------------------------------------------------------------------+
//| Realised profit of closing the compensated orders here.          |
//|  For each compensated order, the price moved (level - this.level)|
//|  in this order's favour, expressed as a return on the compensated|
//|  level and scaled by its volume.                                 |
//+------------------------------------------------------------------+
double CAeLimitOrder::RelativePnL(void) const
  {
   double pnl=0.0;
   int n=ArraySize(m_compensated);
   for(int i=0;i<n;i++)
     {
      double abs_move=(m_compensated[i].Level()-m_level)*m_type;
      pnl+=abs_move/m_compensated[i].Level()*m_compensated[i].Volume();
     }
   return pnl;
  }
//+------------------------------------------------------------------+
