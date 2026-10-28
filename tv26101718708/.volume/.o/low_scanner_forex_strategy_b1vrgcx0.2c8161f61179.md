Calculation: Sampled close = chart close on the first chart bar after each selected aggregation-timeframe boundary; carry forward until the next boundary
Calculation: Scanner value = negative EMA of (previous-bar RSI of cumulative sampled-close change weighted by chart-bar volume minus its longer-lookback WMA), using a shorter lookback for the EMA than for the WMA
Calculation: Trend comparison value = HMA3 of the prior completed selected-timeframe close, shifted by the configured offset; HMA3 = WMA(3 × WMA(close, half-length / 3) − WMA(close, half-length / 2) − WMA(close, half-length), half-length)
Long: Scanner value crosses above zero OR chart close’s 25-bar linear regression crosses above the trend comparison value, AND datetime is within the configured backtest date range
Exit: Long, low reaches the entry price minus the configured stop-loss percentage OR high reaches any of four profit targets above entry price, in ascending order; reduce position progressively at each target
