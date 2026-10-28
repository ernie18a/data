//+------------------------------------------------------------------+
//|                                      KCI Volatility Distance.mq5 |
//|                                    Copyright 2026, KCI Developer |
//|                          https://www.mql5.com/en/users/ritzfalih |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, KCI Developer"
#property link        "https://www.mql5.com/en/users/ritzfalih"
#property description "KCI Volatility Distance - Standalone All-in-One Engine"
#property indicator_separate_window

// --- Plot & Buffer ---
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "KCI-VD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

// --- Input ---
input group "=== KCI Volatility Settings ==="
input int KineticPeriod = 14;   // Calculation period (≥2)

// ===================================================================
//   KCI VOLATILITY DISTANCE CORE ENGINE (OOP EMBEDDED)
// ===================================================================
class CKCIVolatilityDistance
  {
private:
   int               m_kinetic_period;
   double            m_point;

public:
                     CKCIVolatilityDistance(void)
     {
      m_kinetic_period = 14;
      m_point          = _Point;
     }
                    ~CKCIVolatilityDistance(void) {}
   
   // Initialize safety parameters
   bool Init(const int period)
     {
      if(period < 2)
        {
         Print("[KCI VD Error] Period must be at least 2");
         return(false);
        }
      m_kinetic_period = period;
      m_point          = _Point;
      if(m_point <= 0) m_point = 0.00001; // Fallback if point is not detected early
      return(true);
     }
   
   // Core Calculation Functions - Optimized for high CPU performance
   double Calculate(const int index, 
                    const double &high[], 
                    const double &low[], 
                    const double &close[])
     {
      double sum_TR = 0.0;
      double sum_sq_TR = 0.0;
      double path_length = 0.0;

      // --- 1. Optimized Window Loop (Avoid Nested MathMax) ---
      for(int j = 0; j < m_kinetic_period; j++)
        {
         int curr_idx = index + j;
         
         double hl = high[curr_idx] - low[curr_idx];
         double hc = MathAbs(high[curr_idx] - close[curr_idx + 1]);
         double lc = MathAbs(low[curr_idx] - close[curr_idx + 1]);
         
         double tr = hl;
         if(hc > tr) tr = hc;
         if(lc > tr) tr = lc;
         
         sum_TR    += tr;
         sum_sq_TR += (tr * tr);

         if(j < m_kinetic_period - 1)
           {
            path_length += MathAbs(close[curr_idx] - close[curr_idx + 1]);
           }
        }

      // --- 2. Efficiency Ratio ---
      double net_distance = MathAbs(close[index] - close[index + m_kinetic_period - 1]);
      
      if(path_length < net_distance) path_length = net_distance; 
      if(path_length == 0.0)         path_length = m_point;      
      
      double efficiency_ratio = net_distance / path_length;

      // --- 3. Pure Mathematics Standard Deviation ---
      double mean_TR  = sum_TR / m_kinetic_period;
      double variance = (sum_sq_TR / m_kinetic_period) - (mean_TR * mean_TR);
      if(variance < 0.0) variance = 0.0; 
      
      double std_TR = MathSqrt(variance);

      // --- 4. Final Result of KCI VD Range Output ---
      return(std_TR * (2.0 - efficiency_ratio));
     }
  };

// --- Global Buffer & Object Instance ---
double KVR_Buffer[];
CKCIVolatilityDistance kci_engine;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Register the period into the internal engine
   if(!kci_engine.Init(KineticPeriod))
      return(INIT_PARAMETERS_INCORRECT);

   // Indicator Buffer Configuration
   SetIndexBuffer(0, KVR_Buffer, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   ArraySetAsSeries(KVR_Buffer, true);

   // Compact Visual Display Settings
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "KCI-VD(" + IntegerToString(KineticPeriod) + ")");

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
   // Protect the availability of early historical data
   if(rates_total < KineticPeriod + 2) return(0);

   // Force array index alignment as Series (Back to back)
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

   // Clear buffer on reinitialization
   if(prev_calculated == 0)
     {
      ArrayInitialize(KVR_Buffer, 0.0);
     }

   // Set bar iteration limit (Only calculate new bars to save CPU)
   int limit = (prev_calculated == 0) ? (rates_total - KineticPeriod - 2) : (rates_total - prev_calculated + 1);

   // Execute calculations through embedded engine instances
   for(int i = limit; i >= 0 && !IsStopped(); i--)
     {
      KVR_Buffer[i] = kci_engine.Calculate(i, high, low, close);
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+