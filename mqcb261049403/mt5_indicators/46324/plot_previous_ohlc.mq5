//+------------------------------------------------------------------+
//|                                           Plot Previous OHLC.mq5 |
//|                             https://www.mql5.com/en/users/phade/ |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, https://www.mql5.com/en/users/phade/"
#property link      "https://www.mql5.com/en/users/phade/"
#property version   "1.02"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4
#property indicator_label1 "High"
#property indicator_label2 "Low"
#property indicator_label3 "Open"
#property indicator_label4 "Close"
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_type4 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2


// Define buffers
double HighBuffer[];
double LowBuffer[];
double OpenBuffer[];
double CloseBuffer[];

// global vars
datetime timeToUse;
ENUM_TIMEFRAMES prevTimeFrame = PERIOD_CURRENT;

// inputs  
input ENUM_TIMEFRAMES timeFrameSelector = PERIOD_D1; // Choose period to find the previous highs and lows
input color resistanceLineColor = clrDarkTurquoise; // Color of the previous highs
input color supportLineColor = clrDarkGray; // Color of the previous lows
input color candleOpenColor = clrLightGray; // Color of the previous candle open
input color candleCloseColor = clrPeachPuff; // Color of the previous candle close
input int shift = 0; // Shift

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   // Set the indicator label
   IndicatorSetString(INDICATOR_SHORTNAME, "PrevDayHighLow");

   // Create buffers
   SetIndexBuffer(0, HighBuffer);
   SetIndexBuffer(1, LowBuffer);
   SetIndexBuffer(2, OpenBuffer);   
   SetIndexBuffer(3, CloseBuffer);      
   PlotIndexSetInteger(0,PLOT_LINE_COLOR, resistanceLineColor);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR, supportLineColor);
   PlotIndexSetInteger(2,PLOT_LINE_COLOR, candleOpenColor);
   PlotIndexSetInteger(3,PLOT_LINE_COLOR, candleCloseColor);
                        
   timeToUse = iTime(_Symbol, timeFrameSelector, shift);
      
   return(INIT_SUCCEEDED);
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
                const int &spread[]){
          
      if(prev_calculated == 0){   
         ResetBuffers(); // initialize indicator buffers
      }     
      
      int start = (prev_calculated == 0) ? 1 : prev_calculated - 1;
                
      for (int i = start; i < rates_total; i++){
      
         HighBuffer[i] = prevDayHigh(timeToUse, timeFrameSelector);
         LowBuffer[i] = prevDayLow(timeToUse, timeFrameSelector);
         OpenBuffer[i] = prevDayOpen(timeToUse, timeFrameSelector);
         CloseBuffer[i] = prevDayClose(timeToUse, timeFrameSelector);
      }  
         
   return rates_total;
}
  
  
void ResetBuffers(){
   ArrayInitialize(HighBuffer, EMPTY_VALUE); 
   ArrayInitialize(LowBuffer, EMPTY_VALUE);  
   ArrayInitialize(OpenBuffer, EMPTY_VALUE); 
   ArrayInitialize(CloseBuffer, EMPTY_VALUE); 
}


double prevDayHigh(const datetime barShift, const ENUM_TIMEFRAMES timeFrame){

    int prevBar = iBarShift(_Symbol, timeFrame, barShift); // Get the bar index 
    double highPrice = iHigh(_Symbol, timeFrame, prevBar); // Get the high price
    
    return highPrice;
}

double prevDayLow(const datetime barShift, const ENUM_TIMEFRAMES timeFrame){

    int prevBar = iBarShift(_Symbol, timeFrame, barShift); // Get the bar index
    double lowPrice = iLow(_Symbol, timeFrame, prevBar); // Get the low price
    
    return lowPrice;
}

double prevDayOpen(const datetime barShift, const ENUM_TIMEFRAMES timeFrame){

    int prevBar = iBarShift(_Symbol, timeFrame, barShift); // Get the bar index
    double openPrice = iOpen(_Symbol, timeFrame, prevBar); // Get the open price 
    
    return openPrice;
}

double prevDayClose(const datetime barShift, const ENUM_TIMEFRAMES timeFrame){

    int prevBar = iBarShift(_Symbol, timeFrame, barShift); // Get the bar index
    double closePrice = iClose(_Symbol, timeFrame, prevBar); // Get the close price
    
    return closePrice;
}

