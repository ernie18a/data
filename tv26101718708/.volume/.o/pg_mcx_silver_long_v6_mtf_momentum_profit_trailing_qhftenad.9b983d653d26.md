Calculation: SD-1 = signal-timeframe VWMA minus the signal-timeframe standard deviation of close; use the latest available signal-timeframe bar (forming in real time; completed historical values, with lookahead off)
Long: signal-timeframe close > SD-1 AND signal-timeframe ROC > 0
Calculation: Highest high since entry = highest backtest-bar high since the current long position was opened
Calculation: Emergency stop = entry price × (1 − emergency stop percentage)
Calculation: Trailing stop = highest high since entry × (1 − trailing distance percentage)
Calculation: Trailing active = highest high since entry ≥ entry price × (1 + trail activation percentage)
Exit: Long, low ≤ emergency stop OR (trailing active AND low ≤ trailing stop)