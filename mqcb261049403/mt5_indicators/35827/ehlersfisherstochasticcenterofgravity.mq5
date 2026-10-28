//+------------------------------------------------------------------+
//|                        EhlersFisherStochasticCenterOfGravity.mq5 |
//|                                Copyright 2020, Andrei Novichkov. |
//|                                               http://fxstill.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Andrei Novichkov."
#property link      "http://fxstill.com"
#property version   "1.00"

#property description "The Fisher Stochastic Center Of Gravity:\nJohn Ehlers"

#property indicator_separate_window
#property indicator_applied_price PRICE_MEDIAN

#property indicator_buffers 6
#property indicator_plots   2
//--- plot v3
#property indicator_label1  "v3"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot trigger
#property indicator_label2  "trigger"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- input parameters
input int      length=8;
//--- indicator buffers
double         v3[];
double         vc[];
double         trigger[];
double         v1[];
double         v2[];
double         sg[];

static const int MINBAR = length + 1;
double l;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,v3,INDICATOR_DATA);
   SetIndexBuffer(1,vc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,trigger,INDICATOR_DATA);
   SetIndexBuffer(3,v1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,v2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,sg,INDICATOR_CALCULATIONS);
   
   ArraySetAsSeries(v3,true);
   ArraySetAsSeries(vc,true);
   ArraySetAsSeries(trigger,true);
   ArraySetAsSeries(v1,true);
   ArraySetAsSeries(v2,true);
   ArraySetAsSeries(sg,true);
   
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"EhlersFisherStochasticCenterOfGravity");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   
   l = (length + 1) / 2;
   
   return(INIT_SUCCEEDED);
  }
  
void GetValue(const double& price[], int shift) {
   
   double num = 0.0;
   double denom = 0.0;
   for (int i = 0; i < length; i++) {
      num = num + (1 + i) * price[shift + i];
      denom = denom + price[shift + i];   
   } 
   if (denom != 0)
      sg[shift] =  l - num / denom;
   else sg[shift] = 0;   
//   v3[shift] = num / denom;
   
   int maxCg = ArrayMaximum(sg, shift, length);
   int minCg = ArrayMinimum(sg, shift, length);
   if (maxCg == -1 || minCg == -1) return;
   if (sg[maxCg] != sg[minCg])
      v1[shift] = (sg[shift] - sg[minCg]) / (sg[maxCg] - sg[minCg]);
   else v1[shift] = 0;   
   v2[shift] = (4 * v1[shift] + 3 * v1[shift + 1] + 2 * v1[shift + 2] + v1[shift + 3]) / 10;     
   v3[shift] = 0.5 * MathLog((1 + (1.98 * (v2[shift] - 0.5))) / (1 - (1.98 * (v2[shift] - 0.5))));

   trigger[shift] = v3[shift + 1];    
   
   if (v3[shift] < trigger[shift]) vc[shift] = 1 ; 
   else
      if (v3[shift] > trigger[shift]) vc[shift] = 2 ;     
     
//v3[shift] = sg[shift] - sg[maxCg];      
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
         ArrayInitialize(v3,EMPTY_VALUE);
         ArrayInitialize(trigger,EMPTY_VALUE);
         ArrayInitialize(vc,0);
         ArrayInitialize(v1,0);
         ArrayInitialize(v2,0);
         ArrayInitialize(sg,0);
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
