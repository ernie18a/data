Calculation: Fast EMA = exponential moving average of close with a shorter lookback
Calculation: Slow EMA = exponential moving average of close with a longer lookback
Calculation: Long stop = signal-bar close − ATR × stop multiplier
Calculation: Long target = signal-bar close + (signal-bar close − long stop) × reward/risk multiplier
Calculation: Short stop = signal-bar close + ATR × stop multiplier
Calculation: Short target = signal-bar close − (short stop − signal-bar close) × reward/risk multiplier
Calculation: Bars since flat = number of bars since the most recent bar with no open position
Long: Fast EMA crosses above slow EMA AND RSI > threshold AND volume > its longer-lookback SMA
Short: Fast EMA crosses below slow EMA AND RSI < threshold AND volume > its longer-lookback SMA
Exit: Long, low ≤ long stop OR high ≥ long target
Exit: Short, high ≥ short stop OR low ≤ short target
Exit: Long or short, bars since flat > trade limit