//
// Regression Channel with variable polynomial degree indicator
//
// original by Boris
// www.iticsoftware.com
// http://www.mql5.com/en/code/8417
//
// V1.1 by graziani:
// -> minor changes for MT4 b600 compatibility
// https://www.mql5.com/en/code/11749
//
// V1.2 by l3chat
// quick port for MT5

#property copyright "© 2008 BJF Trading Group"
#property link      "www.iticsoftware.com"
#property version   "1.2"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot h
#property indicator_label1  "h"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot m
#property indicator_label2  "m"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot l
#property indicator_label3  "l"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGold
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

//--- input parameters
input int      degree=3;
input double   kstd=2.0;
input int      bars=250;
input int      shift=0;

//--- indicator buffers
double         hBuffer[];
double         mBuffer[];
double         lBuffer[];

double ai[10,10],b[10],x[10],sx[20];
double sum;
int ip,p,n,f;
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
   SetIndexBuffer(0,hBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,mBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,lBuffer,INDICATOR_DATA);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
                const int &spread[]){
//--- Block for calculating indicator values 
   if(rates_total < bars) return(-1);

//----

   int mi;
   ip=bars;
   p=ip;
   sx[1]=p+1;
   nn=degree+1;
   i0=rates_total-p-1;

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-p-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,rates_total-p-1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,rates_total-p-1);

//----------------------sx-------------------------------------------------------------------
   for(mi=1;mi<=nn*2-2;mi++){
      sum=0;
      for(n=i0;n<=i0+p;n++){
         sum+=MathPow(n,mi);
      }
      sx[mi+1]=sum;
     }
//----------------------syx-----------
   for(mi=1;mi<=nn;mi++){
      sum=0.00000;
      for(n=i0;n<=i0+p;n++){
         if(mi==1) sum+=close[n];
         else sum+=close[n]*MathPow(n,mi-1);
      }
      b[mi]=sum;
   }
//===============Linear Equations Matrix=======================================================
   for(jj=1;jj<=nn;jj++){
      for(ii=1; ii<=nn; ii++){
         kk=ii+jj-1;
         ai[ii,jj]=sx[kk];
      }
   }
//===============Solving Equations with Gauss method===========================================
   for(kk=1; kk<=nn-1; kk++){
      ll=0;
      mm=0;
      for(ii=kk; ii<=nn; ii++){
         if(MathAbs(ai[ii,kk])>mm){
            mm=MathAbs(ai[ii,kk]);
            ll=ii;
         }
      }
      if(ll==0) return(rates_total);
      if(ll!=kk){
         for(jj=1; jj<=nn; jj++){
            tt=ai[kk,jj];
            ai[kk,jj]=ai[ll,jj];
            ai[ll,jj]=tt;
         }
         tt=b[kk];
         b[kk]=b[ll];
         b[ll]=tt;
      }
      for(ii=kk+1;ii<=nn;ii++){
         qq=ai[ii,kk]/ai[kk,kk];
         for(jj=1;jj<=nn;jj++){
            if(jj==kk) ai[ii,jj]=0;
            else ai[ii,jj]=ai[ii,jj]-qq*ai[kk,jj];
         }
         b[ii]=b[ii]-qq*b[kk];
      }
   }
   x[nn]=b[nn]/ai[nn,nn];
   for(ii=nn-1;ii>=1;ii--){
      tt=0;
      for(jj=1;jj<=nn-ii;jj++){
         tt=tt+ai[ii,ii+jj]*x[ii+jj];
         x[ii]=(1/ai[ii,ii])*(b[ii]-tt);
      }
   }
//===========================================================================================================================
   for(n=i0;n<=i0+p;n++){
      sum=0;
      for(kk=1;kk<=degree;kk++){
         sum+=x[kk+1]*MathPow(n,kk);
      }
      mBuffer[n]=x[1]+sum;
   }
//-----------------------------------Std-----------------------------------------------------------------------------------
   sq=0.0;
   for(n=i0;n<=i0+p;n++){
      sq+=MathPow(close[n]-mBuffer[n],2);
   }
   sq=MathSqrt(sq/(p+1))*kstd;

   for(n=i0;n<=i0+p;n++){
      hBuffer[n]=mBuffer[n]+sq;
      lBuffer[n]=mBuffer[n]-sq;
   }


//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
