Calculation: Bull trend = close > EMA(close, longest lookback) AND EMA(close, longest lookback) > EMA(close, longest lookback)[1]
Calculation: Bear trend = close < EMA(close, longest lookback) AND EMA(close, longest lookback) < EMA(close, longest lookback)[1]
Calculation: Bullish engulfing = close > open AND close[1] < open[1] AND close > open[1] AND open < close[1]
Calculation: Bearish engulfing = close < open AND close[1] > open[1] AND close < open[1] AND open > close[1]
Calculation: EMA distance = ABS(EMA(close, shorter lookback) - EMA(close, longer lookback))
Calculation: Choppy market = EMA distance < ATR(atr lookback) × chop multiplier
Calculation: ATR expansion = ATR(atr lookback) > SMA(ATR(atr lookback), atr lookback)
Calculation: ADX strength = ADX(adx lookback) > minimum ADX
Long: Bull trend
Long: Bull trend AND EMA(close, shorter lookback) crosses above EMA(close, longer lookback) AND Bullish engulfing AND (NOT VWAP filter enabled OR close > VWAP(close)) AND (NOT ATR filter enabled OR ATR expansion) AND (NOT ADX filter enabled OR ADX strength) AND (NOT chop filter enabled OR NOT Choppy market)
Short: Bear trend
Short: Bear trend AND EMA(close, shorter lookback) crosses below EMA(close, longer lookback) AND Bearish engulfing AND (NOT VWAP filter enabled OR close < VWAP(close)) AND (NOT ATR filter enabled OR ATR expansion) AND (NOT ADX filter enabled OR ADX strength) AND (NOT chop filter enabled OR NOT Choppy market)