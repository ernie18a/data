Calculation: Anchored mean = sum(source × weight) / sum(weight), using a selected source of close, high, low, (high + low) / 2, (high + low + close) / 3, or (open + high + low + close) / 4, and weight of volume, square root of max(volume, 0), or 1. Use either a rolling chart-bar window, expanding from the first available bar until full; chart bars since the start of the current higher-timeframe anchor period; or chart bars whose opening time is at or after an anchor timestamp. Include the current chart bar. The mean is unavailable until a minimum anchor-bar count is reached or when the weight sum is zero.
Calculation: Anchored variance = sum(weight × source²) / sum(weight) − anchored mean², over the same bars and weights as the anchored mean.
Long: close crosses above anchored mean.
Short: close crosses below anchored mean.
Long: anchored mean − anchored mean at the slope lookback > ATR at the slope lookback length × slope threshold.
Short: anchored mean − anchored mean at the slope lookback < −ATR at the slope lookback length × slope threshold.
Long: anchored variance > 0 AND close > anchored mean.
Short: anchored variance > 0 AND close < anchored mean.