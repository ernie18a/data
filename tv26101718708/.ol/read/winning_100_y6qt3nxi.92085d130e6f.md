Calculation: Fast EMA = EMA of close with a shorter lookback than the slow EMA
Calculation: Slow EMA = EMA of close with a longer lookback than the fast EMA
Calculation: Cloud top = max(fast EMA, slow EMA)
Calculation: Cloud bottom = min(fast EMA, slow EMA)
Long: Fast EMA > slow EMA AND close > fast EMA AND close > slow EMA AND close > cloud top AND close > open AND high > previous bar's high AND low <= cloud top AND low >= cloud bottom adjusted downward by a margin AND min(open, close) - low > 0.7 × abs(close - open) AND volume > its simple moving average