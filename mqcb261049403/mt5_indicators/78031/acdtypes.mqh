//+------------------------------------------------------------------+
//|                                                     AcdTypes.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/24742 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/24742"
#property version   "1.00"
#property strict

#include <Math\Stat\Math.mqh>

//+------------------------------------------------------------------+
//| Shared types for the ACD model of Engle and Russell (1998).      |
//|                                                                  |
//|  An adjusted wait x is an expected wait psi times a unit-mean    |
//|  surprise:  psi_i = omega + alpha * x_(i-1) + beta * psi_(i-1)   |
//|  alpha + beta is the persistence; omega pins the long-run        |
//|  wait to the training mean. The surprise is exponential or       |
//|  Weibull with shape k; at k = 1 the two coincide.                |
//+------------------------------------------------------------------+

//--- distribution of the unit-mean surprise
enum ENUM_ACD_DIST
  {
   ACD_DIST_EXPONENTIAL,               // random arrivals; one fewer parameter
   ACD_DIST_WEIBULL                    // adds a shape k; k < 1 means more dispersion
  };

//--- a fully specified model, ready to run
struct SAcdParams
  {
   ENUM_ACD_DIST     dist;
   double            omega;            // constant in the recursion
   double            alpha;            // weight on the last adjusted wait
   double            beta;             // weight on the last expectation
   double            shape;            // Weibull k; exactly 1 for the exponential
   double            mean;             // long-run adjusted wait the model reverts to
  };

//--- calibration result; the baseline is the same density, recursion off
struct SAcdFit
  {
   SAcdParams        params;
   int               n_train;          // events scored in the training range
   int               n_test;           // events scored in the held-out range
   double            ll_train;         // mean log-likelihood per event
   double            ll_test;
   double            base_shape;       // shape fitted with no clustering at all
   double            base_ll_train;    // rhythm only: psi pinned at the mean
   double            base_ll_test;
   int               evaluations;      // likelihood passes spent by the simplex
   bool              converged;
  };

//--- indicator buffer map, fixed for EAs reading it through iCustom
enum ENUM_ACD_BUFFER
  {
   ACD_BUF_ACTIVITY = 0,               // log2 of the activity ratio, plotted
   ACD_BUF_COLOR    = 1,               // 0 normal, 1 busy, 2 quiet
   ACD_BUF_VOLUME   = 2,               // log2 of tick volume against its average
   ACD_BUF_RATIO    = 3,               // the activity ratio itself
   ACD_BUF_EXPECTED = 4                // forming bar only: expected wait in ms for the next quote
  };

//--- persistence: how much of a shock survives one event
double AcdPersistence(const SAcdParams &p)
  {
   return p.alpha+p.beta;
  }

//--- events for a burst's pull to halve; 0 with the recursion off
double AcdHalfLifeEvents(const SAcdParams &p)
  {
   const double q=p.alpha+p.beta;
   if(q<=0.0 || q>=1.0)
      return 0.0;
   return MathLog(0.5)/MathLog(q);
  }

//--- the one-step update, shared by the model and the live state
double AcdNextPsi(const SAcdParams &p,const double x_prev,const double psi_prev)
  {
   return p.omega+p.alpha*x_prev+p.beta*psi_prev;
  }

//--- log of the gamma-function term that makes a Weibull unit-mean
double AcdLogScale(const double shape)
  {
   return MathGammaLog(1.0+1.0/shape);
  }

//--- unit-mean Weibull log-density; psi-free terms are passed in for speed
double AcdLogDensity(const double shape,const double log_shape,const double log_scale,
                     const double log_x,const double psi)
  {
   const double log_z=log_scale+log_x-MathLog(psi);
   return log_shape+shape*log_z-log_x-MathExp(shape*log_z);
  }

//--- CV of the unit-mean surprise; a good fit's residuals come close
double AcdSurpriseCv(const double shape)
  {
   const double g1=MathGammaLog(1.0+1.0/shape);
   const double g2=MathGammaLog(1.0+2.0/shape);
   const double v =MathExp(g2-2.0*g1)-1.0;
   return (v>0.0 ? MathSqrt(v) : 0.0);
  }

//--- one-line rendering of a parameter set, for logs and reports
string AcdParamsToString(const SAcdParams &p)
  {
   return StringFormat("%s  omega %.6f  alpha %.6f  beta %.6f  k %.4f  mean %.6f",
                       (p.dist==ACD_DIST_WEIBULL ? "Weibull" : "exponential"),
                       p.omega,p.alpha,p.beta,p.shape,p.mean);
  }
//+------------------------------------------------------------------+
