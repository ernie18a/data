//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Price Headley's acceleration bands"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   4
#property indicator_label1  "fill"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro
#property indicator_label2  "Upper band"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_width2  2
#property indicator_label3  "Lower band"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGray
#property indicator_width3  2
#property indicator_label4  "Average"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkGray
#property indicator_style4  STYLE_DOT
//--- input parameters
input int inpPeriod = 30; // Period
//--- indicator buffers
double fillu[],filld[],valu[],vald[],valm[],workh[],workl[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fillu,INDICATOR_DATA);
   SetIndexBuffer(1,filld,INDICATOR_DATA);
   SetIndexBuffer(2,valu,INDICATOR_DATA);
   SetIndexBuffer(3,vald,INDICATOR_DATA);
   SetIndexBuffer(4,valm,INDICATOR_DATA);
   SetIndexBuffer(5,workh,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,workl,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Headley's acceleration bands ("+(string)inpPeriod+")");
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
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
   {
      workh[i] = high[i]*(1.0+2.0*(((high[i]-low[i])/((high[i]+low[i])/2.0))*1000.0)*0.001);
      workl[i] = low[i] *(1.0-2.0*(((high[i]-low[i])/((high[i]+low[i])/2.0))*1000.0)*0.001);
      valm[i]  = 0;
      valu[i]  = 0;
      vald[i]  = 0;
         for (int k=0; k<inpPeriod && (i-k)>=0; k++)
         {
            valm[i] += close[i-k];
            valu[i] += workh[i-k];
            vald[i] += workl[i-k];
         }
         valm[i] /= inpPeriod;
         valu[i] /= inpPeriod;
         vald[i] /= inpPeriod;
         fillu[i] = valu[i];
         filld[i] = vald[i];
   }
   return(rates_total);
}