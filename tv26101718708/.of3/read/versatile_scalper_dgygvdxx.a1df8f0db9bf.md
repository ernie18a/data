Calculation: Smoothed regression signal = simple or exponential moving average of either LinReg(close, regression lookback) or close, using the signal smoothing lookback.
Calculation: RSI candle state = bullish after RSI(close, RSI lookback) crosses above SMA(RSI(close, RSI lookback), separate RSI-SMA lookback), and bearish after it crosses below; initially bearish.
Long: Smoothed regression signal > its value one bar ago.
Short: Smoothed regression signal <= its value one bar ago.
Long: RSI candle state = bullish.
Short: RSI candle state = bearish.
Long: close > session VWAP(hlc3).
Short: close < session VWAP(hlc3).
Long: Supertrend(ATR lookback, ATR multiplier) changes from bearish to bullish AND no bullish Supertrend signal occurred within the cooldown lookback.
Short: Supertrend(ATR lookback, ATR multiplier) changes from bullish to bearish AND no bearish Supertrend signal occurred within the cooldown lookback.
Long: confirmed pivot high(selected high-or-close source, pivot lookback, same pivot lookback) > preceding confirmed pivot high OR confirmed pivot low(selected low-or-close source, pivot lookback, same pivot lookback) > preceding confirmed pivot low.
Short: confirmed pivot high(selected high-or-close source, pivot lookback, same pivot lookback) < preceding confirmed pivot high OR confirmed pivot low(selected low-or-close source, pivot lookback, same pivot lookback) < preceding confirmed pivot low.
Long: RSI candle state = bullish AND Smoothed regression signal > its value one bar ago AND close > session VWAP(hlc3) AND a bullish Supertrend signal fires AND the latest confirmed pivot high is higher than its preceding confirmed pivot high AND the latest confirmed pivot low is higher than its preceding confirmed pivot low.
Short: RSI candle state = bearish AND Smoothed regression signal < its value one bar ago AND close < session VWAP(hlc3) AND a bearish Supertrend signal fires AND the latest confirmed pivot high is lower than its preceding confirmed pivot high AND the latest confirmed pivot low is lower than its preceding confirmed pivot low.