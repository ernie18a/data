//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "up level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "down level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_DOT
#property indicator_label3  "value"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrLimeGreen,clrOrange
#property indicator_width3  2

input int  inpWprPeriod    = 14; // WPR period
input int  inpSignalPeriod = 9;  // Signal period
double  val[],valc[],levelUp[],levelDn[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
   SetIndexBuffer(0,levelUp,INDICATOR_DATA);
   SetIndexBuffer(1,levelDn,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   for(int i=0; i<2; i++) PlotIndexSetInteger(i,PLOT_SHOW_DATA,false);
   IndicatorSetString(INDICATOR_SHORTNAME,"(dsl) WPR ("+(string)inpWprPeriod+","+(string)inpSignalPeriod+")");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);

   double alpha=2.0/(1.0+inpSignalPeriod);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      int _start=MathMax(i-inpWprPeriod+1,0);
      double _max = high[ArrayMaximum(high,_start,inpWprPeriod)];
      double _min = low[ArrayMinimum(low,_start,inpWprPeriod)];

      val[i]     = (_max!=_min) ? -(_max-close[i])*100/(_max-_min) : 0;
      levelUp[i] = (i>0) ? (val[i]>-50) ? levelUp[i-1]+alpha*(val[i]-levelUp[i-1]) : levelUp[i-1] : 0;
      levelDn[i] = (i>0) ? (val[i]<-50) ? levelDn[i-1]+alpha*(val[i]-levelDn[i-1]) : levelDn[i-1] : 0;
      valc[i]    = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1]: 0 : 0;
     }
   return(i);
  }
//+------------------------------------------------------------------+
