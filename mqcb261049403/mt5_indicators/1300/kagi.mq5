//+------------------------------------------------------------------+
//|                                                         Kagi.mq5 |
//|                                            Copyright 2012, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Rone."
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "The Kagi chart."
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   4
//--- plot Yang
#property indicator_label1  "Yang"
#property indicator_type1   DRAW_HISTOGRAM2
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Yin
#property indicator_label2  "Yin"
#property indicator_type2   DRAW_HISTOGRAM2
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot BendTop
#property indicator_label3  "BendTop"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrRed,clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot BendBottom
#property indicator_label4  "BendBottom"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrRed,clrBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//---
enum REVERSAL_MODE {
   PIPS,    // In pips
   PERCENT  // In percentage
};
//--- input parameters
input REVERSAL_MODE  InpMode = PIPS;      // Reversal
input int            InpPips = 100;       // Reversal in pips
input double         InpPercent = 0.5;    // Reversal in %
//--- indicator buffers
double         YangBuffer1[];
double         YangBuffer2[];
double         YinBuffer1[];
double         YinBuffer2[];
double         BendTopBuffer[];
double         BendTopColors[];
double         BendBottomBuffer[];
double         BendBottomColors[];
double         KagiBuffer[];
//--- global variables
int            kagiShift;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {   
//--- indicator buffers mapping
   SetIndexBuffer(0, YangBuffer1, INDICATOR_DATA);
   SetIndexBuffer(1, YangBuffer2, INDICATOR_DATA);
   SetIndexBuffer(2, YinBuffer1, INDICATOR_DATA);
   SetIndexBuffer(3, YinBuffer2, INDICATOR_DATA);
   SetIndexBuffer(4, BendTopBuffer, INDICATOR_DATA);
   SetIndexBuffer(5, BendTopColors, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6, BendBottomBuffer, INDICATOR_DATA);
   SetIndexBuffer(7, BendBottomColors, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(8, KagiBuffer, INDICATOR_CALCULATIONS);
//---
   for ( int i = 0; i < 4; i++ ) {
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0);
   }
//---
   IndicatorSetInteger(INDICATOR_LEVELS, 1);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, clrGray);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, STYLE_SOLID);
//---
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
//---
   string modeData = (InpMode == PIPS) ? (string)InpPips+" pips" : DoubleToString(InpPercent, 2)+"%";
   IndicatorSetString(INDICATOR_SHORTNAME, "Kagi ("+modeData+")");
//---
   return(0);
}
//+------------------------------------------------------------------+
//| Get Reversal Value function                                      |
//+------------------------------------------------------------------+
double getReversal(double price) {
//---
   if ( InpMode == PIPS ) {
      return(InpPips*_Point);
   }
   return(NormalizeDouble((price/100)*InpPercent, _Digits));
//---
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
//---
   int shift = 1;
   bool up, yang;
   double localMin, localMax;
   double reversal = getReversal(price[0]);
//---
   for ( ; MathAbs(price[shift]-price[0]) < reversal; shift++ );
//---
   KagiBuffer[0] = KagiBuffer[1] = price[0];
   KagiBuffer[2] = price[shift];
   kagiShift = 2;
   if ( price[shift] > price[0] ) {
      up = true;
      yang = true;
      localMin = price[0];
      localMax = price[shift];
   } else {
      up = false;
      yang = false;
      localMin = price[shift];
      localMax = price[0];
   }
//---
   for ( int bar = shift; bar < rates_total && !IsStopped(); bar++ ) {
      double curPrice = price[bar];
      
      reversal = getReversal(KagiBuffer[kagiShift]);
      if ( up ) {
         if ( curPrice > KagiBuffer[kagiShift] ) {
            KagiBuffer[kagiShift] = curPrice;
         } else if ( curPrice < KagiBuffer[kagiShift] - reversal ) {
            kagiShift += 1;
            KagiBuffer[kagiShift] = KagiBuffer[kagiShift-1];
            kagiShift += 1;
            KagiBuffer[kagiShift] = curPrice;
            up = false;
         }
      } else {
         if ( curPrice < KagiBuffer[kagiShift] ) {
            KagiBuffer[kagiShift] = curPrice;
         } else if ( curPrice > KagiBuffer[kagiShift] + reversal ) {
            kagiShift += 1;
            KagiBuffer[kagiShift] = KagiBuffer[kagiShift-1];
            kagiShift += 1;
            KagiBuffer[kagiShift] = curPrice;
            up = true;
         }
      }
   }
//---
   for ( int i = 1; i <= kagiShift; i++ ) {
      int bar = rates_total - kagiShift - 1 + i;
      double cur = KagiBuffer[i];
      double prev = KagiBuffer[i-1];
      //---
      if ( yang ) {
         YinBuffer1[bar] = YinBuffer2[bar] = 0.0;
         BendTopColors[bar] = BendBottomColors[bar] = 1;
         if ( cur > prev ) {
            YangBuffer1[bar] = localMin = prev;
            YangBuffer2[bar] = localMax = cur;
            //---
            BendTopBuffer[bar] = cur;
            BendBottomBuffer[bar] = prev;
         } else if ( cur < prev ) {
            if ( cur < localMin ) {
               YangBuffer1[bar] = localMax = prev;
               YangBuffer2[bar] = YinBuffer1[bar] = localMin;
               YinBuffer2[bar] = localMin = cur;
               yang = false;
               //---
               BendTopBuffer[bar] = prev;
               BendBottomBuffer[bar] = cur;
            } else {
               YangBuffer1[bar] = localMax = prev;
               YangBuffer2[bar] = localMin = cur;
               //---
               BendTopBuffer[bar] = prev;
               BendBottomBuffer[bar] = cur;
            }
         } else {
            YangBuffer1[bar] = YangBuffer2[bar] = 0.0;
            //---
            if ( cur == localMin ) {
               BendTopBuffer[bar] = 0.0;
               BendBottomBuffer[bar] = cur;
            } else {
               BendTopBuffer[bar] = cur;
               BendBottomBuffer[bar] = 0.0;
            }
         }
      } else {
         YangBuffer1[bar] = YangBuffer2[bar] = 0.0;
         BendTopColors[bar] = BendBottomColors[bar] = 0;
         if ( cur < prev ) {
            YinBuffer1[bar] = localMax = prev;
            YinBuffer2[bar] = localMin = cur;
            //---
            BendTopBuffer[bar] = prev;
            BendBottomBuffer[bar] = cur;
         } else if ( cur > prev ) {
            if ( cur > localMax ) {
               YinBuffer1[bar] = localMin = prev;
               YinBuffer2[bar] = YangBuffer1[bar] = localMax;
               YangBuffer2[bar] = localMax = cur;
               yang = true;
               //---
               BendTopBuffer[bar] = cur;
               BendBottomBuffer[bar] = prev;
            } else {
               YinBuffer1[bar] = localMin = prev;
               YinBuffer2[bar] = localMax = cur;
               //---
               BendTopBuffer[bar] = cur;
               BendBottomBuffer[bar] = prev;
            }
         } else {
            YinBuffer1[bar] = YinBuffer2[bar] = 0.0;
            //---
            if ( cur == localMin ) {
               BendTopBuffer[bar] = 0.0;
               BendBottomBuffer[bar] = cur;
            } else {
               BendTopBuffer[bar] = cur;
               BendBottomBuffer[bar] = 0.0;   
            }
         }
      }
   }
//---
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, price[rates_total-1]);  
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
