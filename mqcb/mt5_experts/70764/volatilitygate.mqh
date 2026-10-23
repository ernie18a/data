//+------------------------------------------------------------------+
//|                                              VolatilityGate.mqh  |
//|                      BGC Grid Trading EA — Volatility Filter     |
//|                      ATR + Drift gating per Papers 3 & 4         |
//+------------------------------------------------------------------+
#property copyright "Muhammad Minhas Qamar - MMQ"
#property strict

#ifndef __VOLATILITY_GATE_MQH__
#define __VOLATILITY_GATE_MQH__

//+------------------------------------------------------------------+
//| CVolatilityGate — pauses grid arming outside productive range    |
//|   Two checks:                                                     |
//|   1. ATR/GridSpacing ratio (existing — too quiet or too explosive)|
//|   2. σt/μt ratio (new — drift detection, the death scenario)     |
//+------------------------------------------------------------------+
class CVolatilityGate
{
private:
   int               m_atrHandle;      // iATR indicator handle
   int               m_maHandle;       // iMA handle for drift measurement
   int               m_atrPeriod;
   int               m_maPeriod;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   double            m_lastATR;        // cached ATR value (σt proxy)
   double            m_lastDrift;      // cached absolute drift per bar (μt proxy)
   double            m_lastSigmaMuRatio; // cached σt/μt ratio
   bool              m_initialized;
   int               m_cooldownBarsLeft; // bars remaining before resume allowed
   int               m_cooldownBars;     // configured cooldown duration

public:
   CVolatilityGate()
   {
      m_atrHandle  = INVALID_HANDLE;
      m_maHandle   = INVALID_HANDLE;
      m_atrPeriod  = 14;
      m_maPeriod   = 20;
      m_lastATR    = 0;
      m_lastDrift  = 0;
      m_lastSigmaMuRatio = 999;
      m_initialized = false;
      m_cooldownBarsLeft = 0;
      m_cooldownBars     = 3;
   }

   //--- Create indicator handles
   bool Init(string symbol, ENUM_TIMEFRAMES tf, int atrPeriod, int maPeriod = 20,
             int cooldownBars = 3)
   {
      m_symbol       = symbol;
      m_timeframe    = tf;
      m_atrPeriod    = atrPeriod;
      m_maPeriod     = maPeriod;
      m_cooldownBars = cooldownBars;

      m_atrHandle = iATR(symbol, tf, atrPeriod);
      if(m_atrHandle == INVALID_HANDLE)
      {
         PrintFormat("[BGC Grid] Failed to create ATR(%d) handle, error %d",
                     atrPeriod, GetLastError());
         return false;
      }

      //--- SMA for drift measurement: slope of MA = μt proxy
      m_maHandle = iMA(symbol, tf, maPeriod, 0, MODE_SMA, PRICE_CLOSE);
      if(m_maHandle == INVALID_HANDLE)
      {
         PrintFormat("[BGC Grid] Failed to create MA(%d) handle, error %d",
                     maPeriod, GetLastError());
         // Non-fatal — drift detection won't work but ATR gate will
      }

      m_initialized = true;
      return true;
   }

   void Deinit()
   {
      if(m_atrHandle != INVALID_HANDLE)
      {
         IndicatorRelease(m_atrHandle);
         m_atrHandle = INVALID_HANDLE;
      }
      if(m_maHandle != INVALID_HANDLE)
      {
         IndicatorRelease(m_maHandle);
         m_maHandle = INVALID_HANDLE;
      }
      m_initialized = false;
   }

   //--- Get current ATR value
   double GetATRValue()
   {
      if(!m_initialized || m_atrHandle == INVALID_HANDLE)
         return 0;

      double atrBuffer[];
      ArraySetAsSeries(atrBuffer, true);

      if(CopyBuffer(m_atrHandle, 0, 1, 1, atrBuffer) <= 0)
      {
         PrintFormat("[BGC Grid] ATR CopyBuffer failed (bar 1), error %d", GetLastError());
         return m_lastATR;
      }

      m_lastATR = atrBuffer[0];
      return m_lastATR;
   }

   //--- Compute drift (μt) as average absolute bar-by-bar MA change
   //    Research-correct proxy for instantaneous drift magnitude from the Itô SDE:
   //    μt = (1/N) × Σ |MA[i] - MA[i+1]|  for i = 0..N-1
   //    This measures the average directional tendency per bar, not net displacement.
   //    Net displacement cancels to zero when trends reverse within the window;
   //    this formula captures the actual kinetic energy of directional movement.
   double ComputeDrift()
   {
      if(m_maHandle == INVALID_HANDLE)
         return 0;

      double maBuffer[];
      ArraySetAsSeries(maBuffer, true);

      //--- Need MA from bar 1 through bar (maPeriod+1) — avoid incomplete bar 0
      if(CopyBuffer(m_maHandle, 0, 1, m_maPeriod + 1, maBuffer) < m_maPeriod + 1)
         return m_lastDrift;

      //--- Average of absolute bar-by-bar MA changes over the window
      double sumAbsChanges = 0;
      for(int i = 0; i < m_maPeriod; i++)
         sumAbsChanges += MathAbs(maBuffer[i] - maBuffer[i + 1]);

      m_lastDrift = sumAbsChanges / m_maPeriod;
      return m_lastDrift;
   }

   //--- Compute σt/μt ratio
   //    High = ranging (good for grid), Low = trending (dangerous)
   double ComputeSigmaMuRatio()
   {
      double atr   = GetATRValue();
      double drift = ComputeDrift();

      if(drift < 0.001)
      {
         m_lastSigmaMuRatio = 999;  // effectively no drift = pure ranging
         return m_lastSigmaMuRatio;
      }

      m_lastSigmaMuRatio = MathMin(atr / drift, 999.0);
      return m_lastSigmaMuRatio;
   }

   //--- Full volatility check: ATR range + drift detection + cooldown
   //    Returns true if conditions are favorable for grid arming.
   //    Cooldown: after drift is detected, requires N consecutive clear bars
   //    before allowing resume — prevents the rapid pause/resume flickering
   //    that lets positions accumulate into a trend.
   //    skipMagnitudeCheck: when ATR-dynamic spacing is active, the grid spacing
   //    is already derived from the same ATR, so the ATR/GridSpacing ratio is
   //    just 1/multiplier (a constant) — the magnitude check is self-calibrating
   //    and should be skipped. Only the drift (σt/μt) check matters.
   bool IsVolatilityFavorable(double gridSpacingPrice, double minRatio, double maxRatio,
                               double minSigmaMuRatio = 2.0, bool skipMagnitudeCheck = false)
   {
      if(!m_initialized)
         return true;

      double atr = GetATRValue();
      if(atr <= 0 || gridSpacingPrice <= 0)
         return true;

      //--- Check 1: ATR/GridSpacing range (skip when ATR-dynamic spacing is active)
      if(!skipMagnitudeCheck)
      {
         double atrGridRatio = atr / gridSpacingPrice;

         if(atrGridRatio < minRatio)
         {
            m_cooldownBarsLeft = m_cooldownBars;  // reset cooldown on any unfavorable signal
            return false;
         }

         if(atrGridRatio > maxRatio)
         {
            m_cooldownBarsLeft = m_cooldownBars;
            return false;
         }
      }

      //--- Check 2: σt/μt ratio (drift detection)
      double sigmaMu = ComputeSigmaMuRatio();

      if(sigmaMu < minSigmaMuRatio)
      {
         m_cooldownBarsLeft = m_cooldownBars;  // reset cooldown on drift
         return false;
      }

      //--- All checks pass — but enforce cooldown
      if(m_cooldownBarsLeft > 0)
      {
         m_cooldownBarsLeft--;
         return false;  // still in cooldown, don't resume yet
      }

      return true;
   }

   //--- Getters for logging
   double GetRatio(double gridSpacingPrice)
   {
      if(gridSpacingPrice <= 0) return 0;
      return m_lastATR / gridSpacingPrice;
   }

   double GetSigmaMuRatio()    { return m_lastSigmaMuRatio; }
   double GetLastATR()         { return m_lastATR; }
   double GetLastDrift()       { return m_lastDrift; }

   //--- Signed drift for TGT/MGT trend direction
   //    Returns the most recent MA bar change (positive = uptrend, negative = downtrend)
   //    Direction is determined by the single most recent bar, not the full window.
   //    The window gives magnitude (via ComputeDrift), this gives direction;
   //    separate questions answered separately, faithful to the Itô framework.
   double GetSignedDrift()
   {
      if(m_maHandle == INVALID_HANDLE)
         return 0;

      double maBuffer[];
      ArraySetAsSeries(maBuffer, true);

      //--- Only need bars 1 and 2 for direction
      if(CopyBuffer(m_maHandle, 0, 1, 2, maBuffer) < 2)
         return 0;

      //--- maBuffer[0] = bar 1 (most recent completed), maBuffer[1] = bar 2
      return maBuffer[0] - maBuffer[1];
   }
};

#endif // __VOLATILITY_GATE_MQH__
//+------------------------------------------------------------------+
