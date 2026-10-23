//+------------------------------------------------------------------+
//|                           EhlersHighPassLowPassRoofingFilter.mq5 |
//|                                Copyright 2020, Andrei Novichkov. |
//|  Main Site: http://fxstill.com                                   |
//|  Telegram:  https://t.me/fxstill (Literature on cryptocurrencies,| 
//|                                   development and code. )        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Andrei Novichkov."
#property link      "http://fxstill.com"
#property version   "1.00"
#property description "Telegram Channel: https://t.me/fxstill\n"
#property description "The HighPass-LowPass Roofing Filter:\nJohn Ehlers, \"Cycle Analytics For Traders\", pg.78"

#property indicator_separate_window
#property indicator_applied_price PRICE_CLOSE

#property indicator_buffers 3
#property indicator_plots   1
//--- plot v3
#property indicator_label1  "RB"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input int      HPLength=48;
input int      SSFLength=10;
//--- indicator buffers
double         rb[];
double         rc[];
double         hb[];


static const int MINBAR = 5;
double a1, a2, c1, c2, c3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,rb,INDICATOR_DATA);
   SetIndexBuffer(1,rc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,hb,INDICATOR_CALCULATIONS);
   
   ArraySetAsSeries(rb,true);
   ArraySetAsSeries(rc,true);
   ArraySetAsSeries(hb,true);
 
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"EhlersHighPassLowPassRoofingFilter");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   
   double twoPiPrd = 2 * M_PI / HPLength;
   double alpha1   = (MathCos(twoPiPrd) + MathSin(twoPiPrd) - 1) / MathCos(twoPiPrd);
   double alpha2   = MathExp(-M_SQRT2 * M_PI / SSFLength);
   double beta     = 2 * alpha2 * MathCos(M_SQRT2 * M_PI / SSFLength);
          c2       = beta;
          c3       = -MathPow(alpha2, 2);
          c1       = 1 - c2 - c3;
          a1       = 1 - alpha1 / 2;
          a2       = 1 - alpha1;
   return INIT__SUCCEEDED();
  }
  
void GetValue(const double& price[], int shift) {
   
   hb[shift] = a1 * (price[shift] - price[shift + 1]) + a2 * hb[shift + 1];

   double r1 = ZerroIfEmpty(rb[shift + 1]);
   double r2 = ZerroIfEmpty(rb[shift + 2]);
   rb[shift] = c1 * (hb[shift] + hb[shift + 1]) / 2 + c2 * r1 + c3 * r2;
   
   
   if (rb[shift] < 0) rc[shift] = 1 ; 
   else
      if (rb[shift] > 0) rc[shift] = 2 ;     
      
}    
int INIT__SUCCEEDED() {
   PlaySound("ok.wav");
   string cm = "Subscribe! https://t.me/fxstill";
   Print(cm);
   Comment("\n"+cm);
   return INIT_SUCCEEDED;
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
      if (limit == 0)        {   // Пришел новый тик 
      } else if (limit == 1) {   // Образовался новый бар
         GetValue(price, 1);  
         return(rates_total);         
      } else if (limit > 1)  {   // Первый вызов индикатора, смена таймфрейма, подгрузка данных из истории
         ArrayInitialize(rb,EMPTY_VALUE);
         ArrayInitialize(rc,0);
         ArrayInitialize(hb,0);
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
