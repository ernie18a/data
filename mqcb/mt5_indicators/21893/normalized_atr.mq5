//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Normalized ATR"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Normalized ATR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2
//
//--- input parameters
//
input int     inpAtrPeriod = 14;   // ATR period
//
//--- indicator buffers
//
double val[],atr[];
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,atr,INDICATOR_CALCULATIONS);
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
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{                
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   
   //
   //---
   //

   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
   {
      atr[i] = 0; 
         for (int k=0; k<inpAtrPeriod && (i-k-1)>=0; k++) 
            atr[i] += MathMax(high[i-k],close[i-k-1])-MathMin(low[i-k],close[i-k-1]); 
            atr[i] /= inpAtrPeriod;
      int _start = MathMax(i-inpAtrPeriod+1,0);
         double _max = atr[ArrayMaximum(atr,_start,inpAtrPeriod)];            
         double _min = atr[ArrayMinimum(atr,_start,inpAtrPeriod)];            
         if (_min!=_max)
               val[i] = (atr[i]-_min)/(_max-_min);
         else  val[i] = 0.5;            
   }          
   return(rates_total);
}