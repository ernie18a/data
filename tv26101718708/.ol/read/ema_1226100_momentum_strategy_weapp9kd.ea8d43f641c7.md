Calculation: Fast EMA = exponential moving average of close with a shorter lookback than the slow EMA
Calculation: Slow EMA = exponential moving average of close with a longer lookback than the fast EMA and shorter than the trend EMA
Calculation: Trend EMA = exponential moving average of close with a longer lookback than the slow EMA
Calculation: MACD line = shorter-lookback EMA of close minus longer-lookback EMA of close
Calculation: MACD signal line = EMA of the MACD line
Calculation: RSI = relative strength index of close
Calculation: Volume average = simple moving average of volume
Calculation: ADX = average directional index
Calculation: Bollinger lower band = close’s moving average minus a standard-deviation multiple of close
Calculation: Bollinger upper band = close’s moving average plus a standard-deviation multiple of close
Calculation: Bullish candle = close > open AND close - open > 0.6 × (high - low)
Calculation: Bearish candle = close < open AND open - close > 0.6 × (high - low)
Calculation: Volume spike = volume > volume average × volume multiplier
Calculation: Bull trend = close > trend EMA AND fast EMA > slow EMA
Calculation: Bear trend = close < trend EMA AND fast EMA < slow EMA
Calculation: Long stop = entry price × (1 - stop percentage), raised to close × (1 - trailing offset percentage) when close is at least the trailing activation percentage above entry price and that candidate exceeds the previous stop
Calculation: Short stop = entry price × (1 + stop percentage), lowered to close × (1 + trailing offset percentage) when close is at least the trailing activation percentage below entry price and that candidate is below the previous stop
Calculation: Long target = entry price × (1 + take-profit percentage)
Calculation: Short target = entry price × (1 - take-profit percentage)
Long: position is flat AND (fast EMA crosses above slow EMA OR MACD line crosses above MACD signal line OR previous RSI < oversold threshold AND RSI > oversold threshold AND RSI > previous RSI OR close > highest high of the preceding lookback bars AND volume spike OR bull trend AND low <= fast EMA × pullback factor AND close > fast EMA AND bullish candle OR previous close <= Bollinger lower band AND close > Bollinger lower band AND bullish candle) AND bull trend AND volume spike AND (ADX filter disabled OR ADX > ADX threshold) AND RSI < long RSI limit
Short: position is flat AND (fast EMA crosses below slow EMA OR MACD line crosses below MACD signal line OR previous RSI > overbought threshold AND RSI < overbought threshold AND RSI < previous RSI OR close < lowest low of the preceding lookback bars AND volume spike OR bear trend AND high >= fast EMA × pullback factor AND close < fast EMA AND bearish candle OR previous close >= Bollinger upper band AND close < Bollinger upper band AND bearish candle) AND bear trend AND volume spike AND (ADX filter disabled OR ADX > ADX threshold) AND RSI > short RSI limit
Exit: long, low <= long stop OR high >= long target OR fast EMA crosses below slow EMA OR bars since entry >= maximum hold bars
Exit: short, high >= short stop OR low <= short target OR fast EMA crosses above slow EMA OR bars since entry >= maximum hold bars