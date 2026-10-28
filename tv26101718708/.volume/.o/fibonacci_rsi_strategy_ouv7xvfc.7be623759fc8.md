Calculation: Lower outer band = VWMA(hlc3, lookback) − multiplier × standard deviation(hlc3, same lookback)
Calculation: Upper outer band = VWMA(hlc3, lookback) + multiplier × standard deviation(hlc3, same lookback)
Calculation: Lower target = VWMA(hlc3, lookback) − 0.764 × multiplier × standard deviation(hlc3, same lookback)
Calculation: Upper target = VWMA(hlc3, lookback) + 0.764 × multiplier × standard deviation(hlc3, same lookback)
Calculation: Long stop = average entry price × (1 − configured stop-loss fraction)
Calculation: Short stop = average entry price × (1 + configured stop-loss fraction)
Long: year(datetime) ≥ 2000 AND low < lower outer band AND RSI(close, lookback)[1] crosses above oversold threshold AND high < lower target
Short: year(datetime) ≥ 2000 AND high > upper outer band AND RSI(close, lookback)[1] crosses below overbought threshold AND low > upper target
Exit: long, high > lower target captured when position size increased OR low ≤ long stop
Exit: short, low < upper target captured when position size decreased OR high ≥ short stop