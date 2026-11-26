Calculation: T1 bullish = EMA(close, fast EMA lookback, T1 value requested on chart bars from the still-forming T1 bar) > EMA(close, medium EMA lookback, T1 value requested on chart bars from the still-forming T1 bar)
Calculation: Entry score = (trend weight if EMA(close, fast EMA lookback) > EMA(close, medium EMA lookback) AND EMA(close, medium EMA lookback) > EMA(close, slow EMA lookback) AND close > VWAP(close), otherwise 0) + (momentum weight if RSI(close, RSI lookback) > lower momentum threshold AND RSI(close, RSI lookback) < upper momentum threshold, otherwise 0) + (volume weight if volume > SMA(volume, volume average lookback) * volume multiplier, otherwise 0) + (ADX weight if ADX(high, low, close, ADX lookback) > ADX threshold, otherwise 0) + (ATR weight if ATR(high, low, close, ATR lookback) > SMA(ATR(high, low, close, ATR lookback), ATR average lookback), otherwise 0) + (breakout weight if close > high[1], otherwise 0) + (T1 trend weight if T1 bullish, otherwise 0)
Long: flat position AND Entry score >= entry score threshold AND T1 bullish AND (no prior long entry OR more than long cooldown chart bars have elapsed since the previous long entry)
Short: flat position AND EMA(close, fast EMA lookback) < EMA(close, medium EMA lookback) AND close < VWAP(close) AND RSI(close, RSI lookback) < short RSI threshold AND EMA(close, fast EMA lookback, T1 value requested on chart bars from the still-forming T1 bar) < EMA(close, medium EMA lookback, T1 value requested on chart bars from the still-forming T1 bar) AND (no prior short entry OR more than short cooldown chart bars have elapsed since the previous short entry)
Exit: long, close < EMA(close, fast EMA lookback) OR close < VWAP(close)
Exit: short, close > EMA(close, fast EMA lookback) OR close > VWAP(close)
Long: Entry score >= score color threshold
Short: Entry score < score color threshold
Long: EMA(close, fast EMA lookback) > EMA(close, medium EMA lookback)
Short: EMA(close, fast EMA lookback) <= EMA(close, medium EMA lookback)
Long: close > VWAP(close)
Short: close <= VWAP(close)