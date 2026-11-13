Calculation: MFI = Money Flow Index of hlc3 weighted by volume
Calculation: BollOsc = 100*(ohlc4 - SMA(ohlc4,n)) / (upper band - lower band), bands = SMA(ohlc4,n) +/- m*stdev(ohlc4,n)
Calculation: Stoch = SMA(short smoothing) of 100*(ohlc4 - lowest low(n))/(highest high(n) - lowest low(n))
Calculation: Trend = (RSI(ohlc4) + MFI + BollOsc + Stoch/3)/2
Calculation: RegTrend = barIndex*slope + intercept, where over n bars slope = correlation(barIndex, Trend)*stdev(Trend)/stdev(barIndex) and intercept = EMA(Trend,n) - slope*EMA(barIndex,n)
Calculation: DipSignal(Q,N) = on each bar, a persistent counter S increments by 1 if close < close 4 bars earlier; signal is true when S > Q AND close > open AND low <= lowest low of the last N bars (including current); S resets to 0 when the signal fires. Major = DipSignal with larger Q and longer N; Minor = DipSignal with smaller Q and shorter N, each with its own counter.
Calculation: ATRStop (ATR length n, multiplier 1): loss = ATR(n); if close > prevStop AND prevClose > prevStop then stop = max(prevStop, close - loss); else if close < prevStop AND prevClose < prevStop then stop = min(prevStop, close + loss); else if close > prevStop then stop = close - loss; else stop = close + loss
Calculation: DailyATR = ATR on a timeframe higher than the chart (daily), using the bar still forming
Long: (Minor OR Major is true) AND RegTrend <= L
Long: RegTrend > RegTrend[1] AND RegTrend[1] > RegTrend[2] AND RegTrend <= L
Long: Trend crosses above L (Trend > L AND Trend[1] <= L)
Long: RegTrend crosses below Trend (RegTrend < Trend AND RegTrend[1] >= Trend[1]) AND RegTrend <= L AND Trend <= L
Long: RegTrend < L on the current bar and each of the previous 2 bars AND RegTrend > RegTrend[1] AND Trend <= L
Long: (RegTrend <= L OR Trend <= L on the current bar or either of the previous 2 bars) AND close crosses above ATRStop (close > ATRStop AND close[1] <= ATRStop[1])
Exit: Long, high >= average entry price + p1*DailyATR (closes half of the position)
Exit: Long, high >= average entry price + p2*DailyATR, with p2 > p1 (closes the remaining position)
Exit: Long, after the first take-profit exit has occurred since the latest Long signal AND low <= average entry price (breakeven stop; no stop before that)