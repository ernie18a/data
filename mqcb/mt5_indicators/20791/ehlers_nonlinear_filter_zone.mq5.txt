//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Ehlers nonlinear filter zone"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   5
#property indicator_label1  "upper filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'207,243,207'
#property indicator_label2  "lower filling"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'255,230,183'
#property indicator_label3  "Upper band"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrLimeGreen,clrDarkOrange
#property indicator_label4  "Lower band"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrLimeGreen,clrDarkOrange
#property indicator_label5  "Middle value"
#property indicator_type5   DRAW_COLOR_LINE
#property indicator_color5  clrSilver,clrLimeGreen,clrDarkOrange
#property indicator_width5  4
//--- input parameters
input int  inpPeriod   = 20; // Nonlinear filter period
input int  inpMomentum = 5;  // Momentum period
//--- indicator buffers
double bufferUp[],bufferUpc[],bufferDn[],bufferDnc[],bufferMe[],bufferMec[],fupu[],fupd[],fdnd[],fdnu[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fupu,INDICATOR_DATA);
   SetIndexBuffer(1,fupd,INDICATOR_DATA);
   SetIndexBuffer(2,fdnu,INDICATOR_DATA);
   SetIndexBuffer(3,fdnd,INDICATOR_DATA);
   SetIndexBuffer(4,bufferUp,INDICATOR_DATA);
   SetIndexBuffer(5,bufferUpc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,bufferDn,INDICATOR_DATA);
   SetIndexBuffer(7,bufferDnc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(8,bufferMe,INDICATOR_DATA);
   SetIndexBuffer(9,bufferMec,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Ehlers nonlinear filter zone ("+(string)inpPeriod+")");
//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      bufferUp[i] = iEnlf(high[i]           ,inpPeriod,inpMomentum,i,rates_total,0);
      bufferMe[i] = iEnlf((high[i]+low[i])/2,inpPeriod,inpMomentum,i,rates_total,1);
      bufferDn[i] = iEnlf( low[i]           ,inpPeriod,inpMomentum,i,rates_total,2);
      fupd[i]      = bufferMe[i]; fupu[i] = bufferUp[i];
      fdnu[i]      = bufferMe[i]; fdnd[i] = bufferDn[i];
      bufferUpc[i] = (i>0) ? (bufferUp[i]>bufferUp[i-1]) ? 1 : (bufferUp[i]<bufferUp[i-1])? 2 : bufferUpc[i-1] : 0;
      bufferDnc[i] = (i>0) ? (bufferDn[i]>bufferDn[i-1]) ? 1 : (bufferDn[i]<bufferDn[i-1])? 2 : bufferDnc[i-1] : 0;
      bufferMec[i] = (bufferUpc[i]==1 && bufferDnc[i]==1) ? 1 : (bufferUpc[i]==2 && bufferDnc[i]==2) ? 2 : 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
//
//---
//
#define _enlfInstances 3
double workEnlf[][_enlfInstances];
//
//---
//
double iEnlf(double price,int length,int momentumLength,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workEnlf,0)!=bars) ArrayResize(workEnlf,bars);
//
//---
//
   workEnlf[r][instanceNo]=price;

   double sumCoef = 0;
   double num     = 0;
   for(int k=0; k<length && (r-k-momentumLength)>=0; k++)
     {
      double coeff=MathAbs(workEnlf[r-k][instanceNo]-workEnlf[r-k-momentumLength][instanceNo]);
      sumCoef += coeff;
      num     += coeff*workEnlf[r-k][instanceNo];
     }
   return( (sumCoef !=0) ? num/sumCoef : price);
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
