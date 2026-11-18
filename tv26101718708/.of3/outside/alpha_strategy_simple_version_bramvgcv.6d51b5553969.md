Calculation: Sharpe Ratio = ((OHLC4 - OHLC4[P1]) / OHLC4) / (standard deviation(OHLC4, P1) / OHLC4)
Calculation: Alpha against the S&P 500 = ((close - close[P1]) / close) - (((S&P 500 close - S&P 500 close[P1]) / S&P 500 close) * correlation((close - close[1]) / close, (S&P 500 close - S&P 500 close[1]) / S&P 500 close, P1) * (standard deviation((close - close[1]) / close, P1) / standard deviation((S&P 500 close - S&P 500 close[1]) / S&P 500 close, P1)))
Long: SMA(Sharpe Ratio, P1/P2) > P3 AND SMA(Alpha against the S&P 500, P1/P2) > P4
Long: close > open AND SMA(Sharpe Ratio, P1/P2) > P3 AND SMA(Alpha against the S&P 500, P1/P2) > P4
Short: SMA(Sharpe Ratio, P1/P2) <= P3 OR SMA(Alpha against the S&P 500, P1/P2) <= P4
Exit: long, SMA(Sharpe Ratio, P1/P2) < P3 OR SMA(Alpha against the S&P 500, P1/P2) < P4