//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Step chart"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "Step chart"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  clrDarkGray,clrLimeGreen,clrOrangeRed
#property indicator_width1  2
//
//--- input parameters
//
input double             inpStepSize     = 2;             // Step size (pips)
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE;   // Price
//
//--- buffers and global variables declarations
//
double barh[],barl[],barc[],steps[],trend[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,barh,INDICATOR_DATA);
   SetIndexBuffer(1,barl,INDICATOR_DATA);
   SetIndexBuffer(2,barc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,steps,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,trend,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Step chart ("+(string)inpStepSize+")");
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
#define displayLine   0
#define displayBars   1
#define displayCandle 2
//+------------------------------------------------------------------+
//|                                                                  |
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
   double _stepSize = inpStepSize*_Point*MathPow(10,_Digits%2);
   
   //
   //---
   //
   
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double _price= getPrice(inpPrice,open,close,high,low,i,rates_total);
      if (i==0) { steps[i] = MathRound(_price/_stepSize) * _stepSize; trend[i] = 0; continue; }
      //
      //---
      //
      steps[i] = steps[i-1];   
      if(MathAbs(_price - steps[i]) < _stepSize) steps[i] = steps[i-1]; 
      else
      { 
         while(MathAbs(_price - steps[i]) > _stepSize) 
         {
            if(_price > steps[i]) steps[i] = steps[i] + _stepSize;
            if(_price < steps[i]) steps[i] = steps[i] - _stepSize;
         }
      }    
      trend[i] = (steps[i]>steps[i-1]) ? 1 : (steps[i]<steps[i-1]) ? -1 : trend[i-1];
      barh[i]  = steps[i];
         if(steps[i] == steps[i-1]) 
              barl[i]  = steps[i] - _Point*MathPow(10,_Digits%2);  
         else  barl[i] = steps[i-1];
         barc[i] = (trend[i]==1) ? 1 : 2;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| custom functions                                                 |
//+------------------------------------------------------------------+
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
