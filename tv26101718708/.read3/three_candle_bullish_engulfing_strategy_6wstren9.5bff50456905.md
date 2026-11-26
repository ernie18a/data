Calculation: Breakout trigger price = chart-bar close on the most recent chart bar where RSI(OHLC4, RSI lookback parameter) on T1 bars, using the current T1 bar as sampled on chart bars, is at least the RSI threshold parameter AND that T1 bar closes above its open; retain until the next qualifying chart bar
Long: close[2] > open[2] AND abs(close[1] - open[1]) <= abs(close[2] - open[2]) * small-body ratio parameter AND close > open AND close > high[1]
Short: close[2] < open[2] AND abs(close[1] - open[1]) <= abs(close[2] - open[2]) * small-body ratio parameter AND close < open AND close < low[1]
Long: position side is not long AND a breakout trigger price exists AND close > breakout trigger price
Exit: long, close < low[1]
Exit: short, close > high[1]
Exit: long, close <= breakout trigger price * (1 - stop-loss percentage parameter / 100)
Exit: long, a new qualifying breakout trigger occurs while long
Exit: long, hour(datetime) = exit-hour parameter AND minute(datetime) >= exit-minute parameter
Exit: short, hour(datetime) = exit-hour parameter AND minute(datetime) >= exit-minute parameter