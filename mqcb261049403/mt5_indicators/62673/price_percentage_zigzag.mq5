#property copyright "Zigzag structure by Evgeniy Chumakov | MT5 indicator by Phade | 2025"
#property link "https://www.mql5.com/en/users/jack857752"
#property description "Zigzag which changes wave direction based on price percentage change on the security"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   1

#property indicator_label1  "ZigZag"
#property indicator_type1   DRAW_COLOR_ZIGZAG
#property indicator_style1  STYLE_SOLID
#property indicator_color1  clrGray, clrDarkOrange

input double ZZPercent = 0.5; // Price Percentage Change
input int ZZLineWidth = 2; // Line Width


double ArrayHighZZ[]; // High point ZZ
double ArrayLowZZ[];  // Low point ZZ
double ArrayTypeZZ[]; // ZigZag direction buffer
double ArrayHighBarZZ[]; // ZigZag maximum bar location
double ArrayLowBarZZ[];  // ZigZag minimum bar location
double ArrayHighLast[]; // Last maximum value
double ArrayLowLast[]; // Last minimum value
double ArrayLegCol[]; // Leg color

int OnInit()
{
  SetIndexBuffer(0,ArrayHighZZ,INDICATOR_DATA);
  SetIndexBuffer(1,ArrayLowZZ,INDICATOR_DATA);
  SetIndexBuffer(2,ArrayLegCol,INDICATOR_COLOR_INDEX);
  SetIndexBuffer(3,ArrayTypeZZ,INDICATOR_CALCULATIONS);
  SetIndexBuffer(4,ArrayHighBarZZ,INDICATOR_CALCULATIONS);
  SetIndexBuffer(5,ArrayLowBarZZ,INDICATOR_CALCULATIONS);
  SetIndexBuffer(6,ArrayHighLast,INDICATOR_CALCULATIONS);
  SetIndexBuffer(7,ArrayLowLast,INDICATOR_CALCULATIONS);
     
  ArraySetAsSeries(ArrayHighZZ, true);
  ArraySetAsSeries(ArrayLowZZ, true);
  ArraySetAsSeries(ArrayTypeZZ, true);
  ArraySetAsSeries(ArrayHighBarZZ, true);
  ArraySetAsSeries(ArrayLowBarZZ, true);
  ArraySetAsSeries(ArrayHighLast, true);
  ArraySetAsSeries(ArrayLowLast, true);
  ArraySetAsSeries(ArrayLegCol, true);

  PlotIndexSetString(0,PLOT_LABEL,"High Point ZZ;Low Point ZZ");
  PlotIndexSetInteger(0, PLOT_LINE_WIDTH, ZZLineWidth);

  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
  IndicatorSetString(INDICATOR_SHORTNAME,"AutoScaleZigZag");


  return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

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
                const int &spread[])
{

  if(rates_total < 3) {
  
    return prev_calculated;
  }
  
  ArraySetAsSeries(open, true);
  ArraySetAsSeries(high, true);
  ArraySetAsSeries(low, true);
  ArraySetAsSeries(close, true);  

  int total = rates_total - 2;

  int limit = total;
 
  if(prev_calculated == 0){
  
    limit = rates_total;
  
    ArrayInitialize(ArrayHighZZ,EMPTY_VALUE);
    ArrayInitialize(ArrayLowZZ,EMPTY_VALUE);
    ArrayInitialize(ArrayTypeZZ,EMPTY_VALUE);
    ArrayInitialize(ArrayHighBarZZ,EMPTY_VALUE);
    ArrayInitialize(ArrayLowBarZZ,EMPTY_VALUE);
    ArrayInitialize(ArrayHighLast,EMPTY_VALUE);
    ArrayInitialize(ArrayLowLast,EMPTY_VALUE);  
  }
  else{
  
   limit = rates_total - prev_calculated + 1; 
  }  
  
  
   if(limit > 1){

    limit = total;

    CalcStartingExtremes(limit,high,low); // starting point for ZigZag
  } 

  // Calculating the indicator
  for(int i = limit; i >=0; i--) {
  
    ArrayHighZZ[i] = EMPTY_VALUE;
    ArrayLowZZ[i] = EMPTY_VALUE;

      if(ArrayTypeZZ[i + 1] != EMPTY_VALUE && ArrayTypeZZ[i + 1] > 0) {
        HighZZPoint(i,high,low);
      }
      if(ArrayTypeZZ[i + 1] != EMPTY_VALUE && ArrayTypeZZ[i + 1] < 0) {
        LowZZPoint(i,high,low);
      }
  }

  return(rates_total);
}



void HighZZPoint(const int index, const double &high[], const double &low[])
{
  double PriceHigh = high[index];
  double PriceLow = low[index];

  bool EventHigh = false;
  bool EventLow = false;

  double R_Step = MathAbs((ArrayHighLast[index + 1] - PriceLow) / ArrayHighLast[index + 1]) * 100.0;
  
  if (PriceHigh > ArrayHighLast[index + 1])
  {
    EventHigh = true;

    ArrayTypeZZ[index] = 1;

    int prev_high_index = (int)ArrayHighBarZZ[index + 1];
    if (prev_high_index >= 0)
      ArrayHighZZ[prev_high_index] = EMPTY_VALUE;

    ArrayHighZZ[index] = PriceHigh;

    ArrayHighBarZZ[index] = index;
    ArrayLowBarZZ[index] = ArrayLowBarZZ[index + 1];

    ArrayHighLast[index] = PriceHigh;
    ArrayLowLast[index] = ArrayLowLast[index + 1];

    ArrayLegCol[index] = 1;
  }

  if (R_Step >= ZZPercent && !EventHigh)
  {
    EventLow = true;

    ArrayTypeZZ[index] = -1;

    ArrayLowZZ[index] = PriceLow;

    ArrayLowLast[index] = PriceLow;
    ArrayHighLast[index] = ArrayHighLast[index + 1];

    ArrayHighBarZZ[index] = ArrayHighBarZZ[index + 1];
    ArrayLowBarZZ[index] = index;

    ArrayLegCol[index] = 0;
  }

  if (!EventHigh && !EventLow)
  {
    ArrayTypeZZ[index] = ArrayTypeZZ[index + 1];

    ArrayHighBarZZ[index] = ArrayHighBarZZ[index + 1];
    ArrayLowBarZZ[index] = ArrayLowBarZZ[index + 1];

    ArrayHighLast[index] = ArrayHighLast[index + 1];
    ArrayLowLast[index] = ArrayLowLast[index + 1];
  }
}



void LowZZPoint(const int index, const double &high[], const double &low[])
{
  double PriceHigh = high[index];
  double PriceLow = low[index];

  bool EventLow = false;
  bool EventHigh = false;

  double R_Step = MathAbs((ArrayLowLast[index + 1] - PriceHigh) / ArrayLowLast[index + 1]) * 100.0;

  if (PriceLow < ArrayLowLast[index + 1])
  {
    EventLow = true;

    ArrayTypeZZ[index] = -1;

    int prev_low_index = (int)ArrayLowBarZZ[index + 1];
    if (prev_low_index >= 0)
      ArrayLowZZ[prev_low_index] = EMPTY_VALUE;

    ArrayLowZZ[index] = PriceLow;

    ArrayLowBarZZ[index] = index;
    ArrayHighBarZZ[index] = ArrayHighBarZZ[index + 1];

    ArrayHighLast[index] = ArrayHighLast[index + 1];
    ArrayLowLast[index] = PriceLow;

    ArrayLegCol[index] = 0;
  }

  if (R_Step >= ZZPercent && !EventLow)
  {
    EventHigh = true;

    ArrayTypeZZ[index] = 1;

    ArrayHighZZ[index] = PriceHigh;

    ArrayHighLast[index] = PriceHigh;
    ArrayLowLast[index] = ArrayLowLast[index + 1];

    ArrayHighBarZZ[index] = index;
    ArrayLowBarZZ[index] = ArrayLowBarZZ[index + 1];

    ArrayLegCol[index] = 1;
  }

  if (!EventHigh && !EventLow)
  {
    ArrayTypeZZ[index] = ArrayTypeZZ[index + 1];

    ArrayHighBarZZ[index] = ArrayHighBarZZ[index + 1];
    ArrayLowBarZZ[index] = ArrayLowBarZZ[index + 1];

    ArrayHighLast[index] = ArrayHighLast[index + 1];
    ArrayLowLast[index] = ArrayLowLast[index + 1];
  }
}


//+------------------------------------------------------------------+
//| Calculation Of Starting Extremes (Percentage-Based Only)        |
//+------------------------------------------------------------------+
int CalcStartingExtremes(int limit, const double &high[], const double &low[])
{
   int init_index = 0;

   for(int i = limit - 1; i >= 0; i--)
   {
      int period_start = i;

      int maxBar = ArrayMaximum(high, period_start, limit);
      int minBar = ArrayMinimum(low,  period_start, limit);

      double maxPrice = high[maxBar];
      double minPrice = low[minBar];

      if(minPrice == 0.0) continue;  // avoid division by zero

      double rangePercent = MathAbs((maxPrice - minPrice) / minPrice) * 100.0;

      // Check for bullish leg (up from max to min)
      if(maxBar != minBar && maxBar < minBar && rangePercent >= ZZPercent)
      {
         ArrayTypeZZ[period_start]    = 1;
         ArrayHighZZ[maxBar]          = maxPrice;
         ArrayLowZZ[minBar]           = minPrice;
         ArrayHighBarZZ[period_start] = maxBar;
         ArrayLowBarZZ[period_start]  = minBar;
         ArrayHighLast[period_start]  = maxPrice;
         ArrayLowLast[period_start]   = minPrice;
         init_index = period_start;
         break;
      }

      // Check for bearish leg (down from min to max)
      if(maxBar != minBar && minBar < maxBar && rangePercent >= ZZPercent)
      {
         ArrayTypeZZ[period_start]    = -1;
         ArrayHighZZ[maxBar]          = maxPrice;
         ArrayLowZZ[minBar]           = minPrice;
         ArrayHighBarZZ[period_start] = maxBar;
         ArrayLowBarZZ[period_start]  = minBar;
         ArrayHighLast[period_start]  = maxPrice;
         ArrayLowLast[period_start]   = minPrice;
         init_index = period_start;
         break;
      }
   }

   return init_index;
}
