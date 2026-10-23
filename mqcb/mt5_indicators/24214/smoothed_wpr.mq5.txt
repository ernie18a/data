//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Smoothed WPR"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "WPR"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//---
//

input int  inpPeriod       = 14; // Period
input int  inpSmoothPeriod =  0; // Smoothing period (< 1 for same as WPR period)

double val[],valc[],smth[],smtl[],smtc[],_alpha;

//------------------------------------------------------------------
//
//------------------------------------------------------------------ 
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,smth,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,smtl,INDICATOR_CALCULATIONS);
         SetIndexBuffer(4,smtc,INDICATOR_CALCULATIONS);
            _alpha = 2.0 / (1.0 + (inpSmoothPeriod>0 ? inpSmoothPeriod : inpPeriod));
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"WPR ("+(string)inpPeriod+","+(string)inpSmoothPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//---
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   static int    prev_i=-1;
   static double prev_max,prev_min;

   //
   //---
   //
   
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (i>0)
      {
         smth[i] = smth[i-1]+_alpha*(high[i] -smth[i-1]);
         smtl[i] = smtl[i-1]+_alpha*(low[i]  -smtl[i-1]);
         smtc[i] = smtc[i-1]+_alpha*(close[i]-smtc[i-1]);
      }  
      else { smth[i] = high[i]; smtl[i] = low[i];  smtc[i] = close[i]; }
      if (prev_i!=i)
      {
         prev_i = i; 
         int start    = i-inpPeriod+1; if (start<0) start=0;
             prev_max = smth[ArrayMaximum(smth,start,inpPeriod-1)];
             prev_min = smtl[ArrayMinimum(smtl,start,inpPeriod-1)];
      }
      double max = (smth[i] > prev_max) ? smth[i] : prev_max;
      double min = (smtl[i] < prev_min) ? smtl[i] : prev_min;
         
      //
      //---
      //
         
      val[i]  = (max !=min) ? -(max-smtc[i])*100.0/(max-min) : 0;
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; 
   }
   return(i);
}