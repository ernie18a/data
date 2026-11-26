Long: datetime is within the session parameter AND volume > the volume-spike threshold parameter AND close > Fibonacci channel level(upper breakout parameter)
Long: close[1] > Fibonacci channel level(overbought parameter) AND low <= VWAP AND close >= VWAP AND (low < min(open, close) OR close > open)
Long: low < Fibonacci channel level(bottom parameter) AND close > Fibonacci channel level(bottom parameter) AND close <= Fibonacci channel level(recovery ceiling parameter) AND close > open AND close - open > bullish-body threshold parameter
Exit: long, high >= Fibonacci channel level(first profit target parameter)
Exit: long, high >= Fibonacci channel level(final profit target parameter)
Exit: long, close < VWAP AND volume < low-volume threshold parameter
Exit: long, high >= Fibonacci channel level(first resistance parameter) OR high >= Fibonacci channel level(second resistance parameter)
Exit: long, low <= Fibonacci channel level(breakdown target parameter) AND close < VWAP AND close < open
Exit: long, high >= Fibonacci channel level(first rebound target parameter) OR high >= VWAP
Exit: long, close < Fibonacci channel level(bottom parameter)