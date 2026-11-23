Calculation: HighDrift(B) = average of the latest N non-NA PivotHigh(high(B), P, P) values, defined once at least M exist
Calculation: LowDrift(B) = average of the latest N non-NA PivotLow(low(B), P, P) values, defined once at least M exist
Calculation: TrendState(B) = bullish when HighDrift(B) and LowDrift(B) are defined AND close(B) crosses above HighDrift(B); bearish when HighDrift(B) and LowDrift(B) are defined AND close(B) crosses below LowDrift(B); otherwise TrendState(B)[1], bullish when undefined
Long: TrendState(chart bars) is bullish
Short: TrendState(chart bars) is bearish