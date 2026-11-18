Calculation: Gap threshold = gap-size factor * minimum tick
Calculation: Low volume = volume < SMA(volume, volume lookback) * low-volume factor
Calculation: Volume spike = volume > SMA(volume, volume lookback) * volume-spike factor
Calculation: Bullish FVG = low - high[2] >= gap threshold AND NOT Low volume AND (high/low filter disabled OR (low[2] <= low[3] AND low[2] <= low[4] AND Volume spike)) AND (volume-spike filter disabled OR Volume spike)
Calculation: Bearish FVG = low[2] - high >= gap threshold AND NOT Low volume AND (high/low filter disabled OR (high[2] >= high[3] AND high[2] >= high[4] AND Volume spike)) AND (volume-spike filter disabled OR Volume spike)
Long: Bullish FVG
Short: Bearish FVG
Long: A previously created bullish FVG has not been mitigated by a later low below its bottom or previously retested, and low <= its top AND low >= its bottom AND NOT Bullish FVG
Short: A previously created FVG that is bearish OR (bullish AND Bullish FVG) has not been mitigated (low below its bottom if bullish, high above its top if bearish) or previously retested, and high >= its bottom AND high <= its top AND NOT Bearish FVG