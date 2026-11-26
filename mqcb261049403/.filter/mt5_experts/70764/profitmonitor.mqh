//+------------------------------------------------------------------+
//|                                                ProfitMonitor.mqh |
//|                              BGC Grid Trading EA — Kill Switch 2 |
//|                      Equity-based profit target & restart cycles |
//+------------------------------------------------------------------+
#property copyright "Muhammad Minhas Qamar - MMQ"
#property strict

#ifndef __PROFIT_MONITOR_MQH__
#define __PROFIT_MONITOR_MQH__

#include "Defines.mqh"

//+------------------------------------------------------------------+
//| CProfitMonitor — equity-based profit monitoring and restart      |
//+------------------------------------------------------------------+
class CProfitMonitor
{
private:
   int               m_magic;
   string            m_symbol;

public:
   void Init(int magic, string symbol)
   {
      m_magic  = magic;
      m_symbol = symbol;
   }

   //--- Compute cycle profit from equity change
   //    Captures realized TP closes + floating P/L + swap + commission
   double GetCycleProfit(double cycleStartEquity)
   {
      return AccountInfoDouble(ACCOUNT_EQUITY) - cycleStartEquity;
   }

   //--- Count open positions for this EA instance
   int GetPositionCount()
   {
      int count = 0;
      int total = PositionsTotal();

      for(int i = 0; i < total; i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;

         if(PositionGetInteger(POSITION_MAGIC) != m_magic) continue;
         if(PositionGetString(POSITION_SYMBOL) != m_symbol) continue;

         count++;
      }

      return count;
   }

   //--- Check if profit target is met
   bool CheckProfitTarget(double cycleProfit, double cycleStartEquity,
                           bool useProfitPercent, double profitTargetDollars,
                           double profitTargetPercent)
   {
      double target;

      if(useProfitPercent)
         target = cycleStartEquity * profitTargetPercent / 100.0;
      else
         target = profitTargetDollars;

      return (cycleProfit >= target && target > 0);
   }

   //--- Fire notification for profit target hit
   void NotifyProfitTarget(double cycleProfit, int cycleCount, datetime cycleStartTime)
   {
      long   duration = (long)(TimeCurrent() - cycleStartTime);
      int    hours    = (int)(duration / 3600);
      int    minutes  = (int)((duration % 3600) / 60);

      string msg = StringFormat(
         "[BGC Grid] Profit target reached. Profit=$%.2f, Cycle #%d, "
         "Duration=%dh %dm, Equity=$%.2f, Symbol=%s",
         cycleProfit, cycleCount + 1,
         hours, minutes,
         AccountInfoDouble(ACCOUNT_EQUITY), m_symbol);

      Print(msg);
      Alert(msg);
      SendNotification(msg);
   }
};

#endif // __PROFIT_MONITOR_MQH__
//+------------------------------------------------------------------+
