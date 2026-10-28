Calculation: Short-period EMA = exponential moving average of close with a shorter lookback than the long-period EMA
Calculation: Long-period EMA = exponential moving average of close with a longer lookback than the short-period EMA
Calculation: Cloud top = max(short-period EMA, long-period EMA)
Calculation: Cloud bottom = min(short-period EMA, long-period EMA)
Calculation: Candle body = abs(close - open)
Calculation: Lower wick = min(open, close) - low
Long: On the last completed bar, short-period EMA > long-period EMA AND close > short-period EMA AND close > long-period EMA AND close > cloud top AND close > open AND high > the previous bar's high AND low <= cloud top AND low >= cloud bottom adjusted downward by the pullback tolerance AND lower wick > candle body times the wick threshold AND volume > its simple moving average.