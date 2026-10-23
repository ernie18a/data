//+------------------------------------------------------------------+
//|                     Non lagging ZigZag based on PSAR             |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 2
#property version "2.0"

#property indicator_type1 DRAW_COLOR_ARROW
#property indicator_color1 clrGreen, clrRed

#property indicator_type2 DRAW_ZIGZAG
#property indicator_color2 clrSilver
#property indicator_width2 2

input int Backstep = 4;       // Back step
input int Forwardstep = 2;       // Forward step
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
   
  const int bs = Backstep;
  const int fs = Forwardstep;

  for (int i = start; i < rates_total; i++){
  
    SarCol[i] = (PSAR[i] > close[i]) ? 1 : 0;
  }

  int begin =  (prev_calculated == 0) ? MathMax(fs,bs) : prev_calculated - bs;
  
  for (int i = begin; i < rates_total; i++){
  
    ZigzagStart[i] = EMPTY_VALUE;
    ZigzagEnd[i] = EMPTY_VALUE;

    double Low = low[i];
    double High = high[i];

    // Backstep logic to find the highest high and lowest low within the Backstep range (before the swing)
    for (int j = 1; j <= bs && i > 50; j++){
    
      if (high[i - j] > High) High = high[i - j];
      if (low[i - j] < Low) Low = low[i - j];
    }
    
    // Forwardstep logic to find the highest high and lowest low within the Forwardstep range (after the swing)
    for (int j = 1; j <= fs && (i + j) < rates_total; j++){
    
      if (high[i + j] > High) High = high[i + j];
      if (low[i + j] < Low) Low = low[i + j];
    }    

    if(i+fs < rates_total){
    
       // State machine for cycle detection
       switch (currentState) {
       
       case NONE:
         if (PSAR[i] > high[i]) {  // Bearish Trend (PSAR selling)
             LL = High;
             if(high[i] == LL) ZigzagStart[i] = LL; // the new LL will link from the current high or from the most recent resistance
             else if(high[i+fs] > high[i]) ZigzagStart[i+fs] = LL;
             else ZigzagStart[i-bs] = LL;
             lastLowSwing[i] = LL;
             lastHighSwing[i] = EMPTY_VALUE;
             currentState = LL_FOUND;
             lastSwingPrice = lastLowSwing[i];
             swing_index = i;
   
         }
         else{
           ZigzagStart[i] = High;
            for (int k = 1; k <= bs; k++)
                ZigzagStart[i - k] = EMPTY_VALUE;
         }
         break;
   
       case LL_FOUND:
         if (PSAR[i] < low[i]) {  // Bullish Trend (PSAR buying)
    
             HL = Low;
             if(low[i] == HL) ZigzagEnd[i] = HL; // the new HL will link from the current low or from the most recent support
             else if(low[i+fs] < low[i]) ZigzagEnd[i+fs] = HL;
             else ZigzagEnd[i-bs] = HL;
             lastHighSwing[i] = HL;
             lastLowSwing[i] = EMPTY_VALUE;
             currentState = HL_FOUND;
             lastSwingPrice = lastHighSwing[i];
             swing_index = i;
           
         }
         else{
           ZigzagEnd[i] = Low;
            for (int k = 1; k <= bs; k++)
                ZigzagEnd[i - k] = EMPTY_VALUE;
         }
         break;
   
       case HL_FOUND:
         if (PSAR[i] > high[i]) {  // Bearish Trend (PSAR selling)
             LH = High;
             if(high[i] == LH) ZigzagStart[i] = LH; // the new LH will link from the current high or from the most recent resistance
             else if(high[i+fs] > high[i]) ZigzagStart[i+fs] = LH;
             else ZigzagStart[i-bs] = LH;
             lastLowSwing[i] = LH;
             lastHighSwing[i] = EMPTY_VALUE;
             currentState = LH_FOUND;
             lastSwingPrice = lastLowSwing[i];
             swing_index = i;
         
         }
         else{
           ZigzagStart[i] = High;
            for (int k = 1; k <= bs; k++)
                ZigzagStart[i - k] = EMPTY_VALUE;
         }
         break;
   
       case LH_FOUND:
         if (PSAR[i] < low[i]) {  // Bullish Trend (PSAR buying)
             HH = Low;
             if(low[i] == HH) ZigzagEnd[i] = HH; // the new HH will link from the current low or from the most recent support
            else if(low[i+fs] < low[i]) ZigzagEnd[i+fs] = HH;
             else ZigzagEnd[i-bs] = HH;
             lastHighSwing[i] = HH;
             lastLowSwing[i] = EMPTY_VALUE;
             currentState = HH_FOUND;
             lastSwingPrice = lastHighSwing[i];
             swing_index = i;
        
         }
         else{
           ZigzagEnd[i] = Low;
            for (int k = 1; k <= bs; k++)
                ZigzagEnd[i - k] = EMPTY_VALUE;
   
         }
         break;
   
       case HH_FOUND:
         currentState = NONE; // Reset cycle
         break;
       }
 
    }
  }

  return rates_total;
}