//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  2
#property indicator_plots    1
#property indicator_label1   "Heken ashi histogram"
#property indicator_type1    DRAW_COLOR_HISTOGRAM
#property indicator_color1   clrDodgerBlue,clrSandyBrown
#property indicator_width1   2
#property indicator_maximum  1
#property indicator_minimum -1
//
//---
//

double val[],valc[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//---
//

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         IndicatorSetString(INDICATOR_SHORTNAME,"Heiken ashi histogram");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//---
//

#define _haSize      5
double workHa[][_haSize];

//
//---
//
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
   static int workHaSize = -1;
          if (workHaSize<rates_total)
          {
               workHaSize = ArrayResize(workHa,rates_total+500); if (workHaSize<rates_total) return(0); 
          }

   //
   //
   //
             
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double haOpen  = (i>0) ? (workHa[i-1][2]+workHa[i-1][3])/2.0 : (open[i]+close[i])/2;;
      double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
      double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
      double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

      if(haOpen  <haClose) { workHa[i][0] = haLow;  workHa[i][1] = haHigh; }
      else                 { workHa[i][0] = haHigh; workHa[i][1] = haLow;  }
                             workHa[i][2] = haOpen;
                             workHa[i][3] = haClose;
                             workHa[i][4] = (haOpen+haClose)/2;

      
      val[i] = haOpen>haClose ? 1 : haOpen<haClose ? -1 : 0;
      valc[i]=(haOpen>haClose) ? 1 : 0;
     }
   return(i);
}