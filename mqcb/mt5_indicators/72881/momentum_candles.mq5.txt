//+------------------------------------------------------------------+
//|                                              MomentumCandles.mq5 |
//|                                      Copyright © phade, 2026     |
//+------------------------------------------------------------------+
#property copyright "phade"
#property version   "1.00"
#property description "Candles colored by Momentum and price expansion (on high impact news)"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   1

//--- Plot
#property indicator_label1  "Momentum Candles"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGreen, clrRed, clrGray, clrSilver 
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Inputs
input int                InpMomPeriod   = 4;           // Momentum Period
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE; // Applied price
input bool               InpNewsCandleFilter = true;    // News Candle Filter
input int                InpNewsPeriod  = 20;          // Period to calculate average candle size
input double             InpNewsMult    = 3.0;         // News candle multiplier
//--- Buffers
double OpenBuffer[];
double HighBuffer[];
double LowBuffer[];
double CloseBuffer[];
double ColorBuffer[];   // Color index: 0=Green, 1=Red, 2=Gray
double mom[];

int MomentumHandle = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// Set buffers
   SetIndexBuffer(0, OpenBuffer,  INDICATOR_DATA);
   SetIndexBuffer(1, HighBuffer,  INDICATOR_DATA);
   SetIndexBuffer(2, LowBuffer,   INDICATOR_DATA);
   SetIndexBuffer(3, CloseBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, ColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5, mom, INDICATOR_CALCULATIONS);

   IndicatorSetString(INDICATOR_SHORTNAME, "Momentum Candles (" + IntegerToString(InpMomPeriod) + ")");
   ChartSetInteger(0, CHART_MODE, 0, CHART_LINE);
   ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrNONE);
   MomentumHandle = iMomentum(_Symbol, _Period, InpMomPeriod, InpAppliedPrice);

   if(MomentumHandle == INVALID_HANDLE)
     {
      Print("Failed to create Momentum handle");
      return INIT_FAILED;
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(MomentumHandle != INVALID_HANDLE)
      IndicatorRelease(MomentumHandle);

   ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrGray);
   ChartSetInteger(0, CHART_MODE, 0, CHART_CANDLES);
  }

//+------------------------------------------------------------------+
//| Main calculation function                                        |
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
                const int &spread[])
  {

   int start = (prev_calculated == 0) ? InpMomPeriod : prev_calculated - 1;

   int to_copy = (prev_calculated < 0) ? rates_total : rates_total - prev_calculated + 1;

   if(CopyBuffer(MomentumHandle, 0, 0, to_copy, mom) <= 0)
      return prev_calculated;

   for(int i = start; i < rates_total && !IsStopped(); i++)
     {
         OpenBuffer[i]  = open[i];
         HighBuffer[i]  = high[i];
         LowBuffer[i]   = low[i];
         CloseBuffer[i] = close[i];
   
         double momentum = mom[i];
         double deviation = (momentum-100)*(uint)MathPow(10, _Digits);
         //Print("Momentum: ", momentum);
         //Print("deviation: ", deviation);
         
         // Determine color
         if(deviation > 0) ColorBuffer[i] = 0.0;      // Green - Upward momentum
         else if(deviation < 0) ColorBuffer[i] = 1.0;      // Red - Downward momentum
         else ColorBuffer[i] = 2.0;      // Gray - Weak momentum
                   
          //  Calculate Average Range for News detection
         double sumRange = 0;
         for(int j = i - InpNewsPeriod; j < i; j++)
         {
            if(j >= 0){     
               double dist1 = fabs(open[j] - low[j]);
               double dist2 = fabs(open[j] - high[j]);
               double maindist = MathMax(dist1, dist2);
               sumRange += maindist;
               }
         }
         double avgRange = sumRange / InpNewsPeriod;
         double currentRange = MathMax(fabs(open[i] - low[i]), fabs(open[i] - high[i]));    
         
         if(InpNewsCandleFilter && currentRange > (avgRange * InpNewsMult)) 
         {
            ColorBuffer[i] = 3.0; // candles paint silver on high impact events
         } 
     }

   return(rates_total);
  }