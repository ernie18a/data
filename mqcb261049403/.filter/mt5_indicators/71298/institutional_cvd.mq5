//+------------------------------------------------------------------+
//|                                        Institutional_CVD.mq5     |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "1.01"
#property indicator_separate_window

// Precisamos de 2 buffers exatos: 1 para os valores, 1 para o índice de cores
#property indicator_buffers 2
#property indicator_plots   1

// --- CVD Histogram Plot
#property indicator_label1  "Cumulative Delta"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrSeaGreen, clrIndianRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

input group "=== CVD Settings ==="
input bool InpSessionReset = true; // Reset Delta at Daily Open

double ExtCvdBuffer[];
double ExtCvdColors[];

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtCvdBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtCvdColors, INDICATOR_COLOR_INDEX);
   
   IndicatorSetInteger(INDICATOR_DIGITS, 0);
   IndicatorSetString(INDICATOR_SHORTNAME, "Inst CVD Flow");
   
   Print("Institutional CVD V1.01 Initialized.");
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

   int limit = (prev_calculated == 0) ? 1 : prev_calculated - 1;
   if(limit >= rates_total) limit = rates_total - 1;

   for(int i = limit; i < rates_total; i++)
     {
      double current_vol = (double)tick_volume[i];
      double range = high[i] - low[i];
      double delta = 0;
      
      // Quantitative approximation of buy/sell aggression
      if(range > 0)
        {
         double buying_pressure = close[i] - low[i];
         double selling_pressure = high[i] - close[i];
         double pressure_ratio = (buying_pressure - selling_pressure) / range;
         delta = current_vol * pressure_ratio;
        }
      else
        {
         if(close[i] > open[i]) delta = current_vol;
         else if(close[i] < open[i]) delta = -current_vol;
        }

      // Check for Daily Session Reset
      bool is_new_day = false;
      if(InpSessionReset && i > 0)
        {
         MqlDateTime dt_curr, dt_prev;
         TimeToStruct(time[i], dt_curr);
         TimeToStruct(time[i-1], dt_prev);
         if(dt_curr.day != dt_prev.day) is_new_day = true;
        }

      // Accumulate Delta
      if(is_new_day || i == 0)
        {
         ExtCvdBuffer[i] = delta;
        }
      else
        {
         ExtCvdBuffer[i] = ExtCvdBuffer[i-1] + delta;
        }

      // Color Coding (0 = SeaGreen, 1 = IndianRed)
      if(ExtCvdBuffer[i] >= 0) ExtCvdColors[i] = 0; 
      else ExtCvdColors[i] = 1; 
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+