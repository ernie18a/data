Calculation: Pressure = SMA(volume × (if high = low then 0 else 2 × (close − low) / (high − low) − 1), pressure lookback)
Calculation: Active pressure = Pressure on chart bars if T1 is unset; otherwise Pressure calculated on T1 bars, sampled on chart bars with lookahead off, then shifted back one chart bar (it can reflect a forming T1 bar in realtime and the last completed T1 value historically)
Long: Active pressure crosses above 0
Short: Active pressure crosses below 0
Long: Active pressure >= 0 AND Active pressure > Active pressure[1]
Short: Active pressure < 0 AND Active pressure < Active pressure[1]
Long: confirmed pivot low of Active pressure on chart bars with divergence lookback on both sides AND low[divergence lookback] < Lowest(low, divergence lookback)[divergence lookback + 1] AND (volume filter disabled OR volume[divergence lookback] > SMA(volume, volume average lookback)[divergence lookback])
Short: confirmed pivot high of Active pressure on chart bars with divergence lookback on both sides AND high[divergence lookback] > Highest(high, divergence lookback)[divergence lookback + 1] AND (volume filter disabled OR volume[divergence lookback] > SMA(volume, volume average lookback)[divergence lookback])