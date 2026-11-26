Calculation: selected source = selected price source, Heikin-Ashi close on chart bars, mean of Heikin-Ashi OHLC on chart bars, or mean of chart-bar OHLC
Calculation: band source = selected source when smoothing is off, otherwise SMA(selected source, band lookback)
Calculation: upper volume band = SMA((previous upper volume band or selected source if unavailable + band source × SMA(volume, band lookback) × correction factor) / (SMA(volume, band lookback) × correction factor), band lookback)
Calculation: lower volume band = SMA((previous lower volume band or selected source if unavailable + band source × SMA(-volume, band lookback) × correction factor) / (SMA(-volume, band lookback) × correction factor), band lookback)
Calculation: adaptive average = k × close + (1 − k) × (previous adaptive average or close if unavailable), where k = abs(VWAP(close) − VWAP(open)) / (VWAP(high) − VWAP(low))
Long: strategy enabled AND adaptive average crosses above upper volume band AND the last emitted signal was not long AND time is within the configured date window
Short: strategy enabled AND adaptive average crosses below lower volume band AND the last emitted signal was not short AND time is within the configured date window
Exit: long, stop-loss offset in ticks is reached below entry price OR take-profit offset in ticks is reached above entry price
Exit: short, stop-loss offset in ticks is reached above entry price OR take-profit offset in ticks is reached below entry price