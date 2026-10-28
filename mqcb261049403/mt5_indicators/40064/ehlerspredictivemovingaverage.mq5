//+------------------------------------------------------------------+
//|                                EhlersPredictiveMovingAverage.mq5 |
//|                                Copyright 2020, Andrei Novichkov. |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Andrei Novichkov."
#property link      "https://www.mql5.com/ru/users/andreifx60"
#property version   "1.00"
#property description "The Predictive Moving Average:\nJohn Ehlers, \"Rocket Science For Traders\", pg.212"

#property indicator_applied_price PRICE_MEDIAN

#property indicator_chart_window

#property indicator_buffers 5
#property indicator_plots   2
//--- plot predict
#property indicator_label1  "predict"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot trigger
#property indicator_label2  "trigger"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrGreen,clrRed,clrLimeGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- indicator buffers
double         pb[];
double         tr[];
double         tc[];
double         wma1[], wma2[];
static const int MINBAR = 13;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,pb,INDICATOR_DATA);
   SetIndexBuffer(1,tr,INDICATOR_DATA);
   SetIndexBuffer(2,tc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,wma1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,wma2,INDICATOR_CALCULATIONS);
//---
   ArraySetAsSeries(pb,true);
   ArraySetAsSeries(tr,true);
   ArraySetAsSeries(tc,true);
   ArraySetAsSeries(wma1,true);
   ArraySetAsSeries(wma2,true);
   
   IndicatorSetString(INDICATOR_SHORTNAME,"EhlersPredictiveMovingAverage");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);      

   return INIT_SUCCEEDED;
  }

void GetValue(const double& price[], int shift) {

   wma1[shift] = (7 * price[shift] + 6 * price[shift + 1] + 5 * price[shift + 2] + 4 * price[shift + 3] + 3 * price[shift + 4] + 2 * price[shift + 5] + price[shift + 6]) / 28;
   wma2[shift] = (7 * wma1[shift] +  6 * wma1[shift + 1] +  5 * wma1[shift + 2] +  4 * wma1[shift + 3] +  3 * wma1[shift + 4] +  2 * wma1[shift + 5] +  wma1[shift + 6])  / 28;
   
   tr[shift] = 2 * wma1[shift] - wma2[shift];
   pb[shift] = (4 * tr[shift] + 3 * tr[shift + 1] + 2 * tr[shift + 2] + tr[shift + 3]) / 10;   
   
   if (pb[shift] < tr[shift]) tc[shift] = 2 ; 
   else
      if (pb[shift] > tr[shift]) tc[shift] = 1 ;   
      
}

double ZerroIfEmpty(double value) {
   if (value >= EMPTY_VALUE || value <= -EMPTY_VALUE) return 0.0;
   return value;
}  
void OnDeinit(const int reason) {
  Comment("");
}  
    
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
      if(rates_total <= MINBAR) return 0;
      ArraySetAsSeries(price, true);    
      int limit = rates_total - prev_calculated;
      if (limit == 0)        {   
      } else if (limit == 1) {   
         GetValue(price, 1);  
         return(rates_total);      
      } else if (limit > 1)  {  
         ArrayInitialize(pb,EMPTY_VALUE);
         ArrayInitialize(tr,EMPTY_VALUE);
         ArrayInitialize(tc,0);
         ArrayInitialize(wma1,0);
         ArrayInitialize(wma2,0);
         limit = rates_total - MINBAR;
         for(int i = limit; i >= 1 && !IsStopped(); i--){
            GetValue(price, i);
         }//for(int i = limit + 1; i >= 0 && !IsStopped(); i--)
         return(rates_total);         
      }
      GetValue(price, 0);  

   return(rates_total);
  }
//+------------------------------------------------------------------+
