//+------------------------------------------------------------------+
//|                                      Hodrick-Prescott Filter.mq5 |
//|                                             Copyright 2010, gpwr |
//|                                               vlad1004@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "gpwr"
#property version   "1.00"
#property description "Hodrick-Prescott Filter"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "filter"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//===================================== INPUTS ===========================================
input int Per =50;  // HP filter period
input int N   =500; // # of prices to smooth
//--- global variables
int PrevBars;
double Lambda;

//--- indicator buffers
double hpf[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- initialize global variables
   PrevBars=Bars(_Symbol,_Period)-1;
   Lambda=0.0625/MathPow(MathSin(M_PI/Per),4);

//--- map indicator buffers
   ArraySetAsSeries(hpf,true);
   SetIndexBuffer(0,hpf,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   IndicatorSetString(INDICATOR_SHORTNAME,"HPF("+string(Per)+")");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int bars,
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
//--- check for insufficient data and new bar
   if(bars<N)
     {
      Print("Error: not enough bars in history!");
      return(0);
     }
   if(PrevBars==bars) return(bars);
   PrevBars=bars;

//--- initialize indicator buffer to EMPTY_VALUE
   ArrayInitialize(hpf,EMPTY_VALUE);

//--- reverse indexing direction for Open
   ArraySetAsSeries(Open,true);

//--- main cycle
   for(int i=0;i<N;i++) hpf[i]=Open[i];
   HPF(N,Lambda,hpf);
   return(bars);
  }
//+------------------------------------------------------------------+
//| Hodrick-Prescott Filter                                          |
//+------------------------------------------------------------------+
void HPF(int n,double lambda,double &x[])
  {
   double a[],b[],c[],h1,h2,h3,h4,h5,hh1,hh2,hh3,hh5,hb,hc,z;
   ArrayResize(a,n);
   ArrayResize(b,n);
   ArrayResize(c,n);

   ArrayInitialize(a,0.0);
   ArrayInitialize(b,0.0);
   ArrayInitialize(c,0.0);

   a[0]=1.0+lambda;
   b[0]=-2.0*lambda;
   c[0]=lambda;
   for(int i=1;i<n-2;i++)
     {
      a[i]=6.0*lambda+1.0;
      b[i]=-4.0*lambda;
      c[i]=lambda;
     }
   a[1]=5.0*lambda+1;
   a[n-1]=1.0+lambda;
   a[n-2]=5.0*lambda+1.0;
   b[n-2]=-2.0*lambda;
   b[n-1]=0.0;
   c[n-2]=0.0;
   c[n-1]=0.0;

//--- forward
   for(int i=0;i<n;i++)
     {
      z=a[i]-h4*h1-hh5*hh2;
      hb=b[i];
      hh1=h1;
      h1=(hb-h4*h2)/z;
      b[i]=h1;
      hc=c[i];
      hh2=h2;
      h2=hc/z;
      c[i]=h2;
      a[i]=(x[i]-hh3*hh5-h3*h4)/z;
      hh3=h3;
      h3=a[i];
      h4=hb-h5*hh1;
      hh5=h5;
      h5=hc;
     }

//--- backward 
   h2=0;
   h1=a[n-1];
   x[n-1]=h1;
   for(int i=n-2;i>=0;i--)
     {
      x[i]=a[i]-b[i]*h1-c[i]*h2;
      h2=h1;
      h1=x[i];
     }
  }
//+------------------------------------------------------------------+
