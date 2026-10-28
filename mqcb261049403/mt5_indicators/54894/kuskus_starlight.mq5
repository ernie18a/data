//+------------------------------------------------------------------+
//|                                             Kuskus_Starlight.mq5 |
//|                                   Copyright © 2025, Marteo Cosme |
//|                      https://www.mql5.com/en/users/simartspoako" |
//|                                    Original Developed by MartinG |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2025, Marteo Cosme (simartspoako)"
#property link "https://www.mql5.com/en/users/simartspoako"
#property version "1.00"
#property description "Kuskus Starlight"
#property description "Converted from MQL4 to MQL5."
#property description "Original MT4 Code and algorithm - https://www.mql5.com/en/code/8365"

//----
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 2
#property indicator_color1 clrBlue
#property indicator_color2 clrRed
#property indicator_levelstyle 2


enum enum_CustomDrawType {
   None = 0,
   Line = 1,
   Histogram = 2,
   StaryStaryNight = 3
};

enum enum_CustomArrow {
   Kuskus_Classic = 251,
   Six_Pointed_Star = 172,
   Five_Pointed_Star_A = 171,
   Five_Pointed_Star_B = 182,
   Four_Pointed_Star_A = 170,
   Four_Pointed_Star_B = 178,
   Four_Pointed_Star_C = 179,
   Three_Pointed_Object = 169,
   Sunbust_A = 174,
   Sunbust_B = 175,
   Diamond_A = 117,
   Diamond_B = 116,
   Diamond_C = 119,
   Circle_Plain = 161,
   Circle_Narrow = 162,
   Circle_Bold = 163,
   Circle_Dotted = 164,
   Circle_Shadow_A = 166,
   Circle_Shadow_B = 109,
   Kaboom = 77,
   YingYang = 91, 
   Snowflake = 84,
   Iron_Cross = 88,
   Star_David = 89,
   Crescent_Moon = 90,
   Radioactive = 62,
   Dotted_Object = 108
};


input int     RangePeriods = 9;            // Range periods
input double  PriceSmoothing = 0.3;         // Price smoothing factor
input double  IndexSmoothing = 0.9;         // Index smoothing factor
input enum_CustomDrawType DrawType = 3;         // Line drawing type
input enum_CustomArrow DrawArrow = 251;     // Arrow type
input int     DrawSize = 3;                 // Line size

// Buffers for indicator values
double ExtMapBuffer_FisherIndex[];                     // Smoothed Fisher index
double ExtMapBuffer_Uptrend[];                     // Uptrend values
double ExtMapBuffer_Downtrend[];                     // Downtrend values
double ExtMapBuffer_PriceLocation[];                     // Smoothed price location

int DrawStart;                              // Minimum bars to start drawing






//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
   // Bind buffers
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0.0);

   
   SetIndexBuffer(0, ExtMapBuffer_Uptrend, INDICATOR_DATA);
   SetIndexBuffer(1, ExtMapBuffer_Downtrend, INDICATOR_DATA);
   SetIndexBuffer(2, ExtMapBuffer_FisherIndex, INDICATOR_DATA);
   SetIndexBuffer(3, ExtMapBuffer_PriceLocation, INDICATOR_CALCULATIONS);


   ArraySetAsSeries(ExtMapBuffer_Uptrend, 1);
   ArraySetAsSeries(ExtMapBuffer_Downtrend, 1);
   ArraySetAsSeries(ExtMapBuffer_FisherIndex, 1);
   ArraySetAsSeries(ExtMapBuffer_PriceLocation, 1);


   // Configure plot properties
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DrawType);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, DrawSize);
   PlotIndexSetInteger(0,PLOT_ARROW,DrawArrow);

   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DrawType);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, DrawSize);
   PlotIndexSetInteger(1,PLOT_ARROW,DrawArrow);

   IndicatorSetString(INDICATOR_SHORTNAME,
                      StringFormat("Kuskus Starlight (rPeriods %d, pSmooth %.2f, iSmooth %.2f)",
                                   RangePeriods, PriceSmoothing, IndexSmoothing));

   DrawStart = 2 * RangePeriods + 4;
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, DrawStart);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, DrawStart);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   // Cleanup if necessary
   SetIndexBuffer(0, ExtMapBuffer_Uptrend, NULL);
   SetIndexBuffer(1, ExtMapBuffer_Downtrend, NULL);
   SetIndexBuffer(2, ExtMapBuffer_FisherIndex, NULL);
   SetIndexBuffer(3, ExtMapBuffer_PriceLocation, NULL);
   
   ArrayFree(ExtMapBuffer_Uptrend);
   ArrayFree(ExtMapBuffer_Downtrend);
   ArrayFree(ExtMapBuffer_FisherIndex);
   ArrayFree(ExtMapBuffer_PriceLocation);
}

//+------------------------------------------------------------------+
//| Custom indicator calculation function                            |
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

   if (rates_total < DrawStart) {
      Print("Kuskus: Not enough bars to calculate");
      return(0);
   }
   ArraySetAsSeries(low, 1);
   ArraySetAsSeries(high, 1);
   int startPos = MathMax(prev_calculated, RangePeriods-1); // Ensure valid starting point
   int endPos = rates_total - 1;
   int currentPos = endPos - startPos; 
   for (int i = currentPos; i >= 0; i--) 
   {
      CalculateCurrentBar(i, high, low, rates_total);
   }
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Single bar calculation                                           |
//+------------------------------------------------------------------+
void CalculateCurrentBar(int pos, const double &high[], const double &low[], const int rates_total) {
   double LowestLow, HighestHigh, GreatestRange, MidPrice;
   double SmoothedLocation, FishIndex, SmoothedFish;
   double PriceLocation;
   // Find highest and lowest prices in range
   LowestLow = low[iLowest(NULL, 0, MODE_LOW, RangePeriods, pos)];
   HighestHigh = high[iHighest(NULL, 0, MODE_HIGH, RangePeriods, pos)];

   if (HighestHigh - LowestLow < 0.1 * _Point)
      HighestHigh = LowestLow + 0.1 * _Point;

   GreatestRange = HighestHigh - LowestLow;
   MidPrice = (high[pos] + low[pos]) / 2.0;

   // Price location in the range
   PriceLocation = (MidPrice - LowestLow) / GreatestRange;
   PriceLocation = 2.0 * PriceLocation - 1.0;

   // Smooth price location
   ExtMapBuffer_PriceLocation[pos] = PriceSmoothing * ExtMapBuffer_PriceLocation[pos + 1] + (1.0 - PriceSmoothing) * PriceLocation;
   SmoothedLocation = ExtMapBuffer_PriceLocation[pos];

   if (SmoothedLocation > 0.99) SmoothedLocation = 0.99;
   if (SmoothedLocation < -0.99) SmoothedLocation = -0.99;

   // Calculate Fisher index
   FishIndex = MathLog((1.0 + SmoothedLocation) / (1.0 - SmoothedLocation));

   // Smooth Fisher index
   ExtMapBuffer_FisherIndex[pos] = IndexSmoothing * ExtMapBuffer_FisherIndex[pos + 1] + (1.0 - IndexSmoothing) * FishIndex;
   if (rates_total - pos < DrawStart)
      ExtMapBuffer_FisherIndex[pos] = 0;

   SmoothedFish = ExtMapBuffer_FisherIndex[pos];

   // Trend determination
   if (SmoothedFish > 0) {
      ExtMapBuffer_Uptrend[pos] = SmoothedFish;
      ExtMapBuffer_Downtrend[pos] = 0;
   } else {
      ExtMapBuffer_Uptrend[pos] = 0;
      ExtMapBuffer_Downtrend[pos] = SmoothedFish;
   }
   //Removed comment below for troubleshooting.. 
   //Print("Pos: ", pos, " Fisher Index: ", ExtMapBuffer_FisherIndex[pos], " Price Location: ", ExtMapBuffer_PriceLocation[pos], " DownTrend: ", ExtMapBuffer_Downtrend[pos], " UpTrend: ", ExtMapBuffer_Uptrend[pos]);
}
//+------------------------------------------------------------------+
