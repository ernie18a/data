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
input int                inpPeriod   = 32;            // CCI period
input ENUM_APPLIED_PRICE inpPrice    = PRICE_TYPICAL; // Price
input double             inpStepSize = 5;             // Step size (in CCI units)
//
//--- buffers and global variables declarations
//
double barh[],barl[],barc[],val[];
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
   IndicatorSetString(INDICATOR_SHORTNAME,"Step chart of ("+(string)inpPeriod+" CCI)");
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
      val[i] = iCci(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,i,rates_total);
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
