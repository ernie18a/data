Calculation: Candle range = high - low
Calculation: Real body = abs(close - open)
Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Calculation: Short SMA = simple moving average of close over a shorter lookback
Calculation: Long EMA = exponential moving average of close over a longer lookback
Calculation: Short SMA slope = short SMA - short SMA from two bars earlier
Calculation: Long EMA slope = long EMA - long EMA from an earlier bar after a longer lookback
Calculation: ATR = average true range
Calculation: Volume average = simple moving average of volume
Long: (Candle range = 0 OR (Real body / Candle range <= body-ratio limit AND Lower wick / Candle range >= dominant-wick minimum AND Upper wick / Candle range <= opposite-wick maximum AND Lower wick > Real body AND Lower wick > Upper wick)) AND (short SMA filter disabled OR (min(open, close) > Short SMA AND low - Short SMA <= ATR × distance multiplier AND Short SMA slope > 0)) AND (longer SMA filter disabled OR (longer SMA slope > 0 AND min(open, close) > longer SMA)) AND (EMA filter disabled OR (min(open, close) >= Long EMA AND Long EMA slope > 0)) AND (volume filter disabled OR (volume >= Volume average × minimum multiplier AND volume <= Volume average × maximum multiplier))
Short: (Candle range = 0 OR (Real body / Candle range <= body-ratio limit AND Upper wick / Candle range >= dominant-wick minimum AND Lower wick / Candle range <= opposite-wick maximum AND Upper wick > Real body AND Upper wick > Lower wick)) AND (short SMA filter disabled OR (max(open, close) < Short SMA AND Short SMA - high <= ATR × distance multiplier AND Short SMA slope < 0)) AND (longer SMA filter disabled OR (longer SMA slope < 0 AND max(open, close) < longer SMA)) AND (EMA filter disabled OR (max(open, close) <= Long EMA AND Long EMA slope < 0)) AND (volume filter disabled OR (volume >= Volume average × minimum multiplier AND volume <= Volume average × maximum multiplier))