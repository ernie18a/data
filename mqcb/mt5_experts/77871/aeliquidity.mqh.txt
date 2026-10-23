//+------------------------------------------------------------------+
//|                                                  AeLiquidity.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23814 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23814"
#property version   "1.00"
#property strict

#include <IntrinsicTime\AeTypes.mqh>

//+------------------------------------------------------------------+
//| Cumulative standard-normal distribution, Zelen & Severo (1964).  |
//|  Ported verbatim from Tools.CumNorm in the reference so the      |
//|  liquidity indicator reproduces the same numbers to the digit.   |
//+------------------------------------------------------------------+
double AeCumNorm(const double x)
  {
   if(x>6.0)
      return 1.0;
   if(x<-6.0)
      return 0.0;

   double b1= 0.31938153;
   double b2=-0.356563782;
   double b3= 1.781477937;
   double b4=-1.821255978;
   double b5= 1.330274429;
   double p = 0.2316419;
   double c2= 0.3989423;

   double a=MathAbs(x);
   double t=1.0/(1.0+a*p);
   double b=c2*MathExp((-x)*(x/2.0));
   double n=((((b5*t+b4)*t+b3)*t+b2)*t+b1)*t;
   n=1.0-b*n;
   if(x<0.0)
      n=1.0-n;
   return n;
  }

//+------------------------------------------------------------------+
//| CAeLocalLiquidity - the information-theoretic probability        |
//| indicator L that sizes the engine's cascades.                    |
//|                                                                  |
//|  Port of LocalLiquidity.java. It runs its own directional-change |
//|  runner and, on every intrinsic event, adds the event's surprise |
//|  - its self-information -log P(event) - into an exponential      |
//|  moving average. A directional change is the common event, so    |
//|  its surprise is small (-ln(1-p) = 0.0834); an overshoot tick is |
//|  rarer, so its surprise is large (-ln(p) = 2.5257), with the     |
//|  transition probability p = exp(-deltaStar/delta) = 0.08 at the  |
//|  paper's deltaStar = 2.525729*delta. The averaged surprise is    |
//|  standardised against its theoretical mean H1 and variance H2    |
//|  and pushed through a normal CDF, giving L in (0,1): near 1 in   |
//|  ordinary, liquid markets and near 0 when the price path is      |
//|  behaving unusually. The coastline trader shrinks its unit size  |
//|  when L drops, trading small through the stress that once        |
//|  derailed the model.                                             |
//|                                                                  |
//|  Fidelity note: the H2 line follows the reference exactly, which |
//|  subtracts the second surprise term where the textbook variance  |
//|  of a two-state self-information would add it. With p = 0.08 the |
//|  affected term is tiny (order 1e-3), so L is unchanged in        |
//|  practice; it is kept as the author wrote it rather than patched.|
//+------------------------------------------------------------------+
class CAeLocalLiquidity
  {
private:
   double            m_delta;          // directional-change threshold
   double            m_delta_star;     // overshoot threshold, 2.525729*delta
   double            m_alpha;          // EMA span for the surprise
   double            m_alpha_weight;   // exp(-2/(alpha+1)), the EMA decay
   double            m_h1;             // theoretical mean surprise (entropy)
   double            m_h2;             // theoretical surprise variance

//--- embedded runner state (the reference's inner runner).
   int               m_type;           // -1 down, +1 up
   bool              m_initialized;
   double            m_extreme;
   double            m_reference;

   double            m_surp;           // EMA of surprise
   double            m_liq;            // the indicator L in (0,1)

   void              ComputeH1H2(void);
   int               Run(const SAeTick &p);

public:
                     CAeLocalLiquidity(void);

//--- delta and deltaStar are log-return thresholds, alpha the EMA span.
   void              Init(const double delta,const double delta_star,const double alpha);

//--- feed one quote; updates and returns L.
   double            Computation(const SAeTick &p);

   double            Liq(void)   const { return m_liq;   }
   double            H1(void)    const { return m_h1;    }
   double            H2(void)    const { return m_h2;    }
  };

//+------------------------------------------------------------------+
//| Construct empty; Init supplies the thresholds.                   |
//+------------------------------------------------------------------+
CAeLocalLiquidity::CAeLocalLiquidity(void)
  {
   m_delta=0.0;
   m_delta_star=0.0;
   m_alpha=0.0;
   m_alpha_weight=0.0;
   m_h1=0.0;
   m_h2=0.0;
   m_type=-1;
   m_initialized=false;
   m_extreme=0.0;
   m_reference=0.0;
   m_surp=0.0;
   m_liq=0.0;
  }

//+------------------------------------------------------------------+
//| Set thresholds and pre-compute the surprise moments.             |
//+------------------------------------------------------------------+
void CAeLocalLiquidity::Init(const double delta,const double delta_star,const double alpha)
  {
   m_delta       =delta;
   m_delta_star  =delta_star;
   m_alpha       =alpha;
   m_alpha_weight=MathExp(-2.0/(alpha+1.0));
   m_type        =-1;
   m_initialized =false;
   m_surp        =0.0;
   m_liq         =0.0;
   ComputeH1H2();
  }

//+------------------------------------------------------------------+
//| Theoretical mean H1 and variance H2 of the per-event surprise.   |
//|  H1 is the Shannon entropy of the two-state transition; H2 is    |
//|  its second moment less H1^2 - see the fidelity note above for   |
//|  the sign the reference uses on the second term.                 |
//+------------------------------------------------------------------+
void CAeLocalLiquidity::ComputeH1H2(void)
  {
   double p=MathExp(-m_delta_star/m_delta);
   double lp=MathLog(p);
   double lq=MathLog(1.0-p);
   m_h1=-p*lp-(1.0-p)*lq;
   m_h2=p*lp*lp-(1.0-p)*lq*lq-m_h1*m_h1;
  }

//+------------------------------------------------------------------+
//| The embedded directional-change / overshoot runner.              |
//+------------------------------------------------------------------+
int CAeLocalLiquidity::Run(const SAeTick &p)
  {
   if(!m_initialized)
     {
      m_type=-1;
      m_initialized=true;
      m_extreme=m_reference=p.Mid();
      return AE_EVENT_NONE;
     }

   if(m_type==-1)
     {
      if(MathLog(p.bid/m_extreme)>=m_delta)
        {
         m_type=1;
         m_extreme=m_reference=p.bid;
         return AE_EVENT_DC_UP;
        }
      if(p.ask<m_extreme)
         m_extreme=p.ask;
      if(MathLog(m_reference/m_extreme)>=m_delta_star)
        {
         m_reference=m_extreme;
         return AE_EVENT_OS_DOWN;
        }
     }
   else
     {
      if(MathLog(p.ask/m_extreme)<=-m_delta)
        {
         m_type=-1;
         m_extreme=m_reference=p.ask;
         return AE_EVENT_DC_DOWN;
        }
      if(p.bid>m_extreme)
         m_extreme=p.bid;
      if(MathLog(m_reference/m_extreme)<=-m_delta_star)
        {
         m_reference=m_extreme;
         return AE_EVENT_OS_UP;
        }
     }
   return AE_EVENT_NONE;
  }

//+------------------------------------------------------------------+
//| Update the indicator on a new quote and return L.                |
//+------------------------------------------------------------------+
double CAeLocalLiquidity::Computation(const SAeTick &p)
  {
   int event=Run(p);
   if(event!=AE_EVENT_NONE)
     {
      double surprise=(MathAbs(event)==1)?0.08338161:2.525729;
      m_surp=m_alpha_weight*surprise+(1.0-m_alpha_weight)*m_surp;
      m_liq =1.0-AeCumNorm(MathSqrt(m_alpha)*(m_surp-m_h1)/MathSqrt(m_h2));
     }
   return m_liq;
  }
//+------------------------------------------------------------------+
