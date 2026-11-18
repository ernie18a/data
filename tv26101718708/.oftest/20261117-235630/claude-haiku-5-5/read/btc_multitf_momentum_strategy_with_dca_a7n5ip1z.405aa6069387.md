Long: close > EMA(close, trend length, T1, last completed bar) AND RSI(close, rsi length, T2, last completed bar) < long pullback threshold AND StochRSI(RSI(close, rsi length, T3, last completed bar), stoch length, chart bars) crosses above SMA(StochRSI(RSI(close, rsi length, T3, last completed bar), stoch length, chart bars), smoothing length) AND StochRSI(RSI(close, rsi length, T3, last completed bar), stoch length, chart bars) < oversold threshold AND entries in position < max entries
Short: close < EMA(close, trend length, T1, last completed bar) AND RSI(close, rsi length, T2, last completed bar) > short rally threshold AND StochRSI(RSI(close, rsi length, T3, last completed bar), stoch length, chart bars) crosses below SMA(StochRSI(RSI(close, rsi length, T3, last completed bar), stoch length, chart bars), smoothing length) AND StochRSI(RSI(close, rsi length, T3, last completed bar), stoch length, chart bars) > overbought threshold AND entries in position < max entries
Long: position side is long AND entries in position < max entries AND low <= entry price - ATR(atr length) * first DCA multiplier
Long: position side is long AND entries in position < max entries AND low <= entry price - ATR(atr length) * second DCA multiplier
Short: position side is short AND entries in position < max entries AND high >= entry price + ATR(atr length) * first DCA multiplier
Short: position side is short AND entries in position < max entries AND high >= entry price + ATR(atr length) * second DCA multiplier
Exit: Long, low <= entry price - ATR(atr length) * stop multiplier
Exit: Long, high >= entry price + ATR(atr length) * take-profit multiplier
Exit: Long, low <= highest high since entry - ATR(atr length) * trail multiplier
Exit: Short, high >= entry price + ATR(atr length) * stop multiplier
Exit: Short, low <= entry price - ATR(atr length) * take-profit multiplier
Exit: Short, high >= lowest low since entry + ATR(atr length) * trail multiplier