//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Price channel stop"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   2
#property indicator_label1  "Price channel stop"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrPowderBlue,clrPeachPuff
#property indicator_label2  "Price channel stop"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDeepSkyBlue,clrDarkOrange
#property indicator_width2  1
//--- input parameters
input int    inpChannelPeriod = 14;  // Channel period
input double inpRisk          = 0.3; // Risk
//--- buffers declarations
double line[],linec[],fillu[],filld[],bsmin[],bsmax[],trend[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fillu,INDICATOR_DATA);
   SetIndexBuffer(1,filld,INDICATOR_DATA);
   SetIndexBuffer(2,line,INDICATOR_DATA);
   SetIndexBuffer(3,linec,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,trend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,bsmin,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,bsmax,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Price channel stop ("+(string)inpChannelPeriod+","+(string)inpRisk+")");
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
      int _start=MathMax(i-inpChannelPeriod+1,0);
      double smin = low[ArrayMinimum(low,_start,inpChannelPeriod)];
      double smax = high[ArrayMaximum(high,_start,inpChannelPeriod)];
      double mid  =0.5*(smin+smax);
      bsmax[i]=smax-(smax-smin)*MathMin(inpRisk,0.49);
      bsmin[i]=smin+(smax-smin)*MathMin(inpRisk,0.49);
      trend[i]=(i>0)? trend[i-1] : 0;
      if(inpRisk>0)
        {
         if(close[i]>bsmax[i]) trend[i]= 1;
         if(close[i]<bsmin[i]) trend[i]=-1;
        }
      else
        {
         if(i>0 && close[i]>bsmax[i-1]) trend[i]= 1;
         if(i>0 && close[i]<bsmin[i-1]) trend[i]=-1;
        }
      if(trend[i]>0 && bsmin[i]<bsmin[i-1]) bsmin[i]=bsmin[i-1];
      if(trend[i]<0 && bsmax[i]>bsmax[i-1]) bsmax[i]=bsmax[i-1];

      //
      //---
      //

      if(trend[i]>0) { filld[i]=bsmin[i]; fillu[i]=mid; }
      if(trend[i]<0) { fillu[i]=mid; filld[i]=bsmax[i]; }
      line[i]  = filld[i];
      linec[i] = trend[i] == 1 ? 0 : 1;
     }
   return (i);
  }
//+------------------------------------------------------------------+
