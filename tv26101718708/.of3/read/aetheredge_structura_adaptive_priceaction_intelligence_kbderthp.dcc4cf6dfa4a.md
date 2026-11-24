Calculation: Active swing high = latest confirmed Pivot High(high, swing lookback, swing lookback), rearmed by each new pivot and consumed on the first close above it
Calculation: Active swing low = latest confirmed Pivot Low(low, swing lookback, swing lookback), rearmed by each new pivot and consumed on the first close below it
Calculation: Structure trend = bullish after a close above an active swing high, bearish after a close below an active swing low, undefined until the first break
Long: active swing high exists AND close > active swing high
Short: active swing low exists AND close < active swing low
Long: Structure trend = bullish
Short: Structure trend = bearish
Long: current confirmed Pivot High(high, swing lookback, swing lookback) > previous confirmed pivot high
Short: current confirmed Pivot High(high, swing lookback, swing lookback) < previous confirmed pivot high
Long: current confirmed Pivot Low(low, swing lookback, swing lookback) > previous confirmed pivot low
Short: current confirmed Pivot Low(low, swing lookback, swing lookback) < previous confirmed pivot low