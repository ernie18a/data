Calculation: Seven-average(source, lookback) = (SMA(source, lookback) + EMA(source, lookback) + WMA(source, lookback) + ALMA(source, lookback, offset parameter, sigma parameter) + RMA(source, lookback) + linear regression(source, lookback, offset parameter) + VWMA(source, lookback)) / 7
Long: close > Seven-average(high, lookback)
Short: close < Seven-average(low, lookback)
Exit: long, high >= entry price + close * long take-profit parameter OR low <= entry price - close * long stop-loss parameter OR low crosses below Seven-average(low, lookback)
Exit: short, low <= entry price - close * short take-profit parameter OR high >= entry price + close * short stop-loss parameter OR high crosses above Seven-average(high, lookback)