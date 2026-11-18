Calculation: Short-lookback EMA = EMA(close, shorter lookback)
Calculation: Long-lookback EMA = EMA(close, longer lookback)
Calculation: Chart VWAP = VWAP(close)
Calculation: Supertrend direction = direction output of Supertrend(supertrend factor, Supertrend ATR lookback)
Calculation: Relative volume = volume / SMA(volume, volume-average lookback)
Calculation: ATR expansion = ATR(ATR lookback) > SMA(ATR(ATR lookback), ATR-average lookback)
Calculation: T1 trend = on chart bars, close from the current T1 bar, including while forming, > EMA(close, shared MTF EMA lookback, current T1 bar, including while forming)
Calculation: T2 trend = on chart bars, close from the current T2 bar, including while forming, > EMA(close, shared MTF EMA lookback, current T2 bar, including while forming)
Calculation: T3 trend = on chart bars, close from the current T3 bar, including while forming, > EMA(close, shared MTF EMA lookback, current T3 bar, including while forming)
Long: close > Short-lookback EMA AND Short-lookback EMA > Long-lookback EMA AND close > Chart VWAP AND Supertrend direction > 0 AND Relative volume > relative-volume threshold AND ATR expansion AND T1 trend AND T2 trend AND T3 trend
Short: close < Short-lookback EMA AND Short-lookback EMA < Long-lookback EMA AND close < Chart VWAP AND Supertrend direction < 0 AND Relative volume > relative-volume threshold AND ATR expansion AND NOT T1 trend AND NOT T2 trend AND NOT T3 trend