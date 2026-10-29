Calculation: Score = +1 if close > short-lookback EMA of close, otherwise -1; +1 if close > long-lookback EMA of close, otherwise -1; -2 if RSI > 70, otherwise +1 if RSI < 50, otherwise -1; +1 if volume > its longer-lookback SMA, otherwise -1. The long-lookback EMA uses a longer lookback than the short-lookback EMA.
Calculation: Trend state = bullish if Score >= 2; bearish if Score <= -2; otherwise the previous trend state; initially neutral.
Long: Trend state = bullish AND previous trend state != bullish
Exit: Long, Trend state = bearish AND previous trend state != bearish