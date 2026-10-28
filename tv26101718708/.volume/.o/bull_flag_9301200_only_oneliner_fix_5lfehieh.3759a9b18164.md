Calculation: Average volume = SMA(volume, configurable lookback); use the same average volume for impulse and breakout checks
Calculation: Bull flag = A bullish impulse bar (close > open, high − low ≥ configurable multiple of ATR, and volume ≥ configurable multiple of average volume) starts a flag during 09:30–12:00. Track its high and low, the lowest low since it began, and bars since it began. Retracement (%) = (impulse high − lowest low) / (impulse high − impulse low) × 100. The flag remains valid while retracement ≤ configurable maximum and bars since start ≤ configurable maximum; otherwise invalidate it.
Calculation: Long stop = lowest low tracked for the valid flag at entry
Calculation: Long target = entry price + configurable risk/reward multiple × (entry price − long stop)
Long: During 09:30–12:00, a bull flag is valid AND high > previous bar's high AND volume ≥ configurable multiple of average volume
Exit: long, low ≤ long stop OR high ≥ long target