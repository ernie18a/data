Calculation: fast EMA = EMA(close, shorter lookback)
Calculation: slow EMA = EMA(close, longer lookback)
Calculation: trend EMA = EMA(close, trend lookback)
Calculation: VWAP = VWAP(close)
Calculation: ATR = ATR(high, low, close, ATR lookback)
Calculation: ADX = Wilder-smoothed average directional index of high, low, and close over the ADX lookback
Long: close > trend EMA AND trend EMA > trend EMA[1] AND fast EMA crosses above slow EMA AND close > open AND close[1] < open[1] AND close > open[1] AND open < close[1] AND (VWAP filter disabled OR close > VWAP) AND (ATR filter disabled OR ATR > SMA(ATR, ATR lookback)) AND (ADX filter disabled OR ADX > minimum ADX) AND (Chop filter disabled OR abs(fast EMA - slow EMA) >= ATR * chop threshold)
Short: close < trend EMA AND trend EMA < trend EMA[1] AND fast EMA crosses below slow EMA AND close < open AND close[1] > open[1] AND close < open[1] AND open > close[1] AND (VWAP filter disabled OR close < VWAP) AND (ATR filter disabled OR ATR > SMA(ATR, ATR lookback)) AND (ADX filter disabled OR ADX > minimum ADX) AND (Chop filter disabled OR abs(fast EMA - slow EMA) >= ATR * chop threshold)