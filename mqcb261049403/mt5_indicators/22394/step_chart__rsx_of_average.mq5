//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Step chart of RSX of averages"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "RSX of average"
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
input int                inpRsiPeriod = 14;          // RSX period
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price
input int                inpAvgPeriod = 14;          // Average period (<=1 for no average)
input enMaTypes          inpMaType    = ma_sma;      // Average type
input double             inpStepSize  = 5;           // Step size (in RSX %)
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
   IndicatorSetString(INDICATOR_SHORTNAME,"Step chart ("+(string)inpRsiPeriod+") RSX"+(inpAvgPeriod>1 ? " of ("+(string)inpAvgPeriod+" "+_avgName[inpMaType] :"")+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      val[i] = iRsx(iCustomMa(inpMaType,getPrice(inpPrice,open,close,high,low,i,rates_total),inpAvgPeriod,i,rates_total),inpRsiPeriod,i);
      double rbarh,rbarl,rtrend;
         iStepChart(val[i],inpStepSize,rbarh,rbarl,rtrend,i);
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
#define _rsxInstances      1
#define _rsxInstancesSize 13
#define _rsxRingSize       5
double workRsi[_rsxRingSize][_rsxInstances*_rsxInstancesSize];
//
//---
//
double iRsx(double price,double period,int i, int instance=0)
  {
   int _indP = (int)MathMod(i-1,_rsxRingSize);
   int _indC = (int)MathMod(i  ,_rsxRingSize);
   int _inst = instance*_rsxInstancesSize;
   
      workRsi[_indC][_inst]=price; if(i<period) { for(int k=1; k<_rsxInstancesSize; k++) workRsi[_indC][_inst+k]=0; return(50); }
      
      //
      //---
      //

      double Kg=(3.0)/(2.0+period),Hg=1.0-Kg;
      double mom = workRsi[_indC][_inst]-workRsi[_indP][_inst];
      double moa = MathAbs(mom);
      for(int k=0; k<3; k++)
      {
         int kk=_inst+k*2;
         workRsi[_indC][kk+1] = Kg*mom                  + Hg*workRsi[_indP][kk+1];
         workRsi[_indC][kk+2] = Kg*workRsi[_indC][kk+1] + Hg*workRsi[_indP][kk+2]; mom = 1.5*workRsi[_indC][kk+1] - 0.5 * workRsi[_indC][kk+2];
         workRsi[_indC][kk+7] = Kg*moa                  + Hg*workRsi[_indP][kk+7];
         workRsi[_indC][kk+8] = Kg*workRsi[_indC][kk+7] + Hg*workRsi[_indP][kk+8]; moa = 1.5*workRsi[_indC][kk+7] - 0.5 * workRsi[_indC][kk+8];
     }
   return(MathMax(MathMin((mom/MathMax(moa,DBL_MIN)+1.0)*50.0,100.00),0.00));
  }
//
//---
//
#define _stepChartInstances     1
#define _stepChartInstancesSize 2
#define _stepChartRingSize      5
double _stepChartWork[_stepChartRingSize][_stepChartInstances*_stepChartInstancesSize];
#define _steps 0
#define _trend 1
//
//---
//
void iStepChart(double value, double stepSize, double& rbarh, double& rbarl, double& rtrend, int i, int instance=0)
{
   int _indP = (int)MathMod(i-1,_stepChartRingSize);
   int _indC = (int)MathMod(i  ,_stepChartRingSize);
   int _inst = instance*_stepChartInstancesSize;
   
   //
   //---
   //
   
   if (i==0)
   {
      _stepChartWork[_indC][_inst+_steps] = rbarh  = rbarl = (stepSize>0) ? MathRound(value/stepSize)*stepSize : value; 
      _stepChartWork[_indC][_inst+_trend] = rtrend = 0;
   }
   else
   {
      if (MathAbs(value-_stepChartWork[_indP][_inst+_steps]) < stepSize) _stepChartWork[_indC][_inst+_steps] = _stepChartWork[_indP][_inst+_steps]; 
      else
      { 
         _stepChartWork[_indC][_inst+_steps] = _stepChartWork[_indP][_inst+_steps];
            while(MathAbs(value - _stepChartWork[_indC][_inst+_steps]) > stepSize) 
            {
               if(value > _stepChartWork[_indC][_inst+_steps]) _stepChartWork[_indC][_inst+_steps] += stepSize;
               if(value < _stepChartWork[_indC][_inst+_steps]) _stepChartWork[_indC][_inst+_steps] -= stepSize;
            }
      }    
      _stepChartWork[_indC][_inst+_trend] = (_stepChartWork[_indC][_inst+_steps]>_stepChartWork[_indP][_inst+_steps]) ? 1 : (_stepChartWork[_indC][_inst+_steps]<_stepChartWork[_indP][_inst+_steps]) ? -1 : _stepChartWork[_indP][_inst+_trend];
         rbarh  = _stepChartWork[_indC][_inst+_steps];
         rbarl  = _stepChartWork[_indP][_inst+_steps];
         rtrend = _stepChartWork[_indC][_inst+_trend];
   }
   #undef _steps
   #undef _trend
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
