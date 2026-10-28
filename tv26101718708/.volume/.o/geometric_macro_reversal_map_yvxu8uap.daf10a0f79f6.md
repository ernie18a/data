Calculation: Candle cut ratio = if high > level and low < level, min(high − level, level − low) / (high − low); otherwise 0
Calculation: Level strength percentage = min(5 × level mass, 100)
Calculation: Level side = resistance if created by a pivot high, support if created by a pivot low; on a candle with cut ratio > 0, support if close > level and resistance if close < level
Long: level side is support AND (level strength percentage ≤ 20 OR (level strength percentage > 20 AND level strength percentage < 90 AND candle cut ratio > 0 AND candle cut ratio < 0.2))
Short: level side is resistance AND (level strength percentage ≤ 20 OR (level strength percentage > 20 AND level strength percentage < 90 AND candle cut ratio > 0 AND candle cut ratio < 0.2))