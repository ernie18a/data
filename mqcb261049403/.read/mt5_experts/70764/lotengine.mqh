//+------------------------------------------------------------------+
//|                                                   LotEngine.mqh  |
//|                      BGC Grid Trading EA — Lot Sizing Engine     |
//+------------------------------------------------------------------+
#property copyright "Muhammad Minhas Qamar - MMQ"
#property strict

#ifndef __LOT_ENGINE_MQH__
#define __LOT_ENGINE_MQH__

#include "Defines.mqh"

//+------------------------------------------------------------------+
//| CLotEngine — computes lot size per grid level                    |
//+------------------------------------------------------------------+
class CLotEngine
{
private:
   double            m_baseLot;
   double            m_multiplier;
   double            m_maxLot;
   bool              m_useMild;
   string            m_symbol;

   //--- Normalise a lot to broker constraints
   double NormaliseLot(double lot)
   {
      double minLot  = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
      double maxLot  = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
      double step    = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);

      //--- Apply user cap
      double cap = MathMin(maxLot, m_maxLot);

      //--- Clamp
      lot = MathMax(lot, minLot);
      lot = MathMin(lot, cap);

      //--- Round to step
      if(step > 0)
         lot = MathFloor(lot / step) * step;

      //--- Final safety
      lot = NormalizeDouble(lot, 2);
      if(lot < minLot)
         lot = minLot;

      return lot;
   }

public:
   //--- Initialise with user parameters
   void Init(string symbol, double baseLot, double multiplier, double maxLot, bool useMild)
   {
      m_symbol     = symbol;
      m_baseLot    = baseLot;
      m_multiplier = multiplier;
      m_maxLot     = maxLot;
      m_useMild    = useMild;
   }

   //--- Compute lot for a given level (absolute distance from anchor)
   //    In dynamic mode, needs current ruin proximity ratio
   double GetLot(int levelDistance, double ruinProximity = 0.0)
   {
      double lot = m_baseLot;

      if(m_useMild)
      {
         //--- Mild Multiplier: BaseLot * pow(Multiplier, level), capped
         lot = m_baseLot * MathPow(m_multiplier, (double)levelDistance);
      }
      else
      {
         //--- Dynamic: scale DOWN as drawdown deepens
         //    Research-correct: closer to ruin = smaller lots
         double scaleFactor = MathMax(0.1, 1.0 - ruinProximity);
         lot = m_baseLot * scaleFactor;
      }

      return NormaliseLot(lot);
   }

   //--- Compute all lot sizes for an array of grid levels
   void ComputeAllLots(GridLevel &levels[], int count, double ruinProximity = 0.0)
   {
      for(int i = 0; i < count; i++)
      {
         int dist = MathAbs(levels[i].levelIndex);
         levels[i].lotSize = GetLot(dist, ruinProximity);
      }
   }
};

#endif // __LOT_ENGINE_MQH__
//+------------------------------------------------------------------+
