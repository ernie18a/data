Calculation: Average volume = SMA of volume over the volume lookback.
Calculation: Net pressure = volume × (close − low) / (high − low + 0.0001) − volume × (high − close) / (high − low + 0.0001).
Calculation: Pressure score = net pressure / SMA of absolute net pressure over the volume lookback when that SMA > 0; otherwise 0.
Calculation: Volume factor = (volume / average volume) raised to the volume-effect exponent when average volume > 0; otherwise 1.
Calculation: Pressure-weighted MACD = EMA of ((shorter-period EMA of close − longer-period EMA of close) × volume factor × (1 + clamp(pressure score × 0.1, −0.3, 0.3))).
Calculation: Signal = EMA of pressure-weighted MACD.
Calculation: Histogram = pressure-weighted MACD − signal.
Calculation: Confirmed pivot = a pivot high or low confirmed after a right-side lookback; the left-side lookback is the greater of half the right-side lookback and 2 bars. Compare each series with its own immediately preceding confirmed pivot of the same type, which need not have occurred on the same bar as the preceding pivot of the other series.
Long: Pressure-weighted MACD crosses above signal.
Short: Pressure-weighted MACD crosses below signal.
Long: Histogram >= 0.
Short: Histogram < 0.
Long: Pressure-weighted MACD > signal.
Short: Pressure-weighted MACD <= signal.
Long: Pressure score > 0.5.
Short: Pressure score < −0.5.
Long: A price low pivot and a pressure-weighted MACD low pivot are confirmed on the same bar AND the price pivot is lower than its preceding price low pivot AND the MACD pivot is higher than its preceding MACD low pivot.
Short: A price high pivot and a pressure-weighted MACD high pivot are confirmed on the same bar AND the price pivot is higher than its preceding price high pivot AND the MACD pivot is lower than its preceding MACD high pivot.
Long: A price low pivot and a histogram low pivot are confirmed on the same bar AND the price pivot is lower than its preceding price low pivot AND the histogram pivot is higher than its preceding histogram low pivot.
Short: A price high pivot and a histogram high pivot are confirmed on the same bar AND the price pivot is higher than its preceding price high pivot AND the histogram pivot is lower than its preceding histogram high pivot.