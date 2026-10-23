//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "DEMA trend"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   3
#property indicator_label1  "Envelope histogram"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_label2  "Upper envelope line"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width2  2
#property indicator_label3  "Lower envelope line"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width3  2
//--- input parameters
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };

input double             inpPeriod    = 21;          // Period
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price
input int                inpEnvPeriod = 40;          // Envelopes period
input enMaTypes          inpEnvMethod = ma_lwma;     // Envelopes method
//--- indicator buffers
double histou[],histod[],histoc[],valu[],valuc[],vald[],valdc[],dema[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,histou,INDICATOR_DATA);
   SetIndexBuffer(1,histod,INDICATOR_DATA);
   SetIndexBuffer(2,histoc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,valu,INDICATOR_DATA);
   SetIndexBuffer(4,valuc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,vald,INDICATOR_DATA);
   SetIndexBuffer(6,valdc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(7,dema,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"DEMA trend ("+(string)inpPeriod+")");
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
      double _price=getPrice(inpPrice,open,close,high,low,i,rates_total);
      dema[i]=iDema(_price,inpPeriod,i,rates_total);
      valu[i] = iCustomMa(inpEnvMethod,high[i],inpEnvPeriod,i,rates_total,0);
      vald[i] = iCustomMa(inpEnvMethod,low[i] ,inpEnvPeriod,i,rates_total,1);
      valuc[i]= (i>0) ?(dema[i]>dema[i-1]) ? 2 :(dema[i]<dema[i-1]) ? 1 : valuc[i-1]: 0;
      valdc[i] = valuc[i];
      histou[i] = valu[i];
      histod[i] = vald[i];
      histoc[i] = valuc[i];
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _demaInstances 1
#define _demaInstancesSize 2
double workDema[][_demaInstances*_demaInstancesSize];
#define _dema1 0
#define _dema2 1
//
//---
//
double iDema(double price, double period, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workDema,0)!= bars) ArrayResize(workDema,bars); instanceNo*=_demaInstancesSize;

   //
   //
   //
   //
   //
      
   workDema[r][_dema1+instanceNo] = price;
   workDema[r][_dema2+instanceNo] = price;
   if (r>0 && period>1)
   {
      double alpha = 2.0 / (1.0+period);
          workDema[r][_dema1+instanceNo] = workDema[r-1][_dema1+instanceNo]+alpha*(price                         -workDema[r-1][_dema1+instanceNo]);
          workDema[r][_dema2+instanceNo] = workDema[r-1][_dema2+instanceNo]+alpha*(workDema[r][_dema1+instanceNo]-workDema[r-1][_dema2+instanceNo]); }
   return(workDema[r][_dema1+instanceNo]*2.0-workDema[r][_dema2+instanceNo]);
}
//
//---
//
#define _maInstances 2
#define _maWorkBufferx1 _maInstances
//
//---
//
double iCustomMa(int mode,double price,double length,int r,int bars,int instanceNo=0)
  {
   switch(mode)
     {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
     }
  }
//
//---
//
double workSma[][_maWorkBufferx1];
//
//---
//
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo]=price;
   double avg=price; int k=1; for(; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo];
   return(avg/(double)k);
  }
//
//---
//
double workEma[][_maWorkBufferx1];
//
//---
//
double iEma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=_bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
  }
//
//---
//
double workSmma[][_maWorkBufferx1];
//
//---
//
double iSmma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSmma,0)!=_bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo]=price;
   if(r>1 && period>1)
      workSmma[r][instanceNo]=workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
  }
//
//---
//
double workLwma[][_maWorkBufferx1];
//
//---
//
double iLwma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workLwma,0)!=_bars) ArrayResize(workLwma,_bars);

   workLwma[r][instanceNo] = price; if(period<1) return(price);
   double sumw = period;
   double sum  = period*price;

   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight=period-k;
      sumw  += weight;
      sum   += weight*workLwma[r-k][instanceNo];
     }
   return(sum/sumw);
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
