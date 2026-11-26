Calculation: TR-weighted moving average(source, lookback) = sum from n=0 through lookback of source[n] × abs(TrueRange[n]) × (lookback + 1 − n) / sum from n=0 through lookback of abs(TrueRange[n]) × (lookback + 1 − n)
Calculation: VWHMA(source, lookback) = TR-weighted moving average(2 × TR-weighted moving average(source, lookback / 2) − TR-weighted moving average(source, lookback), round(sqrt(lookback)))
Long: VWHMA(source, lookback) crosses above VWHMA(source, lookback)[1]
Short: VWHMA(source, lookback) crosses below VWHMA(source, lookback)[1]