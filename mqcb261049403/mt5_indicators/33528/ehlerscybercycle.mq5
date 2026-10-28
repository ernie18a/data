//+------------------------------------------------------------------+
//|                                             EhlersCyberCycle.mq5 |
//|                                Copyright 2020, Andrei Novichkov. |
//|                                               http://fxstill.com |
//|   Telegram: https://t.me/fxstill (Literature on cryptocurrencies,|
//|                                   development and code. )        |
//|  Instagram: https://www.instagram.com/andreifx2020/              |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Andrei Novichkov."
#property link      "http://fxstill.com"
#property version   "1.00"

#property description "Telegram Channel: https://t.me/fxstill\n"
#property description "The Cyber Cycle:\nJohn Ehlers, \"Cybernetic Analysis For Stocks And Futures\", pg.34"

#property indicator_separate_window
#property indicator_applied_price PRICE_MEDIAN


#property indicator_buffers 4
#property indicator_plots 2

#property indicator_type1   DRAW_COLOR_LINE 
#property indicator_width1  2
#property indicator_style1  STYLE_SOLID
#property indicator_color1  clrGreen, clrRed, clrLimeGreen 

#property indicator_type2   DRAW_LINE 
#property indicator_width2  2
#property indicator_style2  STYLE_SOLID
#property indicator_color2  clrOrange 

input double alpha = 0.07;//Alpha

double cycle[], trigger[], smooth[];
double cf[];

double a1, a2;

static const int MINBAR = 5;

int OnInit()  {

   SetIndexBuffer(0,cycle,INDICATOR_DATA);
   SetIndexBuffer(1,cf,INDICATOR_COLOR_INDEX); 
      
   SetIndexBuffer(2,trigger,INDICATOR_DATA);
   SetIndexBuffer(3,smooth,INDICATOR_CALCULATIONS);
   
   ArraySetAsSeries(cycle,true);
   ArraySetAsSeries(trigger,true); 
   ArraySetAsSeries(smooth,true); 
   ArraySetAsSeries(cf,  true); 
   
   
   IndicatorSetString(INDICATOR_SHORTNAME,"EhlersSuperPassBandFilter");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

   return(INIT_SUCCEEDED);
}

void GetValue(const double& price[], int shift) {

   smooth[shift] = (price[shift] + 2 * price[shift + 1] + 2 * price[shift + 2] + price[shift + 3]) / 6;
   if (false/*shift > 7*/) {
      cycle[shift] = (price[shift] - 2 * price[shift + 1] + price[shift + 2]) / 4;
   } else {
      double c1 = ZerroIfEmpty(cycle[shift + 1]);
      double c2 = ZerroIfEmpty(cycle[shift + 2]);
      cycle[shift] = pow(1 - (0.5 * alpha), 2) * (smooth[shift] - 2 * smooth[shift + 1] + smooth[shift + 2]) + 
                     2 * (1 - alpha) * c1 - pow(1 - alpha, 2) * c2;
   }
   trigger[shift] = cycle[shift + 1];

   if (cycle[shift] < trigger[shift]) cf[shift] = 1 ; 
   else
      if (cycle[shift] > trigger[shift]) cf[shift] = 2 ;
             
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])  {

      if(rates_total <= MINBAR) return 0;
      ArraySetAsSeries(price,true);    
      int limit = rates_total - prev_calculated;
      if (limit == 0)        { 
      } else if (limit == 1) {
         GetValue(price, 1);  
         return(rates_total);   
      } else if (limit > 1)  { 
         ArrayInitialize(cycle,   EMPTY_VALUE);
         ArrayInitialize(trigger, EMPTY_VALUE);
         ArrayInitialize(smooth,  0);
         ArrayInitialize(cf,      0);
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