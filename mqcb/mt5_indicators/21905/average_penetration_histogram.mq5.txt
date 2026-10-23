//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Average penetration histogram"
#property description "Histogram calculating way by Vonasi"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "Histogram"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDodgerBlue,clrCrimson
#property indicator_width1  2
#property indicator_maximum  1
#property indicator_minimum -1
//
//--- input parameters
//
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
enum enCountWhat
{
   count_closes, // Count close price for penetration
   count_highlow // Count high and lowe prices for penetration
};  
enum enHistoType
{
   histo_classical, // Classical (higher/lower value) comparison
   histo_vonasi     // Vonasi type histogram
};
input int                inpPeriod    = 63;           // Look-back period
input int                inpMaPeriod  = 100;          // Average period
input enMaTypes          inpMaMethod  = ma_sma;       // Average method
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE;  // Average price
input enCountWhat        inpCountWhat = count_closes; // Count mode :
input enHistoType        inpHistoType = histo_vonasi; // Histogram type
//
//--- indicator buffers
//
double histo[],histoc[],lineup[],linedn[],average[];
string _maNames[] = {"SMA","EMA","SMMA","LWMA"};
string _coNames[] = {"couniting closes","counting high/low"};
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
  {
   SetIndexBuffer(0,histo,INDICATOR_DATA);
   SetIndexBuffer(1,histoc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,lineup,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,linedn,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,average,INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Average penetration histogram "+_coNames[inpCountWhat]+" ("+(string)inpPeriod+","+(string)inpMaPeriod+" "+_maNames[inpMaMethod]+")");
   return(INIT_SUCCEEDED);
  }
//------------------------------------------------------------------
// Custom indicator de-initialization function
//------------------------------------------------------------------
void OnDeinit(const int reason) { return; }
//------------------------------------------------------------------
// Custom iteration function
//------------------------------------------------------------------
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);

//
//---
//

   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
     {
      average[i] = iCustomMa(inpMaMethod,getPrice(inpPrice,open,close,high,low,i,rates_total),inpMaPeriod,i,rates_total,0);
      lineup[i]  = 0;
      linedn[i]  = 0;
      for (int k=0; k<inpPeriod && (i-k)>=0; k++)
      {
         lineup[i]  += (inpCountWhat==count_closes?close[i-k]:high[i-k])>average[i-k];
         linedn[i]  += (inpCountWhat==count_closes?close[i-k]:low[i-k] )<average[i-k];
      }         
      int direction = (lineup[i]>linedn[i]) ? 1 : (lineup[i]<linedn[i]) ? -1 : 0; 
      if (inpHistoType==histo_vonasi)
      {
         if (direction== 1 && i>0 && lineup[i]-linedn[i]<lineup[i-1]-linedn[i-1]) direction = -1;
         if (direction==-1 && i>0 && linedn[i]-lineup[i]<linedn[i-1]-lineup[i-1]) direction =  1;
      }
      histo[i]  = direction;
      histoc[i] = (direction==1) ? 0 : 1;
     }
   return(rates_total);
  }
//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
#define _maInstances 1
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
