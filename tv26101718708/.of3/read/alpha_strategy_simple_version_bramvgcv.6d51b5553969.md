Calculation: Sharpe = ((ohlc4 - ohlc4[lookback]) / ohlc4) / (stdev(ohlc4, lookback) / ohlc4)
Calculation: Alpha = ((close - close[lookback]) / close) - ((benchmark close - benchmark close[lookback]) / benchmark close) * (correlation((close - close[1]) / close, (benchmark close - benchmark close[1]) / benchmark close, lookback) * stdev((close - close[1]) / close, lookback) / stdev((benchmark close - benchmark close[1]) / benchmark close, lookback))
Long: SMA(Sharpe, lookback / sensitivity) > 1 AND SMA(Alpha, lookback / sensitivity) > 0
Short: SMA(Sharpe, lookback / sensitivity) <= 1 OR SMA(Alpha, lookback / sensitivity) <= 0
Long: close > open AND SMA(Sharpe, lookback / sensitivity) > 1 AND SMA(Alpha, lookback / sensitivity) > 0
Exit: long, SMA(Sharpe, lookback / sensitivity) < 1 OR SMA(Alpha, lookback / sensitivity) < 0