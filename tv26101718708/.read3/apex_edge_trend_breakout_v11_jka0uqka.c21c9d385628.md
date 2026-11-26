Calculation: DominantUptrend = close > EMA(close, trend EMA length) AND EMA(close, trend EMA length) > EMA(close, trend EMA length)[EMA slope lookback] AND (HTF switch off OR close > EMA(close, trend EMA length, T1, last completed bar)[1])
Calculation: DominantDowntrend = close < EMA(close, trend EMA length) AND EMA(close, trend EMA length) < EMA(close, trend EMA length)[EMA slope lookback] AND (HTF switch off OR close < EMA(close, trend EMA length, T1, last completed bar)[1])
Long: close crosses above Highest(high, breakout length)[1] AND (trend filter switch off OR (with-trend-only switch on AND DominantUptrend) OR (with-trend-only switch off AND NOT DominantDowntrend))
Short: close crosses below Lowest(low, breakout length)[1] AND (trend filter switch off OR (with-trend-only switch on AND DominantDowntrend) OR (with-trend-only switch off AND NOT DominantUptrend))
Calculation: LongChandelierStop = entry price - initial stop ATR multiple * ATR(ATR length) on the long entry bar, else MAX(LongChandelierStop[1], highest high since entry bar - trail ATR multiple * ATR(ATR length))
Calculation: ShortChandelierStop = entry price + initial stop ATR multiple * ATR(ATR length) on the short entry bar, else MIN(ShortChandelierStop[1], lowest low since entry bar + trail ATR multiple * ATR(ATR length))
Exit: long, low <= LongChandelierStop[1]
Exit: short, high >= ShortChandelierStop[1]