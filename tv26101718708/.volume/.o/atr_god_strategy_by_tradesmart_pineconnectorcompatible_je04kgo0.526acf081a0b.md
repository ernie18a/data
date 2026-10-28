Long: Any configured entry Supertrend flips from bearish to bullish
Short: Any configured entry Supertrend flips from bullish to bearish
Calculation: Supertrend direction = bullish or bearish state; bullish flip occurs when close crosses above the prior bearish band, bearish flip when close crosses below the prior bullish band
Long: Any enabled Supertrend Buy marking occurs
Short: Any enabled Supertrend Sell marking occurs
Long: A configured entry Supertrend flips bullish AND every Supertrend trend constraint configured for long is satisfied AND volume > its configured moving average when the volume filter is enabled AND the configured ATR bounds and ATR-to-moving-average condition are satisfied when the ATR limiter is enabled AND configured Waddah Attar conditions for long are satisfied AND close > configured long moving average when enabled AND configured session, date, and trading-time limits are satisfied AND long entries are allowed
Short: A configured entry Supertrend flips bearish AND every Supertrend trend constraint configured for short is satisfied AND volume > its configured moving average when the volume filter is enabled AND the configured ATR bounds and ATR-to-moving-average condition are satisfied when the ATR limiter is enabled AND configured Waddah Attar conditions for short are satisfied AND close < configured short moving average when enabled AND configured session, date, and trading-time limits are satisfied AND short entries are allowed
Calculation: True range = max(high − low, abs(high − previous close), abs(low − previous close)); ATR = configured smoothing of true range
Calculation: Waddah Attar value = abs(change in (fast moving average of close − slow moving average of close)) × sensitivity; explosion = upper Bollinger band of close − lower Bollinger band of close; deadzone = RMA of true range over its configured lookback × its configured multiplier
Calculation: Stop distance = configured ATR × risk multiplier, or configured candle-based, percentage-based, or pip-based stop distance
Calculation: Long target = signal-bar close + stop distance × reward-to-risk ratio; long stop = signal-bar close − stop distance
Calculation: Short target = signal-bar close − stop distance × reward-to-risk ratio; short stop = signal-bar close + stop distance
Exit: Long, low ≤ long stop OR high ≥ long target OR an enabled custom session has just closed
Exit: Short, high ≥ short stop OR low ≤ short target OR an enabled custom session has just closed