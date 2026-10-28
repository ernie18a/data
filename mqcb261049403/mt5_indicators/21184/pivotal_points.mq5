//----------------------------------------------------------------------------------------------------------------------------
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
//----------------------------------------------------------------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Pivotal points"
#property indicator_type1   DRAW_HISTOGRAM2
#property indicator_color1  clrRed
#property indicator_width1  2
//
//---
//
input int inpLookBackBars = 200; // Look back bars
input int inpAtrPeriod    = 1;   // ATR period

double ih[],il[],atr[];
//------------------------------------------------------------------
//
//------------------------------------------------------------------
int OnInit()
  {
   SetIndexBuffer(0,ih);
   SetIndexBuffer(1,il);
   SetIndexBuffer(2,atr,INDICATOR_CALCULATIONS);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//
//--
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      atr[i]=0;
      for(int k=0; k<inpAtrPeriod && (i-k)>=0; k++)
         atr[i] += (i>0) ? MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]) : high[i]-low[i];
      atr[i] /= inpAtrPeriod;
      ih[i]=il[i]=EMPTY_VALUE;

      //
      //---
      //

      int _start=MathMax(i-inpLookBackBars+1,0);
      if(ArrayMaximum(atr,_start,inpLookBackBars)==i)
        {
         ih[i] = high[i];
         il[i] = low[i];
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
