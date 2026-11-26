Calculation: normalized price-range oscillator = JJMA(100 * (applied price - (MA(applied price, shared lookback, method 1, phase 1) - MA(high - low, shared lookback, method 2, phase 2))) / (2 * (MA(high - low, shared lookback, method 2, phase 2), replaced by 1 when zero)) - 50, smoothing lookback, phase parameter)
Long: normalized price-range oscillator > upper threshold
Long: normalized price-range oscillator > 0 AND normalized price-range oscillator <= upper threshold
Short: normalized price-range oscillator < lower threshold
Short: normalized price-range oscillator < 0 AND normalized price-range oscillator >= lower threshold
Long: normalized price-range oscillator calculated on the still-forming T1 bar and sampled on chart bars > upper threshold
Long: normalized price-range oscillator calculated on the still-forming T1 bar and sampled on chart bars > 0 AND normalized price-range oscillator calculated on the still-forming T1 bar and sampled on chart bars <= upper threshold
Short: normalized price-range oscillator calculated on the still-forming T1 bar and sampled on chart bars < lower threshold
Short: normalized price-range oscillator calculated on the still-forming T1 bar and sampled on chart bars < 0 AND normalized price-range oscillator calculated on the still-forming T1 bar and sampled on chart bars >= lower threshold