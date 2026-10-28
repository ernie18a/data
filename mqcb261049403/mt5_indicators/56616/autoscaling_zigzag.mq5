#property copyright "Evgeniy Chumakov | © Copyright 2024"
#property description "ZigZag with automatic step size detection for changing wave direction."
#property version "1.0"
#property link "https://www.mql5.com/en/users/jack857752"
#property strict
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   1

#property indicator_label1  "ZigZag"
#property indicator_type1   DRAW_COLOR_ZIGZAG
#property indicator_style1  STYLE_SOLID
#property indicator_color1  clrGray, clrViolet

input double ZZScale = 1.0; // Scale
input int ZZLineWidth = 2; // Line Width


double ArrayHighZZ[]; // High point ZZ
double ArrayLowZZ[];  // Low point ZZ
double ArrayTypeZZ[]; // ZigZag direction buffer
double ArrayHighBarZZ[]; // ZigZag maximum bar location
double ArrayLowBarZZ[];  // ZigZag minimum bar location
double ArrayHighLast[]; // Last maximum value
double ArrayLowLast[]; // Last minimum value
double ArrayLegCol[]; // Leg color

double SpecDivSymb = 1.0; // Special Divider / Symbol Correction


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

  IndicatorSetInteger(INDICATOR_DIGITS,Digits());
  IndicatorSetString(INDICATOR_SHORTNAME,"AutoScaleZigZag");

  int Find = StringFind(Symbol(),"JPY",0); //

  if(Find != -1) {
    SpecDivSymb = 100.0;
  } else {
    SpecDivSymb = 1.0;
  }

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

  // Checking for the minimum number of bars to calculate
  if(rates_total < 3) {
    return(0);
  }
  
  ArraySetAsSeries(open, true);
  ArraySetAsSeries(high, true);
  ArraySetAsSeries(low, true);
  ArraySetAsSeries(close, true);  

  // Checking and calculating the number of calculated bars
  int total = rates_total - 2;

  int limit = (prev_calculated == 0) ? rates_total : rates_total - prev_calculated + 1;

  if(limit > 1) {

    limit = total;

    ArrayInitialize(ArrayHighZZ,EMPTY_VALUE);
    ArrayInitialize(ArrayLowZZ,EMPTY_VALUE);
    ArrayInitialize(ArrayTypeZZ,EMPTY_VALUE);
    ArrayInitialize(ArrayHighBarZZ,EMPTY_VALUE);
    ArrayInitialize(ArrayLowBarZZ,EMPTY_VALUE);
    ArrayInitialize(ArrayHighLast,EMPTY_VALUE);
    ArrayInitialize(ArrayLowLast,EMPTY_VALUE);

    CalcStartingExtremes(rates_total,high,low); // Let's get the starting point for ZigZag
  }

  // Calculating the indicator
  //for(int i = 0; i <limit; i++) {  // will plot nothing with an incremental loop
  for(int i = limit-1; i >=0; i--) {
  
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
//+------------------------------------------------------------------+
//| Calculation High ZZ Point                                        |
//+------------------------------------------------------------------+
void HighZZPoint(const int index, const double &high[], const double &low[])
{

  double PriceHigh = high[index]; // Current maximum price value
  double PriceLow = low[index]; // Current minimum price value

  bool EventHigh = false; // High point ZZ update event
  bool EventLow = false; // Low point ZZ update event

  double R_Step = MathAbs((ArrayHighLast[index+1] - PriceLow)/PriceLow) * 100.0; // Price range in percent
  double StepDownLevel = PriceLow/SpecDivSymb/ZZScale; // Step to form a segment down

// Updating and redrawing the maximum extremum
  if(PriceHigh > ArrayHighLast[index+1]) {

    EventHigh = true;

    ArrayTypeZZ[index] = 1;
    int prev_high_index = (int)ArrayHighBarZZ[index+1];
    if(prev_high_index >= 0) ArrayHighZZ[prev_high_index] = EMPTY_VALUE;
    ArrayHighZZ[index] = PriceHigh;

    ArrayHighBarZZ[index] = index;
    ArrayLowBarZZ[index] = ArrayLowBarZZ[index+1];

    ArrayHighLast[index] = PriceHigh;
    ArrayLowLast[index] = ArrayLowLast[index+1];
    
    ArrayLegCol[index] = 1;   
  }
//--------------------------------------------------------//

// Creating and drawing the minimum extremum
  if(R_Step >= StepDownLevel && !EventHigh) {

    EventLow = true;

    ArrayTypeZZ[index] = -1;

    ArrayLowZZ[index] = PriceLow;

    ArrayLowLast[index] = PriceLow;
    ArrayHighLast[index] = ArrayHighLast[index+1];

    ArrayHighBarZZ[index] = ArrayHighBarZZ[index+1];
    ArrayLowBarZZ[index] = index;
    
    ArrayLegCol[index] = 0;
  }
//--------------------------------------------------------//

// No events for forming extremes. Copying past data.
  if(!EventHigh && !EventLow) {

    ArrayTypeZZ[index] = ArrayTypeZZ[index+1];

    ArrayHighBarZZ[index] = ArrayHighBarZZ[index+1];
    ArrayLowBarZZ[index] = ArrayLowBarZZ[index+1];

    ArrayHighLast[index] = ArrayHighLast[index+1];
    ArrayLowLast[index] = ArrayLowLast[index+1];
    
  }
//--------------------------------------------------------//

  return;
}
//+------------------------------------------------------------------+
//| Calculation Low ZZ Point                                         |
//+------------------------------------------------------------------+
void LowZZPoint(const int index, const double &high[], const double &low[])
{

  double PriceHigh = high[index]; // Current maximum price value
  double PriceLow = low[index]; // Current minimum price value

  bool EventLow = false; // High point ZZ update event
  bool EventHigh = false; // Low point ZZ update event


  double R_Step = MathAbs((ArrayLowLast[index+1] - PriceHigh)/PriceHigh) * 100.0; // Price range in percent
  double StepUpLevel = PriceHigh/SpecDivSymb/ZZScale; // Step to form a segment up
  

// Updating and redrawing the minimum extremum
  if(PriceLow < ArrayLowLast[index+1]) {

    EventLow = true;

    ArrayTypeZZ[index] = -1;
    int prev_low_index = (int)ArrayLowBarZZ[index+1];
    if(prev_low_index >= 0) ArrayLowZZ[prev_low_index] = EMPTY_VALUE;
    ArrayLowZZ[index] = PriceLow;

    ArrayLowBarZZ[index] = index;
    ArrayHighBarZZ[index] = ArrayHighBarZZ[index+1];

    ArrayHighLast[index] = ArrayHighLast[index+1];
    ArrayLowLast[index] = PriceLow;
    
    ArrayLegCol[index] = 0;
  }
//--------------------------------------------------------//

// Creating and drawing the maximum extremum
  if(R_Step >= StepUpLevel && !EventLow) {

    EventHigh = true;

    ArrayTypeZZ[index] = 1;

    ArrayHighZZ[index] = PriceHigh;

    ArrayHighLast[index] = PriceHigh;
    ArrayLowLast[index] = ArrayLowLast[index+1];

    ArrayHighBarZZ[index] = index;
    ArrayLowBarZZ[index] = ArrayLowBarZZ[index+1];
    
    ArrayLegCol[index] = 1;
  }
//--------------------------------------------------------//

// No events for forming extremes. Copying past data.
  if(!EventHigh && !EventLow) {

    ArrayTypeZZ[index] = ArrayTypeZZ[index+1];

    ArrayHighBarZZ[index] = ArrayHighBarZZ[index+1];
    ArrayLowBarZZ[index] = ArrayLowBarZZ[index+1];

    ArrayHighLast[index] = ArrayHighLast[index+1];
    ArrayLowLast[index] = ArrayLowLast[index+1];
  }
//--------------------------------------------------------//

  return;
}
//+------------------------------------------------------------------+
//| Calculation Of Starting Extremes                                 |
//+------------------------------------------------------------------+
int CalcStartingExtremes(int limit, const double &high[], const double &low[])
{

  int init_index = 0;


  for(int i = limit-1; i >=0; i--) {
  
    int period_start = i; // Measurement start position

    int MaxBar = ArrayMaximum(high,period_start,limit); // Position (bar) for the maximum price on the measurement interval.
    int MinBar = ArrayMinimum(low,period_start,limit); // Position (bar) for the minimum price on the measurement interval.

    double Max_Price = high[MaxBar]; // The value of the maximum price on the measured interval.
    double Min_Price = low[MinBar]; // The value of the minimum price on the measured interval.

    double R_Step = MathAbs((Max_Price - Min_Price)/Min_Price) * 100.0; // Price range in percent

    double StepUpLevel = Max_Price/SpecDivSymb/ZZScale; // Step to form a segment up
    double StepDownLevel = Min_Price/SpecDivSymb/ZZScale; // Step to form a segment down

// Formation of the maximum extremum
    if(MaxBar != MinBar && MaxBar < MinBar && R_Step >= StepUpLevel) {

      ArrayTypeZZ[period_start] = 1;

      ArrayHighZZ[MaxBar] = Max_Price;
      ArrayLowZZ[MinBar] = Min_Price;

      ArrayHighBarZZ[period_start] = MaxBar;
      ArrayLowBarZZ[period_start] = MinBar;

      ArrayHighLast[period_start] = Max_Price;
      ArrayLowLast[period_start] = Min_Price;

      init_index = period_start;
    }

    if(init_index != 0) {
      break;
    }
//--------------------------------------------------------//

// Formation of a minimum extremum
    if(MaxBar != MinBar && MinBar < MaxBar && R_Step >= StepDownLevel) {

      ArrayTypeZZ[period_start] = -1;

      ArrayHighZZ[MaxBar] = Max_Price;
      ArrayLowZZ[MinBar] = Min_Price;

      ArrayHighBarZZ[period_start] = MaxBar;
      ArrayLowBarZZ[period_start] = MinBar;

      ArrayHighLast[period_start] = Max_Price;
      ArrayLowLast[period_start] = Min_Price;

      init_index = period_start;
    }

    if(init_index != 0) {
      break;
    }
  }

  return(init_index);
}
