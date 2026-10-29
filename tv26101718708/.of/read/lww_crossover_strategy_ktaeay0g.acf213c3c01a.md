Calculation: smoothed VWAP = EMA of VWAP using a shorter lookback than MVWAP
Calculation: MVWAP = EMA of VWAP
Calculation: fast EMA = EMA of its selected price source using a shorter lookback than the slow EMA
Long: no open position AND fast EMA >= MVWAP AND slow EMA >= MVWAP AND smoothed VWAP >= MVWAP AND the condition was false on the previous bar
Short: no open position AND fast EMA <= MVWAP AND slow EMA <= MVWAP AND smoothed VWAP <= MVWAP AND the condition was false on the previous bar
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance OR (opposite-signal closing is enabled AND short-entry condition is true)
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance OR (opposite-signal closing is enabled AND long-entry condition is true)