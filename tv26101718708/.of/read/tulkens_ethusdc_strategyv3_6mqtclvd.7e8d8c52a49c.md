Calculation: Fast EMA = EMA of Heikin-Ashi close from a higher timeframe, using the current bar still forming and the configured chart-bar shift.
Calculation: Slow EMA = EMA of Heikin-Ashi close from a higher timeframe, using the last completed bar and the configured chart-bar shift; its lookback is longer than the fast EMA’s.
Calculation: MACD line and signal line = MACD and its signal line calculated from higher-timeframe Heikin-Ashi close, using the last completed bar.
Long: Fast EMA crosses above Slow EMA AND (MACD line > MACD signal line OR MACD filter is disabled).
Short: Fast EMA crosses below Slow EMA AND (MACD line < MACD signal line OR MACD filter is disabled).