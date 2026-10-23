//+------------------------------------------------------------------+
//|                                            Kinematic_Physics.mq5 |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2

//--- Velocity Plot (1st Derivative)
#property indicator_label1  "Velocity (dP/dt)"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrSeaGreen, clrIndianRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Acceleration Plot (2nd Derivative)
#property indicator_label2  "Acceleration (dV/dt)"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGold
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- Zero Line
#property indicator_level1  0.0
#property indicator_levelcolor clrDimGray
#property indicator_levelstyle STYLE_DOT

input group "=== Kinematic Calculus Settings ==="
input int InpTimeStep = 3; // Differential Time Step (dt)

double ExtVelocityBuffer[];
double ExtColorBuffer[];
double ExtAccelerationBuffer[];

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtVelocityBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, ExtAccelerationBuffer, INDICATOR_DATA);
   
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "Inst Kinematics (dt=" + IntegerToString(InpTimeStep) + ")");
   
   Print("Institutional Kinematic Physics Engine Initialized.");
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
   // Require enough data for the 2nd derivative calculation
   if(rates_total < (InpTimeStep * 2) + 1) return(0);

   int limit = (prev_calculated == 0) ? (InpTimeStep * 2) : prev_calculated - 1;

   for(int i = limit; i < rates_total; i++)
     {
      // 1. Calculate Velocity (First Derivative): V = (P[t] - P[t-dt]) / dt
      double current_price = close[i];
      double past_price = close[i - InpTimeStep];
      double velocity = (current_price - past_price) / InpTimeStep;
      
      ExtVelocityBuffer[i] = velocity;
      
      // Color coding for Velocity Histogram
      if(velocity > 0) ExtColorBuffer[i] = 0; // SeaGreen
      else ExtColorBuffer[i] = 1; // IndianRed

      // 2. Calculate Acceleration (Second Derivative): A = (V[t] - V[t-dt]) / dt
      double past_velocity = (close[i - InpTimeStep] - close[i - (InpTimeStep * 2)]) / InpTimeStep;
      double acceleration = (velocity - past_velocity) / InpTimeStep;
      
      ExtAccelerationBuffer[i] = acceleration;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+