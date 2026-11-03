Calculation: Lower shadow = min(open, close) - low
Calculation: Candle range = high - low
Calculation: Volume MACD = EMA(volume, longer lookback) - EMA(volume, shorter lookback); signal line = EMA(Volume MACD, shorter signal lookback)
Long: Position is flat AND ((RSI is below its oversold threshold AND close is below the Bollinger lower band AND (close > open OR lower shadow exceeds its threshold fraction of candle range)) OR (close is sufficiently below the 60-period SMA AND (close > open OR lower shadow exceeds its threshold fraction of candle range)) OR (a confirmed pivot low has a lower price low and a higher MACD histogram than the preceding comparison low, the histogram is below zero, AND current MACD histogram > prior-bar MACD histogram))
Long: MACD line > MACD signal line AND CCI > its breakout threshold AND close > short-term SMA AND Volume MACD > its signal line
Exit: Long left-side position, fast SMA < slow SMA AND (close < fast SMA OR close >= slow SMA OR (prior-bar RSI > its rebound threshold AND RSI crosses below its short-lookback SMA))
Exit: Long left-side position, close < entry price - ATR × hard-stop multiple
Exit: Long, close < highest high since position opened - ATR × trailing-stop multiple
Exit: Long, close crosses below fast SMA AND MACD line < MACD signal line