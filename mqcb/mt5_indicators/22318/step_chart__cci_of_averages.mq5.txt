//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Step chart of CCI"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "Step chart of CCI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Step chart"
#property indicator_type2   DRAW_COLOR_HISTOGRAM2
#property indicator_color2  clrDarkGray,clrDodgerBlue,clrSandyBrown
#property indicator_width2  2
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
input int                inpPeriod    = 32;            // CCI period
input ENUM_APPLIED_PRICE inpPrice     = PRICE_TYPICAL; // Price
input int                inpAvgPeriod = 14;            // Average filter period (<=1 for no filtering)
input enMaTypes          inpMaType    = ma_sma;        // Average type
input double             inpStepSize  = 50;            // Step size (in CCI units)
//
//--- buffers and global variables declarations
//
double barh[],barl[],barc[],val[];
string _avgName[] = {"SMA","EMA","SMMA","LWMA"};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,barh,INDICATOR_DATA);
   SetIndexBuffer(2,barl,INDICATOR_DATA);
   SetIndexBuffer(3,barc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Step chart of ("+(string)inpPeriod+" CCI"+(inpAvgPeriod>1 ? " of "+(string)inpAvgPeriod+" "+_avgName[inpMaType] :"")+")");
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
   
   //
   //---
   //
   
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      val[i] = iCci(iCustomMa(inpMaType,getPrice(inpPrice,open,close,high,low,i,rates_total),inpAvgPeriod,i,rates_total),inpPeriod,i,rates_total);
      double rbarh,rbarl,rtrend;
         iStepChart(val[i],inpStepSize,rbarh,rbarl,rtrend,i,rates_total);
            barh[i] = rbarh;
            barl[i] = (rbarh==rbarl) ? rbarh-1 : rbarl;
            barc[i] = (rtrend==1) ? 1 : 2;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _maInstances 1
#define _maWorkBufferx1 _maInstances
double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   switch (mode)
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
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars); int k=1;

   workSma[r][instanceNo+0] = price;
   double avg = price; for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo+0];  avg /= (double)k;
   return(avg);
}
//
//---
//
double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}
//
//---
//
double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo] = price;
   if (r>1 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}
//
//---
//
double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   workLwma[r][instanceNo] = price; if (period<1) return(price);
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}
//
//---
//
#define _cciInstances 1
double workCci[][_cciInstances];
#define _price  0
//
//---
//
double iCci(double price,double period,int i,int bars,int instanceNo=0)
{
   if(ArrayRange(workCci,0)!=bars) ArrayResize(workCci,bars);
   //
   //---
   //
   
   workCci[i][instanceNo+_price]=price;
         double avg = 0; for(int k=0; k<period && (i-k)>=0; k++) avg +=         workCci[i-k][instanceNo];      avg /= (double)period;
         double dev = 0; for(int k=0; k<period && (i-k)>=0; k++) dev += MathAbs(workCci[i-k][instanceNo]-avg); dev /= (double)period;
         double cci = (dev!=0) ? (price-avg)/(0.015*dev) : 0;
   return(cci);
  }
//
//---
//
#define _stepChartInstances     1
#define _stepChartInstancesSize 2
double _stepChartWork[][_stepChartInstances*_stepChartInstancesSize];
#define _steps 0
#define _trend 1
//
//---
//
void iStepChart(double value, double stepSize, double& rbarh, double& rbarl, double& rtrend, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(_stepChartWork,0)!=bars) ArrayResize(_stepChartWork,bars); instanceNo*=_stepChartInstancesSize;
   
   //
   //---
   //
   
   if (i==0)
   {
      _stepChartWork[i][instanceNo+_steps] = rbarh  = rbarl = (stepSize>0) ? MathRound(value/stepSize)*stepSize : value; 
      _stepChartWork[i][instanceNo+_trend] = rtrend = 0;
   }
   else
   {
      if (MathAbs(value-_stepChartWork[i-1][instanceNo+_steps]) < stepSize) _stepChartWork[i][instanceNo+_steps] = _stepChartWork[i-1][instanceNo+_steps]; 
      else
      { 
         _stepChartWork[i][instanceNo+_steps] = _stepChartWork[i-1][instanceNo+_steps];
            while(MathAbs(value - _stepChartWork[i][instanceNo+_steps]) > stepSize) 
            {
               if(value > _stepChartWork[i][instanceNo+_steps]) _stepChartWork[i][instanceNo+_steps] += stepSize;
               if(value < _stepChartWork[i][instanceNo+_steps]) _stepChartWork[i][instanceNo+_steps] -= stepSize;
            }
      }    
      _stepChartWork[i][instanceNo+_trend] = (_stepChartWork[i][instanceNo+_steps]>_stepChartWork[i-1][instanceNo+_steps]) ? 1 : (_stepChartWork[i][instanceNo+_steps]<_stepChartWork[i-1][instanceNo+_steps]) ? -1 : _stepChartWork[i-1][instanceNo+_trend];
         rbarh  = _stepChartWork[i  ][instanceNo+_steps];
         rbarl  = _stepChartWork[i-1][instanceNo+_steps];
         rtrend = _stepChartWork[i  ][instanceNo+_trend];
   }
}  
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
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
