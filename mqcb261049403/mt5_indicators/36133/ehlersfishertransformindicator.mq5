//+------------------------------------------------------------------+
//|                               EhlersFisherTransformIndicator.mq5 |
//|                                Copyright 2020, Andrei Novichkov. |
//|                                               http://fxstill.com |
//|   Telegram: https://t.me/fxstill (Literature on cryptocurrencies,| 
//|                                   development and code. )        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Andrei Novichkov."
#property link      "http://fxstill.com"
#property version   "1.00"

#property description "The Fisher Transform Indicator:\nJohn Ehlers, \"Cybernetic Analysis For Stocks And Futures\", pg.7-8"


#property indicator_separate_window
#property indicator_applied_price PRICE_MEDIAN

#property indicator_buffers 4
#property indicator_plots   2
//--- plot v3
#property indicator_label1  "fb"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot trigger
#property indicator_label2  "f1"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- input parameters
input int      length=10;
//--- indicator buffers
double         fb[];
double         fc[];
double         f1[];
double         v1[];


static const int MINBAR = 5;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fb,INDICATOR_DATA);
   SetIndexBuffer(1,fc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,f1,INDICATOR_DATA);
   SetIndexBuffer(3,v1,INDICATOR_CALCULATIONS);
   
   ArraySetAsSeries(fb,true);
   ArraySetAsSeries(fc,true);
   ArraySetAsSeries(f1,true);
   ArraySetAsSeries(v1,true);
   
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"EhlersFisherTransformIndicator");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   
   return(INIT_SUCCEEDED);
  }
  
void GetValue(const double& price[], int shift) {
   
   int mx = ArrayMaximum(price, shift, length);
   int mn = ArrayMinimum(price, shift, length);
   
   if (mx == -1 || mn == -1) return;
   
   if (price[mx] != price[mn])
      v1[shift] = (price[shift] - price[mn])/(price[mx] - price[mn]) - 0.5 + 0.5 * v1[shift + 1];
   else v1[shift] = 0;
   v1[shift] = MathMax(MathMin(v1[shift], 0.999), -0.999);   

   double ft = ZerroIfEmpty(fb[shift + 1]);
   fb[shift] = 0.25 * MathLog((1 + v1[shift])/(1 - v1[shift])) + 0.5 * ft;   

   f1[shift] = fb[shift + 1];
   
   if (fb[shift] < f1[shift]) fc[shift] = 1 ; 
   else
      if (fb[shift] > f1[shift]) fc[shift] = 2 ;     
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
         ArrayInitialize(fb,EMPTY_VALUE);
         ArrayInitialize(f1,EMPTY_VALUE);
         ArrayInitialize(fc,0);
         ArrayInitialize(v1,0);
         limit = rates_total - MINBAR;
         for(int i = limit; i >= 1 && !IsStopped(); i--){
            GetValue(price, i);
         }//for(int i = limit + 1; i >= 0 && !IsStopped(); i--)
         return(rates_total);         
      }
      GetValue(price, 0); 

   return(rates_total);
  }
  
double ZerroIfEmpty(double value) {
   if (value >= EMPTY_VALUE || value <= -EMPTY_VALUE) return 0.0;
   return value;
}  
//+------------------------------------------------------------------+
