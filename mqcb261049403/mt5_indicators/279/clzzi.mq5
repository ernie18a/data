//+------------------------------------------------------------------+
//|               A-la Clyde Lee Patterns, Nonparametric Zig Zag.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Zig Zag indicator bases on a-la Clyde Lee 4-point patterns."
#property description "Uptrend monotonicity condition starts with simultaneous "
#property description "appearence of bullish patterns for highs and lows."
#property description "Similar logic applies for downtrend."
#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots   11
//--- plot P0
#property indicator_label1  "P0"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot P1
#property indicator_label2  "P1"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  Red
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot P2
#property indicator_label3  "P2"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  Red
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot P3
#property indicator_label4  "P3"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  Red
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot P4
#property indicator_label5  "P4"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  Red
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot P5
#property indicator_label6  "P5"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  Blue
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot P6
#property indicator_label7  "P6"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  Blue
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot P7
#property indicator_label8  "P7"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  Blue
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot P8
#property indicator_label9  "P8"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  Blue
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1
//--- plot P9
#property indicator_label10  "P9"
#property indicator_type10   DRAW_ARROW
#property indicator_color10  Blue
#property indicator_style10  STYLE_SOLID
#property indicator_width10  1
//--- plot ZigZagLine
#property indicator_label11  "ZigZagLine"
#property indicator_type11   DRAW_SECTION
#property indicator_color11  White
#property indicator_style11  STYLE_SOLID
#property indicator_width11  1
//--- indicator buffers
double         P0[], P1[], P2[], P3[], P4[], P5[], P6[], P7[], P8[], P9[], PT[];
double         ZigZagLineBuffer[];
//--- custom variables
int            lastz = 0;
int            patterns[16] = {0, 5, -1, 7, 1, -1, -1, 8, 3, -1, -1, 6, 2, -1, 4, 9};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,P0,INDICATOR_DATA);
   SetIndexBuffer(1,P1,INDICATOR_DATA);
   SetIndexBuffer(2,P2,INDICATOR_DATA);
   SetIndexBuffer(3,P3,INDICATOR_DATA);
   SetIndexBuffer(4,P4,INDICATOR_DATA);
   SetIndexBuffer(5,P5,INDICATOR_DATA);
   SetIndexBuffer(6,P6,INDICATOR_DATA);
   SetIndexBuffer(7,P7,INDICATOR_DATA);
   SetIndexBuffer(8,P8,INDICATOR_DATA);
   SetIndexBuffer(9,P9,INDICATOR_DATA);
   SetIndexBuffer(10,ZigZagLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(11,PT,INDICATOR_CALCULATIONS);
//--- set short name and digits   
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- set OBJ_ARROW value
   PlotIndexSetInteger(0,PLOT_ARROW,139);
   PlotIndexSetInteger(1,PLOT_ARROW,140);
   PlotIndexSetInteger(2,PLOT_ARROW,141);
   PlotIndexSetInteger(3,PLOT_ARROW,142);
   PlotIndexSetInteger(4,PLOT_ARROW,143);
   PlotIndexSetInteger(5,PLOT_ARROW,144);
   PlotIndexSetInteger(6,PLOT_ARROW,145);
   PlotIndexSetInteger(7,PLOT_ARROW,146);
   PlotIndexSetInteger(8,PLOT_ARROW,147);
   PlotIndexSetInteger(9,PLOT_ARROW,148);
//---
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,+10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,+10);
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,+10);
   PlotIndexSetInteger(3,PLOT_ARROW_SHIFT,+10);
   PlotIndexSetInteger(4,PLOT_ARROW_SHIFT,+10);
   PlotIndexSetInteger(5,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(6,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(7,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(8,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(9,PLOT_ARROW_SHIFT,-10);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Get Pattern Number                                               |
//+------------------------------------------------------------------+
int GetPatternNumber(const double& rate[], int bar)
{
   double D = rate[bar - 0];
   int cnt = bar - 1;
   while (cnt > 0 && rate[bar - 0] == rate[cnt]) cnt--;
   if (cnt <= 0) return(-1);
   if (rate[cnt] < rate[cnt + 1])
      while (cnt > 1 && rate[cnt - 1] <= rate[cnt]) cnt--;
   else
      while (cnt > 1 && rate[cnt - 1] >= rate[cnt]) cnt--;
   if (cnt <= 1) return(-1);
   
   double C = rate[cnt];
   if (rate[cnt - 1] < rate[cnt])
      while (cnt > 1 && rate[cnt - 1] <= rate[cnt]) cnt--;
   else
      while (cnt > 1 && rate[cnt - 1] >= rate[cnt]) cnt--;
   if (cnt <= 1) return(-1);
   
   double B = rate[cnt];
   if (rate[cnt - 1] < rate[cnt])
      while (cnt > 1 && rate[cnt - 1] <= rate[cnt]) cnt--;
   else
      while (cnt > 1 && rate[cnt - 1] >= rate[cnt]) cnt--;
   if (cnt <= 1) return(-1);
   
   double A = rate[cnt];

   int code = 0;
   if (B > A) code++;
   if (D > A) code += 2;
   if (D > B) code += 4;
   if (C > A) code += 8;
   return(patterns[code]);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
//--- initializing
  if (rates_total - prev_calculated == 0) return(rates_total);
   int shift, trend;
   int last_bar = rates_total - 1;
   if (prev_calculated == 0)
      {
      ArrayInitialize(ZigZagLineBuffer, EMPTY_VALUE);
      ArrayInitialize(P0, EMPTY_VALUE);
      ArrayInitialize(P1, EMPTY_VALUE);
      ArrayInitialize(P2, EMPTY_VALUE);
      ArrayInitialize(P3, EMPTY_VALUE);
      ArrayInitialize(P4, EMPTY_VALUE);
      ArrayInitialize(P5, EMPTY_VALUE);
      ArrayInitialize(P6, EMPTY_VALUE);
      ArrayInitialize(P7, EMPTY_VALUE);
      ArrayInitialize(P8, EMPTY_VALUE);
      ArrayInitialize(P9, EMPTY_VALUE);
      ArrayInitialize(PT, EMPTY_VALUE);
      shift = 2;
      lastz = 0;
      }
      else
      {
      for (int cnt = prev_calculated; cnt < rates_total; cnt++)
         {
         ZigZagLineBuffer[cnt] = EMPTY_VALUE;
         P0[cnt] = EMPTY_VALUE;
         P1[cnt] = EMPTY_VALUE;
         P2[cnt] = EMPTY_VALUE;
         P3[cnt] = EMPTY_VALUE;
         P4[cnt] = EMPTY_VALUE;
         P5[cnt] = EMPTY_VALUE;
         P6[cnt] = EMPTY_VALUE;
         P7[cnt] = EMPTY_VALUE;
         P8[cnt] = EMPTY_VALUE;
         P9[cnt] = EMPTY_VALUE;
         PT[cnt] = EMPTY_VALUE;
         }
      shift = prev_calculated - 2;
      if (ZigZagLineBuffer[lastz] == 0) 
         {
         Print("WTF! lastz doesn't fit");
         lastz = prev_calculated - 1;
         while (lastz > 0 && ZigZagLineBuffer[lastz] == 0) lastz--;
         }
      }
   
   while (++shift < last_bar)
      {
      int ph = GetPatternNumber(high, shift);
      int pl = GetPatternNumber(low, shift);
     
      switch (ph)
         {
         case 0:
         case 1:
         case 2:
         case 3:
         case 4: switch (pl)
                  {
                  case 0:
                  case 1:
                  case 2:
                  case 3:
                  case 4: trend = -1; break;
                  case 5:
                  case 6:
                  case 7:
                  case 8:
                  case 9: trend = 0; break;
                  default: trend = 0; break;
                  }
                  break;
         case 5:
         case 6:
         case 7:
         case 8:
         case 9: switch (pl)
                  {
                  case 0:
                  case 1:
                  case 2:
                  case 3:
                  case 4: trend = 0; break;
                  case 5:
                  case 6:
                  case 7:
                  case 8:
                  case 9: trend = 1; break;
                  default: trend = 0; break;
                  }
                  break;
         default: trend = 0; break;
         }
      if (trend != 0) PT[shift] = trend; else PT[shift] = PT[shift - 1];
      }   
      
   shift = lastz  + 1;
   while(shift < last_bar && (PT[shift] == PT[lastz] || PT[shift] == 0)) shift++;
   
   while (shift < last_bar)
      {
      int iminlow = shift;
      int imaxhigh = shift;
      while(shift < last_bar && PT[shift] == PT[iminlow]) 
         {
         if (low[iminlow] > low[shift]) iminlow = shift;
         if (high[imaxhigh] < high[shift]) imaxhigh = shift;           
         shift++;
         }
      if (shift < last_bar)
         {
         if (PT[iminlow] == - 1)
            {
            lastz = iminlow;
            ZigZagLineBuffer[lastz] = low[lastz];
            }
            else
            {
            lastz = imaxhigh;
            ZigZagLineBuffer[lastz] = high[lastz];
            }
         
         int pattern;
         if (PT[lastz] == 1) pattern = GetPatternNumber(high, lastz); else pattern = GetPatternNumber(low, lastz);
         
         switch (pattern)
            {
            case 0: P0[lastz] = low[lastz]; break;
            case 1: P1[lastz] = low[lastz]; break;
            case 2: P2[lastz] = low[lastz]; break;
            case 3: P3[lastz] = low[lastz]; break;
            case 4: P4[lastz] = low[lastz]; break;
            case 5: P5[lastz] = high[lastz]; break;
            case 6: P6[lastz] = high[lastz]; break;
            case 7: P7[lastz] = high[lastz]; break;
            case 8: P8[lastz] = high[lastz]; break;
            case 9: P9[lastz] = high[lastz]; break;
            default: break;
            }
         }
      }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
