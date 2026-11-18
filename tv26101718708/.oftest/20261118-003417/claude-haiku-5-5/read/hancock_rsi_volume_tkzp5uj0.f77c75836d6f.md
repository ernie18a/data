Calculation: BarUpVolume = wick weighting on: (if close > open: volume * (high - low) / (2 * (high - low) - abs(close - open)); else if close < open: volume * (high - low - abs(close - open)) / (2 * (high - low) - abs(close - open)); else 0); wick weighting off: (if open <= close: volume; else 0)
Calculation: BarDownVolume = wick weighting on: (if close > open: volume * (high - low - abs(close - open)) / (2 * (high - low) - abs(close - open)); else if close < open: volume * (high - low) / (2 * (high - low) - abs(close - open)); else 0); wick weighting off: (if open > close: volume; else 0)
Calculation: UpMove = (if close > close[1]: abs(close - close[1]) * SUM(BarUpVolume, T1 bars per chart bar, T1, last completed bar); else 0)
Calculation: DownMove = (if close < close[1]: abs(close - close[1]) * SUM(BarDownVolume, T1 bars per chart bar, T1, last completed bar); else 0)
Calculation: VolumeRSI = 100 * RMA(UpMove, length) / (RMA(UpMove, length) + RMA(DownMove, length))
Calculation: VolumeTrend = 1 if VolumeRSI > 50 + 50 * threshold, or VolumeRSI > 50 - 50 * threshold AND VolumeTrend[1] = 1; -1 if VolumeRSI < 50 - 50 * threshold, or VolumeRSI < 50 + 50 * threshold AND VolumeTrend[1] = -1; otherwise 0
Long: VolumeTrend = 1
Short: VolumeTrend = -1
Exit: long, VolumeTrend = 0
Exit: short, VolumeTrend = 0