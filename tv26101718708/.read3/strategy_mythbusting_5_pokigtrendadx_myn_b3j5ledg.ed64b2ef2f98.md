Calculation: SignedVolume = Renko(close, brick size) * sum of volume from the bar where Renko(close, brick size) last changed through the current bar
Long: crosses above(SignedVolume, 0)
Short: crosses below(SignedVolume, 0)
Long: G-Channel(OHLC4, G-Channel length) is bullish
Short: G-Channel(OHLC4, G-Channel length) is not bullish
Long: crosses above(SignedVolume, 0) AND G-Channel(OHLC4, G-Channel length) is bullish AND ADX(high, low, close, DI length, ADX smoothing) > ADX threshold AND position side is not long
Short: crosses below(SignedVolume, 0) AND G-Channel(OHLC4, G-Channel length) is not bullish AND ADX(high, low, close, DI length, ADX smoothing) > ADX threshold AND position side is not short
Exit: long, high >= entry price * (1 + TP1 / 100)
Exit: long, high >= entry price * (1 + TP2 / 100)
Exit: long, high >= entry price * (1 + TP3 / 100)
Exit: long, high >= entry price * (1 + TP4 / 100)
Exit: long, close < entry price * (1 - SL / 100)
Exit: short, low <= entry price * (1 - TP1 / 100)
Exit: short, low <= entry price * (1 - TP2 / 100)
Exit: short, low <= entry price * (1 - TP3 / 100)
Exit: short, low <= entry price * (1 - TP4 / 100)
Exit: short, close > entry price * (1 + SL / 100)