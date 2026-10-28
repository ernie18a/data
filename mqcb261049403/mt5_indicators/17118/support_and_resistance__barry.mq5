//------------------------------------------------------------------
#property copyright   "© mladen, 2016, MetaQuotes Software Corp."
#property link        "www.forex-tsd.com, forge.mql5.io"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro,clrGainsboro
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrMediumTurquoise
#property indicator_width2  2
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrTan
#property indicator_width3  2

//
//
//
//
//

input int FractalPeriod=25; // Fractals period

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double res[],sup[],fup[],fdn[];
void OnInit()
{
   SetIndexBuffer(0,fup,INDICATOR_DATA);
   SetIndexBuffer(1,fdn,INDICATOR_DATA);
   SetIndexBuffer(2,res,INDICATOR_DATA);
   SetIndexBuffer(3,sup,INDICATOR_DATA);
}
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
   int k,half = FractalPeriod/2; double compareTo;
   for (int i=(int)MathMax(prev_calculated-half,half); i<rates_total && !_StopFlag; i++)
   {
         compareTo = high[i];
            for (k=1;k<=half && (i+k)<rates_total ;k++)
            {
               if (high[i+k]> compareTo) break;
               if (high[i-k]>=compareTo) break;
            }
            double fractalUp = (k==half+1) ? high[i] : EMPTY_VALUE;
         compareTo = low[i];
            for (k=1;k<=half && (i+k)<rates_total ;k++)
            {
               if (low[i+k]< compareTo) break;
               if (low[i-k]<=compareTo) break;
            }
            double fractalDn = (k==half+1) ? high[i] : EMPTY_VALUE;
         
            //
            //
            //
            //
            //
         
            res[i] = (fractalUp != EMPTY_VALUE) ? high[i] : (i>0) ? res[i-1] : high[i]; fup[i] = res[i];
            sup[i] = (fractalDn != EMPTY_VALUE) ? low[i]  : (i>0) ? sup[i-1] : low[i] ; fdn[i] = sup[i];
   }  
   return(rates_total);
}