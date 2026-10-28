//+------------------------------------------------------------------+
//|                              i-Regr(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property version   "1.001"
#property indicator_chart_window
#property indicator_buffers   3
#property indicator_plots     3
#property indicator_type1     DRAW_LINE
#property indicator_type2     DRAW_LINE
#property indicator_type3     DRAW_LINE
#property indicator_color1    clrLimeGreen
#property indicator_color2    clrGold
#property indicator_color3    clrGold
#property indicator_label1    "top"   
#property indicator_label2    "middle"  
#property indicator_label3    "bottom"  
//+------------------------------------------------------------------+
//| Type of Regression Channel                                       |
//+------------------------------------------------------------------+
enum ENUM_Polynomial
  {
   linear=1,      // linear 
   parabolic=2,   // parabolic 
   Third_power=3, // third-power 
  };
input ENUM_Polynomial degree=linear;
input double kstd=2.0;
input int bars=250;
input int shift=0;

//--- indicator buffers
double sqh_buffer[];
double fx_buffer[];
double sql_buffer[];

double ai[10,10],b[10],x[10],sx[20];
double sum;
int p,n,f;
double qq,mm,tt;
int ii,jj,kk,ll,nn;
double sq;

int i0=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,sqh_buffer,INDICATOR_DATA);
   SetIndexBuffer(1,fx_buffer,INDICATOR_DATA);
   SetIndexBuffer(2,sql_buffer,INDICATOR_DATA);
//--- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//--- line shifts when drawing
   PlotIndexSetInteger(0,PLOT_SHIFT,shift);
   PlotIndexSetInteger(1,PLOT_SHIFT,shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,shift);
//---
   ArraySetAsSeries(fx_buffer,true);
   ArraySetAsSeries(sqh_buffer,true);
   ArraySetAsSeries(sql_buffer,true);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//|  OnCalculate function                                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   ArraySetAsSeries(close,true);
//--- check for rates total
   if(rates_total<bars)
      return(0); // not enough bars for calculation
//---
   int mi;
   p=bars;
   sx[1]=p+1;
   nn=degree+1;
//--- sets first candle from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-p-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,rates_total-p-1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,rates_total-p-1);
//--- sx 
   for(mi=1;mi<=nn*2-2;mi++)
     {
      sum=0;
      for(n=i0;n<=i0+p;n++)
        {
         sum+=MathPow(n,mi);
        }
      sx[mi+1]=sum;
     }
//--- syx 
   for(mi=1;mi<=nn;mi++)
     {
      sum=0.00000;
      for(n=i0;n<=i0+p;n++)
        {
         if(mi==1)
            sum+=close[n];
         else
            sum+=close[n]*MathPow(n,mi-1);
        }
      b[mi]=sum;
     }
//--- Matrix 
   for(jj=1;jj<=nn;jj++)
     {
      for(ii=1; ii<=nn; ii++)
        {
         kk=ii+jj-1;
         ai[ii,jj]=sx[kk];
        }
     }
//--- Gauss 
   for(kk=1; kk<=nn-1; kk++)
     {
      ll=0;
      mm=0;
      for(ii=kk; ii<=nn; ii++)
        {
         if(MathAbs(ai[ii,kk])>mm)
           {
            mm=MathAbs(ai[ii,kk]);
            ll=ii;
           }
        }
      if(ll==0)
         return(rates_total);
      if(ll!=kk)
        {
         for(jj=1; jj<=nn; jj++)
           {
            tt=ai[kk,jj];
            ai[kk,jj]=ai[ll,jj];
            ai[ll,jj]=tt;
           }
         tt=b[kk];
         b[kk]=b[ll];
         b[ll]=tt;
        }
      for(ii=kk+1;ii<=nn;ii++)
        {
         qq=ai[ii,kk]/ai[kk,kk];
         for(jj=1;jj<=nn;jj++)
           {
            if(jj==kk)
               ai[ii,jj]=0;
            else
               ai[ii,jj]=ai[ii,jj]-qq*ai[kk,jj];
           }
         b[ii]=b[ii]-qq*b[kk];
        }
     }
   x[nn]=b[nn]/ai[nn,nn];
   for(ii=nn-1;ii>=1;ii--)
     {
      tt=0;
      for(jj=1;jj<=nn-ii;jj++)
        {
         tt=tt+ai[ii,ii+jj]*x[ii+jj];
         x[ii]=(1/ai[ii,ii])*(b[ii]-tt);
        }
     }
//---
   for(n=i0;n<=i0+p;n++)
     {
      sum=0;
      for(kk=1;kk<=degree;kk++)
        {
         sum+=x[kk+1]*MathPow(n,kk);
        }
      fx_buffer[n]=x[1]+sum;
     }
//--- Std 
   sq=0.0;
   for(n=i0;n<=i0+p;n++)
     {
      sq+=MathPow(close[n]-fx_buffer[n],2);
     }
   sq=MathSqrt(sq/(p+1))*kstd;

   for(n=i0;n<=i0+p;n++)
     {
      sqh_buffer[n]=fx_buffer[n]+sq;
      sql_buffer[n]=fx_buffer[n]-sq;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
