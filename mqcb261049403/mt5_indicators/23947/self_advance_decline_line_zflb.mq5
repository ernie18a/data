//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Self Advance Decline line ..."
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   4
#property indicator_label1  "Upper level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Middle level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Lower level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Self Advance Decline line"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width4  2
//
//--- input parameters
//
input int inpPeriod =  25; // Period
enum enColorChangeOn
{
   cchange_onSlope,  // Change color on slope change
   cchange_onLevels, // Change color on outer levels cross
   cchange_onZero    // Change color on middle level cross
};
input int                inpFlPeriod    = 25;               // Floating levels period
input double             inpFlLevelUp   = 90;               // Floating levels up %
input double             inpFlLevelDn   = 10;               // Floating levels down %
input enColorChangeOn    inpColorChange = cchange_onLevels; // Color changing mode

//
//--- buffers declarations
//
double val[],valc[],sum[],state[],levu[],levd[],levm[];

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
         SetIndexBuffer(0,levu ,INDICATOR_DATA);
         SetIndexBuffer(1,levm ,INDICATOR_DATA);
         SetIndexBuffer(2,levd ,INDICATOR_DATA);
         SetIndexBuffer(3,val  ,INDICATOR_DATA);
         SetIndexBuffer(4,valc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(5,sum  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(6,state,INDICATOR_CALCULATIONS);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Self Advance Decline line ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
  }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//
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
   //
   //
   
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      state[i] = (close[i]>open[i]) ? 1 : (close[i]<open[i]) ? -1 : 0;
         if (i>inpPeriod)
                sum[i] = sum[i-1] + state[i]-state[i-inpPeriod];
         else { sum[i] = state[i]; for (int k=1; k<inpPeriod && i>=k; k++) sum[i] += state[i-k]; }
         val[i] = (i>0) ? val[i-1] + sum[i] : sum[i];
         if (prev_i!=i)
         {
            prev_i = i; 
            int start    = i-inpFlPeriod+1; if (start<0) start=0;
                prev_max = val[ArrayMaximum(val,start,inpFlPeriod-1)];
                prev_min = val[ArrayMinimum(val,start,inpFlPeriod-1)];
         }
         double max = (val[i] > prev_max) ? val[i] : prev_max;
         double min = (val[i] < prev_min) ? val[i]  : prev_min;
         double range = (max-min)/100.0;
            levu[i] = min+inpFlLevelUp*range;
            levd[i] = min+inpFlLevelDn*range;
            levm[i] = (levu[i]+levd[i])/2;
            
            //
            //---
            //
            
            switch (inpColorChange)
            {
               case cchange_onLevels : valc[i] = (val[i]>levu[i]) ? 1 :(val[i]<levd[i]) ? 2 : 0; break;
               case cchange_onSlope  : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
               case cchange_onZero   : valc[i] = (val[i]>levm[i]) ? 1 :(val[i]<levm[i]) ? 2 : 0; break;
            }         
   }
   return (i);
}