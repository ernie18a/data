//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Trading the trend"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "Trend histogram"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrSandyBrown
#property indicator_width1  2
#property indicator_minimum 0
#property indicator_maximum 1
//
//--- input parameters
//
input int     inpPeriod       = 21;  // Look back period
input double  inpMultiplier   = 3;   // Multiplier
input int     inpChannelShift = 1;   // Channel shift

//--- buffers and global variables declarations
//
double histo[],histoc[],line[],linecl[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,histo,INDICATOR_DATA);
   SetIndexBuffer(1,histoc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,line,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,linecl,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Trade the trend histogram ("+(string)inpPeriod+")");
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
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   //
   //---
   //
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      int _start = MathMax(i-inpPeriod-inpChannelShift+1,0);
      double hi      = close[ArrayMaximum(close,_start,inpPeriod)];
      double lo      = close[ArrayMinimum(close,_start,inpPeriod)];
      double tr      = iLwma((i>0?MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]):high[i]-low[i]),inpPeriod,i,rates_total);
      double hiLimit = hi-tr*inpMultiplier;
      double loLimit = lo+tr*inpMultiplier;
         
      line[i]   = (i>0) ? line[i-1] : close[i];
      linecl[i] = (i>0) ? linecl[i-1] : 0;
         if (close[i]>loLimit && close[i]>hiLimit) line[i] = hiLimit;
         if (close[i]<loLimit && close[i]<hiLimit) line[i] = loLimit;
         if (close[i]>line[i]) { linecl[i] = 1; }
         if (close[i]<line[i]) { linecl[i] = 2; }
         histo[i] = 1;
         histoc[i] = linecl[i];
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| custom functions                                                 |
//+------------------------------------------------------------------+
double workLwma[][1];
//
//---
//
double iLwma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workLwma,0)!=_bars) ArrayResize(workLwma,_bars);

   workLwma[r][instanceNo] = price; if(period<1) return(price);
   double sumw = period;
   double sum  = period*price;

   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight=period-k;
      sumw  += weight;
      sum   += weight*workLwma[r-k][instanceNo];
     }
   return(sum/sumw);
  }
//+------------------------------------------------------------------+
