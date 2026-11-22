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
Calculation: ATR expansion = ATR(ATR period) > SMA(ATR(ATR period), ATR averaging period)
Option: buy call, close > EMA(close, fast EMA period) AND EMA(close, fast EMA period) > EMA(close, slow EMA period) AND close > VWAP(close) AND Supertrend direction(Supertrend ATR period, Supertrend factor) > 0 AND Relative Volume(volume, volume averaging period) > relative volume threshold AND ATR expansion AND T1 close > EMA(T1 close, trend EMA period) AND T2 close > EMA(T2 close, trend EMA period) AND T3 close > EMA(T3 close, trend EMA period)
Option: buy put, close < EMA(close, fast EMA period) AND EMA(close, fast EMA period) < EMA(close, slow EMA period) AND close < VWAP(close) AND Supertrend direction(Supertrend ATR period, Supertrend factor) < 0 AND Relative Volume(volume, volume averaging period) > relative volume threshold AND ATR expansion AND T1 close <= EMA(T1 close, trend EMA period) AND T2 close <= EMA(T2 close, trend EMA period) AND T3 close <= EMA(T3 close, trend EMA period)