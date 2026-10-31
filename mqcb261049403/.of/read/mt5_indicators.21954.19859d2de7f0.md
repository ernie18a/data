Calculation: Oscillator close = selected moving average of (CCI of close × volume).
Calculation: Oscillator open = selected moving average of (CCI of open × volume); replace it with the previous bar's oscillator close when abs(open − close) is at most the gap threshold.
Long: Oscillator close >= oscillator open.
Short: Oscillator close < oscillator open.
Long: Previous oscillator close < 0 AND current oscillator close >= 0.
Short: Previous oscillator close > 0 AND current oscillator close <= 0.