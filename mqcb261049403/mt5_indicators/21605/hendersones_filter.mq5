//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Henderson's filter"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Henderson's filter"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_width1  2
//
//---
//
input int                inpPeriod = 32;          // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price

double val[],prices[],weights[];
int _filterSize,_half,_size;
//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,val,INDICATOR_DATA); 
   SetIndexBuffer(1,prices,INDICATOR_CALCULATIONS); 
   //
   //---
   //
      _filterSize = MathMax(inpPeriod,3);
         if (MathMod(_filterSize,2)==0) _filterSize++; ArrayResize(weights,_filterSize);
         double m = MathFloor(_filterSize/2.0); _half = (int)m;
         double divisor = 8.0*(m+2.0)*((m+2.0)*(m+2.0)-1.0)*(4.0*(m+2.0)*(m+2)-1.0)*(4.0*(m+2.0)*(m+2.0)-9.0)*(4.0*(m+2.0)*(m+2.0)-25.0);  
         for (int j=-_half; j<=_half; j++)
            weights[j+_half] = 315.0*((m+1.0)*(m+1.0)-(j*j))*((m+2.0)*(m+2.0)-(j*j))*((m+3.0)*(m+3.0)-(j*j))*(3.0*(m+2.0)*(m+2.0)-11.0*(j*j)-16.0)/divisor;
            _size = ArraySize(weights);
   //
   //---            
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Henderson's filter ("+string(inpPeriod)+")");
   return(INIT_SUCCEEDED);
}
//
//---
//
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   for (int i=(int)MathMax(prev_calculated-_half,0); i<rates_total; i++)
   {
      double mod = 1.0;
      if ((rates_total-i-1)<_half)
      {
         double weightTotal = 0; for (int k=_half-(rates_total-i-1); k<_size; k++) weightTotal += weights[k]; mod = 1.0/weightTotal;               
      }
      //
      //---
      //
      double sum = mod*weights[_half]*getPrice(inpPrice,open,close,high,low,i,rates_total);
      for(int j=1; j<=_half; j++)
      {
         if (i-j>=0         ) sum += mod*weights[_half+j]*getPrice(inpPrice,open,close,high,low,i-j,rates_total);
         if (i+j<rates_total) sum += mod*weights[_half-j]*getPrice(inpPrice,open,close,high,low,i+j,rates_total);
      }
      val[i] = sum;
   }      
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
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