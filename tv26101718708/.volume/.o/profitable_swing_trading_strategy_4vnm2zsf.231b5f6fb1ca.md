Long: (Fast EMA crosses above medium EMA AND close > trend EMA OR Fast EMA > medium EMA > trend EMA AND close > trend EMA AND close > medium EMA AND close is within a configured percentage above medium EMA AND MACD line > MACD signal line AND RSI is above its lower momentum threshold AND below its upper momentum threshold) AND (volume confirmation is disabled OR volume > volume moving average)
Short: (Fast EMA crosses below medium EMA AND close < trend EMA OR Fast EMA < medium EMA < trend EMA AND close < trend EMA AND close < medium EMA AND close is within a configured percentage below medium EMA AND MACD line < MACD signal line AND RSI is below its upper momentum threshold AND above its lower momentum threshold) AND (volume confirmation is disabled OR volume > volume moving average)
Calculation: ATR = average true range of current-timeframe bars
Calculation: Long stop = signal-bar close − ATR × configured stop multiplier
Calculation: Long target = signal-bar close + (signal-bar close − Long stop) × configured risk/reward ratio
Calculation: Short stop = signal-bar close + ATR × configured stop multiplier
Calculation: Short target = signal-bar close − (Short stop − signal-bar close) × configured risk/reward ratio
Exit: long, Fast EMA crosses below medium EMA OR close < trend EMA OR RSI > configured overbought threshold OR low ≤ Long stop OR high ≥ Long target
Exit: short, Fast EMA crosses above medium EMA OR close > trend EMA OR RSI < configured oversold threshold OR high ≥ Short stop OR low ≤ Short target