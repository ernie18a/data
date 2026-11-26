Calculation: CVD values = CVD(T1 anchor period, using T2 lower-timeframe values sampled on chart bars from the current, possibly still-forming T1 and T2 bars)
Calculation: Up/down volume delta = up/down volume delta from T2 lower-timeframe bars within each chart bar, sampled on chart bars using the current, possibly still-forming T2 bars
Calculation: MACD histogram = MACD histogram(source, fast lookback, slow lookback, signal lookback, oscillator MA type, signal MA type)
Long: CVD last value > CVD opening value OR Up/down volume delta > 0 OR MACD histogram crosses above zero
Short: CVD last value <= CVD opening value OR Up/down volume delta <= 0 OR MACD histogram crosses below zero