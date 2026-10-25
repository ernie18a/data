//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Choppiness index"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "Choppiness index"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//
//---
//
input int inpChoPeriod    = 14;  // Choppiness index period

double csi[];

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,csi,INDICATOR_DATA); 
   IndicatorSetString(INDICATOR_SHORTNAME,"Choppiness index ("+string(inpChoPeriod)+")");
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
   double _log = MathLog(inpChoPeriod)/100.00;
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
   {
      double atrSum =    0.00;
      double maxHig = high[i];
      double minLow =  low[i];
               
         for (int k = 0; k<inpChoPeriod && (i-k-1)>=0; k++)
         {
            atrSum += MathMax(high[i-k],close[i-k-1])-MathMin(low[i-k],close[i-k-1]);
            maxHig  = MathMax(maxHig,MathMax(high[i-k],close[i-k-1]));
            minLow  = MathMin(minLow,MathMin( low[i-k],close[i-k-1]));
         }
         csi[i] = (maxHig!=minLow) ? MathLog(atrSum/(maxHig-minLow))/_log : 0;   
   }      
   return(rates_total);
}