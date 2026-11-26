Calculation: Triple-EMA rate = 100 * (EMA(EMA(EMA(close, TRIX lookback), TRIX lookback), TRIX lookback) - EMA(EMA(EMA(EMA(close, TRIX lookback), TRIX lookback), TRIX lookback), TRIX lookback)) / EMA(EMA(EMA(EMA(close, TRIX lookback), TRIX lookback), TRIX lookback), TRIX lookback)
Calculation: TRIX bullish = Triple-EMA rate crosses above EMA(Triple-EMA rate, TRIX signal lookback)
Calculation: Aroon bullish = Aroon Up(Aroon lookback) crosses above Aroon Down(Aroon lookback)
Calculation: MACD bullish = MACD line(close, fast MACD lookback, slow MACD lookback, MACD signal lookback) crosses above its signal line OR MACD histogram(fast MACD lookback, slow MACD lookback, MACD signal lookback) > 0
Calculation: RSI bullish = RSI(close, RSI lookback) > RSI threshold
Calculation: OBV bullish = OBV > EMA(OBV, OBV smoothing lookback) AND OBV is rising over OBV rise lookback
Calculation: ADX bullish = ADX(DMI lookback, DMI lookback) > ADX threshold AND +DI(DMI lookback) > -DI(DMI lookback)
Long: TRIX bullish AND Aroon bullish
Long: MACD bullish AND RSI bullish
Long: OBV bullish AND ADX bullish
Long: TRIX bullish AND Aroon bullish AND MACD bullish AND RSI bullish AND close > EMA(close, trend lookback) AND OBV bullish AND ADX bullish