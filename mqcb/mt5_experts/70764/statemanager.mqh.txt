//+------------------------------------------------------------------+
//|                                                StateManager.mqh  |
//|                      BGC Grid Trading EA — State Persistence     |
//+------------------------------------------------------------------+
#property copyright "Muhammad Minhas Qamar - MMQ"
#property strict

#ifndef __STATE_MANAGER_MQH__
#define __STATE_MANAGER_MQH__

#include "Defines.mqh"

//+------------------------------------------------------------------+
//| CStateManager — persists grid state via MQL5 global variables    |
//+------------------------------------------------------------------+
class CStateManager
{
private:
   string            m_prefix;         // Unique key prefix for this instance
   int               m_magic;

   string GetKey(string field) { return m_prefix + field; }

public:
   //--- Initialise with magic and symbol to create unique keys
   void Init(int magic, string symbol)
   {
      m_magic  = magic;
      m_prefix = STATE_PREFIX + symbol + "_" + IntegerToString(magic) + "_";
   }

   //--- Check if a previously saved state exists
   bool HasSavedState()
   {
      return GlobalVariableCheck(GetKey("AnchorPrice"));
   }

   //--- Save the current grid session to global variables
   void SaveState(GridSession &s)
   {
      GlobalVariableSet(GetKey("AnchorPrice"),      s.anchorPrice);
      GlobalVariableSet(GetKey("GridSpacing"),       s.gridSpacing);
      GlobalVariableSet(GetKey("SessionHigh"),       s.sessionHigh);
      GlobalVariableSet(GetKey("SessionLow"),        s.sessionLow);
      GlobalVariableSet(GetKey("CycleStartEquity"),  s.cycleStartEquity);
      GlobalVariableSet(GetKey("CycleStartTime"),    (double)s.cycleStartTime);
      GlobalVariableSet(GetKey("CycleCount"),        (double)s.cycleCount);
      GlobalVariableSet(GetKey("CumulativeProfit"),  s.cumulativeProfit);
      GlobalVariableSet(GetKey("State"),             (double)s.state);
      GlobalVariableSet(GetKey("TotalLevels"),       (double)s.totalLevels);
      GlobalVariableSet(GetKey("GridMode"),          (double)s.gridMode);
      GlobalVariableSet(GetKey("TrendDirection"),    (double)s.trendDirection);
   }

   //--- Load state from global variables. Returns false if not found
   //    or if persisted GridSpacing doesn't match current input.
   //    allowSpacingMismatch: when true (ATR-dynamic mode), skip spacing check
   bool LoadState(GridSession &s, double currentGridSpacing, bool allowSpacingMismatch = false)
   {
      if(!HasSavedState())
         return false;

      double savedSpacing = GlobalVariableGet(GetKey("GridSpacing"));

      //--- GridSpacing mismatch — user changed the input between restarts
      //    Skip this check in ATR-dynamic mode where spacing legitimately changes each cycle
      if(!allowSpacingMismatch && MathAbs(savedSpacing - currentGridSpacing) > 0.000001)
      {
         Alert(StringFormat("[BGC Grid] Saved state uses GridSpacing=%s, but the current input is %s. "
                            "Starting a new grid and clearing the old state.",
                            DoubleToString(savedSpacing, 5),
                            DoubleToString(currentGridSpacing, 5)));
         ClearState();
         return false;
      }

      s.anchorPrice      = GlobalVariableGet(GetKey("AnchorPrice"));
      s.gridSpacing      = savedSpacing;
      s.sessionHigh      = GlobalVariableGet(GetKey("SessionHigh"));
      s.sessionLow       = GlobalVariableGet(GetKey("SessionLow"));
      s.cycleStartEquity = GlobalVariableGet(GetKey("CycleStartEquity"));
      s.cycleStartTime   = (datetime)GlobalVariableGet(GetKey("CycleStartTime"));
      s.cycleCount       = (int)GlobalVariableGet(GetKey("CycleCount"));
      s.cumulativeProfit = GlobalVariableGet(GetKey("CumulativeProfit"));
      s.state            = (ENUM_GRID_STATE)(int)GlobalVariableGet(GetKey("State"));
      s.totalLevels      = (int)GlobalVariableGet(GetKey("TotalLevels"));
      s.gridMode         = (ENUM_GRID_MODE)(int)GlobalVariableGet(GetKey("GridMode"));
      s.trendDirection   = (int)GlobalVariableGet(GetKey("TrendDirection"));

      //--- Rebuild unified level array with correct prices
      int total = 2 * s.totalLevels;
      ArrayResize(s.levels, total);
      for(int i = 0; i < s.totalLevels; i++)
      {
         //--- Above anchor: indices 0..N-1
         s.levels[i].Reset();
         s.levels[i].levelIndex = i + 1;
         s.levels[i].price      = s.anchorPrice + (i + 1) * s.gridSpacing;

         //--- Below anchor: indices N..2N-1
         s.levels[s.totalLevels + i].Reset();
         s.levels[s.totalLevels + i].levelIndex = -(i + 1);
         s.levels[s.totalLevels + i].price      = s.anchorPrice - (i + 1) * s.gridSpacing;
      }

      return true;
   }

   //--- Delete all global variables for this instance
   void ClearState()
   {
      GlobalVariableDel(GetKey("AnchorPrice"));
      GlobalVariableDel(GetKey("GridSpacing"));
      GlobalVariableDel(GetKey("SessionHigh"));
      GlobalVariableDel(GetKey("SessionLow"));
      GlobalVariableDel(GetKey("CycleStartEquity"));
      GlobalVariableDel(GetKey("CycleStartTime"));
      GlobalVariableDel(GetKey("CycleCount"));
      GlobalVariableDel(GetKey("CumulativeProfit"));
      GlobalVariableDel(GetKey("State"));
      GlobalVariableDel(GetKey("TotalLevels"));
      GlobalVariableDel(GetKey("GridMode"));
      GlobalVariableDel(GetKey("TrendDirection"));
   }
};

#endif // __STATE_MANAGER_MQH__
//+------------------------------------------------------------------+
