Calculation: Altered OBV = cumulative sum of volume when close rises or is unchanged from the previous bar, minus volume when close falls
Calculation: OBV MACD line = MA(Altered OBV, OBV shorter lookback, OBV oscillator MA type) - MA(Altered OBV, OBV longer lookback, OBV oscillator MA type)
Calculation: OBV MACD signal = MA(OBV MACD line, OBV signal lookback, OBV signal MA type)
Calculation: Close MACD line = EMA(close, close shorter lookback) - EMA(close, close longer lookback)
Calculation: Close MACD signal = EMA(Close MACD line, close signal lookback)
Long: (OBV MACD line > OBV MACD signal AND Close MACD line > Close MACD signal) OR (OBV MACD line crosses above OBV MACD signal AND rising(OBV MACD line, OBV rise lookback))
Short: OBV MACD line < OBV MACD signal AND Close MACD line < Close MACD signal