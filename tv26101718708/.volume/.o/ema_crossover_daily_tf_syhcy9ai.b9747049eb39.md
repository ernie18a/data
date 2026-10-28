Calculation: Short-term smoothed EMA = EMA of close, then EMA of that result using the same shorter lookback
Calculation: Long-term smoothed EMA = EMA of close, then EMA of that result using the same longer lookback
Calculation: Candle body fraction = abs(close − open) / (high − low)
Calculation: Stop price = for a long entry, max(min(current low, previous bar low), long-term smoothed EMA); for a short entry, min(max(current low, previous bar low), long-term smoothed EMA). On a qualifying long position bar, multiply stop price by 1.05; on a qualifying short position bar, multiply it by 0.95.
Calculation: Entry price = OHLC4 of the entry bar; while a long position qualifies for a stop update, multiply entry price by 1.05; while a short position qualifies for a stop update, multiply it by 0.95.
Calculation: Target price = for a long entry, entry price + 10 × (entry price − initial stop price); for a short entry, entry price − 10 × (initial stop price − entry price)
Long: no open position AND bar is confirmed AND close > short-term smoothed EMA AND close > long-term smoothed EMA AND close > open AND candle body fraction > 0.6 AND volume > its simple moving average AND RSI of close > 50 AND short-term smoothed EMA > long-term smoothed EMA AND volume > previous bar volume
Short: no open position AND bar is confirmed AND close < short-term smoothed EMA AND close < long-term smoothed EMA AND close < open AND candle body fraction > 0.6 AND volume > its simple moving average AND RSI of close < 50 AND short-term smoothed EMA > long-term smoothed EMA AND volume > previous bar volume
Exit: long, close < stop price
Exit: short, close > stop price