//+------------------------------------------------------------------+ 
//|                                                 Extrapolator.mq5 |
//|                                   Copyright 2026, MetaQuotes Ltd.|
//|                                             https://www.mql5.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version   "5.01"
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   7
//--- plot types are fixed here (they decide how buffers map to plots); colours and styles are set in OnInit
#property indicator_type1   DRAW_FILLING     // zone above
#property indicator_type2   DRAW_FILLING     // zone below
#property indicator_type3   DRAW_LINE        // main line
#property indicator_type4   DRAW_LINE        // band +1
#property indicator_type5   DRAW_LINE        // band +2
#property indicator_type6   DRAW_LINE        // band -1
#property indicator_type7   DRAW_LINE        // band -2

//--- constants
#define TWO_PI          6.283185307179586
#define MAX_FREQ_ITER   100        // hard cap on Quinn-Fernandes iterations
#define MIN_ENERGY      1.0e-40
#define MIN_DET         1.0e-9
#define MIN_NPAST       16
#define MIN_TOL         1.0e-12

//--- colour choice shown as a text drop-down list in the inputs
enum ENUM_FX_COLOR
{
   FXC_RED, // Red
   FXC_ORANGE, // Orange
   FXC_GOLD, // Gold
   FXC_YELLOW, // Yellow
   FXC_LIME, // Lime
   FXC_GREEN, // Green
   FXC_TEAL, // Teal
   FXC_LIGHT_SEA_GREEN, // Light Sea Green
   FXC_AQUA, // Aqua
   FXC_DODGER_BLUE, // Dodger Blue
   FXC_BLUE, // Blue
   FXC_NAVY, // Navy
   FXC_PURPLE, // Purple
   FXC_MAGENTA, // Magenta
   FXC_HOT_PINK, // Hot Pink
   FXC_MAROON, // Maroon
   FXC_INDIAN_RED, // Indian Red
   FXC_BROWN, // Brown
   FXC_WHITE, // White
   FXC_SILVER, // Silver
   FXC_GRAY, // Gray
   FXC_BLACK  // Black
};

//--- inputs
input group "=== Timeframe ==="
input ENUM_TIMEFRAMES TimeFrame =PERIOD_CURRENT; // Timeframe of the model (never below the chart timeframe)
input group "=== Model (in bars of the selected timeframe) ==="
input int    Npast         =300;      // Past bars used for the fit
input int    Nfut          =24;       // Max predicted future bars
input int    Nharm         =5;        // Max harmonics (fewer = less overfitting)
input double FreqTOL       =0.00001;  // Tolerance of frequency calculations
input bool   UseLogPrice   =true;     // Fit log(price) instead of price
input double TrendDamp     =0.5;      // Future trend slope multiplier (0 = flat, 1 = full)
input group "=== Harmonic filters ==="
input double MinPeriod     =8.0;      // Ignore cycles shorter than this many bars = noise
input double MaxPeriodFrac =0.5;      // Ignore cycles longer than this * window = trend in disguise
input double MinHarmGain   =0.02;     // Stop adding harmonics below this share of the remaining variance
input double HorizonFrac   =0.5;      // Forecast horizon <= this * dominant period (0 = no limit)
input group "=== Bands ==="
input bool   ShowBands     =true;     // Draw the 4 band lines (+1, +2, -1, -2)
input double ChannelK      =2.0;      // Distance of the OUTER bands from the main line, in residual sigmas (inner = half)
input bool   FillZones     =true;     // Fill the zones between the bands
input bool   FillOuterOnly =true;     // true: fill between band 1 and 2; false: between main line and band 1
input group "=== Colours ==="
input ENUM_FX_COLOR LineColor     =FXC_DODGER_BLUE;      // Main Fourier line
input int           LineWidth     =2;                    // Main line width
input ENUM_FX_COLOR BandUpColor   =FXC_INDIAN_RED;       // Bands above the main line
input ENUM_FX_COLOR BandDownColor =FXC_LIGHT_SEA_GREEN;  // Bands below the main line
input ENUM_FX_COLOR FillUpColor   =FXC_MAROON;           // Zone above
input ENUM_FX_COLOR FillDownColor =FXC_TEAL;             // Zone below
input group "=== Drawing limits (chart bars) ==="
input int    MaxFutureBars =500;      // Max bars drawn to the right of the last bar
input int    MaxPastBars   =3000;     // Max chart bars drawn back in time

//--- validated copies of the inputs
int    g_past,g_fut,g_harm,g_maxFut,g_maxPast,g_csec,g_minBars;
double g_tol,g_damp,g_minPer,g_maxPerFrac,g_minGain,g_horFrac,g_chK;
bool   g_log,g_showBands,g_fill,g_fillOut;

//--- model state
ENUM_TIMEFRAMES g_tf;            // effective timeframe of the model
int      g_sec=1;                // seconds per model bar
int      g_S=1;                  // plot shift = chart bars drawn into the future
int      g_n=0;                  // fitted window length
int      g_h=0;                  // effective horizon (model bars)
datetime g_t0=0;                 // open time of the newest model bar used by the fit
double   g_step=0.0;             // ONE band step in price units (constant along the whole line)
bool     g_have=false;           // data of the newest model bar was loaded
bool     g_ok=false;             // fit succeeded for that bar
bool     g_pending=false;        // history of the model timeframe is not ready yet
bool     g_warned=false;
datetime g_lastBar=0;

//--- work arrays (allocated once)
double   g_y[],g_dt[],g_r[],g_z[],g_rej[],g_cs[],g_sn[],g_cyc[],g_fy[];
double   g_o[];                  // open prices of the model timeframe (series order)
datetime g_tm[];                 // their open times
//--- cache of the fitted model, used to map it onto the chart bars
double   g_pv[];                 // model value (price) at each past model-bar open
datetime g_tmc[];                // open time of those bars
double   g_fv[];                 // model value (price) at future bars k=0..h

//--- indicator buffers
double fUA[],fUB[];              // zone above (2 boundaries)
double fDA[],fDB[];              // zone below (2 boundaries)
double mn[];                     // main line
double u1[],u2[],l1[],l2[];      // bands +1, +2, -1, -2

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Drop-down choice -> terminal colour                              |
//+------------------------------------------------------------------+
color FxColor(const ENUM_FX_COLOR c)
{
   switch(c)
   {
      case FXC_RED: return(clrRed);
      case FXC_ORANGE: return(clrOrange);
      case FXC_GOLD: return(clrGold);
      case FXC_YELLOW: return(clrYellow);
      case FXC_LIME: return(clrLime);
      case FXC_GREEN: return(clrGreen);
      case FXC_TEAL: return(clrTeal);
      case FXC_LIGHT_SEA_GREEN: return(clrLightSeaGreen);
      case FXC_AQUA: return(clrAqua);
      case FXC_DODGER_BLUE: return(clrDodgerBlue);
      case FXC_BLUE: return(clrBlue);
      case FXC_NAVY: return(clrNavy);
      case FXC_PURPLE: return(clrPurple);
      case FXC_MAGENTA: return(clrMagenta);
      case FXC_HOT_PINK: return(clrHotPink);
      case FXC_MAROON: return(clrMaroon);
      case FXC_INDIAN_RED: return(clrIndianRed);
      case FXC_BROWN: return(clrSaddleBrown);
      case FXC_WHITE: return(clrWhite);
      case FXC_SILVER: return(clrSilver);
      case FXC_GRAY: return(clrGray);
      case FXC_BLACK: return(clrBlack);
   }
   return(clrDodgerBlue);
}
//+------------------------------------------------------------------+
double ToPrice(const double v) { return(g_log ? MathExp(v) : v); }
//+------------------------------------------------------------------+
//| Price distance of ONE band step around model value v.            |
//| Log mode: exp(v)*sinh(s) is the symmetric half-width, so that    |
//| c+d and c-d are exactly equidistant from the main line.          |
//+------------------------------------------------------------------+
double StepPrice(const double v,const double s)
{
   return(g_log ? MathExp(v)*MathSinh(s) : s);
}
datetime TimeAt(const datetime &Time[],const int total,const int i)
{
   return(ArrayGetAsSeries(Time) ? Time[i] : Time[total-1-i]);
}
//+------------------------------------------------------------------+
void ClearRange(double &a[],const int cnt)
{
   for(int i=0;i<cnt;i++) a[i]=EMPTY_VALUE;
}
//+------------------------------------------------------------------+
//| Clear drawn buffers. full = everything; otherwise only the range |
//| that can hold data (buffers shift by 1 on a new bar).            |
//+------------------------------------------------------------------+
void ClearAll(const bool full,const int total)
{
   if(full)
   {
      ArrayInitialize(fUA,EMPTY_VALUE); ArrayInitialize(fUB,EMPTY_VALUE);
      ArrayInitialize(fDA,EMPTY_VALUE); ArrayInitialize(fDB,EMPTY_VALUE);
      ArrayInitialize(mn,EMPTY_VALUE);
      ArrayInitialize(u1,EMPTY_VALUE);  ArrayInitialize(u2,EMPTY_VALUE);
      ArrayInitialize(l1,EMPTY_VALUE);  ArrayInitialize(l2,EMPTY_VALUE);
      return;
   }
   const int cnt=MathMin(total,g_S+g_maxPast+4);
   ClearRange(fUA,cnt); ClearRange(fUB,cnt);
   ClearRange(fDA,cnt); ClearRange(fDB,cnt);
   ClearRange(mn,cnt);
   ClearRange(u1,cnt);  ClearRange(u2,cnt);
   ClearRange(l1,cnt);  ClearRange(l2,cnt);
}
//+------------------------------------------------------------------+
//| Write one point (main line, 4 bands, 2 fills) at buffer index m. |
//| Bands are c +/- d and c +/- 2d, d constant = parallel lines.     |
//+------------------------------------------------------------------+
void Put(const int m,const double c,const double d)
{
   mn[m]=c;
   if(!g_showBands) return;
   const double a1=c+d,                  a2=c+2.0*d;
   const double b1=MathMax(c-d,_Point),  b2=MathMax(c-2.0*d,_Point);
   u1[m]=a1; u2[m]=a2; l1[m]=b1; l2[m]=b2;
   if(!g_fill) return;
   fUA[m]=(g_fillOut ? a1 : c); fUB[m]=(g_fillOut ? a2 : a1);
   fDA[m]=(g_fillOut ? b1 : c); fDB[m]=(g_fillOut ? b2 : b1);
}
//+------------------------------------------------------------------+
//| Model value k bars into the future (k fractional), cached model  |
//+------------------------------------------------------------------+
bool FutVal(const double kf,double &v)
{
   if(kf<0.0 || kf>(double)g_h) return(false);
   const int i0=(int)MathFloor(kf);
   if(i0>=g_h) { v=g_fv[g_h]; return(true); }
   const double fr=kf-i0;
   v=g_fv[i0]*(1.0-fr)+g_fv[i0+1]*fr;
   return(true);
}
//+------------------------------------------------------------------+
//| Map the cached model onto the chart bars.                        |
//| Buffer index m = S + i  (i = chart bar, series order);           |
//| m < S  = future bars. The plot shift S puts index S on bar 0.    |
//+------------------------------------------------------------------+
void BuildLines(const int total,const datetime &Time[])
{
   if(!g_ok) return;
   const int S=g_S;
   const int nb=MathMin(total-S,g_maxPast);
   if(nb<1) return;
   const int    n   =g_n;
   const double sec =(double)g_sec;
   const double T0  =(double)g_t0;
   const double d   =g_step;
   const double tc0 =(double)TimeAt(Time,total,0);
   double v=0.0;

//--- future chart bars: u = 1..S bars after the last bar
   for(int u=S;u>=1;u--)
   {
      const double kf=(tc0+(double)u*g_csec-T0)/sec;
      if(FutVal(kf,v)) Put(S-u,v,d);
   }

//--- chart bars up to the last one (moving pointer j over the cached model bars)
   int j=0;
   const double tOld=(double)g_tmc[n-1];
   for(int i=0;i<nb;i++)
   {
      const double x=(double)TimeAt(Time,total,i);
      if(x>=T0)
      {
         // inside the still-forming model bar: continue along the predicted part
         if(!FutVal((x-T0)/sec,v)) continue;
      }
      else
      {
         if(x<tOld) break;                               // older than the fitted window
         while(j+1<n && (double)g_tmc[j+1]>=x) j++;
         const double tj=(double)g_tmc[j];
         if(j+1<n && tj>x)
         {
            const double tn=(double)g_tmc[j+1];
            const double fr=(tj-x)/(tj-tn);
            v=g_pv[j]*(1.0-fr)+g_pv[j+1]*fr;             // linear interpolation between bar opens
         }
         else
            v=g_pv[j];
      }
      Put(S+i,v,d);
   }
}
//+------------------------------------------------------------------+
string TFName(const ENUM_TIMEFRAMES tf)
{
   return(StringSubstr(EnumToString(tf),7));
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   g_past      =MathMax(Npast,MIN_NPAST);
   g_fut       =MathMax(Nfut,1);
   g_harm      =MathMax(Nharm,1);
   g_tol       =MathMax(FreqTOL,MIN_TOL);
   g_damp      =MathMin(MathMax(TrendDamp,0.0),1.0);
   g_log       =UseLogPrice;
   g_minPer    =MathMax(MinPeriod,3.0);
   g_maxPerFrac=MathMin(MathMax(MaxPeriodFrac,0.1),1.0);
   g_minGain   =MathMax(MinHarmGain,0.0);
   g_horFrac   =MathMax(HorizonFrac,0.0);
   g_chK       =MathMax(ChannelK,0.1);
   g_showBands =ShowBands;
   g_fill      =FillZones && ShowBands;
   g_fillOut   =FillOuterOnly;
   g_maxFut    =MathMax(MaxFutureBars,1);
   g_maxPast   =MathMax(MaxPastBars,10);
   g_csec      =MathMax(PeriodSeconds(_Period),1);

//--- effective timeframe: never below the chart timeframe
   g_tf=(TimeFrame==PERIOD_CURRENT ? _Period : TimeFrame);
   g_sec=MathMax(PeriodSeconds(g_tf),1);
   if(g_sec<g_csec)
   {
      PrintFormat("Fourier: timeframe %s is lower than the chart timeframe %s - using %s",
                  TFName(g_tf),TFName(_Period),TFName(_Period));
      g_tf =_Period;
      g_sec=g_csec;
   }
   g_S=MathMax(1,MathMin(g_maxFut,(int)MathCeil((double)g_fut*g_sec/g_csec)));
   g_minBars=MathMax(g_S+10,g_past/4);

   g_n=0; g_h=0; g_t0=0; g_step=0.0;
   g_have=false; g_ok=false; g_pending=false; g_warned=false; g_lastBar=0;

//--- work arrays
   const int nmax=MathMax(g_past,g_fut+1);
   if(ArrayResize(g_y,g_past)<0   || ArrayResize(g_dt,g_past)<0  || ArrayResize(g_r,g_past)<0 ||
      ArrayResize(g_z,g_past)<0   || ArrayResize(g_rej,g_past)<0 || ArrayResize(g_cs,nmax)<0  ||
      ArrayResize(g_sn,nmax)<0    || ArrayResize(g_cyc,nmax)<0   || ArrayResize(g_fy,g_fut+1)<0 ||
      ArrayResize(g_pv,g_past)<0  || ArrayResize(g_tmc,g_past)<0 || ArrayResize(g_fv,g_fut+1)<0)
   {
      Print("Fourier: memory allocation failed");
      return(INIT_FAILED);
   }
   ArraySetAsSeries(g_o,true);
   ArraySetAsSeries(g_tm,true);

//--- buffers: fill above (2), fill below (2), main line, bands +1 +2 -1 -2
   bool ok=true;
   ok=ok && SetIndexBuffer(0,fUA,INDICATOR_DATA); ok=ok && SetIndexBuffer(1,fUB,INDICATOR_DATA);
   ok=ok && SetIndexBuffer(2,fDA,INDICATOR_DATA); ok=ok && SetIndexBuffer(3,fDB,INDICATOR_DATA);
   ok=ok && SetIndexBuffer(4,mn,INDICATOR_DATA);
   ok=ok && SetIndexBuffer(5,u1,INDICATOR_DATA);  ok=ok && SetIndexBuffer(6,u2,INDICATOR_DATA);
   ok=ok && SetIndexBuffer(7,l1,INDICATOR_DATA);  ok=ok && SetIndexBuffer(8,l2,INDICATOR_DATA);
   if(!ok)
   {
      Print("Fourier: SetIndexBuffer failed");
      return(INIT_FAILED);
   }
   ArraySetAsSeries(fUA,true); ArraySetAsSeries(fUB,true);
   ArraySetAsSeries(fDA,true); ArraySetAsSeries(fDB,true);
   ArraySetAsSeries(mn,true);
   ArraySetAsSeries(u1,true);  ArraySetAsSeries(u2,true);
   ArraySetAsSeries(l1,true);  ArraySetAsSeries(l2,true);

//--- plots
   const string nmT=TFName(g_tf);
   for(int p=0;p<7;p++)
   {
      PlotIndexSetDouble(p,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      PlotIndexSetInteger(p,PLOT_SHIFT,g_S);
   }
   for(int p=0;p<2;p++)                                   // zones
   {
      PlotIndexSetInteger(p,PLOT_DRAW_TYPE,g_fill ? DRAW_FILLING : DRAW_NONE);
      PlotIndexSetInteger(p,PLOT_COLOR_INDEXES,2);
      const color fc=FxColor(p==0 ? FillUpColor : FillDownColor);
      PlotIndexSetInteger(p,PLOT_LINE_COLOR,0,fc);
      PlotIndexSetInteger(p,PLOT_LINE_COLOR,1,fc);
      PlotIndexSetInteger(p,PLOT_SHOW_DATA,false);
      PlotIndexSetString(p,PLOT_LABEL,"Fourier "+nmT+(p==0 ? " zone up" : " zone down"));
   }
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE);       // main line
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,FxColor(LineColor));
   PlotIndexSetInteger(2,PLOT_LINE_STYLE,STYLE_SOLID);
   PlotIndexSetInteger(2,PLOT_LINE_WIDTH,MathMin(MathMax(LineWidth,1),5));
   PlotIndexSetString(2,PLOT_LABEL,"Fourier "+nmT);
   const string bl[4]={"+1","+2","-1","-2"};              // bands
   for(int k=0;k<4;k++)
   {
      const int p=3+k;
      PlotIndexSetInteger(p,PLOT_DRAW_TYPE,g_showBands ? DRAW_LINE : DRAW_NONE);
      PlotIndexSetInteger(p,PLOT_LINE_COLOR,FxColor(k<2 ? BandUpColor : BandDownColor));
      PlotIndexSetInteger(p,PLOT_LINE_STYLE,(k%2==0 ? STYLE_DASH : STYLE_DOT));
      PlotIndexSetInteger(p,PLOT_LINE_WIDTH,1);
      PlotIndexSetString(p,PLOT_LABEL,"Fourier "+nmT+" band "+bl[k]);
   }
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   IndicatorSetString(INDICATOR_SHORTNAME,"Fourier("+nmT+","+IntegerToString(g_past)+")");
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Fit the multitone model on the last n bars of the model          |
//| timeframe (g_o, g_tm already loaded) and cache the line values.  |
//+------------------------------------------------------------------+
bool Fit(const int n)
{
   const int nm=MathMax(n,g_fut+1);

//--- load prices
   double my=0.0;
   for(int i=0;i<n;i++)
   {
      const double p=g_o[i];
      if(!MathIsValidNumber(p) || p<=0.0) return(false);
      const double v=(g_log ? MathLog(p) : p);
      g_y[i]=v;
      my+=v;
   }
   my/=n;

//--- linear detrending: y = c0 + c1*i   (i = bars ago, c0 = value at newest bar)
   const double mi=0.5*(n-1);
   double Sxy=0.0,Sxx=0.0;
   for(int i=0;i<n;i++)
   {
      const double di=i-mi;
      Sxy+=di*(g_y[i]-my); Sxx+=di*di;
   }
   if(Sxx<=0.0) return(false);
   const double c1=Sxy/Sxx;
   const double c0=my-c1*mi;

   double ssDet=0.0;
   for(int i=0;i<n;i++)
   {
      const double d=g_y[i]-(c0+c1*i);
      g_dt[i]=d;
      ssDet+=d*d;
   }
   if(ssDet<MIN_ENERGY) return(false);

   ArrayInitialize(g_cyc,0.0);
   ArrayInitialize(g_fy,0.0);
   ArrayInitialize(g_rej,0.0);

//--- harmonic extraction
   const int hl=MathMin(g_harm,n/2);
   const int maxTries=2*hl+2;
   int    nAcc=0,tries=0;
   double ssCur=ssDet,domPeriod=0.0,bestGain=0.0;

   while(nAcc<hl && tries<maxTries)
   {
      tries++;
      for(int i=0;i<n;i++) g_r[i]=g_dt[i]-g_cyc[i]-g_rej[i];

      double w=0.0,m=0.0,a=0.0,b=0.0;
      if(!Freq(n,w)) break;
      const double cd=MathCos(w),sd=MathSin(w);          // rotation recurrence: 2 trig calls instead of 2*nm
      double cc=1.0,ss=0.0;
      for(int i=0;i<nm;i++)
      {
         g_cs[i]=cc;
         g_sn[i]=ss;
         const double cn=cc*cd-ss*sd;
         ss=ss*cd+cc*sd;
         cc=cn;
      }
      if(!TrigFit(n,w,m,a,b)) break;

      double ssNew=0.0;
      for(int i=0;i<n;i++)
      {
         const double d=g_r[i]-(m+a*g_cs[i]+b*g_sn[i]);
         ssNew+=d*d;
      }
      const double gain  =(ssCur-ssNew)/MathMax(ssCur,MIN_ENERGY);   // share of the REMAINING variance
      const double period=(w>1.0e-9 ? TWO_PI/w : 1.0e9);

      // outside the allowed band: remove from residual, but do not use for extrapolation
      if(period<g_minPer || period>g_maxPerFrac*n)
      {
         for(int i=0;i<n;i++) g_rej[i]+=m+a*g_cs[i]+b*g_sn[i];
         ssCur=ssNew;
         continue;
      }
      if(gain<g_minGain) break;           // remaining harmonics are not significant

      for(int i=0;i<nm;i++)       g_cyc[i]+=m+a*g_cs[i]+b*g_sn[i];
      for(int k=0;k<=g_fut;k++)   g_fy[k] +=m+a*g_cs[k]-b*g_sn[k];
      nAcc++;
      ssCur=ssNew;
      if(gain>bestGain) { bestGain=gain; domPeriod=period; }
   }

//--- residual sigma of the accepted model (band width)
   double ssAcc=0.0;
   for(int i=0;i<n;i++)
   {
      const double d=g_dt[i]-g_cyc[i];
      ssAcc+=d*d;
   }
   const double sig=MathSqrt(MathMax(ssAcc,0.0)/n);

//--- horizon limited by dominant cycle
   int h=g_fut;
   if(nAcc>0 && g_horFrac>0.0 && domPeriod>0.0)
      h=MathMin(g_fut,MathMax(1,(int)MathFloor(domPeriod*g_horFrac)));

   const double f0  =c0+g_cyc[0];
   const double step=StepPrice(f0,0.5*g_chK*sig);
   if(!MathIsValidNumber(f0) || !MathIsValidNumber(step) || step<0.0) return(false);

//--- cache: past values at every bar open, future values k=0..h (price units)
   for(int i=0;i<n;i++)
   {
      const double pv=ToPrice(c0+c1*i+g_cyc[i]);
      if(!MathIsValidNumber(pv)) return(false);
      g_pv[i] =pv;
      g_tmc[i]=g_tm[i];
   }
   for(int k=0;k<=h;k++)
   {
      const double fv=ToPrice(c0-c1*k*g_damp+g_fy[k]);
      if(!MathIsValidNumber(fv)) return(false);
      g_fv[k]=fv;
   }
   g_n=n; g_h=h; g_step=step;
   return(true);
}
//+------------------------------------------------------------------+
//| Load the data of the model timeframe and refit. Returns false    |
//| only if the DATA is not available yet (retry later); a failed    |
//| fit is remembered for this bar and not retried on every tick.    |
//+------------------------------------------------------------------+
bool Refit()
{
   g_ok=false;
   const int avail=Bars(_Symbol,g_tf);
   const int n=MathMin(g_past,avail);
   if(n<MIN_NPAST) return(false);
   if(CopyOpen(_Symbol,g_tf,0,n,g_o)!=n || CopyTime(_Symbol,g_tf,0,n,g_tm)!=n) return(false);
   g_t0  =g_tm[0];
   g_have=true;
   g_ok  =Fit(n);
   return(true);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(rates_total<g_minBars)
   {
      if(!g_warned)
      {
         PrintFormat("Fourier: not enough bars in history (%d < %d)",rates_total,g_minBars);
         g_warned=true;
      }
      return(0);
   }
   g_warned=false;

   const datetime newest=TimeAt(Time,rates_total,0);

//--- same bar, new tick: redraw only if the model timeframe opened a new bar or still waits for data
   const bool need=(prev_calculated==0 || prev_calculated!=rates_total || newest!=g_lastBar ||
                    g_pending || iTime(_Symbol,g_tf,0)!=g_t0);
   if(!need) return(rates_total);

//--- full clear unless exactly one new bar arrived
   const bool full=(prev_calculated==0 || prev_calculated>rates_total || rates_total-prev_calculated!=1);
   ClearAll(full,rates_total);

//--- refit when the newest model bar changed (or the data never arrived)
   g_pending=false;
   const datetime cur=iTime(_Symbol,g_tf,0);
   if(cur==0)
   {
      g_pending=true;
      g_ok=false;
   }
   else if(!g_have || cur!=g_t0)
   {
      if(!Refit()) { g_pending=true; g_have=false; }
   }

//--- map the cached model onto the chart bars
   BuildLines(rates_total,Time);

   g_lastBar=newest;
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Quinn and Fernandes algorithm for finding frequency              |
//| Works on g_r[0..n-1]. Returns false if no valid frequency.       |
//+------------------------------------------------------------------+
bool Freq(const int n,double &w)
{
   double alpha=0.0;
   double beta =2.0;
   int    iter =0;

   g_z[0]=g_r[0];
   do
   {
      alpha=beta;
      g_z[1]=g_r[1]+alpha*g_z[0];
      double num=g_z[0]*g_z[1];
      double den=g_z[0]*g_z[0];
      for(int i=2;i<n;i++)
      {
         g_z[i]=g_r[i]+alpha*g_z[i-1]-g_z[i-2];
         num+=g_z[i-1]*(g_z[i]+g_z[i-2]);
         den+=g_z[i-1]*g_z[i-1];
      }
      if(!MathIsValidNumber(num) || !MathIsValidNumber(den) || den<MIN_ENERGY) return(false);
      beta=num/den;
      iter++;
   }
   while(MathAbs(alpha-beta)>g_tol && iter<MAX_FREQ_ITER);

   if(!MathIsValidNumber(beta)) return(false);
   double c=beta/2.0;
   if(c> 1.0) c= 1.0;
   if(c<-1.0) c=-1.0;
   w=MathArccos(c);
   return(MathIsValidNumber(w));
}
//+------------------------------------------------------------------+
//| Least-squares fitting of one harmonic (uses g_r, g_cs, g_sn)     |
//+------------------------------------------------------------------+
bool TrigFit(const int n,const double w,double &m,double &a,double &b)
{
   double Sc=0.0,Ss=0.0,Scc=0.0,Sss=0.0,Scs=0.0,Sx=0.0,Sxc=0.0,Sxs=0.0;
   for(int i=0;i<n;i++)
   {
      const double c =g_cs[i];
      const double s =g_sn[i];
      const double dx=g_r[i];
      Sc +=c;     Ss +=s;
      Scc+=c*c;   Sss+=s*s;   Scs+=c*s;
      Sx +=dx;    Sxc+=dx*c;  Sxs+=dx*s;
   }
   Sc/=n; Ss/=n; Scc/=n; Sss/=n; Scs/=n; Sx/=n; Sxc/=n; Sxs/=n;

   const double Ccc=Scc-Sc*Sc;
   const double Css=Sss-Ss*Ss;
   const double Ccs=Scs-Sc*Ss;
   const double Cxc=Sxc-Sx*Sc;
   const double Cxs=Sxs-Sx*Ss;
   const double den=Ccs*Ccs-Ccc*Css;

   if(w<1.0e-9)
   {
      m=Sx; a=0.0; b=0.0;
   }
   else if(MathAbs(den)>MIN_DET)
   {
      a=(Cxs*Ccs-Cxc*Css)/den;
      b=(Cxc*Ccs-Cxs*Ccc)/den;
      m=Sx-a*Sc-b*Ss;
   }
   else if(Ccc>MIN_DET)
   {
      a=Cxc/Ccc;                           // sin() ~ 0 (w near pi): cos-only fit
      b=0.0;
      m=Sx-a*Sc;
   }
   else
   {
      m=Sx; a=0.0; b=0.0;
   }
   return(MathIsValidNumber(m) && MathIsValidNumber(a) && MathIsValidNumber(b));
}
