Calculation: ratio = ATR / simple moving average of ATR (the averaging lookback is longer than the ATR lookback); ratio = 1 if that average is 0
Calculation: period = clamp(SMA over a short lookback of clamp(Pmax - k*ratio)), where clamp(x) = max(ratio, min(Pmax, x)), Pmax is a fixed maximum period, and k is a fixed scale factor
Calculation: AdaptiveEMA = EMA of close whose smoothing factor on each bar is 2/(period+1), using that bar's period
Long: close > AdaptiveEMA AND previous close <= previous AdaptiveEMA
Short: close < AdaptiveEMA AND previous close >= previous AdaptiveEMA