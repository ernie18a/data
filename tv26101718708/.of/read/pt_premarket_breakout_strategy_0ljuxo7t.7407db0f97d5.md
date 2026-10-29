Calculation: Premarket high = highest high during the configured premarket session; reset at the daily reset window
Calculation: Premarket low = lowest low during the configured premarket session; reset at the daily reset window
Calculation: Premarket breakout state = reset to neutral during the premarket session; when neutral, set to long if close > premarket high or short if close < premarket low; otherwise retain the state until reset
Calculation: Daily ATR buffer = configured percentage of ATR calculated from daily bars using a Wilder moving average of true range; use the still-forming higher-timeframe daily bar
Calculation: Long stop = if entry price > premarket high, premarket low − daily ATR buffer; otherwise entry price − (premarket high − premarket low) − daily ATR buffer
Calculation: Short stop = if entry price < premarket low, premarket high + daily ATR buffer; otherwise entry price + (premarket high − premarket low) + daily ATR buffer
Calculation: Long target = entry price + (entry price − long stop) × configured reward-to-risk ratio
Calculation: Short target = entry price − (short stop − entry price) × configured reward-to-risk ratio
Calculation: Bearish RSI condition = smoothed RSI < its longer-lookback moving average, RSI < 50, and RSI < smoothed RSI
Calculation: Bullish RSI condition = smoothed RSI > its longer-lookback moving average, RSI > 50, and RSI > smoothed RSI
Long: premarket breakout state is long AND no trade has yet been taken since the daily reset AND datetime is within the configured trading window and entry session AND previous-bar Stochastic RSI D < configured lower threshold AND Stochastic RSI K crosses above D
Short: premarket breakout state is short AND no trade has yet been taken since the daily reset AND datetime is within the configured trading window and entry session AND previous-bar Stochastic RSI D > configured upper threshold AND Stochastic RSI K crosses below D
Exit: long, low <= long stop OR high >= long target OR (open profit <= 0 AND Stochastic RSI D > configured upper exit threshold AND bearish RSI condition) OR datetime is within the configured daily reset window
Exit: short, high >= short stop OR low <= short target OR (open profit <= 0 AND Stochastic RSI D < configured lower exit threshold AND bullish RSI condition) OR datetime is within the configured daily reset window