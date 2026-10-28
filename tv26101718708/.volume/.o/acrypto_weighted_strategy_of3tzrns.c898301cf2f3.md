Calculation: MACD = shorter-lookback moving average of its configured source minus longer-lookback moving average of its configured source
Calculation: MACD signal = 9-bar simple moving average of MACD
Calculation: Stochastic RSI = stochastic of RSI, smoothed with a simple moving average
Calculation: Weighted long score = sum of the configured weights for each active long signal
Calculation: Weighted short score = sum of the configured weights for each active short signal
Calculation: Profit target = entry price plus (long) or minus (short) the side’s profit increment multiplied by the target number
Long: MACD > MACD signal now AND MACD > MACD signal at delay − 1 bars ago AND MACD <= MACD signal at delay bars ago
Long: MACD <= MACD signal at delay bars ago AND MACD > MACD signal now AND MACD > MACD signal at delay − 1 bars ago
Long: Stochastic RSI was at or below its oversold threshold delay bars ago AND it is below its overbought threshold now AND bars since entry and since last close are each at least the exit delay
Long: RSI was at or below its oversold threshold delay bars ago AND it is below its overbought threshold now AND bars since entry and since last close are each at least the exit delay
Long: Supertrend changed from down to up, with the up state holding now and at delay − 1 bars ago
Long: The shorter-lookback moving average crossed above the longer-lookback moving average, with the shorter average above the longer one now and at delay − 1 bars ago
Long: Weighted long score >= entry weight trigger
Short: MACD < MACD signal now AND MACD < MACD signal at delay − 1 bars ago AND MACD >= MACD signal at delay bars ago
Short: MACD >= MACD signal at delay bars ago AND MACD < MACD signal now AND MACD < MACD signal at delay − 1 bars ago
Short: Stochastic RSI was at or above its overbought threshold delay bars ago AND it is above its oversold threshold now AND bars since entry and since last close are each at least the exit delay
Short: RSI was at or above its overbought threshold delay bars ago AND it is above its oversold threshold now AND bars since entry and since last close are each at least the exit delay
Short: Supertrend changed from up to down, with the down state holding now and at delay − 1 bars ago
Short: The shorter-lookback moving average crossed below the longer-lookback moving average, with the shorter average below the longer one now and at delay − 1 bars ago
Short: Weighted short score >= entry weight trigger
Exit: Long, high >= any active profit target
Exit: Short, low <= any active profit target
Exit: Long, stop source <= long stop price
Exit: Short, stop source >= short stop price
Exit: Long, weighted short score >= entry weight trigger when longs are allowed and shorts are not
Exit: Short, weighted long score >= entry weight trigger when shorts are allowed and longs are not
Exit: Long, short signal from any active strategy when longs are allowed and shorts are not
Exit: Short, long signal from any active strategy when shorts are allowed and longs are not