// MQL5-code

class BACKTEST
  {
public:
   // Возвращает true, если полностью выполнился OnTick() на последнее событие NewTick в тестере - окончание бэктеста. Иначе - false.
   static bool BACKTEST::IsEnding(void)
     {
      return(::TesterStatistics(STAT_BALANCEMIN) > 0);
     }

   // Возвращает баланс бэктеста (по этому значению идет оптимизация "Balance max")
   static double BACKTEST::Balance(void)
     {
      return(BACKTEST::IsEnding() ? ::TesterStatistics(STAT_INITIAL_DEPOSIT) +
                                    ::TesterStatistics(STAT_WITHDRAWAL) +
                                    ::TesterStatistics(STAT_PROFIT) : ::AccountInfoDouble(ACCOUNT_BALANCE));
     }

   // Возвращает true, если не было "снятия средств" после окончания бэктеста. Иначе - false.
   static bool BACKTEST::IsNotWithdrawalAfter(void)
     {
      return(BACKTEST::IsEnding() && (::MathAbs(BACKTEST::Balance() - ::AccountInfoDouble(ACCOUNT_BALANCE)) < 0.005));
     }

   // Корректировка окончательного баланса бэктеста
   static bool BACKTEST::CorrectFinishBalance(const double Value)
     {
      return(BACKTEST::IsNotWithdrawalAfter() ? ::TesterWithdrawal(Value) : false);
     }
  };
//+------------------------------------------------------------------+
