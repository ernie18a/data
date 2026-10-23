//+------------------------------------------------------------------+
//|                                                       OnTick.mq4 |
//|                                           Copyright 2020, ernst. |
//|                             https://www.mql5.com/en/users/pippod |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, ernst."
#property link      "https://www.mql5.com/en/users/pippod"
#property version   "1.00"
#property indicator_chart_window
//--- input parameters
input long ChartID=0;
input ushort EventID=0;
input bool Pips=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   printf("ChartID:%lld Event ID:%d Initialized for %s.",ChartID,EventID,_Symbol);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
   if(prev_calculated)
     {
      if(Pips)
        { 
         static double open,close,preClose,muldiv=MathPow(10,_Digits-1),point=_Point;
         if(rates_total!=prev_calculated)
           {
            open=price[rates_total-3];
            close=price[rates_total-2];
            open=close>open?MathFloor(close*muldiv)/muldiv:MathCeil(close*muldiv)/muldiv;
           }
         close=price[rates_total-1];
         close=close>open?MathFloor(close*muldiv)/muldiv:MathCeil(close*muldiv)/muldiv;
         if(rates_total==prev_calculated && MathAbs(preClose-close)<point)
            return(rates_total);
         preClose=close;   
        }   
      ::EventChartCustom(ChartID,EventID,rates_total!=prev_calculated?rates_total-prev_calculated-1:0,0.0,_Symbol);
     }     
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+