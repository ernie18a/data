Calculation: Higher-low count = number of qualifying bars since the last long entry; increment when the current low is above the lowest low of the prior shorter lookback; reset on long entry.
Calculation: Lower-high count = number of qualifying bars since the last short entry; increment when the current high is below the highest high of the prior shorter lookback; reset on short entry.
Calculation: SMA slope = long-term SMA minus that same SMA from a shorter lookback ago.
Calculation: Bullish engulfing = current candle is bullish, previous candle is bullish, and the current body contains the previous body.
Calculation: Bearish engulfing = current candle is bearish, previous candle is bearish, and the current body contains the previous body.
Calculation: Stop distance = current bar range, halved when it exceeds the configured large-candle threshold.
Long: close > long-term SMA AND SMA slope > positive threshold AND higher-low count is divisible by three AND bullish engulfing AND volume > shorter-lookback volume SMA AND current bar range <= configured maximum AND within the configured trading session.
Short: close < long-term SMA AND SMA slope < negative threshold AND lower-high count is divisible by three AND bearish engulfing AND volume > shorter-lookback volume SMA AND current bar range <= configured maximum AND within the configured trading session.
Exit: long, low <= long signal bar close − stop distance OR high >= long signal bar close + configured reward multiple × stop distance.
Exit: short, high >= short signal bar close + stop distance OR low <= short signal bar close − configured reward multiple × stop distance.