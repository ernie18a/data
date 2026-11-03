Calculation: Bollinger Band width = (upper Bollinger Band − lower Bollinger Band) / Bollinger Band basis
Calculation: Squeeze = Bollinger Band width < its simple moving average over a lookback
Calculation: Long stop = signal-bar close − ATR × stop multiplier
Calculation: Long target = signal-bar close + ATR × target multiplier
Calculation: Short stop = signal-bar close + ATR × stop multiplier
Calculation: Short target = signal-bar close − ATR × target multiplier
Long: Previous bar was in a squeeze AND close crosses above the upper Bollinger Band AND volume > its simple moving average AND position is flat
Short: Previous bar was in a squeeze AND close crosses below the lower Bollinger Band AND volume > its simple moving average AND position is flat
Exit: Long, low ≤ long stop OR high ≥ long target
Exit: Short, high ≥ short stop OR low ≤ short target