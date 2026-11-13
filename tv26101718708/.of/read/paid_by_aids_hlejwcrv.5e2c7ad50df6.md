Calculation: LogClose = natural log of close
Calculation: RSI = RSI of LogClose; RSISma = simple moving average of RSI (smoothing length)
Calculation: MACD line = EMA(LogClose, short lookback) - EMA(LogClose, long lookback); MACDSignal = EMA of MACD line
Calculation: ROC(n) = 100 * (LogClose - LogClose[n]) / LogClose[n]
Calculation: KST = 1*SMA(ROC(n1)) + 2*SMA(ROC(n2)) + 3*SMA(ROC(n3)) + 4*SMA(ROC(n4)), with n1 < n2 < n3 < n4 (weights rise with ROC lookback); KSTSignal = SMA of KST (signal length)
Calculation: TrendFast and TrendSlow = SMA of close computed on bars of a timeframe higher than the chart, using the still-forming higher-timeframe bar; TrendFast has a shorter lookback than TrendSlow
Long: on the first bar where all of the following hold (the same combined condition was false on the previous bar; it must become false again before another Long can fire): TrendFast > TrendSlow AND RSI > RSISma AND MACD line > MACDSignal AND KST > KSTSignal AND KST < 0
Short: on the first bar where all of the following hold (the same combined condition was false on the previous bar; it must become false again before another Short can fire): TrendFast < TrendSlow AND RSI < RSISma AND MACD line < MACDSignal AND KST < KSTSignal AND KST > 0