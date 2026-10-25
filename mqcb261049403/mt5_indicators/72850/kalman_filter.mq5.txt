//+------------------------------------------------------------------+
//|                                                Kalman_Filter.mq5 |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

//--- Kalman Plot
#property indicator_label1  "Kalman True Price"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMagenta
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

input group "=== Kalman Filter Parameters ==="
input double InpProcessNoise     = 0.001; // Process Noise (System Uncertainty)
input double InpMeasurementNoise = 0.1;   // Measurement Noise (Market Volatility)

double ExtKalmanBuffer[];

// Internal State Variables
double error_covariance = 1.0;
double estimated_price  = 0.0;

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtKalmanBuffer, INDICATOR_DATA);
   
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "Inst Kalman Filter");
   
   Print("Institutional Kalman State Estimator Initialized.");
   return(INIT_SUCCEEDED);
  }

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
   if(rates_total < 2) return(0);

   int limit = prev_calculated;

   // Initialization on the first bar
   if(limit == 0)
     {
      estimated_price = close[0];
      error_covariance = 1.0;
      ExtKalmanBuffer[0] = estimated_price;
      limit = 1;
     }
   else
     {
      limit = prev_calculated - 1; 
     }

   for(int i = limit; i < rates_total; i++)
     {
      // 1. Prediction Update
      // In a simple 1D random walk price model, predicted state equals previous state
      double predicted_price = estimated_price;
      double predicted_covariance = error_covariance + InpProcessNoise;
      
      // 2. Measurement Update (Calculating the Kalman Gain)
      double kalman_gain = predicted_covariance / (predicted_covariance + InpMeasurementNoise);
      
      // 3. Estimating the True Price (State Update)
      estimated_price = predicted_price + kalman_gain * (close[i] - predicted_price);
      
      // 4. Updating Error Covariance for the next iteration
      error_covariance = (1.0 - kalman_gain) * predicted_covariance;
      
      ExtKalmanBuffer[i] = estimated_price;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+