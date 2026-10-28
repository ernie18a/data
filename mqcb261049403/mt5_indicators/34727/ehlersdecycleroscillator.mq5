//+------------------------------------------------------------------+
//|                                     EhlersDecyclerOscillator.mq5 |
//|                                Copyright 2020, Andrei Novichkov. |
//|                                               http://fxstill.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Andrei Novichkov."
#property link      "http://fxstill.com"
#property version   "1.00"

#property description "The Decycler Oscillator:\nJohn Ehlers, \"Cycle Analytics For Traders\", pg.43-44"


#property indicator_applied_price PRICE_CLOSE
#property indicator_separate_window

#property indicator_buffers 3
#property indicator_plots   1

#property indicator_level1 (double)0
#property indicator_levelwidth 1
#property indicator_levelcolor clrRed
#property indicator_levelstyle STYLE_SOLID 

#property indicator_label1  "Dec"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2



input int l1 = 10; //Period 1
input int l2 = 20; //Period 2

double         dec[];
double         hp1[];
double         hp2[];

static const int MINBAR = 5;
double a1, a1k, a1l, a2, a2k, a2l;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()   {

//--- indicator buffers mapping
   SetIndexBuffer(0,dec,INDICATOR_DATA);
   SetIndexBuffer(1,hp1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,hp2,INDICATOR_CALCULATIONS);
   ArraySetAsSeries(dec,true);
   ArraySetAsSeries(hp1,true); 
   ArraySetAsSeries(hp2,true); 
   
   IndicatorSetString(INDICATOR_SHORTNAME,"EhlersDecyclerOscillator");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits); 
   
   double k = M_SQRT1_2 * 2 * M_PI;
   double t1 = (MathCos(k / l1) + MathSin (k / l1) - 1) / MathCos(k / l1); 
   a1 = 1 - t1; a1k = 1 - t1 / 2; a1k *= a1k; a1l = MathPow(a1, 2); a1 *= 2;
   double t2 = (MathCos(k / l2) + MathSin (k / l2) - 1) / MathCos(k / l2);
   a2 = 1 - t2; a2k = 1 - t2 / 2; a2k *= a2k; a2l = MathPow(a2, 2); a2 *= 2;       
//---
   return(INIT_SUCCEEDED);
  }

  
  
void GetValue(const double& price[], int shift) {

   hp1[shift] = a1k * (price[shift] - 2 * price[shift + 1] + price[shift + 2]) + 
                a1 * hp1[shift + 1] - a1l * hp1[shift + 2];
   hp2[shift] = a2k * (price[shift] - 2 * price[shift + 1] + price[shift + 2]) + 
                a2 * hp2[shift + 1] - a2l * hp2[shift + 2];
   dec[shift] = hp2[shift] - hp1[shift];    
}  

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
      if(rates_total < MINBAR) return 0;
      ArraySetAsSeries(price,true); 
      int limit = rates_total - prev_calculated;
      if (limit == 0)        {   
      } else if (limit == 1) {   
         GetValue(price, 1);  
         return(rates_total);                
      } else if (limit > 1)  {   
         ArrayInitialize(dec,   EMPTY_VALUE);
         ArrayInitialize(hp1,    0);
         ArrayInitialize(hp2, 0);
         limit = rates_total - MINBAR;
         for(int i = limit; i >= 1 && !IsStopped(); i--){
            GetValue(price, i);
         }//for(int i = limit + 1; i >= 0 && !IsStopped(); i--)
         return(rates_total);         
      }
      GetValue(price, 0);          
   return(rates_total);
}
