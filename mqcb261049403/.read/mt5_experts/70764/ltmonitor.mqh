//+------------------------------------------------------------------+
//|                                                    LtMonitor.mqh |
//|                              BGC Grid Trading EA — Kill Switch 1 |
//|                         Lt = ½(Dt²+Dt+Ut²+Ut) + weighted version |
//+------------------------------------------------------------------+
#property copyright "Muhammad Minhas Qamar - MMQ"
#property strict

#ifndef __LT_MONITOR_MQH__
#define __LT_MONITOR_MQH__

#include "Defines.mqh"

//+------------------------------------------------------------------+
//| CLtMonitor — real-time ruin proximity monitoring                 |
//+------------------------------------------------------------------+
class CLtMonitor
{
private:
   string            m_symbol;
   double            m_pointValue;     // tick value for 1 lot, 1 point move

public:
   void Init(string symbol)
   {
      m_symbol     = symbol;
      m_pointValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE)
                     / SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   }

   //--- Update session high and low
   void UpdateSessionExtremes(GridSession &session, double bid)
   {
      if(bid > session.sessionHigh)
         session.sessionHigh = bid;
      if(bid < session.sessionLow)
         session.sessionLow = bid;
   }

   //--- Compute theoretical Lt in grid-level units (for logging/diagnostics)
   //    Uses the classic formula: Lt = 0.5*(Dt²+Dt+Ut²+Ut)
   double ComputeLt(const GridSession &session, double bid)
   {
      double dtPrice = session.sessionHigh - bid;
      double utPrice = bid - session.sessionLow;

      if(dtPrice < 0) dtPrice = 0;
      if(utPrice < 0) utPrice = 0;

      double dtLevels = MathFloor(dtPrice / session.gridSpacing);
      double utLevels = MathFloor(utPrice / session.gridSpacing);
      dtLevels = MathMin(dtLevels, (double)session.totalLevels);
      utLevels = MathMin(utLevels, (double)session.totalLevels);

      double lt = 0.5 * (dtLevels * dtLevels + dtLevels + utLevels * utLevels + utLevels);
      return lt;
   }

   //--- Compute weighted loss in account currency
   //    Sums actual dollar exposure per active losing level
   //    This correctly handles variable lot sizes (mild multiplier mode)
   double ComputeWeightedLoss(const GridSession &session, double bid)
   {
      double totalLoss = 0.0;
      int total = 2 * session.totalLevels;

      for(int i = 0; i < total; i++)
      {
         double levelPrice = session.levels[i].price;
         double lot        = session.levels[i].lotSize;

         //--- Buy side: losing when current price < open price
         if(session.levels[i].buyOpen && session.levels[i].buyTicket > 0)
         {
            double distance = levelPrice - bid;
            if(distance > 0)
               totalLoss += lot * distance * m_pointValue;
         }

         //--- Sell side: losing when current price > open price
         if(session.levels[i].sellOpen && session.levels[i].sellTicket > 0)
         {
            double distance = bid - levelPrice;
            if(distance > 0)
               totalLoss += lot * distance * m_pointValue;
         }
      }

      return totalLoss;
   }

   //--- Compute ruin proximity ratio
   double ComputeRPR(double weightedLoss, double cycleStartEquity)
   {
      if(cycleStartEquity <= 0) return 1.0;
      return weightedLoss / cycleStartEquity;
   }

   //--- Check if kill switch should fire
   bool CheckKillSwitch(double rpr, double threshold)
   {
      return (rpr >= threshold);
   }

   //--- Theorem 52: probability of winning (reaching N coins)
   //    P(win | start at n, target N) = n/N  (symmetric random walk)
   //    n = current "coins" (equity in grid-unit v terms)
   //    N = total equity in grid-unit v terms
   double ComputeWinProbability(int currentCoins, int totalCoins, int /*gridLevel*/)
   {
      if(totalCoins <= 0) return 0.0;
      if(currentCoins >= totalCoins) return 1.0;
      if(currentCoins <= 0) return 0.0;
      return (double)currentCoins / (double)totalCoins;
   }

   //--- Theorem 53: probability of ruin given the current state
   //    P(ruin) = 1 - P(win) = 1 - n/N  (symmetric random walk)
   //    Maps EA parameters to theorem units:
   //    v = baseLot × pointValue × gridSpacing (value per grid step)
   //    n = cycleEquity / v (current coins)
   //    N = totalEquity / v (total coins)
   double ComputeRuinProbability(double cycleEquity, double totalEquity,
                                  double baseLot, double gridSpacing, int /*maxLevelReached*/)
   {
      double v = baseLot * m_pointValue * gridSpacing;
      if(v <= 0) return 0.0;

      int n = (int)MathFloor(cycleEquity / v);
      int N = (int)MathFloor(totalEquity / v);

      if(N <= 0) return 1.0;
      if(n <= 0) return 1.0;
      if(n >= N) return 0.0;

      return 1.0 - (double)n / (double)N;
   }

   //--- Expected number of steps before absorption (ruin or win)
   //    E[T] = n * (N - n)  for symmetric random walk
   double ComputeExpectedSteps(double cycleEquity, double totalEquity,
                                double baseLot, double gridSpacing)
   {
      double v = baseLot * m_pointValue * gridSpacing;
      if(v <= 0) return 0.0;

      double n = MathFloor(cycleEquity / v);
      double N = MathFloor(totalEquity / v);

      if(N <= 0 || n <= 0 || n >= N) return 0.0;

      return n * (N - n);
   }

   //--- Path-aware Lt: count actual losing positions
   //    Compares to theoretical Lt to validate Refraction Principle
   double ComputePathAwareLt(const GridSession &session, double bid)
   {
      double pathLt = 0.0;
      int total = 2 * session.totalLevels;

      for(int i = 0; i < total; i++)
      {
         //--- Buy side: losing when bid < level price
         if(session.levels[i].buyOpen && session.levels[i].buyTicket > 0)
         {
            if(bid < session.levels[i].price)
               pathLt += 1.0;
         }
         //--- Sell side: losing when bid > level price
         if(session.levels[i].sellOpen && session.levels[i].sellTicket > 0)
         {
            if(bid > session.levels[i].price)
               pathLt += 1.0;
         }
      }

      return pathLt;
   }

   //--- Full check: update extremes, compute weighted loss, check kill switch
   //    Returns true if kill switch fires
   bool OnTick(GridSession &session, double bid, double threshold,
               double &outRPR, double &outLt, double &outWeightedLoss)
   {
      UpdateSessionExtremes(session, bid);

      outLt           = ComputeLt(session, bid);
      outWeightedLoss = ComputeWeightedLoss(session, bid);
      outRPR          = ComputeRPR(outWeightedLoss, session.cycleStartEquity);

      if(CheckKillSwitch(outRPR, threshold))
      {
         string msg = StringFormat(
            "[BGC Grid] Kill switch triggered. RPR=%.2f%% (threshold=%.2f%%), "
            "WeightedLoss=$%.2f, Lt=%.1f levels, Equity=$%.2f, Symbol=%s",
            outRPR * 100, threshold * 100,
            outWeightedLoss, outLt,
            AccountInfoDouble(ACCOUNT_EQUITY), m_symbol);

         Print(msg);
         Alert(msg);
         SendNotification(msg);

         return true;
      }

      return false;
   }
};

#endif // __LT_MONITOR_MQH__
//+------------------------------------------------------------------+
