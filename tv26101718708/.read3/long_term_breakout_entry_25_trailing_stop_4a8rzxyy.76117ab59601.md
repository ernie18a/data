Calculation: Long trailing stop = if long then max(close * (1 - trailing percentage), Long trailing stop[1]) else 0
Long: close crosses above highest(close, breakout lookback)[1] AND SMA(close, shorter lookback) * SMA(volume, shorter lookback) > threshold
Exit: long, close crosses below SMA(close, longer lookback) OR low <= Long trailing stop