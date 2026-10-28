Calculation: Fast and slow EMA = exponential moving averages of close, with the fast EMA using a shorter lookback than the slow EMA.
Calculation: Pullback, trend, and macro EMA = exponential moving averages of close, with the pullback EMA using a shorter lookback than the trend EMA, and the trend EMA using a shorter lookback than the macro EMA.
Calculation: Volume average = simple moving average of volume.
Long: Close > trend EMA AND trend EMA > macro EMA AND (low <= pullback EMA OR low <= trend EMA) AND fast EMA crosses above slow EMA AND MACD line crosses above MACD signal line AND RSI > its long-entry threshold AND +DI > -DI AND ADX > its minimum threshold AND volume > volume average
Short: Close < trend EMA AND trend EMA < macro EMA AND (high >= pullback EMA OR high >= trend EMA) AND fast EMA crosses below slow EMA AND MACD line crosses below MACD signal line AND RSI < its short-entry threshold AND -DI > +DI AND ADX > its minimum threshold AND volume > volume average
Exit: Long, low <= entry price - ATR × stop multiple OR high >= entry price + ATR × target multiple
Exit: Short, high >= entry price + ATR × stop multiple OR low <= entry price - ATR × target multiple