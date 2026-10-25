//------------------------------------------------------------------
#property copyright   "copyright© mladen 2020"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  2
#property indicator_plots    2
#property indicator_label1   "Short"
#property indicator_type1    DRAW_LINE
#property indicator_color1   clrSilver
#property indicator_width1   2
#property indicator_label2   "Long"
#property indicator_type2    DRAW_LINE
#property indicator_color2   clrRed
#property indicator_width2   2

//
//
//

input int  inpPeriodShort = 20; // Short period
input int  inpPeriodLong  = 40; // Long period

double vals[],vall[]; int _longPeriod, _shortPeriod;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,vals,INDICATOR_DATA); 
   SetIndexBuffer(1,vall,INDICATOR_DATA); 
      
      //
      //
      //

      _longPeriod  = MathMax(inpPeriodShort,inpPeriodLong);
      _shortPeriod = MathMin(inpPeriodShort,inpPeriodLong);
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Correlation trend (%i,%i)",_shortPeriod,_longPeriod));
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {  return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   int limit = prev_calculated-1; if (limit<0) limit = 0;

   //
   //
   //
   
      for (int i=limit; i<rates_total; i++)
      {
         double SumSx  = 0; double SumLx  = 0;
         double SumSy  = 0; double SumLy  = 0;
         double SumSxx = 0; double SumLxx = 0;
         double SumSxy = 0; double SumLxy = 0;
         double SumSyy = 0; double SumLyy = 0;

         for (int k=0; k<_longPeriod && i>=k; k++)
         {
            int y = -k;
            if (k<_shortPeriod)
            {
               SumSx  += close[i-k];
               SumSxx += close[i-k]*close[i-k];
               SumSxy += close[i-k]*y;
               SumSy  +=            y;
               SumSyy +=            y*y;
            }
            SumLx  += close[i-k];
            SumLxx += close[i-k]*close[i-k];
            SumLxy += close[i-k]*y;
            SumLy  +=            y;
            SumLyy +=            y*y;
         }
         double _ts1 = _shortPeriod*SumSxx-SumSx*SumSx;
         double _ts2 = _shortPeriod*SumSyy-SumSy*SumSy;
         double _tl1 = _longPeriod *SumLxx-SumLx*SumLx;
         double _tl2 = _longPeriod *SumLyy-SumLy*SumLy;

         vals[i] = (_ts1>0 && _ts2>0) ? (_shortPeriod*SumSxy-SumSx*SumSy)/MathSqrt(_ts1*_ts2) : 0;
         vall[i] = (_tl1>0 && _tl2>0) ? (_longPeriod *SumLxy-SumLx*SumLy)/MathSqrt(_tl1*_tl2) : 0;
   }      
   return(rates_total);
}