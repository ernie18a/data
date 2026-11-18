Calculation: StochRSI_K = Stochastic(RSI(close, RSI lookback, T3, last completed bar) on chart bars, stoch lookback)
Long: close > EMA(close, trend lookback, T1, last completed bar) AND RSI(close, RSI lookback, T2, last completed bar) < long RSI level AND StochRSI_K crosses above SMA(StochRSI_K, D smoothing length) AND StochRSI_K < oversold level
Short: close < EMA(close, trend lookback, T1, last completed bar) AND RSI(close, RSI lookback, T2, last completed bar) > short RSI level AND StochRSI_K crosses below SMA(StochRSI_K, D smoothing length) AND StochRSI_K > overbought level
Long: position side is long AND low <= entry price - ATR(ATR lookback) * first DCA multiple
Long: position side is long AND low <= entry price - ATR(ATR lookback) * second DCA multiple
Short: position side is short AND high >= entry price + ATR(ATR lookback) * first DCA multiple
Short: position side is short AND high >= entry price + ATR(ATR lookback) * second DCA multiple
Exit: long, low <= entry price - ATR(ATR lookback) * stop multiple
Exit: short, high >= entry price + ATR(ATR lookback) * stop multiple
Exit: long, high >= entry price + ATR(ATR lookback) * take-profit multiple
Exit: short, low <= entry price - ATR(ATR lookback) * take-profit multiple
Exit: long, low <= highest(high) since entry - ATR(ATR lookback) * trail multiple
Exit: short, high >= lowest(low) since entry + ATR(ATR lookback) * trail multiple