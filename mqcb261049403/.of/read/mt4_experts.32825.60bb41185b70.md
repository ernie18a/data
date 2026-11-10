Calculation: Price displacement = (current chart-bar open - last completed reference-timeframe close) / last completed reference-timeframe close × 10000; the reference timeframe may be higher or lower than the chart timeframe.
Long: No open long position AND previous chart-bar close < previous chart-bar open AND price displacement < negative displacement threshold
Short: No open short position AND previous chart-bar close > previous chart-bar open AND price displacement > displacement threshold
Exit: Long, price <= most recent long entry price - stop distance
Exit: Short, price >= most recent short entry price + stop distance