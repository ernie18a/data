//+------------------------------------------------------------------+
//| Indicator : Bollinger Band Signal                                |
//| Version: v1.1                                                    |
//| Author:  BENALI                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, BENALI"
#property link      "https://www.mql5.com/en/users/dahmi_benali"
#property version   "1.1"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5

//--- Plot 1: Buy Signal
#property indicator_label1  "Buy Signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_width1  3

//--- Plot 2: Sell Signal
#property indicator_label2  "Sell Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_width2  3

//--- Plot 3: Bollinger Bands - Upper
#property indicator_label3  "BB Upper"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_width3  1

//--- Plot 4: Bollinger Bands - Middle
#property indicator_label4  "BB Middle"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSilver
#property indicator_width4  1

//--- Plot 5: Bollinger Bands - Lower
#property indicator_label5  "BB Lower"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGray
#property indicator_width5  1

//--- Input parameters
input int    BB_Period    = 20;              // Bollinger Bands Period
input double BB_Deviation = 2.0;             // Standard Deviation
input ENUM_APPLIED_PRICE BB_Price = PRICE_CLOSE; // Applied Price
input bool   Show_BBands  = true;            // Show Bollinger Bands

//--- Indicator buffers
double BuyBuffer[];
double SellBuffer[];
double BB_Upper[];
double BB_Middle[];
double BB_Lower[];

//--- Bollinger Bands handle
int bb_handle;

//--- Last signal tracking
// 0 = none, 1 = buy, -1 = sell
int last_signal = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                        |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Map buffers
   SetIndexBuffer(0, BuyBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SellBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, BB_Upper, INDICATOR_DATA);
   SetIndexBuffer(3, BB_Middle, INDICATOR_DATA);
   SetIndexBuffer(4, BB_Lower, INDICATOR_DATA);

//--- Set arrow symbols for buy/sell
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);

//--- Control Bollinger Bands visibility
   PlotIndexSetInteger(2, PLOT_SHOW_DATA, Show_BBands);
   PlotIndexSetInteger(3, PLOT_SHOW_DATA, Show_BBands);
   PlotIndexSetInteger(4, PLOT_SHOW_DATA, Show_BBands);

//--- Series direction
   ArraySetAsSeries(BuyBuffer, true);
   ArraySetAsSeries(SellBuffer, true);
   ArraySetAsSeries(BB_Upper, true);
   ArraySetAsSeries(BB_Middle, true);
   ArraySetAsSeries(BB_Lower, true);

//--- Create Bollinger Bands handle
   bb_handle = iBands(_Symbol, _Period, BB_Period, 0, BB_Deviation, BB_Price);
   if(bb_handle == INVALID_HANDLE)
     {
      Print("Error creating iBands handle");
      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator calculation function                           |
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
//--- Check minimum bars
   if(rates_total < BB_Period + 2)
      return 0;

   ArraySetAsSeries(close, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   int bars_to_copy = rates_total;

//--- Temporary arrays for BB values
   double upper[], middle[], lower[];
   ArraySetAsSeries(upper, true);
   ArraySetAsSeries(middle, true);
   ArraySetAsSeries(lower, true);

//--- Copy BB data:
//  Buffer 0 = Upper, Buffer 1 = Middle, Buffer 2 = Lower in MQL5's iBands
   if(CopyBuffer(bb_handle, 1, 0, rates_total, upper) <= 0 ||
      CopyBuffer(bb_handle, 0, 0, rates_total, middle) <= 0 ||
      CopyBuffer(bb_handle, 2, 0, rates_total, lower) <= 0)
     {
      Print("❌ Failed to copy Bollinger Bands data");
      return 0;
     }

//--- Determine calculation start index
   int start = rates_total - prev_calculated;
   if(start > rates_total - 2)
      start = rates_total - 2;

//--- Reset signal if first calculation
   if(prev_calculated == 0)
      last_signal = 0;

//--- Main loop
   for(int i = start; i >= 0; i--)
     {
      // Reset buffers
      BuyBuffer[i]  = EMPTY_VALUE;
      SellBuffer[i] = EMPTY_VALUE;

      //--- Set Bollinger Bands values if enabled
      if(Show_BBands)
        {
         BB_Upper[i]  = upper[i];
         BB_Middle[i] = middle[i];
         BB_Lower[i]  = lower[i];
        }
      else
        {
         BB_Upper[i]  = EMPTY_VALUE;
         BB_Middle[i] = EMPTY_VALUE;
         BB_Lower[i]  = EMPTY_VALUE;
        }

      //--- Buy signal: Close crosses above lower band
      if(last_signal != 1 &&
         close[i + 1] > lower[i + 1] && close[i] < lower[i])
        {
         BuyBuffer[i] = low[i] - 10 * _Point;
         last_signal = 1;
        }

      //--- Sell signal: Close crosses below upper band
      if (last_signal != -1 &&
          close[i + 1] < upper[i + 1] && close[i] > upper[i])
      {
         SellBuffer[i] = high[i] + 10 * _Point;
         last_signal = -1;
      }
     }

   return rates_total;
  }
//+------------------------------------------------------------------+
