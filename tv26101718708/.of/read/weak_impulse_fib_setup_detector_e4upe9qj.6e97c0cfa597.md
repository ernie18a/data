Calculation: Confirmed swing high/low = pivot high/low with equal left and right lookbacks; use the latest confirmed pivot.
Calculation: Long stop = weak bearish signal candle low + its high-low range × configured stop fib level
Calculation: Long target = weak bearish signal candle low + its high-low range × configured target fib level
Calculation: Short stop = weak bullish signal candle high − its high-low range × configured stop fib level
Calculation: Short target = weak bullish signal candle high − its high-low range × configured target fib level
Long: Current low < the last confirmed swing low value from the swing-lookback bars earlier AND close < open AND abs(close − open) > (high − max(close, open)) + (min(close, open) − low) AND volume < its moving average
Short: Current high > the last confirmed swing high value from the swing-lookback bars earlier AND close > open AND abs(close − open) > (high − max(close, open)) + (min(close, open) − low) AND volume < its moving average
Exit: Long, low <= long stop OR high >= long target
Exit: Short, high >= short stop OR low <= short target