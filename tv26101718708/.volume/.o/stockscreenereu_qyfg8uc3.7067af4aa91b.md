Calculation: High reference = high when wick filtering is enabled; otherwise max(open, close)
Calculation: Low reference = low when wick filtering is enabled; otherwise min(open, close)
Calculation: Distance to 252-bar high = (highest high reference over 252 bars − close) / highest high reference over 252 bars × 100
Calculation: Relative volume = volume / 20-bar SMA(volume)
Long: (EMA(8) > EMA(21) AND EMA(21) > EMA(50) AND close > EMA(200) AND (VWAP filter disabled OR close > VWAP) AND distance to 252-bar high ≤ 15 AND relative volume ≥ 1.2 AND close crosses above the highest high reference of the prior 20 bars) OR (EMA(8) > EMA(21) AND EMA(21) > EMA(50) AND close > EMA(200) AND (VWAP filter disabled OR close > VWAP) AND low reference ≥ 0.98 × EMA(21) AND high reference ≤ 1.05 × EMA(8) AND relative volume < 0.8) OR (EMA(8) > EMA(21) AND EMA(21) > EMA(50) AND close > EMA(200) AND (VWAP filter disabled OR close > VWAP) AND low reference ≥ 0.98 × EMA(21) AND low reference ≤ 1.01 × EMA(21) AND MFI(14) > 50) OR (close crosses above EMA(200) AND relative volume ≥ 1.3 AND close > VWAP)
Short: 
Exit: 