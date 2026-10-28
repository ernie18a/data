//+------------------------------------------------------------------+
//|                                      EhlersHilbertOscillator.mq5 |
//|                                Copyright 2020, Andrei Novichkov. |
//|  Main Site: http://fxstill.com                                   |
//| Telegram:  https://t.me/fxstill (Literature on cryptocurrencies, |
//|                                          development and code. ) |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Andrei Novichkov."
#property link      "http://fxstill.com"
#property version   "1.00"
#property description "Telegram Channel: https://t.me/fxstill\n"
#property description "The Hilbert Oscillator:\nJohn Ehlers, \"Rocket Science For Traders\", pg.90-91"

#property indicator_applied_price PRICE_MEDIAN
#property indicator_separate_window

#property indicator_buffers 5
#property indicator_plots   3
//--- plot snr
#property indicator_label1  "snr"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "V3"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "I3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- indicator buffers
double         zr[];
double         zc[];
double         v1[];
double         i3[];
double         q3[];

static const int MINBAR = 5;

int h;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()   {
   h = iCustom(NULL,0,"EhlersHilbertTransform");
   if (h == INVALID_HANDLE) {
      Print("Error while creating \"EhlersHilbertTransform\"");
      return (INIT_FAILED);
   }
//--- indicator buffers mapping
   SetIndexBuffer(0,zr,INDICATOR_DATA);
   SetIndexBuffer(1,zc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,v1,INDICATOR_DATA);
   SetIndexBuffer(3,i3,INDICATOR_DATA);
   SetIndexBuffer(4,q3,INDICATOR_CALCULATIONS);
   ArraySetAsSeries(zr,true);
   ArraySetAsSeries(zc,true); 
   ArraySetAsSeries(v1,true); 
   ArraySetAsSeries(i3,true);    
   ArraySetAsSeries(q3,true); 
   
   IndicatorSetString(INDICATOR_SHORTNAME,"EhlersHilbertOscillator");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);     
//---
   return INIT__SUCCEEDED();
  }

  
  
void GetValue(const double& price[], int shift) {

   double SmoothPeriod[1];
   if (CopyBuffer(h, 13, shift, 1, SmoothPeriod) <= 0) return;
   if (SmoothPeriod[0] == 0.0) return;
   int sp2 = (int)MathCeil(SmoothPeriod[0] / 2);
   if (shift + sp2 >= ArraySize(q3) ) return;
   if (sp2 < 3) sp2 = 3;
   double Smooth[];
   ArrayResize(Smooth, sp2 + 1);
   ArrayInitialize(Smooth, 0);
   ArraySetAsSeries(Smooth, true);
   if (CopyBuffer(h, 2,  shift, sp2, Smooth)      <= 0) return;
   q3[shift] = 0.5 * (Smooth[0] - Smooth[2]) * (0.1759 * SmoothPeriod[0] + 0.4607);
   i3[shift] = q3[shift];
   i3[shift] = 0.0;
   for (int i = 0; i < sp2; i++) 
      i3[shift] = i3[shift] + q3[shift + i];
   i3[shift] = (1.57 * i3[shift]) / sp2;
   
   double sp4 = MathCeil(SmoothPeriod[0] / 4);
   v1[shift] = 0.0;
   for (int i = 0; i < sp4; i++)
      v1[shift] = v1[shift] + q3[shift + i];
   v1[shift] = 1.25 * v1[shift] / sp4;

   if (price[shift] < Smooth[0]) zc[shift] = 1 ; //red
   else
      if (price[shift] > Smooth[0]) zc[shift] = 2 ; //blue   
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
   if (h != INVALID_HANDLE)
      IndicatorRelease(h);
  
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
      if (limit == 0)        {   // Пришел новый тик 
      } else if (limit == 1) {   // Образовался новый бар
         GetValue(price, 1);  
         return(rates_total);         
      } else if (limit > 1)  {   // Первый вызов индикатора, смена таймфрейма, подгрузка данных из истории
         ArrayInitialize(zr,   0);
         ArrayInitialize(v1,   EMPTY_VALUE);
         ArrayInitialize(i3,   EMPTY_VALUE);
         ArrayInitialize(zc,    0);
         ArrayInitialize(q3, 0);
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
