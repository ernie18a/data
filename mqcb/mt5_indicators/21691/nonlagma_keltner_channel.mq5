//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "NonLagMA Keltner channel"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   5
#property indicator_label1  "upper filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'207,243,207'
#property indicator_label2  "lower filling"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'252,225,205'
#property indicator_label3  "Upper band"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrLimeGreen,clrSandyBrown
#property indicator_label4  "Lower band"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrLimeGreen,clrSandyBrown
#property indicator_label5  "Middle value"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDarkGray
//
//---
//
input int                inpPeriod        = 14;            // Period
input ENUM_APPLIED_PRICE inpPrice         = PRICE_TYPICAL; // Price
input int                inpAtrPeriod     = 14;            // ATR period
input double             inpAtrMultiplier = 1.5;           // Channel multiplier

double bufferUp[],bufferUpc[],bufferDn[],bufferDnc[],bufferMe[],fupu[],fupd[],fdnd[],fdnu[];
//------------------------------------------------------------------
//
//------------------------------------------------------------------
int OnInit()
  {
   SetIndexBuffer(0,fupu,INDICATOR_DATA);     SetIndexBuffer(1,fupd,INDICATOR_DATA);
   SetIndexBuffer(2,fdnu,INDICATOR_DATA);     SetIndexBuffer(3,fdnd,INDICATOR_DATA);
   SetIndexBuffer(4,bufferUp,INDICATOR_DATA); SetIndexBuffer(5,bufferUpc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,bufferDn,INDICATOR_DATA); SetIndexBuffer(7,bufferDnc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(8,bufferMe,INDICATOR_DATA);
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason) { return; }
//
//---
//
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
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   //
   //---
   //
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double _atr = 0;
         for (int k=0; k<inpAtrPeriod && (i-k-1)>=0; k++) _atr += MathMax(high[i-k],close[i-k-1])-MathMin(low[i-k],close[i-k-1]); _atr /= inpAtrPeriod;
      bufferMe[i] = iNonLagMa(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,i,rates_total);         
      bufferUp[i] = bufferMe[i] + _atr*inpAtrMultiplier;
      bufferDn[i] = bufferMe[i] - _atr*inpAtrMultiplier;
      fupd[i]     = bufferMe[i]; fupu[i] = bufferUp[i];
      fdnu[i]     = bufferMe[i]; fdnd[i] = bufferDn[i];
      if(i>0)
        {
         bufferUpc[i] = bufferUpc[i-1];
         bufferDnc[i] = bufferDnc[i-1];

         //
         //
         //
         //
         //

         if(bufferUp[i]>bufferUp[i-1]) bufferUpc[i] = 0;
         if(bufferUp[i]<bufferUp[i-1]) bufferUpc[i] = 1;
         if(bufferDn[i]>bufferDn[i-1]) bufferDnc[i] = 0;
         if(bufferDn[i]<bufferDn[i-1]) bufferDnc[i] = 1;
        }
     }
   return(i);
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _length  0
#define _len     1
#define _weight  2
//
//---
//
double  nlmvalues[][3];
double  nlmprices[][1];
double  nlmalphas[][1];
//
//---
//
double iNonLagMa(double price,double length,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(nlmprices,0)!=bars) ArrayResize(nlmprices,bars);
   if(ArrayRange(nlmvalues,0)<instanceNo+1) ArrayResize(nlmvalues,instanceNo+1);
   nlmprices[r][instanceNo]=price;
   if(length<5 || r<3) return(nlmprices[r][instanceNo]);
//
//---
//
   if(nlmvalues[instanceNo][_length]!=length)
     {
      double Cycle = 4.0;
      double Coeff = 3.0*M_PI;
      int    Phase = (int)(length-1);

      nlmvalues[instanceNo][_length] =       length;
      nlmvalues[instanceNo][_len   ] = (int)(length*4) + Phase;
      nlmvalues[instanceNo][_weight] = 0;

      if(ArrayRange(nlmalphas,0)<(int)nlmvalues[instanceNo][_len]) ArrayResize(nlmalphas,(int)nlmvalues[instanceNo][_len]);
      for(int k=0; k<(int)nlmvalues[instanceNo][_len]; k++)
        {
         double t;
         if(k<=Phase-1)
               t = 1.0 * k/(Phase-1);
         else  t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0);
         double beta=MathCos(M_PI*t);
         double g=1.0/(Coeff*t+1); if(t<=0.5) g=1;

         nlmalphas[k][instanceNo]        = g * beta;
         nlmvalues[instanceNo][_weight] += nlmalphas[k][instanceNo];
        }
     }
//
//---
//
   if(nlmvalues[instanceNo][_weight]>0)
     {
      double sum=0;
      for(int k=0; k<(int)nlmvalues[instanceNo][_len] && (r-k)>=0; k++) sum+=nlmalphas[k][instanceNo]*nlmprices[r-k][instanceNo];
      return( sum / nlmvalues[instanceNo][_weight]);
     }
   else return(0);
  }
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>=0)
      switch(tprice)
        {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
        }
   return(0);
  }
//+------------------------------------------------------------------+
