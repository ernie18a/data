//+------------------------------------------------------------------+
//|                                                     GPDModel.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23278 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23278"
#property version   "1.00"
#property strict

#include <Math\Alglib\alglib.mqh>

//--- model status / data-sufficiency flag
enum ENUM_GPD_STATUS
  {
   GPD_OK,                 // fit succeeded and is usable
   GPD_NOT_FITTED,         // Fit() not called yet
   GPD_TOO_FEW_EXCEEDANCES,// not enough tail data for a trustworthy fit
   GPD_FIT_FAILED,         // optimizer did not converge to a valid solution
   GPD_BAD_INPUT           // empty / degenerate input
  };

//--- minimum exceedances below which a GPD fit is not trustworthy.
//--- EVT literature treats ~30-50 tail points as a practical floor.
#define GPD_MIN_EXCEEDANCES 30

//+------------------------------------------------------------------+
//| Negative log-likelihood objective for ALGLIB.                    |
//| Holds a copy of the exceedances (excesses over the threshold).   |
//| x[0]=xi, x[1]=sigma. Writes NLL into func.                       |
//+------------------------------------------------------------------+
class CGPDNegLogLik : public CNDimensional_Func
  {
private:
   double            m_excess[];   // y_i = loss_i - u, all > 0
   int               m_n;
public:
   void              SetData(const double &excess[],const int n);
   virtual void      Func(double &x[],double &func,CObject &obj);
  };

//+------------------------------------------------------------------+
//| Store a private copy of the exceedances for the objective.       |
//+------------------------------------------------------------------+
void CGPDNegLogLik::SetData(const double &excess[],const int n)
  {
   m_n=n;
   ArrayResize(m_excess,n);
   for(int i=0;i<n;i++)
      m_excess[i]=excess[i];
  }

//+------------------------------------------------------------------+
//| GPD negative log-likelihood.                                     |
//|  For xi ~ 0 we use the exponential limit to stay numerically     |
//|  stable. Invalid parameter regions return a large penalty so the |
//|  optimizer is repelled rather than producing NaNs.               |
//+------------------------------------------------------------------+
void CGPDNegLogLik::Func(double &x[],double &func,CObject &obj)
  {
   double xi    = x[0];
   double sigma = x[1];
   const double BIG = 1.0e15;

   if(sigma<=0.0)
     {
      func=BIG;
      return;
     }

   double nll=0.0;
   for(int i=0;i<m_n;i++)
     {
      double y=m_excess[i];
      double z=y/sigma;
      if(MathAbs(xi)<1.0e-8)
        {
         //--- exponential limit: log f = -log(sigma) - y/sigma
         nll += MathLog(sigma) + z;
        }
      else
        {
         double t=1.0+xi*z;
         if(t<=0.0)
           {
            //--- excess outside the GPD support for this xi: reject
            func=BIG;
            return;
           }
         //--- log f = -log(sigma) - (1 + 1/xi) * log(1 + xi*z)
         nll += MathLog(sigma) + (1.0+1.0/xi)*MathLog(t);
        }
     }
   func=nll;
  }

//+------------------------------------------------------------------+
//| CGPDModel - the public engine.                                   |
//+------------------------------------------------------------------+
class CGPDModel
  {
private:
   //--- configuration
   double            m_threshold_q;   // quantile used to pick u (default 0.95)
   //--- fitted state
   double            m_u;             // threshold u
   double            m_xi;            // fitted shape
   double            m_sigma;         // fitted scale
   int               m_n_total;       // total loss observations used
   int               m_n_exceed;      // number of exceedances
   ENUM_GPD_STATUS   m_status;

   //--- helpers
   double            Quantile(double &sorted[],int n,double q) const;
   bool              RunMLE(const double &excess[],int n);

public:
                     CGPDModel(void);
   void              SetThresholdQuantile(double q) { if(q>0.5 && q<0.999) m_threshold_q=q; }

   //--- main entry: fit the tail of an array of LOSSES (positive = bad).
   bool              Fit(const double &losses[],int count);

   //--- fitted parameters / diagnostics
   double            Xi(void)             const { return m_xi; }
   double            Sigma(void)          const { return m_sigma; }
   double            Threshold(void)      const { return m_u; }
   int               ExceedanceCount(void)const { return m_n_exceed; }
   ENUM_GPD_STATUS   Status(void)         const { return m_status; }
   bool              IsReliable(void)     const { return m_status==GPD_OK; }
   string            StatusText(void)     const;

   //--- risk metrics (p e.g. 0.99, 0.999). Valid for p beyond the sample.
   double            VaR(double p)               const;
   double            ExpectedShortfall(double p) const;
  };

//+------------------------------------------------------------------+
//| Construct an unfitted model with the default 0.95 threshold.     |
//+------------------------------------------------------------------+
CGPDModel::CGPDModel(void)
  {
   m_threshold_q=0.95;
   m_u=0.0;
   m_xi=0.0;
   m_sigma=0.0;
   m_n_total=0;
   m_n_exceed=0;
   m_status=GPD_NOT_FITTED;
  }

//+------------------------------------------------------------------+
//| Linear-interpolated quantile of an ascending sorted array.       |
//+------------------------------------------------------------------+
double CGPDModel::Quantile(double &sorted[],int n,double q) const
  {
   if(n<=0)
      return 0.0;
   if(n==1)
      return sorted[0];
   double pos=q*(n-1);
   int lo=(int)MathFloor(pos);
   int hi=lo+1;
   if(hi>=n)
      return sorted[n-1];
   double frac=pos-lo;
   return sorted[lo]+frac*(sorted[hi]-sorted[lo]);
  }

//+------------------------------------------------------------------+
//| Fit the GPD tail by MLE.                                         |
//|  losses[] : array of losses where larger = worse (e.g. negative  |
//|             returns flipped to positive). Sign convention is the |
//|             caller's; this class only sees "bigger is worse".    |
//+------------------------------------------------------------------+
bool CGPDModel::Fit(const double &losses[],int count)
  {
   m_status=GPD_NOT_FITTED;
   m_xi=0.0;
   m_sigma=0.0;
   m_u=0.0;
   m_n_exceed=0;

   if(count<=0)
     {
      m_status=GPD_BAD_INPUT;
      return false;
     }
   m_n_total=count;

//--- sort losses ascending to locate the threshold quantile
   double sorted[];
   ArrayResize(sorted,count);
   for(int i=0;i<count;i++)
      sorted[i]=losses[i];
   ArraySort(sorted);

   m_u=Quantile(sorted,count,m_threshold_q);

//--- collect excesses over u (strictly positive)
   double excess[];
   int k=0;
   ArrayResize(excess,count);
   for(int i=0;i<count;i++)
     {
      double e=losses[i]-m_u;
      if(e>0.0)
         excess[k++]=e;
     }
   ArrayResize(excess,k);
   m_n_exceed=k;

   if(k<GPD_MIN_EXCEEDANCES)
     {
      m_status=GPD_TOO_FEW_EXCEEDANCES;
      return false;
     }

   if(!RunMLE(excess,k))
     {
      m_status=GPD_FIT_FAILED;
      return false;
     }

   m_status=GPD_OK;
   return true;
  }

//+------------------------------------------------------------------+
//| Maximum-likelihood fit of (xi, sigma) via ALGLIB MinBLEIC with   |
//| finite-difference gradients and box constraints.                 |
//+------------------------------------------------------------------+
bool CGPDModel::RunMLE(const double &excess[],int n)
  {
//--- starting point: method-of-moments seed for robustness
   double mean=0.0;
   for(int i=0;i<n;i++)
      mean+=excess[i];
   mean/=n;
   double var=0.0;
   for(int i=0;i<n;i++)
      var+=(excess[i]-mean)*(excess[i]-mean);
   var/=MathMax(1,n-1);

//--- MoM: xi0 = 0.5*(1 - mean^2/var), sigma0 = 0.5*mean*(mean^2/var + 1)
   double ratio=(var>0.0)?(mean*mean/var):1.0;
   double xi0   = 0.5*(1.0-ratio);
   double sig0  = 0.5*mean*(ratio+1.0);
   if(!MathIsValidNumber(xi0)  || xi0<-0.4 || xi0>0.9)
      xi0=0.1;
   if(!MathIsValidNumber(sig0) || sig0<=0.0)
      sig0=MathMax(mean,1.0e-8);

   double x[];
   ArrayResize(x,2);
   x[0]=xi0;
   x[1]=sig0;

//--- box constraints: xi in [-0.5, 1.0], sigma in (eps, +inf)
   double bndl[];
   ArrayResize(bndl,2);
   double bndu[];
   ArrayResize(bndu,2);
   bndl[0]=-0.5;
   bndu[0]=1.0;
   bndl[1]=1.0e-12;
   bndu[1]=CInfOrNaN::PositiveInfinity();

   CMinBLEICStateShell  state;
   CMinBLEICReportShell rep;
   CGPDNegLogLik        objective;
   CNDimensional_Rep    repcb;
   CObject              dummy;

   objective.SetData(excess,n);

//--- finite-difference variant: we supply only the function value.
   double diffstep=1.0e-6;
   CAlglib::MinBLEICCreateF(2,x,diffstep,state);
   CAlglib::MinBLEICSetBC(state,bndl,bndu);
//--- inner stop: epsg, epsf, epsx ; outer stop: epsx, epsi
   CAlglib::MinBLEICSetInnerCond(state,0.0,0.0,1.0e-8);
   CAlglib::MinBLEICSetOuterCond(state,1.0e-8,1.0e-8);
   CAlglib::MinBLEICOptimize(state,objective,repcb,false,dummy);

   double xout[];
   CAlglib::MinBLEICResults(state,xout,rep);

   if(ArraySize(xout)<2)
      return false;

   double xi=xout[0];
   double sg=xout[1];
   if(!MathIsValidNumber(xi) || !MathIsValidNumber(sg) || sg<=0.0)
      return false;

   m_xi=xi;
   m_sigma=sg;
   return true;
  }

//+------------------------------------------------------------------+
//| GPD-POT Value at Risk at confidence p (e.g. 0.99).               |
//|  VaR_p = u + (sigma/xi)*[ ( n/Nu * (1-p) )^(-xi) - 1 ]           |
//|  with the exponential limit as xi -> 0.                          |
//|  Nu/n is the exceedance rate = m_n_exceed / m_n_total.           |
//+------------------------------------------------------------------+
double CGPDModel::VaR(double p) const
  {
   if(m_status!=GPD_OK)
      return 0.0;
   if(p<=0.0 || p>=1.0)
      return 0.0;

   double rate=(double)m_n_exceed/(double)m_n_total; // Nu/n
   if(rate<=0.0)
      return 0.0;

   double frac=(1.0-p)/rate;       // = n/Nu * (1-p)
   if(frac<=0.0)
      return m_u;

   if(MathAbs(m_xi)<1.0e-8)
      return m_u - m_sigma*MathLog(frac);            // exponential limit
   return m_u + (m_sigma/m_xi)*(MathPow(frac,-m_xi)-1.0);
  }

//+------------------------------------------------------------------+
//| GPD-POT Expected Shortfall (CVaR) at confidence p.               |
//|  ES_p = VaR_p/(1-xi) + (sigma - xi*u)/(1-xi),  for xi < 1.       |
//|  Exponential limit (xi->0): ES_p = VaR_p + sigma.                |
//+------------------------------------------------------------------+
double CGPDModel::ExpectedShortfall(double p) const
  {
   if(m_status!=GPD_OK)
      return 0.0;
   double var=VaR(p);
   if(var==0.0)
      return 0.0;

   if(MathAbs(m_xi)<1.0e-8)
      return var+m_sigma;                            // exponential limit
   if(m_xi>=1.0)
      return 0.0;                                    // ES undefined (infinite mean)
   return var/(1.0-m_xi) + (m_sigma-m_xi*m_u)/(1.0-m_xi);
  }

//+------------------------------------------------------------------+
//| Human-readable description of the current model status.          |
//+------------------------------------------------------------------+
string CGPDModel::StatusText(void) const
  {
   switch(m_status)
     {
      case GPD_OK:
         return "OK";
      case GPD_NOT_FITTED:
         return "not fitted";
      case GPD_TOO_FEW_EXCEEDANCES:
         return StringFormat("insufficient tail data (%d/%d exceedances)",
                             m_n_exceed,GPD_MIN_EXCEEDANCES);
      case GPD_FIT_FAILED:
         return "fit did not converge";
      case GPD_BAD_INPUT:
         return "bad input";
     }
   return "unknown";
  }
//+------------------------------------------------------------------+
