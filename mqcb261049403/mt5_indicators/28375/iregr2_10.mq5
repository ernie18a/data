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
//
// V2.0 by l3chat
// - greatly improved calculation accuracy,
// - added trend colors

#property copyright "© 2008 BJF Trading Group"
#property link      "www.iticsoftware.com"
#property version   "2.0"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   3
//--- plot h
#property indicator_label1  "up"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGold, clrDarkGoldenrod
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot m
#property indicator_label2  "middle"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrLimeGreen, clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3
//--- plot l
#property indicator_label3  "down"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrGold, clrDarkGoldenrod
#property indicator_style3  STYLE_SOLID
#property indicator_width3  3

//--- input parameters
input int      degree=4;//Polynome degree
input double   kstd=2.0;//Channel width, std deviations
input int      bars=500;//Channel length, bars
input int      nextBars=100;//Extrapolate for N bars

//--- indicator buffers
double         hBuffer[];
double         hcBuffer[];
double         mBuffer[];
double         mcBuffer[];
double         lBuffer[];
double         lcBuffer[];
double         dBuffer[];

double ai[10,10],b[10],x[10],sx[20];
int f;
double qq,mm,tt;
int ii,jj,kk,ll;

int i0=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){
//--- indicator buffers mapping, buffers are accessible from EA
   SetIndexBuffer(0,hBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,hcBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,mBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,mcBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,lBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,lcBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,dBuffer,INDICATOR_CALCULATIONS);
   
   PlotIndexSetInteger(0,PLOT_SHIFT,nextBars);
   PlotIndexSetInteger(1,PLOT_SHIFT,nextBars);
   PlotIndexSetInteger(2,PLOT_SHIFT,nextBars);
//----------------------sx-------------------------------------------------------------------
   sx[1]=bars+1;
   for(int i=1; i<=(degree+1)*2-2; i++){
      double sum=0;
      for(int n=0; n<=bars; n++){
         sum+=MathPow(1+(n+0.)/bars, i);
      }
      sx[i+1]=sum;
   }

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
   
   if(rates_total > prev_calculated){
   } else {
      return(rates_total);
   }

//----

   i0=rates_total-bars-1;

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-bars-nextBars-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,rates_total-bars-nextBars-1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,rates_total-bars-nextBars-1);

//===============restore Linear Equations Matrix=============================================
   for(jj=1;jj<=degree+1;jj++){
      for(ii=1; ii<=degree+1; ii++){
         ai[ii,jj]=sx[ii+jj-1];
      }
   }
//----------------------syx-----------
   for(int mi=1;mi<=degree+1;mi++){
      double sum=0.00000;
      for(int n=i0;n<=i0+bars;n++){
         if(mi==1) sum+=open[n];
         else sum+=open[n]*MathPow(1+(n-i0+0.)/bars,mi-1);
      }
      b[mi]=sum;
   }
//===============Solving Equations with Gauss method===========================================
   for(kk=1; kk<=degree; kk++){
      ll=0;
      mm=0;
      for(ii=kk; ii<=degree+1; ii++){
         if(MathAbs(ai[ii,kk])>mm){
            mm=MathAbs(ai[ii,kk]);
            ll=ii;
         }
      }
      if(ll==0) return(rates_total);
      if(ll!=kk){
         for(jj=1; jj<=degree+1; jj++){
            tt=ai[kk,jj];
            ai[kk,jj]=ai[ll,jj];
            ai[ll,jj]=tt;
         }
         tt=b[kk];
         b[kk]=b[ll];
         b[ll]=tt;
      }
      for(ii=kk+1;ii<=degree+1;ii++){
         qq=ai[ii,kk]/ai[kk,kk];
         for(jj=1;jj<=degree+1;jj++){
            if(jj==kk) ai[ii,jj]=0;
            else ai[ii,jj]=ai[ii,jj]-qq*ai[kk,jj];
         }
         b[ii]=b[ii]-qq*b[kk];
      }
   }
   x[degree+1]=b[degree+1]/ai[degree+1,degree+1];
   for(ii=degree;ii>=1;ii--){
      tt=0;
      for(jj=1;jj<=degree+1-ii;jj++){
         tt=tt+ai[ii,ii+jj]*x[ii+jj];
         x[ii]=(1/ai[ii,ii])*(b[ii]-tt);
      }
   }
//===========================================================================================================================
   for(int n=i0;n<=i0+bars+nextBars;n++){
      double sum=0;
      for(kk=1;kk<=degree;kk++){
         sum+=x[kk+1]*MathPow(1+(n-i0+0.)/bars,kk);
      }
      mBuffer[n-nextBars]=x[1]+sum;
   }
   for(int n=i0+bars; n>i0-nextBars; n--){
      if(mBuffer[n]>mBuffer[n-1]) mcBuffer[n]=0;
      else mcBuffer[n]=1;
   }
   mcBuffer[i0-nextBars]=mcBuffer[i0-nextBars+1];
   for(int n=i0+bars; n>i0+1-nextBars; n--){
      if(mBuffer[n]-2*mBuffer[n-1]+mBuffer[n-2]>0){
         hcBuffer[n]=0;
         lcBuffer[n]=0;
      }else{
         hcBuffer[n]=1;
         lcBuffer[n]=1;
      }
   }
   hcBuffer[i0+1-nextBars]=hcBuffer[i0+2-nextBars];
   lcBuffer[i0+1-nextBars]=lcBuffer[i0+2-nextBars];
   hcBuffer[i0-nextBars]=hcBuffer[i0+2-nextBars];
   lcBuffer[i0-nextBars]=lcBuffer[i0+2-nextBars];
//-----------------------------------Std-----------------------------------------------------------------------------------
   double sq=0.0;
   for(int n=i0;n<=i0+bars;n++){
      sq+=MathPow(open[n]-mBuffer[n-nextBars],2);
   }
   sq=MathSqrt(sq/(bars+1))*kstd;

   for(int n=i0-nextBars;n<=i0+bars;n++){
      hBuffer[n]=mBuffer[n]+sq;
      lBuffer[n]=mBuffer[n]-sq;
      dBuffer[n]=sq;
   }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
