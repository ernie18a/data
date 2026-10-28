Calculation: Premarket high = highest high during the current day's premarket session; reset at the daily reset window
Calculation: Premarket low = lowest low during the current day's premarket session; reset at the daily reset window
Calculation: Premarket range = premarket high - premarket low
Calculation: Breakout direction = after resetting during the premarket session, set bullish when close > premarket high or bearish when close < premarket low; otherwise retain the set direction until reset
Calculation: Daily ATR = Wilder moving average of true range on daily bars, using the last completed daily bar
Calculation: ATR buffer = daily ATR × configured percentage
Calculation: Long stop = if entry price > premarket high, premarket low - ATR buffer; otherwise entry price - premarket range - ATR buffer
Calculation: Short stop = if entry price < premarket low, premarket high + ATR buffer; otherwise entry price + premarket range + ATR buffer
Calculation: Long target = entry price + (entry price - long stop) × configured reward-to-risk ratio
Calculation: Short target = entry price - (short stop - entry price) × configured reward-to-risk ratio
Calculation: RSI = Wilder RSI of close
Calculation: Smoothed RSI = short-period SMA of RSI
Calculation: RSI average = longer-period selectable moving average of RSI
Calculation: Bearish RSI condition = smoothed RSI < RSI average AND RSI < 50 AND RSI < smoothed RSI
Calculation: Bullish RSI condition = smoothed RSI > RSI average AND RSI > 50 AND RSI > smoothed RSI
Long: bullish breakout direction AND no trade yet taken since daily reset AND within configured date and entry-session windows AND previous-bar stochastic RSI D < configured lower threshold AND stochastic RSI K crosses above D
Short: bearish breakout direction AND no trade yet taken since daily reset AND within configured date and entry-session windows AND previous-bar stochastic RSI D > configured upper threshold AND stochastic RSI K crosses below D
Exit: long, low <= long stop OR high >= long target OR (stochastic RSI D > configured upper threshold AND close <= entry price AND bearish RSI condition) OR within the configured daily reset/close windows
Exit: short, high >= short stop OR low <= short target OR (stochastic RSI D < configured lower threshold AND close >= entry price AND bullish RSI condition) OR within the configured daily reset/close windows