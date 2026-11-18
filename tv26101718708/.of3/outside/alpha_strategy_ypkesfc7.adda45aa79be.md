Calculation: Sharpe Ratio = (((OHLC4 - OHLC4[P1]) / OHLC4 + P2 * (P1 / P3)) - P4) / (standard deviation of OHLC4 over P1 / OHLC4)
Calculation: Alpha against S&P 500 = ((traded instrument close - traded instrument close[P6]) / traded instrument close) - (((S&P 500 close - S&P 500 close[P6]) / S&P 500 close) * Beta of traded instrument returns against S&P 500 returns over P5)
Calculation: normalized return-volatility score = ((traded instrument close - traded instrument close[P11]) / traded instrument close) / sum(stdev(((traded instrument close - traded instrument close[P11]) / traded instrument close, P11), P11)
Long: SMA(Sharpe Ratio, P7) > P8 AND SMA(Alpha against S&P 500, P7) > P9
Short: SMA(Sharpe Ratio, P7) <= P8 OR SMA(Alpha against S&P 500, P7) <= P9
Long: traded instrument close > traded instrument open AND SMA(Sharpe Ratio, P7) > P8 AND SMA(Alpha against S&P 500, P7) > P10 AND normalized return-volatility score > P12
Exit: long, SMA(Sharpe Ratio, P7) < P8 OR SMA(Alpha against S&P 500, P7) < P9