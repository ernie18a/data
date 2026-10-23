//+------------------------------------------------------------------+
//|                                                iMA+ATR Bands.mq5 |
//|                                   Copyright © 2025, Marteo Cosme |
//|                     https://www.mql5.com/en/users/simartspoako"  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2025, Marteo Cosme (simartspoako)"
#property link "https://www.mql5.com/en/users/simartspoako/publications"
#property version "1.00"
#property description "Baseline: iMA+ATR Bands"
#property description "Combines a Moving Average with ATR-based upper and lower bands to act as a trend filter and volatility channel."

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3
//--- plot SWMA
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot UpperATR
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_DASH
//--- plot LowerATR
//#property indicator_label3 "LowerATR"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_DASH

//--- input parameters
input group "iMA Settings"
input uint                 InpPeriod         =  6;             // iMA Period
input uint                 InpShift          =  0;             // iMA Shift
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // iMA Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input group "ATR Settings"
input uint                 InpPeriodATR      =  14;            // ATR Period
input double               InpATRxPlier      =  1.0;           // ATR Multiplier

//--- indicator buffers
double         BufferMA[];
double         BufferATR[];
double         BufferMAline[];
double         BufferUpperATR[];
double         BufferLowerATR[];
//--- global variables
int            period_MA;
int            handle_MA;
int            period_ATR;
int            handle_ATR;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- set global variables
   period_MA = int(InpPeriod < 1 ? 1 : InpPeriod);
   period_ATR = int(InpPeriodATR < 1 ? 1 : InpPeriodATR);
//--- indicator buffers mapping
   SetIndexBuffer(0, BufferMAline, INDICATOR_DATA);
   SetIndexBuffer(1, BufferUpperATR, INDICATOR_DATA);
   SetIndexBuffer(2, BufferLowerATR, INDICATOR_DATA);   
   SetIndexBuffer(3, BufferATR, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, BufferMA, INDICATOR_CALCULATIONS);
   
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME, EnumToString(InpMethod) + "(" + (string)period_MA + ")");
   PlotIndexSetString(0, PLOT_LABEL, EnumToString(InpMethod) + "(" + (string)period_MA + ")");
   PlotIndexSetString(1, PLOT_LABEL, "upperATR" + "(" + IntegerToString(InpPeriodATR) + " x " + DoubleToString(InpATRxPlier, 1) + ")");
   PlotIndexSetString(2, PLOT_LABEL, "lowerATR" + "(" + IntegerToString(InpPeriodATR) + " x " + DoubleToString(InpATRxPlier, 1) + ")");

   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
//--- setting buffer arrays as timeseries
   
   ArraySetAsSeries(BufferMAline, true);
   ArraySetAsSeries(BufferUpperATR, true);
   ArraySetAsSeries(BufferLowerATR, true);
   ArraySetAsSeries(BufferATR, true);
   ArraySetAsSeries(BufferMA, true);
   
//--- create MA's handle
   ResetLastError();
   handle_MA = iMA(NULL, PERIOD_CURRENT, InpPeriod, InpShift, InpMethod, InpAppliedPrice);

   if(handle_MA == INVALID_HANDLE) {
      Print("The iMA(1) object was not created: Error ", GetLastError());
      return INIT_FAILED;
   }
   handle_ATR = iATR(NULL, PERIOD_CURRENT, period_ATR);
   if(handle_ATR == INVALID_HANDLE) {
      Print("The iATR(1) object was not created: Error ", GetLastError());
      return INIT_FAILED;
   }
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//--- Checking for the minimum number of bars for calculation
   if(rates_total < period_MA) return 0;
//--- Checking and calculating the number of bars to be calculated
   int limit = rates_total - prev_calculated;
   if(limit > 1) {
      limit = rates_total - period_MA - 1;
      ArrayInitialize(BufferMA, EMPTY_VALUE);
      //ArrayInitialize(BufferMA, 0);
   }
//--- Data preparation
   int copied = 0, count = (limit == 0 ? 1 : rates_total);
   copied = CopyBuffer(handle_MA, 0, 0, count, BufferMA);
   if(copied != count) return 0;
   copied = CopyBuffer(handle_ATR, 0, 0, count, BufferATR);
   if(copied != count) return 0;
//--- Indicator calculation
   for(int i = limit; i >= 0 && !IsStopped(); i--) {
         //BufferMA[i]=(denominator!=0 ? numerator/denominator : 0);
         BufferMAline[i] = BufferMA[i];
         BufferUpperATR[i] = BufferMA[i] + (BufferATR[i] * InpATRxPlier);
         BufferLowerATR[i] = BufferMA[i] - (BufferATR[i] * InpATRxPlier);
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
