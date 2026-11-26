Calculation: Opening-range high = highest(high, opening-range lookback) over the opening-range bars, captured when the range is set
Calculation: Opening-range low = lowest(low, opening-range lookback) over the opening-range bars, captured when the range is set
Calculation: Opening-range average volume = SMA(volume, opening-range lookback) over the opening-range bars, captured when the range is set
Calculation: Initial long stop = lowest(low, stop lookback) - ATR(ATR lookback) * stop multiplier, calculated at entry
Calculation: Initial short stop = highest(high, stop lookback) + ATR(ATR lookback) * stop multiplier, calculated at entry
Calculation: Long target 1 = entry price + (entry price - initial long stop) * target 1 risk/reward parameter
Calculation: Long target 2 = entry price + (entry price - initial long stop) * target 2 risk/reward parameter
Calculation: Short target 1 = entry price - (initial short stop - entry price) * target 1 risk/reward parameter
Calculation: Short target 2 = entry price - (initial short stop - entry price) * target 2 risk/reward parameter
Long: position is flat AND ((close crosses above SMA(close, shorter SMA lookback) AND RSI(close, RSI lookback) < oversold threshold AND close < VWAP(close) AND close > SMA(close, longer SMA lookback)) OR (EMA(close, shorter EMA lookback) crosses above EMA(close, longer EMA lookback) AND close > VWAP(close) AND close > SMA(close, longer SMA lookback)) OR (opening-range high is set AND close crosses above opening-range high AND volume > opening-range average volume * volume threshold)
Short: position is flat AND ((close crosses below SMA(close, shorter SMA lookback) AND RSI(close, RSI lookback) > overbought threshold AND close > VWAP(close) AND close < SMA(close, longer SMA lookback)) OR (EMA(close, shorter EMA lookback) crosses below EMA(close, longer EMA lookback) AND close < VWAP(close) AND close < SMA(close, longer SMA lookback)) OR (opening-range low is set AND close crosses below opening-range low AND volume > opening-range average volume * volume threshold)
Exit: Long, low <= initial long stop OR (target 1 has not been hit AND high >= long target 1) OR high >= long target 2
Exit: Long, target 1 has been hit AND low <= entry price
Exit: Short, high >= initial short stop OR (target 1 has not been hit AND low <= short target 1) OR low <= short target 2
Exit: Short, target 1 has been hit AND high >= entry price