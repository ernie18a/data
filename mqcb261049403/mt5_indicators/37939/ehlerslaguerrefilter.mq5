//+------------------------------------------------------------------+
//|                                         EhlersLaguerreFilter.mq5 |
//|                                Copyright 2020, Andrei Novichkov. |
//|  Main Site: http://fxstill.com                                   |
//|  Telegram:  https://t.me/fxstill (Literature on cryptocurrencies,| 
//|                                   development and code. )        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Andrei Novichkov."
#property link      "http://fxstill.com"
#property version   "1.00"
#property description "Telegram Channel: https://t.me/fxstill\n"
#property description "The Laguerre Filter:\nJohn Ehlers, \"Cybernetic Analysis For Stocks And Futures\", pg.216"

#property indicator_applied_price PRICE_MEDIAN

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   2
//--- plot filt
#property indicator_label1  "filt"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot fir
#property indicator_label2  "fir"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrGreen,clrRed,clrLimeGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input double   gamma=0.8;
//--- indicator buffers
double         fi[];
double         fr[];
double         fc[];

double l0[], l1[], l2[], l3[];

static const int MINBAR = 5;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fi,INDICATOR_DATA);
   SetIndexBuffer(1,fr,INDICATOR_DATA);
   SetIndexBuffer(2,fc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,l0,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,l1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,l2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,l3,INDICATOR_CALCULATIONS);
   
   ArraySetAsSeries(fi,true);
   ArraySetAsSeries(fr,true);
   ArraySetAsSeries(fc,true);
   ArraySetAsSeries(l0,true);
   ArraySetAsSeries(l1,true);
   ArraySetAsSeries(l2,true);
   ArraySetAsSeries(l3,true);   
   
   IndicatorSetString(INDICATOR_SHORTNAME,"EhlersLaguerreFilter");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);   
//---
   return INIT__SUCCEEDED();
  }
  
void GetValue(const double& price[], int shift) {

   l0[shift] = (1 - gamma) * price[shift] + gamma * l0[shift + 1];
   l1[shift] = -gamma * l0[shift] + l0[shift + 1] + gamma * l1[shift + 1];
   l2[shift] = -gamma * l1[shift] + l1[shift + 1] + gamma * l2[shift + 1];
   l3[shift] = -gamma * l2[shift] + l2[shift + 1] + gamma * l3[shift + 1];

   fi[shift] = (l0[shift] + 2 * l1[shift] + 2 * l2[shift] + l3[shift]) / 6;
   fr[shift] = (price[shift] + 2 * price[shift + 1] + 2 * price[shift + 2] + price[shift + 3]) / 6   ;          
   
   if (fi[shift] < fr[shift]) fc[shift] = 2 ; 
   else
      if (fi[shift] > fr[shift]) fc[shift] = 1 ;   
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
      ArraySetAsSeries(price,true);    
      int limit = rates_total - prev_calculated;
      if (limit == 0)        {   // Пришел новый тик 
      } else if (limit == 1) {   // Образовался новый бар
         GetValue(price, 1);  
         return(rates_total);      
      } else if (limit > 1)  {   // Первый вызов индикатора, смена таймфрейма, подгрузка данных из истории
         ArrayInitialize(fi,EMPTY_VALUE);
         ArrayInitialize(fr,EMPTY_VALUE);
         ArrayInitialize(fc,0);
         ArrayInitialize(l0,0);
         ArrayInitialize(l1,0);
         ArrayInitialize(l2,0);
         ArrayInitialize(l3,0);   
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
