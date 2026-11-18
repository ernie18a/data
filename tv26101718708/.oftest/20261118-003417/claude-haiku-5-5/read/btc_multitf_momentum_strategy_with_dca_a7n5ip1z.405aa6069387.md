Calculation: TrendEMA = EMA(close, trend length, T1, last completed bar)
Calculation: PullbackRSI = RSI(close, rsi length, T2, last completed bar)
Calculation: StochRSI = Stochastic(RSI(close, rsi length, T3, last completed bar), stoch length) on chart bars
Calculation: SignalLine = SMA(StochRSI, signal length)
Calculation: ATRValue = ATR(atr length)
Long: close > TrendEMA AND PullbackRSI < pullback long threshold AND StochRSI crosses above SignalLine AND StochRSI < oversold level
Long: position side is long AND low <= entry price - ATRValue * first DCA multiplier
Long: position side is long AND low <= entry price - ATRValue * second DCA multiplier
Short: close < TrendEMA AND PullbackRSI > pullback short threshold AND StochRSI crosses below SignalLine AND StochRSI > overbought level
Short: position side is short AND high >= entry price + ATRValue * first DCA multiplier
Short: position side is short AND high >= entry price + ATRValue * second DCA multiplier
Exit: long, low <= entry price - ATRValue * stop multiplier
Exit: long, high >= entry price + ATRValue * take-profit multiplier
Exit: long, highest high since entry >= entry price + ATRValue * trail multiplier AND low <= highest high since entry - ATRValue * trail multiplier
Exit: short, high >= entry price + ATRValue * stop multiplier
Exit: short, low <= entry price - ATRValue * take-profit multiplier
Exit: short, lowest low since entry <= entry price - ATRValue * trail multiplier AND high >= lowest low since entry + ATRValue * trail multiplier