//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Vortex"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   3
#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'218,231,226',C'255,221,217'
#property indicator_label2  "Vortex +"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDodgerBlue,clrCrimson
#property indicator_width2  2
#property indicator_label3  "Vortex -"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDodgerBlue,clrCrimson
#property indicator_width3  1

//--- input parameters
input int  inpPeriod=32; // Vortex period
//--- buffers declarations
double fillu[],filld[],valp[],valpc[],valm[],valmc[],rngbuffer[],vmpbuffer[],vmmbuffer[];;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fillu,INDICATOR_DATA);
   SetIndexBuffer(1,filld,INDICATOR_DATA);
   SetIndexBuffer(2,valp,INDICATOR_DATA);
   SetIndexBuffer(3,valpc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,valm,INDICATOR_DATA);
   SetIndexBuffer(5,valmc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,rngbuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,vmpbuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,vmmbuffer,INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Vortex ("+(string)inpPeriod+")");
//---
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
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      rngbuffer[i] = (i>0) ? MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]) : high[i]-low[i];
      vmpbuffer[i] = (i>0) ? MathAbs(high[i] - low[i-1]) : MathAbs(high[i] - low[i]);
      vmmbuffer[i] = (i>0) ? MathAbs(low[i] - high[i-1]) : MathAbs(low[i] - high[i]);
      //
      //---
      //
      double vmpSum = 0;
      double vmmSum = 0;
      double rngSum = 0;
      for(int k=0; k<inpPeriod && (i-k)>=0; k++)
        {
         vmpSum += vmpbuffer[i-k];
         vmmSum += vmmbuffer[i-k];
         rngSum += rngbuffer[i-k];
        }
      if(rngSum!=0)
        {
         valp[i] = vmpSum/rngSum;
         valm[i] = vmmSum/rngSum;
        }
      valpc[i] = (valp[i]>valm[i]) ? 1 : 2;
      valmc[i] = (valp[i]>valm[i]) ? 1 : 2;
      fillu[i] = valp[i];
      filld[i] = valm[i];
     }
   return (i);
  }
//+------------------------------------------------------------------+
