//+------------------------------------------------------------------+
//|                                    RSI_Price_Action_Breakout.mq5 |
//|                      Copyright 2026, Amanda V. Software Engineer |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Amanda V. - Algo Architect"
#property link      "https://www.mql5.com/en/users/kayruyuta"
#property version   "10.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- Plot Settings
#property indicator_label1  "Bearish Breakout"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Bullish Breakout"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrLime
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- Input Parameters
input int      InpRSIPeriod = 14;   // RSI Period
input double   InpRSIOverbought = 70.0; // Overbought Level (Sell Zone)
input double   InpRSIOversold  = 30.0; // Oversold Level (Buy Zone)

//--- Global Buffers
double         SellBuffer[];
double         BuyBuffer[];
int            handle_rsi;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// Buffer Mapping
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);

// Visual Attributes
   PlotIndexSetInteger(0,PLOT_ARROW,234); // Arrow Down Code
   PlotIndexSetInteger(1,PLOT_ARROW,233); // Arrow Up Code

// Empty Values initialization
   ArrayInitialize(SellBuffer,EMPTY_VALUE);
   ArrayInitialize(BuyBuffer,EMPTY_VALUE);

// Indicator Handles
   handle_rsi = iRSI(NULL,0,InpRSIPeriod,PRICE_CLOSE);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("Failed to create RSI handle");
      return(INIT_FAILED);
     }

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
                const int &spread[])
  {
// Data sufficiency check
   if(rates_total < InpRSIPeriod + 2)
      return(0);

   int start = prev_calculated - 1;
   if(start < 2)
      start = 2;

// RSI Buffer Copy
   double rsi_values[];
   ArraySetAsSeries(rsi_values,true); // Index 0 is the newest

   if(CopyBuffer(handle_rsi,0,0,rates_total,rsi_values) <= 0)
      return(0);

// Main Logic Loop
   for(int i=start; i<rates_total; i++)
     {
      // Index Mapping for OnCalculate (Default: Left to Right)
      // Logic targets the completed candle at [i-1] based on setup at [i-2]

      // 1. Retrieve RSI relative to the current loop index
      // Since rsi_values is AsSeries, we need to map correctly or use simple iRSI equivalent logic
      // Ideally for optimization we align indexes. Here we assume generic access.

      // Simplified logic for visual backtest
      double current_rsi = rsi_values[rates_total-1-i];

      // Candle Definitions
      double open_prev = open[i-2];
      double close_prev = close[i-2];
      double low_prev = low[i-2];
      double high_prev = high[i-2];

      double open_curr = open[i-1];
      double close_curr = close[i-1];

      // --- BEARISH SETUP (PUT) ---
      bool is_overbought = current_rsi >= InpRSIOverbought;
      bool prev_was_green = close_prev > open_prev;
      bool curr_is_red = close_curr < open_curr;
      bool breakout_low = close_curr < low_prev; // The key breakout

      if(is_overbought && prev_was_green && curr_is_red && breakout_low)
        {
         SellBuffer[i-1] = high[i-1] + 10 * Point();
        }
      else
        {
         SellBuffer[i-1] = EMPTY_VALUE;
        }

      // --- BULLISH SETUP (CALL) ---
      bool is_oversold = current_rsi <= InpRSIOversold;
      bool prev_was_red = close_prev < open_prev;
      bool curr_is_green = close_curr > open_curr;
      bool breakout_high = close_curr > high_prev;

      if(is_oversold && prev_was_red && curr_is_green && breakout_high)
        {
         BuyBuffer[i-1] = low[i-1] - 10 * Point();
        }
      else
        {
         BuyBuffer[i-1] = EMPTY_VALUE;
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
