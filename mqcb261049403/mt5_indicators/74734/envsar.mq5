//+------------------------------------------------------------------+
//|                                                       EnvSar.mq5 |
//|                        Copyright 2026, Amarnath Kondiyan Mohan . |
//|     https://www.linkedin.com/in/amarnath-kondiyan-mohan-546293a/ |
//+------------------------------------------------------------------+
#property copyright "Amarnath Kondiyan Mohan"
#property link      "https://www.linkedin.com/in/amarnath-kondiyan-mohan-546293a/"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  Lime      // UpLevel
#property indicator_width1  2
#property indicator_label1  "UpLevel"

#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  Red       // DownLevel
#property indicator_width2  2
#property indicator_label2  "DownLevel"

#property indicator_level1     0.5
#property indicator_level2    -0.5
#property indicator_level3     1.5
#property indicator_level4    -1.5
#property indicator_level5     2.5
#property indicator_level6    -2.5

//---- indicator buffers
double UpLevelBuffer[];
double DownLevelBuffer[];

//-- Input parameters (Validator will try to break these)
input int            envPeriod    = 14;          // Envelopes Period
input double         envDeviation = 0.1;         // Envelopes Deviation (%)
input ENUM_MA_METHOD envMethod    = MODE_SMA;    // Envelopes MA Method
input double         pstep        = 0.02;        // SAR step
input double         pMax         = 0.2;         // SAR maximum

//-- Internal Validated Parameters
int    val_envPeriod;
double val_envDeviation;
double val_pstep;
double val_pMax;
ENUM_MA_METHOD val_envMethod;

//-- Handles for technical indicators
int sarHandle;
int envHandle;

//-- Array to store indicator values
double sarPart[];
double upperPart[], lowerPart[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//-- 1. Silently Correct Invalid Input Parameters
// If the validator feeds garbage, fallback to safe default values
   val_envPeriod    = (envPeriod < 1) ? 14 : envPeriod;
   val_envDeviation = (envDeviation < 0) ? 0.1 : envDeviation;
   val_pstep        = (pstep <= 0) ? 0.02 : pstep;
   val_pMax         = (pMax <= 0) ? 0.2 : pMax;
   
// Ensure the ENUM is within valid standard MA bounds
   val_envMethod    = envMethod;
   if(val_envMethod < 0 || val_envMethod > 3) 
      val_envMethod = MODE_SMA;

//-- 2. Set indicator buffers
   SetIndexBuffer(0, UpLevelBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, DownLevelBuffer, INDICATOR_DATA);

//-- 3. Create indicator handles using the VALIDATED parameters
   envHandle = iEnvelopes(_Symbol, _Period, val_envPeriod, 0, val_envMethod, PRICE_CLOSE, val_envDeviation);
   sarHandle = iSAR(_Symbol, _Period, val_pstep, val_pMax);

//-- 4. Check for invalid handles
   if(sarHandle == INVALID_HANDLE || envHandle == INVALID_HANDLE)
     {
      Print("iEnvelopes handle=", envHandle, " iSAR handle=", sarHandle, " err=", GetLastError());
      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(sarHandle != INVALID_HANDLE)
      IndicatorRelease(sarHandle);
   if(envHandle != INVALID_HANDLE)
      IndicatorRelease(envHandle);
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
// Ensure enough bars exist for calculation (Using validated period)
   if(rates_total < val_envPeriod)
      return(0);

// Enforce true timeseries indexing (0 is current live bar)
   ArraySetAsSeries(UpLevelBuffer, true);
   ArraySetAsSeries(DownLevelBuffer, true);
   ArraySetAsSeries(sarPart, true);
   ArraySetAsSeries(upperPart, true);
   ArraySetAsSeries(lowerPart, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(close, true);

// Determine limit of bars to recalculate
   int limit = rates_total - prev_calculated;
   if(limit > 0)
     {
      limit = rates_total - 1; // Full history calculation
     }
   else
     {
      limit = 1; // Real-time single tick update
     }

// Copy buffer data (Envelopes: Upper band = 0, Lower band = 1)
   if(CopyBuffer(sarHandle, 0, 0, rates_total, sarPart) < 0)
      return(0);
   if(CopyBuffer(envHandle, 0, 0, rates_total, upperPart) < 0)
      return(0);
   if(CopyBuffer(envHandle, 1, 0, rates_total, lowerPart) < 0)
      return(0);

// Loop from old history down to the live bar (index 0)
   for(int i = limit; i >= 0; i--)
     {
      UpLevelBuffer[i] = EMPTY_VALUE;
      DownLevelBuffer[i] = EMPTY_VALUE;

      if(sarPart[i] == EMPTY_VALUE || upperPart[i] == EMPTY_VALUE || lowerPart[i] == EMPTY_VALUE)
         continue;

      // Calculate the width of the envelope channel
      double envWidth = MathAbs(upperPart[i] - lowerPart[i]);
      if(envWidth == 0.0)
         envWidth = _Point;

      double minOC = MathMin(open[i], close[i]);
      double maxOC = MathMax(open[i], close[i]);

      double invEnvWidth = 1.0 / envWidth;
      double upLevel = (minOC - sarPart[i]) * invEnvWidth;
      double downLevel = (maxOC - sarPart[i]) * invEnvWidth;

      if(upLevel > 0)
         UpLevelBuffer[i] = upLevel;
      else
         if(downLevel < 0)
            DownLevelBuffer[i] = downLevel;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+