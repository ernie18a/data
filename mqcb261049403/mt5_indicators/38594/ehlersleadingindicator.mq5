//+------------------------------------------------------------------+
//|                                       EhlersLeadingIndicator.mq5 |
//|                                Copyright 2020, Andrei Novichkov. |
//|  Main Site: http://fxstill.com                                   |
//| Telegram:  https://t.me/fxstill (Literature on cryptocurrencies, |
//|                                          development and code. ) |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Andrei Novichkov."
#property link      "http://fxstill.com"
#property version   "1.00"
#property description "Telegram Channel: https://t.me/fxstill\n"
#property description "The Leading Indicator:\nJohn Ehlers, \"Cybernetic Analysis For Stocks And Futures\", pg.235"

#property indicator_separate_window
#property indicator_applied_price PRICE_MEDIAN

#property indicator_buffers 4
#property indicator_plots   2
//--- plot netLead
#property indicator_label1  "netLead"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot ema
#property indicator_label2  "ema"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input double   alpha1=0.25;
input double   alpha2=0.33;
//--- indicator buffers
double         nb[];
double         nc[];
double         eb[];
double         lb[];

static const int MINBAR = 5;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,nb,INDICATOR_DATA);
   SetIndexBuffer(1,nc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,eb,INDICATOR_DATA);
   SetIndexBuffer(3,lb,INDICATOR_CALCULATIONS);
   
   ArraySetAsSeries(nb,true);
   ArraySetAsSeries(nc,true);
   ArraySetAsSeries(eb,true);
   ArraySetAsSeries(lb,true);     
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"EhlersLeadingIndicator");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   
   return INIT__SUCCEEDED();
  }
  
void GetValue(const double& price[], int shift) {
   
   lb[shift] = 2 * price[shift] + (alpha1 - 2) * price[shift + 1] + (1 - alpha1) * lb[shift + 1];//l1;

   double nb1 = ZerroIfEmpty(nb[shift + 1]);
   nb[shift] = alpha2 * lb[shift] + (1 - alpha2) * nb1;

   double e1 = ZerroIfEmpty(eb[shift + 1]);
   eb[shift] = 0.5 * price[shift] + 0.5 * e1;
   
   if (nb[shift] < eb[shift]) nc[shift] = 1 ; 
   else
      if (nb[shift] > eb[shift]) nc[shift] = 2 ;     
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
      if (limit == 0)        {
      } else if (limit == 1) {
      } else if (limit > 1)  {
         ArrayInitialize(nb,EMPTY_VALUE);
         ArrayInitialize(eb,EMPTY_VALUE);
         ArrayInitialize(nc,0);
         ArrayInitialize(lb,0);
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
