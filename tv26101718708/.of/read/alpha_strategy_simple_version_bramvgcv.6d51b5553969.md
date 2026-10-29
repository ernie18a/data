Calculation: Simplified Sharpe ratio = ((current OHLC4 − OHLC4 N bars ago) / current OHLC4) / (standard deviation of OHLC4 over N bars / current OHLC4), smoothed with a lookback no longer than N
Calculation: Beta = correlation of daily asset and benchmark returns over N bars × (standard deviation of asset daily returns over N bars / standard deviation of benchmark daily returns over N bars)
Calculation: Alpha = (current asset close − asset close N bars ago) / current asset close − ((current benchmark close − benchmark close N bars ago) / current benchmark close × Beta)
Long: close > open AND smoothed simplified Sharpe ratio > 1 AND smoothed Alpha > 0
Exit: long, smoothed simplified Sharpe ratio < 1 OR smoothed Alpha < 0