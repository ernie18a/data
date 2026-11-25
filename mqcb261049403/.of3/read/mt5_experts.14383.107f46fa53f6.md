Calculation: MACD candle = (open=MACD(price open series, fast lookback, slow lookback, signal lookback, component), close=MACD(price close series, fast lookback, slow lookback, signal lookback, component)
Long: On T1 bars, MACD candle(T1, last completed bar).close > MACD candle(T1, last completed bar).open AND MACD candle(T1, bar still forming).close <= MACD candle(T1, bar still forming).open
Short: On T1 bars, MACD candle(T1, last completed bar).close < MACD candle(T1, last completed bar).open AND MACD candle(T1, bar still forming).close >= MACD candle(T1, bar still forming).open
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance