//+------------------------------------------------------------------+
//|                                                   CPDEngine.mqh  |
//|                      BGC Grid Trading EA — Change Point Detection|
//|                      CUSUM (Cumulative Sum Control Chart)        |
//|                      Online O(1)-per-bar mean shift detector     |
//+------------------------------------------------------------------+
#property copyright "Muhammad Minhas Qamar - MMQ"
#property strict

#ifndef __CPD_ENGINE_MQH__
#define __CPD_ENGINE_MQH__

//+------------------------------------------------------------------+
//| CCPDEngine — CUSUM-based regime change detection                 |
//|   Observation feed: MA slope (drift) from VolatilityGate          |
//|   Detects sustained mean shifts in drift magnitude                |
//|   Complementary to VolatilityGate — confirmation signal only      |
//+------------------------------------------------------------------+
class CCPDEngine
{
private:
   bool              m_enabled;
   int               m_windowSize;     // Baseline estimation window (bars)
   double            m_delta;          // Min detectable shift (× baseline σ)
   double            m_threshold;      // CUSUM threshold h

   //--- CUSUM accumulators
   double            m_sHigh;          // Upward CUSUM
   double            m_sLow;           // Downward CUSUM
   double            m_peakSHigh;      // Peak values at detection (before reset)
   double            m_peakSLow;       // Peak values at detection (before reset)

   //--- Baseline statistics (rolling estimation)
   double            m_baselineMean;   // μ₀ — rolling mean of drift observations
   double            m_baselineStd;    // σ₀ — rolling std of drift observations
   double            m_observations[]; // Circular buffer for baseline window
   int               m_obsCount;       // Number of observations collected
   int               m_obsIndex;       // Current write position in circular buffer
   bool              m_baselineReady;  // True after m_windowSize observations

   //--- Detection state
   bool              m_changeDetected; // True when CUSUM exceeds threshold
   int               m_barsSinceReset; // Bars since last reset

public:
   CCPDEngine()
   {
      m_enabled        = false;
      m_windowSize     = 50;
      m_delta          = 0.5;
      m_threshold      = 5.0;
      m_sHigh          = 0;
      m_sLow           = 0;
      m_peakSHigh      = 0;
      m_peakSLow       = 0;
      m_baselineMean   = 0;
      m_baselineStd    = 0;
      m_obsCount       = 0;
      m_obsIndex       = 0;
      m_baselineReady  = false;
      m_changeDetected = false;
      m_barsSinceReset = 0;
   }

   void Init(bool enabled, int windowSize, double delta, double threshold)
   {
      m_enabled    = enabled;
      m_windowSize = MathMax(windowSize, 10);
      m_delta      = delta;
      m_threshold  = threshold;

      ArrayResize(m_observations, m_windowSize);
      ArrayInitialize(m_observations, 0);
      Reset();
   }

   void Reset()
   {
      m_sHigh          = 0;
      m_sLow           = 0;
      m_peakSHigh      = 0;
      m_peakSLow       = 0;
      m_obsCount       = 0;
      m_obsIndex       = 0;
      m_baselineReady  = false;
      m_changeDetected = false;
      m_barsSinceReset = 0;
      m_baselineMean   = 0;
      m_baselineStd    = 0;
      ArrayInitialize(m_observations, 0);
   }

   //--- Feed a new observation (drift value) on each new bar
   //    Returns true if a change point is detected
   bool OnNewBar(double driftValue)
   {
      if(!m_enabled)
         return false;

      m_barsSinceReset++;

      //--- Add to circular buffer
      m_observations[m_obsIndex] = driftValue;
      m_obsIndex = (m_obsIndex + 1) % m_windowSize;
      m_obsCount++;

      //--- Phase 1: Collecting baseline (first m_windowSize bars)
      if(!m_baselineReady)
      {
         if(m_obsCount >= m_windowSize)
         {
            ComputeBaseline();
            m_baselineReady = true;
         }
         return false;
      }

      //--- Phase 2: CUSUM detection
      //    Baseline is frozen from Phase 1 — NOT recomputed.
      //    A rolling baseline tracks the trend it should detect, making CUSUM
      //    self-defeating: deviations from a sliding mean are always small.
      //    Frozen baseline means CUSUM accumulates genuine shifts against the
      //    original regime, which is what change point detection requires.

      double scaledDelta = m_delta * m_baselineStd;
      if(scaledDelta <= 0)
         scaledDelta = 0.0001;  // safety floor

      //--- CUSUM update
      //    S_high[t] = max(0, S_high[t-1] + (x[t] - μ₀ - δ/2))
      //    S_low[t]  = max(0, S_low[t-1]  + (-x[t] + μ₀ - δ/2))
      m_sHigh = MathMax(0.0, m_sHigh + (driftValue - m_baselineMean - scaledDelta / 2.0));
      m_sLow  = MathMax(0.0, m_sLow  + (-driftValue + m_baselineMean - scaledDelta / 2.0));

      double scaledThreshold = m_threshold * m_baselineStd;
      if(scaledThreshold <= 0)
         scaledThreshold = 0.001;

      m_changeDetected = (m_sHigh > scaledThreshold || m_sLow > scaledThreshold);

      //--- Save peak values before reset so callers can read them
      //    Reset accumulators after detection to allow re-detection
      if(m_changeDetected)
      {
         m_peakSHigh = m_sHigh;
         m_peakSLow  = m_sLow;
         m_sHigh = 0;
         m_sLow  = 0;
      }

      return m_changeDetected;
   }

   //--- Getters
   bool   IsChangeDetected()  const { return m_changeDetected; }
   bool   IsEnabled()         const { return m_enabled; }
   bool   IsBaselineReady()   const { return m_baselineReady; }
   double GetSHigh()          const { return m_peakSHigh; }  // peak at detection
   double GetSLow()           const { return m_peakSLow; }   // peak at detection
   double GetBaselineMean()   const { return m_baselineMean; }
   double GetBaselineStd()    const { return m_baselineStd; }

private:
   void ComputeBaseline()
   {
      int count = MathMin(m_obsCount, m_windowSize);
      if(count <= 1)
      {
         m_baselineMean = 0;
         m_baselineStd  = 0;
         return;
      }

      //--- Compute mean
      double sum = 0;
      for(int i = 0; i < count; i++)
         sum += m_observations[i];
      m_baselineMean = sum / count;

      //--- Compute std
      double sumSq = 0;
      for(int i = 0; i < count; i++)
      {
         double diff = m_observations[i] - m_baselineMean;
         sumSq += diff * diff;
      }
      m_baselineStd = MathSqrt(sumSq / (count - 1));
   }
};

#endif // __CPD_ENGINE_MQH__
//+------------------------------------------------------------------+
