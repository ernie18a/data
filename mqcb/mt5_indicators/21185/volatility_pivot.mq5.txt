//----------------------------------------------------------------------------------------------------------------------------
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
//----------------------------------------------------------------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Volatility pivot"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDodgerBlue,clrSandyBrown
//
//---
//
input int    inpAtrRange  = 100; // ATR period
input double inpAtrFactor = 3;   // ATR factor
input int    inpMaRange   = 10;  // EMA period

double val[],valc[],atr[];
//------------------------------------------------------------------
//
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,val);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,atr,INDICATOR_CALCULATIONS);
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
  {
  }
//
//--
//
int OnCalculate (const int rates_total, const int prev_calculated, const datetime& time[], 
                 const double& open[], 
                 const double& high[], 
                 const double& low[], 
                 const double& close[], 
                 const long& tick_volume[], 
                 const long& volume[], 
                 const int& spread[] )
{ 
   double _alpha = 2.0 / (inpMaRange+1.0);
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _atr = 0; for (int k=0; k<inpAtrRange && (i-k-1)>=0; k++) _atr += (i>0) ? MathMax(high[i-k],close[i-k-1])-MathMin(low[i-k],close[i-k-1]) : high[i-k]-low[i-k];  _atr /= inpAtrRange;
      atr[i] = (i>0) ? atr[i-1] + _alpha*(_atr - atr[i-1]) : _atr;
      val[i] = close[i];
      double _deltaStop = atr[i]*inpAtrFactor;
      while (i>0 && true)
      {
         if (close[i]  == val[i-1]) { val[i] = val[i-1]; break; }
         if (close[i-1] < val[i-1] && close[i]<val[i-1]) { val[i] = MathMin(val[i-1], close[i] + _deltaStop); break; }
         if (close[i-1] > val[i-1] && close[i]>val[i-1]) { val[i] = MathMax(val[i-1], close[i] - _deltaStop); break; }         
         if (close[i]   > val[i-1]) 
              val[i] = close[i] - _deltaStop; 
         else val[i] = close[i] + _deltaStop;
         break;
      }
      valc[i] = (close[i]>val[i]) ? 1 : (close[i]<val[i]) ? 2 : (i>0) ? valc[i-1] : 0;
   }
   return(rates_total);
}
