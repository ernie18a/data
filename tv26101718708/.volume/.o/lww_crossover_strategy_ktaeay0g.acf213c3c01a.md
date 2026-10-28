Calculation: VWAP = session VWAP calculated from chart bars using typical price (high + low + close) / 3
Calculation: MVWAP = EMA of VWAP with a longer lookback than the EMA used for smoothed VWAP
Calculation: Smoothed VWAP = EMA of VWAP with a shorter lookback than MVWAP
Calculation: Short-term EMA = EMA of close with a shorter lookback than the long-term EMA
Calculation: Long-term EMA = EMA of close with a longer lookback than the short-term EMA
Long: no open position AND short-term EMA >= MVWAP AND long-term EMA >= MVWAP AND smoothed VWAP >= MVWAP AND this condition was false on the previous chart bar
Short: no open position AND short-term EMA <= MVWAP AND long-term EMA <= MVWAP AND smoothed VWAP <= MVWAP AND this condition was false on the previous chart bar
Exit: long, low <= entry price minus stop distance OR high >= entry price plus target distance OR (opposite-signal closing is enabled AND short-entry condition is true)
Exit: short, high >= entry price plus stop distance OR low <= entry price minus target distance OR (opposite-signal closing is enabled AND long-entry condition is true)