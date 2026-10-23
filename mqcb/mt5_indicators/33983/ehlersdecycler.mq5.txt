//+------------------------------------------------------------------+
//|                                               EhlersDecycler.mq5 |
//|                                Copyright 2020, Andrei Novichkov. |
//|                                               http://fxstill.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Andrei Novichkov."
#property link      "http://fxstill.com"
#property version   "1.00"


#property description "The Decycler:\nJohn Ehlers, \"Cycle Analytics For Traders\", pg.40-41"


#property indicator_applied_price PRICE_CLOSE

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot db
#property indicator_label1  "db"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input int      length=20;
//--- indicator buffers
double         db[];
double         dc[];
double a, a1, t;
static const int MINBAR = 5;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,db,INDICATOR_DATA);
   SetIndexBuffer(1,dc,INDICATOR_COLOR_INDEX);
   
   ArraySetAsSeries(db,true);
   ArraySetAsSeries(dc,true);   
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"EhlersDecycler");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

    t = 2 * M_PI / length;
    a = (MathCos(t) + MathSin(t) - 1) / MathCos(t);
    a1 = 1 - a;
    a /= 2;
   return(INIT_SUCCEEDED);
  }
  
void GetValue(const double& price[], int shift) {
   double d1 = ZerroIfEmpty(db[shift + 1]);
   db[shift] = a * (price[shift] + price[shift + 1]) + a1 * d1;
   
   if (db[shift] < price[shift]) dc[shift] = 2 ; 
   else
      if (db[shift] > price[shift]) dc[shift] = 1 ;      
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
         ArrayInitialize(db,EMPTY_VALUE);
         ArrayInitialize(dc,0);
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
