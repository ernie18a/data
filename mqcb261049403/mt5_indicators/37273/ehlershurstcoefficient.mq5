//+------------------------------------------------------------------+
//|                                     EhlersHurstCoefficient.mq5   |
//|                                Copyright 2020, Andrei Novichkov. |
//|  Main Site: http://fxstill.com                                   |
//|  Telegram:  https://t.me/fxstill (Literature on cryptocurrencies,| 
//|                                   development and code. )        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Andrei Novichkov."
#property link      "http://fxstill.com"
#property version   "1.00"
#property description "Telegram Channel: https://t.me/fxstill\n"
#property description "The Hurst Coefficient:\nJohn Ehlers, \"Cycle Analytics For Traders\", pg.67-68"

#property indicator_separate_window

#property indicator_applied_price PRICE_CLOSE

#property indicator_buffers 4
#property indicator_plots   1

#property indicator_type1   DRAW_COLOR_LINE 
#property indicator_width1  2
#property indicator_style1  STYLE_SOLID
#property indicator_color1  clrGreen, clrRed, clrLimeGreen 

input int length    = 30; //Length
input int ssflength = 20; //SuperSmoother filter Length

double a, b, c1, c2, c3;
int hl;
double smoothHurst[], hurst[], cf[], dimen[];

static const int MINBAR = length;

int OnInit() {
   
   SetIndexBuffer     (0, smoothHurst, INDICATOR_DATA);
   SetIndexBuffer     (1, cf,          INDICATOR_COLOR_INDEX); 
   SetIndexBuffer     (2, hurst,       INDICATOR_CALCULATIONS); 
   SetIndexBuffer     (3, dimen,       INDICATOR_CALCULATIONS);    
   ArraySetAsSeries   ( smoothHurst, true);
   ArraySetAsSeries   ( cf,          true); 
   ArraySetAsSeries   ( hurst,       true);
   ArraySetAsSeries   ( dimen,       true);
   
   
   IndicatorSetString (INDICATOR_SHORTNAME,"EhlersHurstCoefficient");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   
   a = MathExp(-M_SQRT2 * M_PI  / ssflength);
   b = 2 * a * MathCos(M_SQRT2 * M_PI / ssflength); 
   c2 = b;
   c3 = -MathPow(a, 2);
   c1 = 1 - c2 - c3;
   hl = (int)MathCeil(length / 2);
   
   return INIT__SUCCEEDED();
}

void GetValue(const double& price[], int shift) {

   int ih = iHighest(NULL, 0, MODE_CLOSE, length, shift); 
   int il = iLowest (NULL, 0, MODE_CLOSE, length, shift); 
   if (ih == -1 || il == -1) return;
   
   double n3 = (price[ih] - price[il]) / length;
   double hh = price[shift];
   double ll = price[shift];

   for (int i = shift; i < shift + hl; i++) {
      if (price[i] > hh) hh = price[i];
      if (price[i] < ll) ll = price[i];
   }
   
   double n1 = (hh - ll) / hl;
   
   hh = price[shift + hl];
   ll = price[shift + hl];
   
   for (int i = shift + hl; i < shift + length; i++) {
      if (price[i] > hh) hh = price[i];
      if (price[i] < ll) ll = price[i];
   }
    
   double n2 = (hh - ll) / hl;   
   
   dimen[shift] = (n1 > 0 && n2 > 0 && n3 > 0) ? 
                   0.5 * ( (log(n1 + n2) - log(n3)) / log(2) + dimen[shift + 1]) : 0;
                   
   hurst[shift] = 2 - dimen[shift];  
 
   double s1 = ZerroIfEmpty(smoothHurst[shift + 1]);// == EMPTY_VALUE)? 0: smoothHurst[shift + 1];
   double s2 = ZerroIfEmpty(smoothHurst[shift + 2]);// == EMPTY_VALUE)? 0: smoothHurst[shift + 2];                
   
   smoothHurst[shift] = c1 * (hurst[shift] + hurst[shift + 1]) / 2 + c2 * s1 + c3 * s2;
                         
   if (smoothHurst[shift] < 0.5) cf[shift] = 1 ; 
   else
      if (smoothHurst[shift] > 0.5) cf[shift] = 2 ;                         
}//void GetValue(const double& price[], int shift)
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
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
      if(rates_total <= MINBAR) return 0;
      ArraySetAsSeries(close,true);   
      ArraySetAsSeries(high, true); 
      ArraySetAsSeries(low,  true);
      int limit = rates_total - prev_calculated;
      if (limit == 0)        {   // Пришел новый тик 
      } else if (limit == 1) {   // Образовался новый бар
         GetValue(close, 1);  
         return(rates_total);         
      } else if (limit > 1)  {   // Первый вызов индикатора, смена таймфрейма, подгрузка данных из истории
         ArrayInitialize(smoothHurst, EMPTY_VALUE);
         ArrayInitialize(cf, 0);
         ArrayInitialize(hurst, 0);
         ArrayInitialize(dimen, 0);
         limit = rates_total - MINBAR;
         for(int i = limit; i >= 1 && !IsStopped(); i--){
            GetValue(close, i);
         }//for(int i = limit + 1; i >= 0 && !IsStopped(); i--)
         return(rates_total);         
      }
      GetValue(close, 0);          

   return(rates_total);
  }
//+------------------------------------------------------------------+
