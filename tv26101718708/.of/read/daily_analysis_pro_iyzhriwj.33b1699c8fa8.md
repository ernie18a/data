Calculation: UltimateRSI = with src=close, upper=highest(src,n), lower=lowest(src,n), r=upper-lower, d=src-src[1], diff = r if upper>upper[1] else -r if lower<lower[1] else d, raw = 50+50*RMA(diff,n)/RMA(abs(diff),n) (50 if the denominator is 0), UltimateRSI = moving average of raw over a short smoothing length (classic RSI with the same smoothing may be used instead)
Long: UltimateRSI[1] <= oversold level AND UltimateRSI > oversold level (oversold level < overbought level)
Long: low > high[2] AND close[2] < open[2] AND (close - open[2]) > ATR * strength multiplier
Short: UltimateRSI[1] >= overbought level AND UltimateRSI < overbought level
Short: high < low[2] AND close[2] > open[2] AND (open[2] - close) > ATR * strength multiplier