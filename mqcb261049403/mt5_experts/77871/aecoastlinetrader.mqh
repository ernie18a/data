//+------------------------------------------------------------------+
//|                                            AeCoastlineTrader.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23814 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23814"
#property version   "1.00"
#property strict

#include <IntrinsicTime\AeRunner.mqh>
#include <IntrinsicTime\AeLiquidity.mqh>
#include <IntrinsicTime\AeLimitOrder.mqh>

//+------------------------------------------------------------------+
//| CAeCoastlineTrader - one directional coastline agent.            |
//|                                                                  |
//|  Port of CoastlineTrader.java. A single agent trades one side    |
//|  (long-only or short-only) at one base threshold delta. It is    |
//|  counter-trending: it opens into an overshoot, cascades - adds a |
//|  unit - at each intrinsic event that runs against it, and        |
//|  de-cascades - trims a unit at a profit - at each event that     |
//|  runs in its favour, closing the whole position once its return  |
//|  reaches delta.                                                  |
//|                                                                  |
//|  Three runners give the agent its inventory-aware skew. While    |
//|  the inventory is small it follows the symmetric runner; as the  |
//|  position grows past 15 and then 30 units it switches to runners |
//|  with thresholds skewed against the trend (ratio 2, then 4) and  |
//|  halves, then quarters, the unit it adds - the paper's fractional|
//|  cascading that keeps a trend from running the inventory away.   |
//|  The liquidity indicator shrinks the unit further when the market|
//|  behaves unusually.                                              |
//|                                                                  |
//|  Take-profit: the reference leaves the profit target to the      |
//|  implementer (its computeTargetRelatPnL is a stub). Following the|
//|  wiring in the author's overview code, where profitTarget equals |
//|  the trader's own delta, a position is closed once its total     |
//|  return - realised de-cascade profit plus the open mark-to-      |
//|  market - reaches delta on the size it was opened with.          |
//|                                                                  |
//|  Ownership: the agent owns every order in m_imbalanced and the   |
//|  two resting orders. A de-cascade order only references the      |
//|  imbalanced orders it closes; those are deleted when it fills.   |
//+------------------------------------------------------------------+
class CAeCoastlineTrader
  {
private:
   CAeRunner         m_runners[3];     // symmetric, then two skewed runners
   CAeLocalLiquidity m_liquidity;      // probability indicator L
   CAeLimitOrder    *m_buy_order;      // resting buy, owned
   CAeLimitOrder    *m_sell_order;     // resting sell, owned
   CAeLimitOrder    *m_imbalanced[];  // open cascade, owned

   double            m_original_delta; // base threshold
   double            m_original_unit;  // base unit size, one lot in the abstract
   double            m_unit_from_inv;  // unit after the inventory haircut
   int               m_long_short;     // +1 long-only, -1 short-only
   bool              m_initialized;
   double            m_inventory;      // net position, in units
   double            m_realized;       // profit of all closed positions
   double            m_pos_realized;   // profit of de-cascades in the open one
   double            m_target_pnl;     // take-profit level for the open position

   void              InitiateRunners(void);
   int               FindProperRunnerIndex(void);
   void              CorrectThresholdsAndVolumes(void);
   double            ComputeLiqUnitCoef(const double liq);

   void              SetBuyOrder(CAeLimitOrder *o);
   void              SetSellOrder(CAeLimitOrder *o);
   void              AddImbalanced(CAeLimitOrder *o);
   void              RemoveAndDeleteImbalanced(CAeLimitOrder *o);
   void              ClearImbalanced(void);

   void              PutOrders(const SAeTick &p);
   bool              CheckBuyFilled(const SAeTick &p);
   bool              CheckSellFilled(const SAeTick &p);
   void              MakeBuyFilled(const SAeTick &p);
   void              MakeSellFilled(const SAeTick &p);
   void              CorrectOrdersLevel(const double expected_dc);
   void              CorrectBuyLimitOrder(const double expected_dc);
   void              CorrectSellLimitOrder(const double expected_dc);
   void              FindCompensatedOrdersList(const double level,const double delta,const int buy_sell,CAeLimitOrder *&out[]);

   bool              PositionCrossedTargetPnL(const SAeTick &p);
   double            PositionUnrealizedProfit(const SAeTick &p);
   double            PositionTotalPnL(const SAeTick &p);
   void              ClosePosition(const SAeTick &p);
   void              MarketOrderToClosePosition(const SAeTick &p);
   void              ComputeTargetPnL(CAeLimitOrder *opening);

public:
                     CAeCoastlineTrader(void);
                    ~CAeCoastlineTrader(void);

//--- one base threshold (as a fraction), one side (+1 long, -1 short).
   void              Init(const double original_delta,const int long_short);

//--- advance the agent by one quote.
   void              Run(const SAeTick &p);

//--- read-outs for inspection and testing.
   double            RealizedProfit(void) const { return m_realized;     }
   double            Inventory(void)      const { return m_inventory;    }
   int               NumImbalanced(void) const { return ArraySize(m_imbalanced); }
   double            Liquidity(void)            { return m_liquidity.Liq(); }
   double            OpenPnL(const SAeTick &p)  { return PositionTotalPnL(p); }
   double            TotalPnL(const SAeTick &p) { return m_realized+PositionTotalPnL(p); }
  };

//+------------------------------------------------------------------+
//| Construct empty.                                                 |
//+------------------------------------------------------------------+
CAeCoastlineTrader::CAeCoastlineTrader(void)
  {
   m_buy_order=NULL;
   m_sell_order=NULL;
   ArrayResize(m_imbalanced,0);
   m_original_delta=0.0;
   m_original_unit=1.0;
   m_unit_from_inv=1.0;
   m_long_short=1;
   m_initialized=false;
   m_inventory=0.0;
   m_realized=0.0;
   m_pos_realized=0.0;
   m_target_pnl=0.0;
  }

//+------------------------------------------------------------------+
//| Free every owned order.                                          |
//+------------------------------------------------------------------+
CAeCoastlineTrader::~CAeCoastlineTrader(void)
  {
   SetBuyOrder(NULL);
   SetSellOrder(NULL);
   ClearImbalanced();
  }

//+------------------------------------------------------------------+
//| Configure the agent and its three runners.                       |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::Init(const double original_delta,const int long_short)
  {
   m_original_delta=original_delta;
   m_original_unit=1.0;
   m_unit_from_inv=1.0;
   m_long_short=long_short;
   m_initialized=false;
   m_inventory=0.0;
   m_realized=0.0;
   m_pos_realized=0.0;
   m_target_pnl=0.0;
   SetBuyOrder(NULL);
   SetSellOrder(NULL);
   ClearImbalanced();

   InitiateRunners();
   m_liquidity.Init(original_delta,original_delta*2.525729,50.0);
  }

//+------------------------------------------------------------------+
//| The symmetric runner and the two inventory-skewed runners.       |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::InitiateRunners(void)
  {
   double d=m_original_delta;
   m_runners[0].Init(d,d,d,d);
   if(m_long_short==1)
     {
      m_runners[1].Init(0.75*d,1.50*d,0.75*d,0.75*d);
      m_runners[2].Init(0.50*d,2.00*d,0.50*d,0.50*d);
     }
   else
     {
      m_runners[1].Init(1.50*d,0.75*d,0.75*d,0.75*d);
      m_runners[2].Init(2.00*d,0.50*d,0.50*d,0.50*d);
     }
  }

//+------------------------------------------------------------------+
//| Which runner drives the agent at the current inventory.          |
//+------------------------------------------------------------------+
int CAeCoastlineTrader::FindProperRunnerIndex(void)
  {
   double a=MathAbs(m_inventory);
   if(a<15.0)
      return 0;
   if(a<30.0)
      return 1;
   return 2;
  }

//+------------------------------------------------------------------+
//| Haircut the unit size as the inventory grows.                    |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::CorrectThresholdsAndVolumes(void)
  {
   double a=MathAbs(m_inventory);
   if(a<15.0)
      m_unit_from_inv=m_original_unit;
   else if(a<30.0)
      m_unit_from_inv=m_original_unit/2.0;
   else
      m_unit_from_inv=m_original_unit/4.0;
  }

//+------------------------------------------------------------------+
//| Liquidity haircut on the cascade unit (paper, page 15).          |
//+------------------------------------------------------------------+
double CAeCoastlineTrader::ComputeLiqUnitCoef(const double liq)
  {
   if(liq>=0.5)
      return 1.0;
   if(liq>=0.1)
      return 0.5;
   return 0.1;
  }

//+------------------------------------------------------------------+
//| Owned-pointer helpers, so nothing leaks or double-frees.         |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::SetBuyOrder(CAeLimitOrder *o)
  {
   if(m_buy_order!=NULL)
      delete m_buy_order;
   m_buy_order=o;
  }

//+------------------------------------------------------------------+
//| Replace the resting sell order, freeing any previous one.        |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::SetSellOrder(CAeLimitOrder *o)
  {
   if(m_sell_order!=NULL)
      delete m_sell_order;
   m_sell_order=o;
  }

//+------------------------------------------------------------------+
//| Append an order to the open cascade (ownership taken).           |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::AddImbalanced(CAeLimitOrder *o)
  {
   int n=ArraySize(m_imbalanced);
   ArrayResize(m_imbalanced,n+1);
   m_imbalanced[n]=o;
  }

//+------------------------------------------------------------------+
//| Remove one order from the cascade and free it.                   |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::RemoveAndDeleteImbalanced(CAeLimitOrder *o)
  {
   int n=ArraySize(m_imbalanced);
   for(int i=0;i<n;i++)
     {
      if(m_imbalanced[i]==o)
        {
         for(int j=i;j<n-1;j++)
            m_imbalanced[j]=m_imbalanced[j+1];
         ArrayResize(m_imbalanced,n-1);
         delete o;
         return;
        }
     }
  }

//+------------------------------------------------------------------+
//| Empty the cascade, freeing every order.                          |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::ClearImbalanced(void)
  {
   int n=ArraySize(m_imbalanced);
   for(int i=0;i<n;i++)
      if(m_imbalanced[i]!=NULL)
         delete m_imbalanced[i];
   ArrayResize(m_imbalanced,0);
  }

//+------------------------------------------------------------------+
//| The main event loop, once per quote.                             |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::Run(const SAeTick &p)
  {
   m_liquidity.Computation(p);

   int events[3];
   events[0]=m_runners[0].Run(p);
   events[1]=m_runners[1].Run(p);
   events[2]=m_runners[2].Run(p);

   if(!m_initialized)
     {
      m_initialized=true;
      CorrectThresholdsAndVolumes();
      PutOrders(p);
      return;
     }

   if(CheckBuyFilled(p))
     {
      MakeBuyFilled(p);
      SetSellOrder(NULL);
     }
   else if(CheckSellFilled(p))
     {
      MakeSellFilled(p);
      SetBuyOrder(NULL);
     }

   int idx=FindProperRunnerIndex();
   if(events[idx]!=AE_EVENT_NONE)
     {
      SetBuyOrder(NULL);
      SetSellOrder(NULL);
      PutOrders(p);
     }
   else
     {
      if(PositionCrossedTargetPnL(p))
        {
         ClosePosition(p);
         PutOrders(p);
        }
      else
         CorrectOrdersLevel(m_runners[idx].ExpectedDc());
     }
  }

//+------------------------------------------------------------------+
//| A buy fills when the ask trades through its level.               |
//+------------------------------------------------------------------+
bool CAeCoastlineTrader::CheckBuyFilled(const SAeTick &p)
  {
   return (m_buy_order!=NULL && p.ask<m_buy_order.Level());
  }

//+------------------------------------------------------------------+
//| A sell fills when the bid trades through its level.              |
//+------------------------------------------------------------------+
bool CAeCoastlineTrader::CheckSellFilled(const SAeTick &p)
  {
   return (m_sell_order!=NULL && p.bid>m_sell_order.Level());
  }

//+------------------------------------------------------------------+
//| Post the resting orders at the runner's intrinsic-event levels.  |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::PutOrders(const SAeTick &p)
  {
   double cascade_vol=m_unit_from_inv*ComputeLiqUnitCoef(m_liquidity.Liq());
   int idx=FindProperRunnerIndex();
   double upper=m_runners[idx].ExpectedUpperIE();
   double lower=m_runners[idx].ExpectedLowerIE();
   int    mode =m_runners[idx].Mode();
   double dUp  =m_runners[idx].DeltaUp();
   double dDown=m_runners[idx].DeltaDown();
   double dsUp =m_runners[idx].DstarUp();
   double dsDown=m_runners[idx].DstarDown();
   int    upperType=m_runners[idx].UpperIEType();
   int    lowerType=m_runners[idx].LowerIEType();

   int    buyDcOs,sellDcOs;
   double buyDelta,sellDelta;
   if(mode==-1)
     {
      buyDcOs=2;
      buyDelta=dsDown;
      sellDcOs=1;
      sellDelta=dUp;
     }
   else
     {
      buyDcOs=1;
      buyDelta=dDown;
      sellDcOs=2;
      sellDelta=dsUp;
     }

   if(m_long_short==1)
     {
      if(ArraySize(m_imbalanced)==0)
        {
         SetSellOrder(NULL);
         CAeLimitOrder *b=new CAeLimitOrder();
         b.Init(1,p,lower,cascade_vol,lowerType,dsDown);
         SetBuyOrder(b);
         ComputeTargetPnL(b);
        }
      else
        {
         CAeLimitOrder *b=new CAeLimitOrder();
         b.Init(1,p,lower,cascade_vol,buyDcOs,buyDelta);
         SetBuyOrder(b);
         CAeLimitOrder *comp[];
         FindCompensatedOrdersList(upper,m_original_delta,-1,comp);
         if(ArraySize(comp)!=0)
           {
            CAeLimitOrder *s=new CAeLimitOrder();
            s.Init(-1,p,upper,0.0,sellDcOs,sellDelta);
            s.SetCompensatedOrders(comp);
            SetSellOrder(s);
           }
         else
            SetSellOrder(NULL);
        }
     }
   else
     {
      if(ArraySize(m_imbalanced)==0)
        {
         SetBuyOrder(NULL);
         CAeLimitOrder *s=new CAeLimitOrder();
         s.Init(-1,p,upper,cascade_vol,upperType,dUp);
         SetSellOrder(s);
         ComputeTargetPnL(s);
        }
      else
        {
         CAeLimitOrder *comp[];
         FindCompensatedOrdersList(lower,m_original_delta,1,comp);
         if(ArraySize(comp)!=0)
           {
            CAeLimitOrder *b=new CAeLimitOrder();
            b.Init(1,p,lower,0.0,buyDcOs,buyDelta);
            b.SetCompensatedOrders(comp);
            SetBuyOrder(b);
           }
         else
            SetBuyOrder(NULL);
         CAeLimitOrder *s=new CAeLimitOrder();
         s.Init(-1,p,upper,cascade_vol,sellDcOs,sellDelta);
         SetSellOrder(s);
        }
     }
  }

//+------------------------------------------------------------------+
//| Book a filled buy: a cascade adds to inventory, a de-cascade     |
//| closes the orders it compensates and realises their profit.      |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::MakeBuyFilled(const SAeTick &p)
  {
   m_inventory+=m_buy_order.Volume();
   CorrectThresholdsAndVolumes();
   if(m_long_short==1)
     {
      AddImbalanced(m_buy_order);       // cascade: keep the order open
      m_buy_order=NULL;                  // ownership moved to the cascade
     }
   else
     {
      m_pos_realized+=m_buy_order.RelativePnL();
      int n=m_buy_order.CompensatedCount();
      for(int i=0;i<n;i++)
         RemoveAndDeleteImbalanced(m_buy_order.Compensated(i));
      SetBuyOrder(NULL);
     }
   if(ArraySize(m_imbalanced)==0)
      ClosePosition(p);
  }

//+------------------------------------------------------------------+
//| Book a filled sell, mirror image of the buy path.                |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::MakeSellFilled(const SAeTick &p)
  {
   m_inventory-=m_sell_order.Volume();
   CorrectThresholdsAndVolumes();
   if(m_long_short==-1)
     {
      AddImbalanced(m_sell_order);
      m_sell_order=NULL;
     }
   else
     {
      m_pos_realized+=m_sell_order.RelativePnL();
      int n=m_sell_order.CompensatedCount();
      for(int i=0;i<n;i++)
         RemoveAndDeleteImbalanced(m_sell_order.Compensated(i));
      SetSellOrder(NULL);
     }
   if(ArraySize(m_imbalanced)==0)
      ClosePosition(p);
  }

//+------------------------------------------------------------------+
//| Trail the directional-change limit order as intrinsic time runs. |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::CorrectOrdersLevel(const double expected_dc)
  {
   if(m_buy_order!=NULL)
      CorrectBuyLimitOrder(expected_dc);
   if(m_sell_order!=NULL)
      CorrectSellLimitOrder(expected_dc);
  }

//+------------------------------------------------------------------+
//| Move the buy DC order up to the new expected level, re-matching  |
//| its compensated orders when it is a de-cascade.                  |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::CorrectBuyLimitOrder(const double expected_dc)
  {
   if(m_buy_order.DcOrOs()!=1)
      return;
   if(!(m_long_short==1 || ArraySize(m_imbalanced)>1))
      return;
   if(expected_dc>m_buy_order.Level())
     {
      if(ArraySize(m_imbalanced)>1 && m_long_short==-1)
        {
         CAeLimitOrder *comp[];
         FindCompensatedOrdersList(expected_dc,m_original_delta,1,comp);
         if(ArraySize(comp)!=0)
           {
            m_buy_order.SetLevel(expected_dc);
            m_buy_order.SetCompensatedOrders(comp);
           }
         else
            SetBuyOrder(NULL);
        }
      else
         m_buy_order.SetLevel(expected_dc);
     }
  }

//+------------------------------------------------------------------+
//| Mirror image: move the sell DC order down.                       |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::CorrectSellLimitOrder(const double expected_dc)
  {
   if(m_sell_order.DcOrOs()!=1)
      return;
   if(!(m_long_short==-1 || ArraySize(m_imbalanced)>1))
      return;
   if(expected_dc<m_sell_order.Level())
     {
      if(ArraySize(m_imbalanced)>1 && m_long_short==1)
        {
         CAeLimitOrder *comp[];
         FindCompensatedOrdersList(expected_dc,m_original_delta,-1,comp);
         if(ArraySize(comp)!=0)
           {
            m_sell_order.SetLevel(expected_dc);
            m_sell_order.SetCompensatedOrders(comp);
           }
         else
            SetSellOrder(NULL);
        }
      else
         m_sell_order.SetLevel(expected_dc);
     }
  }

//+------------------------------------------------------------------+
//| Collect the open orders a trim at 'level' would profitably close.|
//+------------------------------------------------------------------+
void CAeCoastlineTrader::FindCompensatedOrdersList(const double level,const double delta,const int buy_sell,CAeLimitOrder *&out[])
  {
   ArrayResize(out,0);
   int n=ArraySize(m_imbalanced);
   for(int i=0;i<n;i++)
     {
      double lvl=m_imbalanced[i].Level();
      if((lvl-level)*buy_sell>=delta*lvl)
        {
         int k=ArraySize(out);
         ArrayResize(out,k+1);
         out[k]=m_imbalanced[i];
        }
     }
  }

//+------------------------------------------------------------------+
//| Has the open position reached its take-profit.                   |
//+------------------------------------------------------------------+
bool CAeCoastlineTrader::PositionCrossedTargetPnL(const SAeTick &p)
  {
   return (PositionTotalPnL(p)>=m_target_pnl);
  }

//+------------------------------------------------------------------+
//| Mark-to-market profit of the open cascade.                       |
//+------------------------------------------------------------------+
double CAeCoastlineTrader::PositionUnrealizedProfit(const SAeTick &p)
  {
   int n=ArraySize(m_imbalanced);
   if(n==0)
      return 0.0;
   double market=(m_long_short==1)?p.bid:p.ask;
   double u=0.0;
   for(int i=0;i<n;i++)
     {
      double lvl=m_imbalanced[i].Level();
      double abs_move=(market-lvl)*m_imbalanced[i].Type();
      u+=abs_move/lvl*m_imbalanced[i].Volume();
     }
   return u;
  }

//+------------------------------------------------------------------+
//| Realised de-cascade profit plus the open mark-to-market.         |
//+------------------------------------------------------------------+
double CAeCoastlineTrader::PositionTotalPnL(const SAeTick &p)
  {
   return m_pos_realized+PositionUnrealizedProfit(p);
  }

//+------------------------------------------------------------------+
//| Close everything at market, bank the profit, flatten.            |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::ClosePosition(const SAeTick &p)
  {
   MarketOrderToClosePosition(p);
   m_realized+=m_pos_realized;
   m_pos_realized=0.0;
   m_inventory=0.0;
   SetBuyOrder(NULL);
   SetSellOrder(NULL);
   CorrectThresholdsAndVolumes();
  }

//+------------------------------------------------------------------+
//| Realise every open order at market and empty the cascade.        |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::MarketOrderToClosePosition(const SAeTick &p)
  {
   double market=(m_long_short==1)?p.bid:p.ask;
   int n=ArraySize(m_imbalanced);
   for(int i=0;i<n;i++)
     {
      double lvl=m_imbalanced[i].Level();
      double abs_move=(market-lvl)*m_imbalanced[i].Type();
      m_pos_realized+=abs_move/lvl*m_imbalanced[i].Volume();
     }
   ClearImbalanced();
  }

//+------------------------------------------------------------------+
//| Take-profit target for a freshly opened position.                |
//|  The reference stubs this; following its overview code, the      |
//|  target is delta of return on the size the position opened with. |
//+------------------------------------------------------------------+
void CAeCoastlineTrader::ComputeTargetPnL(CAeLimitOrder *opening)
  {
   m_target_pnl=m_original_delta*opening.Volume();
  }
//+------------------------------------------------------------------+
