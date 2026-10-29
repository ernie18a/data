Calculation: Trend EMA = exponential moving average of close over the trend lookback
Calculation: Trend slope = current Trend EMA − Trend EMA five bars earlier
Calculation: Prior range high/low = highest high / lowest low over the trigger lookback, excluding the current bar
Calculation: ATR = average true range over its lookback
Long: no active tracked setup AND trigger cooldown elapsed AND long context (forced long, or automatic with close ≥ Trend EMA and Trend slope ≥ 0) AND the selected trigger condition is met: close crosses above Prior range high; OR bullish close above the previous high with body size ≥ the impulse threshold × ATR and close ≥ Trend EMA; OR close crosses above Trend EMA
Short: no active tracked setup AND trigger cooldown elapsed AND short context (forced short, or automatic when long context is false) AND the selected trigger condition is met: close crosses below Prior range low; OR bearish close below the previous low with body size ≥ the impulse threshold × ATR and close ≤ Trend EMA; OR close crosses below Trend EMA
Exit: long, low ≤ the low over the trigger lookback at trigger time − ATR at trigger time × risk buffer
Exit: short, high ≥ the high over the trigger lookback at trigger time + ATR at trigger time × risk buffer