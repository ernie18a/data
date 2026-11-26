//+------------------------------------------------------------------+
//|                                                     AcdModel.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/24742 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/24742"
#property version   "1.00"
#property strict

#include <ACD\AcdTypes.mqh>
#include <ACD\AcdEvents.mqh>
#include <ACD\AcdDiurnal.mqh>

//+------------------------------------------------------------------+
//| CAcdModel - fits the duration model and checks what it earned.   |
//|                                                                  |
//|  Chronological train/test cut; the rhythm and the recursion are  |
//|  both fitted on training only. Each fit is scored against a      |
//|  rhythm-only baseline. Nelder-Mead searches transformed values,  |
//|  so every point it reaches is a valid, stationary model.         |
//+------------------------------------------------------------------+
class CAcdModel
  {
private:
   CAcdDiurnal       m_diurnal;
   double            m_x[];            // adjusted wait per event, 0 at a start
   double            m_logx[];         // its logarithm, cached for the likelihood
   uchar             m_start[];        // 1 where no usable wait exists
   double            m_psi[];          // expected adjusted wait, filled on demand
   int               m_total;
   int               m_split;          // first event of the test range
   double            m_mean;           // mean adjusted wait over training events

//--- configuration
   double            m_train_frac;
   int               m_bin_minutes;
   bool              m_by_weekday;
   int               m_max_evals;

//--- search state
   ENUM_ACD_DIST     m_dist;
   int               m_evals;

   void              Decode(const double &u[],SAcdParams &p) const;
   double            MeanLogLik(const SAcdParams &p,const int a,const int b,int &n) const;
   double            Objective(const double &u[]);
   bool              Simplex(double &u[],const int dim,const int budget,double &fbest);
   double            FitBaseShape(void) const;
   double            Acf(const double &v[],const int n,const double mean,
                         const double var,const int lag) const;

public:
                     CAcdModel(void);

//--- chronological share of events used for fitting
   bool              SetSplit(const double train_fraction);

//--- bin width in minutes, and whether weekdays get separate profiles
   bool              SetDiurnal(const int bin_minutes,const bool by_weekday);
   void              SetMaxEvals(const int evals) { m_max_evals=(evals>60 ? evals : 60); }

//--- split, fit the rhythm on the training range, build adjusted waits
   bool              SetEvents(const CAcdEvents &ev);

//--- maximum likelihood on the training range, both ranges scored
   bool              Calibrate(const ENUM_ACD_DIST dist,SAcdFit &fit);

//--- score a caller's parameter set; fills everything but the search fields
   bool              Evaluate(const SAcdParams &p,SAcdFit &fit);

//--- expected adjusted wait for every event under a parameter set
   bool              Fill(const SAcdParams &p);

//--- ACF and Ljung-Box Q of adjusted waits, or residuals after Fill, on [a,b]
   bool              Autocorrelation(const bool residual,const int a,const int b,
                                     const int max_lag,double &acf[],double &q) const;

//--- coefficient of variation of the residuals over [a,b], after Fill
   double            ResidualCv(const int a,const int b) const;

   int               Total(void)      const { return m_total; }
   int               SplitIndex(void) const { return m_split; }
   double            Mean(void)       const { return m_mean;  }
   bool              IsStart(const int i) const { return m_start[i]!=0; }
   double            X(const int i)   const { return m_x[i];   }
   double            Psi(const int i) const { return m_psi[i]; }
   CAcdDiurnal      *Diurnal(void)          { return GetPointer(m_diurnal); }
  };

//+------------------------------------------------------------------+
//| Defaults: 70/30 split, half-hour pooled bins, 600 passes.        |
//+------------------------------------------------------------------+
CAcdModel::CAcdModel(void)
  {
   m_total      =0;
   m_split      =0;
   m_mean       =1.0;
   m_train_frac =0.7;
   m_bin_minutes=30;
   m_by_weekday =false;
   m_max_evals  =600;
   m_dist       =ACD_DIST_EXPONENTIAL;
   m_evals      =0;
  }

//+------------------------------------------------------------------+
//| Set the training share. Takes effect at the next SetEvents.      |
//+------------------------------------------------------------------+
bool CAcdModel::SetSplit(const double train_fraction)
  {
   if(train_fraction<=0.05 || train_fraction>=0.98)
      return false;
   m_train_frac=train_fraction;
   return true;
  }

//+------------------------------------------------------------------+
//| Set the rhythm binning. Takes effect at the next SetEvents.      |
//+------------------------------------------------------------------+
bool CAcdModel::SetDiurnal(const int bin_minutes,const bool by_weekday)
  {
   if(bin_minutes<1 || 1440%bin_minutes!=0)
      return false;
   m_bin_minutes=bin_minutes;
   m_by_weekday =by_weekday;
   return true;
  }

//+------------------------------------------------------------------+
//| Build the adjusted waits. The profile is scaled first and each   |
//| wait divided once, so the live state matches bit for bit.        |
//+------------------------------------------------------------------+
bool CAcdModel::SetEvents(const CAcdEvents &ev)
  {
   m_total=ev.Total();
   if(m_total<5000)
     {
      PrintFormat("CAcdModel: %d events is too few to fit a duration model",m_total);
      m_total=0;
      return false;
     }
   m_split=(int)MathFloor(m_train_frac*m_total);

   if(!m_diurnal.Setup(m_bin_minutes,m_by_weekday))
      return false;
   if(!m_diurnal.FitWaits(ev,1,m_split-1))
      return false;

   if(m_diurnal.UnitMeanWaits(ev,1,m_split-1)<=0.0)
     {
      Print("CAcdModel: the training range holds too few usable waits");
      return false;
     }

   ArrayResize(m_x,m_total);
   ArrayResize(m_logx,m_total);
   ArrayResize(m_start,m_total);
   double sum=0.0;
   long   cnt=0;
   for(int i=0;i<m_total;i++)
     {
      if(i==0 || ev.IsStart(i))
        {
         m_x[i]    =0.0;
         m_logx[i] =0.0;
         m_start[i]=1;
         continue;
        }
      m_x[i]    =ev.Wait(i)/m_diurnal.Value(ev.Time(i-1));
      m_logx[i] =MathLog(m_x[i]);
      m_start[i]=0;
      if(i<m_split)
        {
         sum+=m_x[i];
         cnt++;
        }
     }
   m_mean=sum/cnt;
   ArrayFree(m_psi);
   return true;
  }

//+------------------------------------------------------------------+
//| Search vector to parameters; persistence stays below one.        |
//+------------------------------------------------------------------+
void CAcdModel::Decode(const double &u[],SAcdParams &p) const
  {
   double q=1.0/(1.0+MathExp(-u[0]));
   if(q>0.99999)
      q=0.99999;
   const double s=1.0/(1.0+MathExp(-u[1]));

   p.dist =m_dist;
   p.alpha=q*s;
   p.beta =q*(1.0-s);
   p.mean =m_mean;
   p.omega=(1.0-q)*m_mean;
   p.shape=1.0;
   if(m_dist==ACD_DIST_WEIBULL)
      p.shape=MathMax(0.05,MathMin(10.0,MathExp(u[2])));
  }

//+------------------------------------------------------------------+
//| Mean log-likelihood per usable event in [a,b]. The recursion runs|
//| from event 0 and restarts at the mean after each session start.  |
//+------------------------------------------------------------------+
double CAcdModel::MeanLogLik(const SAcdParams &p,const int a,const int b,int &n) const
  {
   const bool   expo     =(p.dist==ACD_DIST_EXPONENTIAL);
   const double log_shape=MathLog(p.shape);
   const double log_scale=(expo ? 0.0 : AcdLogScale(p.shape));

   double ll    =0.0;
   double psi   =p.mean;
   double x_prev=0.0;
   bool   fresh =true;
   n=0;

   for(int i=0;i<=b;i++)
     {
      if(m_start[i]!=0)
        {
         fresh=true;
         continue;
        }
      psi  =(fresh ? p.mean : AcdNextPsi(p,x_prev,psi));
      fresh=false;
      x_prev=m_x[i];
      if(i<a)
         continue;

      if(expo)
         ll+=-MathLog(psi)-m_x[i]/psi;
      else
         ll+=AcdLogDensity(p.shape,log_shape,log_scale,m_logx[i],psi);
      n++;
     }
   return (n>0 ? ll/n : 0.0);
  }

//+------------------------------------------------------------------+
//| Negative training log-likelihood for one search vector.          |
//+------------------------------------------------------------------+
double CAcdModel::Objective(const double &u[])
  {
   SAcdParams p;
   Decode(u,p);
   m_evals++;
   int n=0;
   const double ll=MeanLogLik(p,0,m_split-1,n);
   return (n>0 && MathIsValidNumber(ll) ? -ll : DBL_MAX);
  }

//+------------------------------------------------------------------+
//| Nelder-Mead over two or three dimensions.                        |
//+------------------------------------------------------------------+
bool CAcdModel::Simplex(double &u[],const int dim,const int budget,double &fbest)
  {
   const int    nv   =dim+1;
   const double alpha=1.0,gamma=2.0,rho=0.5,shrink=0.5;
   const double ftol =1.0e-10;
   const int    stop =m_evals+budget;

   double v[4][3];
   double f[4];
   double probe[3],xc[3],xr[3],xe[3],xk[3];

   for(int i=0;i<nv;i++)
     {
      for(int j=0;j<dim;j++)
         v[i][j]=u[j];
      if(i>0)
         v[i][i-1]+=0.8;
      for(int j=0;j<dim;j++)
         probe[j]=v[i][j];
      f[i]=Objective(probe);
     }

   while(m_evals<stop)
     {
      int lo=0,hi=0,nh=0;
      for(int i=1;i<nv;i++)
        {
         if(f[i]<f[lo])
            lo=i;
         if(f[i]>f[hi])
            hi=i;
        }
      nh=(hi==0 ? 1 : 0);
      for(int i=0;i<nv;i++)
         if(i!=hi && f[i]>f[nh])
            nh=i;

      if(MathAbs(f[hi]-f[lo])<=ftol*(MathAbs(f[hi])+MathAbs(f[lo])+ftol))
         break;

      for(int j=0;j<dim;j++)
        {
         double s=0.0;
         for(int i=0;i<nv;i++)
            if(i!=hi)
               s+=v[i][j];
         xc[j]=s/dim;
         xr[j]=xc[j]+alpha*(xc[j]-v[hi][j]);
        }
      const double fr=Objective(xr);

      if(fr<f[lo])
        {
         for(int j=0;j<dim;j++)
            xe[j]=xc[j]+gamma*(xc[j]-v[hi][j]);
         const double fe=Objective(xe);
         const bool   ex=(fe<fr);
         for(int j=0;j<dim;j++)
            v[hi][j]=(ex ? xe[j] : xr[j]);
         f[hi]=(ex ? fe : fr);
         continue;
        }
      if(fr<f[nh])
        {
         for(int j=0;j<dim;j++)
            v[hi][j]=xr[j];
         f[hi]=fr;
         continue;
        }

      //--- contract toward whichever side of the face is better
      const bool outside=(fr<f[hi]);
      for(int j=0;j<dim;j++)
         xk[j]=(outside ? xc[j]+rho*(xr[j]-xc[j]) : xc[j]+rho*(v[hi][j]-xc[j]));
      const double fk=Objective(xk);
      if(fk<(outside ? fr : f[hi]))
        {
         for(int j=0;j<dim;j++)
            v[hi][j]=xk[j];
         f[hi]=fk;
         continue;
        }

      //--- nothing helped: shrink every vertex halfway toward the best
      for(int i=0;i<nv;i++)
        {
         if(i==lo)
            continue;
         for(int j=0;j<dim;j++)
           {
            v[i][j]=v[lo][j]+shrink*(v[i][j]-v[lo][j]);
            probe[j]=v[i][j];
           }
         f[i]=Objective(probe);
        }
     }

   int best=0;
   for(int i=1;i<nv;i++)
      if(f[i]<f[best])
         best=i;
   for(int j=0;j<dim;j++)
      u[j]=v[best][j];
   fbest=f[best];
   return (fbest<DBL_MAX);
  }

//+------------------------------------------------------------------+
//| Baseline Weibull shape by golden section. Its own best shape, so |
//| the recursion gets no credit for dispersion.                     |
//+------------------------------------------------------------------+
double CAcdModel::FitBaseShape(void) const
  {
   const double gr=(MathSqrt(5.0)-1.0)/2.0;
   double lo=MathLog(0.05),hi=MathLog(10.0);

   SAcdParams p;
   p.dist =ACD_DIST_WEIBULL;
   p.alpha=0.0;
   p.beta =0.0;
   p.mean =m_mean;
   p.omega=m_mean;

   double c=hi-gr*(hi-lo),d=lo+gr*(hi-lo);
   int n=0;
   p.shape=MathExp(c);
   double fc=MeanLogLik(p,0,m_split-1,n);
   p.shape=MathExp(d);
   double fd=MeanLogLik(p,0,m_split-1,n);

   for(int it=0;it<60 && hi-lo>1.0e-6;it++)
     {
      if(fc>fd)
        {
         hi=d;
         d =c;
         fd=fc;
         c =hi-gr*(hi-lo);
         p.shape=MathExp(c);
         fc=MeanLogLik(p,0,m_split-1,n);
        }
      else
        {
         lo=c;
         c =d;
         fc=fd;
         d =lo+gr*(hi-lo);
         p.shape=MathExp(d);
         fd=MeanLogLik(p,0,m_split-1,n);
        }
     }
   return MathExp(0.5*(lo+hi));
  }

//+------------------------------------------------------------------+
//| Score a parameter set on both ranges, with its baseline.         |
//+------------------------------------------------------------------+
bool CAcdModel::Evaluate(const SAcdParams &p,SAcdFit &fit)
  {
   if(m_total==0)
      return false;

   fit.params  =p;
   fit.ll_train=MeanLogLik(p,0,m_split-1,fit.n_train);
   fit.ll_test =MeanLogLik(p,m_split,m_total-1,fit.n_test);

   SAcdParams base=p;
   base.alpha=0.0;
   base.beta =0.0;
   base.omega=p.mean;
   base.shape=(p.dist==ACD_DIST_WEIBULL ? FitBaseShape() : 1.0);

   int n=0;
   fit.base_shape   =base.shape;
   fit.base_ll_train=MeanLogLik(base,0,m_split-1,n);
   fit.base_ll_test =MeanLogLik(base,m_split,m_total-1,n);
   fit.evaluations  =0;
   fit.converged    =true;
   return true;
  }

//+------------------------------------------------------------------+
//| Full calibration: three persistence starts, then one restart of  |
//| the best, since the likelihood is flat along persistence.        |
//+------------------------------------------------------------------+
bool CAcdModel::Calibrate(const ENUM_ACD_DIST dist,SAcdFit &fit)
  {
   if(m_total==0)
     {
      Print("CAcdModel: no events, call SetEvents first");
      return false;
     }

   m_dist =dist;
   m_evals=0;
   const int dim  =(dist==ACD_DIST_WEIBULL ? 3 : 2);
   const int share=m_max_evals/4;
   const double starts[3][2]={{0.95,0.10},{0.99,0.05},{0.998,0.02}};

   double ubest[3];
   double fbest=DBL_MAX;
   for(int s=0;s<3;s++)
     {
      double u[3];
      u[0]=MathLog(starts[s][0]/(1.0-starts[s][0]));
      u[1]=MathLog(starts[s][1]/(1.0-starts[s][1]));
      u[2]=MathLog(0.8);
      double f=DBL_MAX;
      if(!Simplex(u,dim,share,f))
         continue;
      if(f<fbest)
        {
         fbest=f;
         for(int j=0;j<3;j++)
            ubest[j]=u[j];
        }
     }
   if(fbest==DBL_MAX)
     {
      Print("CAcdModel: every start failed to produce a usable fit");
      return false;
     }

   double f=fbest;
   Simplex(ubest,dim,m_max_evals-m_evals,f);

   SAcdParams p;
   Decode(ubest,p);
   const int spent=m_evals;
   if(!Evaluate(p,fit))
      return false;
   fit.evaluations=spent;
   fit.converged  =(spent<m_max_evals);
   return true;
  }

//+------------------------------------------------------------------+
//| Store the expected adjusted wait for every event.                |
//+------------------------------------------------------------------+
bool CAcdModel::Fill(const SAcdParams &p)
  {
   if(m_total==0)
      return false;
   ArrayResize(m_psi,m_total);

   double psi   =p.mean;
   double x_prev=0.0;
   bool   fresh =true;
   for(int i=0;i<m_total;i++)
     {
      if(m_start[i]!=0)
        {
         m_psi[i]=0.0;
         fresh=true;
         continue;
        }
      psi     =(fresh ? p.mean : AcdNextPsi(p,x_prev,psi));
      fresh   =false;
      x_prev  =m_x[i];
      m_psi[i]=psi;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Autocorrelation at one lag of a compact series.                  |
//+------------------------------------------------------------------+
double CAcdModel::Acf(const double &v[],const int n,const double mean,
                      const double var,const int lag) const
  {
   if(n<=lag+2 || var<=0.0)
      return 0.0;
   double c=0.0;
   for(int i=0;i+lag<n;i++)
      c+=(v[i]-mean)*(v[i+lag]-mean);
   return c/var;
  }

//+------------------------------------------------------------------+
//| Autocorrelation profile and Ljung-Box Q. At this sample size read|
//| the drop in Q from waits to residuals, not a p-value.            |
//+------------------------------------------------------------------+
bool CAcdModel::Autocorrelation(const bool residual,const int a,const int b,
                                const int max_lag,double &acf[],double &q) const
  {
   q=0.0;
   if(m_total==0 || max_lag<1 || (residual && ArraySize(m_psi)!=m_total))
      return false;

   const int lo=MathMax(a,0);
   const int hi=MathMin(b,m_total-1);
   double v[];
   ArrayResize(v,hi-lo+1);
   int n=0;
   for(int i=lo;i<=hi;i++)
     {
      if(m_start[i]!=0)
         continue;
      v[n++]=(residual ? m_x[i]/m_psi[i] : m_x[i]);
     }
   if(n<=max_lag+2)
      return false;

   double mean=0.0,var=0.0;
   for(int i=0;i<n;i++)
      mean+=v[i];
   mean/=n;
   for(int i=0;i<n;i++)
      var+=(v[i]-mean)*(v[i]-mean);

   ArrayResize(acf,max_lag+1);
   acf[0]=1.0;
   for(int k=1;k<=max_lag;k++)
     {
      acf[k]=Acf(v,n,mean,var,k);
      q+=acf[k]*acf[k]/(n-k);
     }
   q*=(double)n*(n+2.0);
   return true;
  }

//+------------------------------------------------------------------+
//| Dispersion of the residuals. Pure random arrivals give one.      |
//+------------------------------------------------------------------+
double CAcdModel::ResidualCv(const int a,const int b) const
  {
   if(ArraySize(m_psi)!=m_total || m_total==0)
      return 0.0;
   double s=0.0,s2=0.0;
   long n=0;
   for(int i=MathMax(a,0);i<=MathMin(b,m_total-1);i++)
     {
      if(m_start[i]!=0)
         continue;
      const double e=m_x[i]/m_psi[i];
      s +=e;
      s2+=e*e;
      n++;
     }
   if(n<2)
      return 0.0;
   const double m=s/n;
   const double v=s2/n-m*m;
   return (m>0.0 && v>0.0 ? MathSqrt(v)/m : 0.0);
  }
//+------------------------------------------------------------------+
