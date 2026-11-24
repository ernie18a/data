Calculation: Bullish FVG channel reference = SMA(SMA(mean of active bullish FVG reference prices, smoothing lookback), smoothing lookback), using SMA(close, smoothing lookback) instead of the mean when none are active; retain at most the maximum active FVG count and remove the oldest on overflow
Calculation: Bearish FVG channel reference = SMA(SMA(mean of active bearish FVG reference prices, smoothing lookback), smoothing lookback), using SMA(close, smoothing lookback) instead of the mean when none are active; retain at most the maximum active FVG count and remove the oldest on overflow
Calculation: Upper boundary = max(bullish FVG channel reference, bearish FVG channel reference)
Calculation: Lower boundary = min(bullish FVG channel reference, bearish FVG channel reference)
Calculation: Volume filter = volume confirmation disabled OR SMA(volume, volume lookback) exists AND volume > SMA(volume, volume lookback) * volume confirmation multiplier
Calculation: Bullish wick extension = 0 when lower boundary = 0, otherwise max((lower boundary - low) / abs(lower boundary), 0)
Calculation: Bearish wick extension = 0 when upper boundary = 0, otherwise max((high - upper boundary) / abs(upper boundary), 0)
Calculation: Bull recovery = upper and lower boundaries exist AND bar is confirmed AND close crosses above lower boundary after close was below lower boundary for at least the minimum consecutive closes immediately before this bar AND no prior bullish signal or bars since the most recent bullish signal >= signal cooldown AND volume filter
Calculation: Bear recovery = upper and lower boundaries exist AND bar is confirmed AND close crosses below upper boundary after close was above upper boundary for at least the minimum consecutive closes immediately before this bar AND no prior bearish signal or bars since the most recent bearish signal >= signal cooldown AND volume filter
Long: Bull recovery AND bullish wick extension < Super wick extension threshold
Long: Bull recovery AND bullish wick extension >= Super wick extension threshold
Short: Bear recovery AND bearish wick extension < Super wick extension threshold
Short: Bear recovery AND bearish wick extension >= Super wick extension threshold