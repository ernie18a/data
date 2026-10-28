//+------------------------------------------------------------------+
//|                     Non lagging ZigZag based on PSAR             |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 2
#property version "1.1"

#property indicator_type1 DRAW_COLOR_ARROW
#property indicator_color1 clrGreen, clrRed

#property indicator_type2 DRAW_ZIGZAG
#property indicator_color2 clrSilver
#property indicator_width2 2

input int Backstep = 3;       // Backstep
input double SARStep = 0.01;  // SAR Step value
input double SARMaximum = 0.1; // SAR Maximum value

double ZigzagStart[], ZigzagEnd[], PrevLegEnd[], PSAR[], SarCol[];
double lastHighSwing[], lastLowSwing[];

int sarHandle = INVALID_HANDLE;

double LL = 0, HL = 0, LH = 0, HH = 0;

double lastSwingPrice = 0;

// Enum to track ZigZag cycle
enum ZigZagState
{
  NONE,
  LL_FOUND,
  HL_FOUND,
  LH_FOUND,
  HH_FOUND
};

ZigZagState currentState = NONE;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  SetIndexBuffer(0, PSAR, INDICATOR_DATA);
  SetIndexBuffer(1, SarCol, INDICATOR_COLOR_INDEX);
  SetIndexBuffer(2, ZigzagStart, INDICATOR_DATA);
  SetIndexBuffer(3, ZigzagEnd, INDICATOR_DATA);
  SetIndexBuffer(4, lastHighSwing, INDICATOR_CALCULATIONS);
  SetIndexBuffer(5, lastLowSwing, INDICATOR_CALCULATIONS);

  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

  sarHandle = iSAR(_Symbol, _Period, SARStep, SARMaximum);

  if (sarHandle == INVALID_HANDLE) {
    Print("Failed to create SAR handle");
    return INIT_FAILED;
  }

  return INIT_SUCCEEDED;
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
                const int &spread[])
{

  int to_copy = (prev_calculated > 0) ? (rates_total - prev_calculated + 1) : rates_total;
  
  if (CopyBuffer(sarHandle, 0, 0, to_copy, PSAR) <= 0) return rates_total;

  int start = (prev_calculated == 0) ? 50 : prev_calculated - 1;

  static int swing_index = 0;
  int confirmCount = 0;  // counter for confirming a new trend

  for (int i = start; i < rates_total; i++){
  
    SarCol[i] = (PSAR[i] > close[i]) ? 1 : 0;
  }

  for (int i = start + 1; i < rates_total; i++){
  
    ZigzagStart[i] = EMPTY_VALUE;
    ZigzagEnd[i] = EMPTY_VALUE;

    double Low = low[i];
    double High = high[i];

    // Backstep logic to find the highest high and lowest low within the Backstep range
    for (int j = 1; j <= Backstep && i > 50; j++){
    
      if (high[i - j] > High) High = high[i - j];
      if (low[i - j] < Low) Low = low[i - j];
    }

    // State machine for cycle detection
    switch (currentState) {
    
    case NONE:
      if (PSAR[i] > close[i]) {  // Bearish Trend (PSAR selling)
          LL = High;
          ZigzagStart[i] = LL; // the new LL will link from the current high or from the most recent resistance
          lastLowSwing[i] = LL;
          lastHighSwing[i] = EMPTY_VALUE;
          currentState = LL_FOUND;
          lastSwingPrice = lastLowSwing[i];
          swing_index = i;

      }
      else{
        ZigzagStart[i] = High;
        ZigzagStart[i-1] = EMPTY_VALUE;
      }
      break;

    case LL_FOUND:
      if (PSAR[i] < close[i]) {  // Bullish Trend (PSAR buying)
 
          HL = Low;
          ZigzagEnd[i] = HL; // the new HL will link from the current low or from the most recent support
          lastHighSwing[i] = HL;
          lastLowSwing[i] = EMPTY_VALUE;
          currentState = HL_FOUND;
          lastSwingPrice = lastHighSwing[i];
          swing_index = i;
        
      }
      else{
        ZigzagEnd[i] = Low;
        ZigzagEnd[i-1] = EMPTY_VALUE;
      }
      break;

    case HL_FOUND:
      if (PSAR[i] > close[i]) {  // Bearish Trend (PSAR selling)
          LH = High;
          ZigzagStart[i] = LH; // the new LH will link from the current high or from the most recent resistance
          lastLowSwing[i] = LH;
          lastHighSwing[i] = EMPTY_VALUE;
          currentState = LH_FOUND;
          lastSwingPrice = lastLowSwing[i];
          swing_index = i;
      
      }
      else{
        ZigzagStart[i] = High;
        ZigzagStart[i-1] = EMPTY_VALUE;
      }
      break;

    case LH_FOUND:
      if (PSAR[i] < close[i]) {  // Bullish Trend (PSAR buying)
          HH = Low;
          ZigzagEnd[i] = HH; // the new HH will link from the current low or from the most recent support
          lastHighSwing[i] = HH;
          lastLowSwing[i] = EMPTY_VALUE;
          currentState = HH_FOUND;
          lastSwingPrice = lastHighSwing[i];
          swing_index = i;
     
      }
      else{
        ZigzagEnd[i] = Low;
        ZigzagEnd[i-1] = EMPTY_VALUE;
      }
      break;

    case HH_FOUND:
      currentState = NONE; // Reset cycle
      break;
    }
  }

  return rates_total;
}