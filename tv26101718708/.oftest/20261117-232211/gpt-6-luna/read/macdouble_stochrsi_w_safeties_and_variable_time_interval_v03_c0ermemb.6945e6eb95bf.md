Calculation: MACD histogram(fast lookback, slow lookback, signal lookback) = EMA(close, fast lookback) - EMA(close, slow lookback) - SMA(EMA(close, fast lookback) - EMA(close, slow lookback), signal lookback)
Calculation: StochRSI K = SMA(Stoch(RSI(close, RSI lookback), RSI(close, RSI lookback), RSI(close, RSI lookback), stochastic lookback), K smoothing lookback)
Calculation: StochRSI D = SMA(StochRSI K, D smoothing lookback)
Calculation: Uptrend ratio = (close + high) / (close[1] + high[2])
Calculation: Downtrend ratio = (close + low) / (close[1] + low[2])
Long: MACD histogram(fast lookback 1, slow lookback 1, signal lookback 1) > 0 AND MACD histogram(fast lookback 2, slow lookback 2, signal lookback 2, T1 current bar) > 0 AND year(datetime) > start-year parameter AND Uptrend ratio > 1 AND StochRSI K(T2 current bar) != 0 AND StochRSI D(T2 current bar) < long threshold AND StochRSI K(T2 current bar) > StochRSI D(T2 current bar)
Short: MACD histogram(fast lookback 1, slow lookback 1, signal lookback 1) < 0 AND MACD histogram(fast lookback 2, slow lookback 2, signal lookback 2, T1 current bar) < 0 AND year(datetime) > start-year parameter AND Downtrend ratio < 1 AND StochRSI K(T2 current bar) != 0 AND StochRSI D(T2 current bar) > short threshold AND StochRSI K(T2 current bar) < StochRSI D(T2 current bar)
Exit: Short, high >= entry price + stop-loss distance