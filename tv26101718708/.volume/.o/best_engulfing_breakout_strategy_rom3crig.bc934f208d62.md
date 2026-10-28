Calculation: Bullish engulfing = current close > open, previous close < open, current body length > previous body length, and max(current open, current close) > max(previous open, previous close)
Calculation: Bearish engulfing = current close < open, previous close > open, current body length > previous body length, and min(current open, current close) < min(previous open, previous close)
Calculation: Bullish engulfing state = bars since latest bullish engulfing < bars since latest bearish engulfing
Calculation: Bearish engulfing state = bars since latest bearish engulfing < bars since latest bullish engulfing
Calculation: Selected moving average = selected moving-average method applied to selected price source over its lookback
Calculation: Bullish MA state = bars since latest upward cross of the price source above the selected moving average < bars since latest downward cross
Calculation: Bearish MA state = bars since latest downward cross of the price source below the selected moving average < bars since latest upward cross
Calculation: Bullish setup = bullish engulfing state AND bullish MA state; bearish setup = bearish engulfing state AND bearish MA state
Calculation: Bullish setup event = bullish setup is true now and was false on the previous bar; bearish setup event = bearish setup is true now and was false on the previous bar
Calculation: Long signal = bars since latest bullish setup event < bars since latest bearish setup event now, and was >= it on the previous bar
Calculation: Short signal = bars since latest bullish setup event > bars since latest bearish setup event now, and was <= it on the previous bar
Calculation: Long take-profit level = long entry price + configurable profit distance; long stop-loss level = long entry price - configurable loss distance
Calculation: Short take-profit level = short entry price - configurable profit distance; short stop-loss level = short entry price + configurable loss distance
Long: Long signal AND datetime is within the configurable backtest start and stop dates
Short: Short signal AND datetime is within the configurable backtest start and stop dates
Exit: Long, datetime is within the configurable backtest start and stop dates AND (previous bar close < current selected moving average OR (bullish trend state AND current high >= long take-profit level) OR (bullish trend state AND current low <= long stop-loss level))
Exit: Short, datetime is within the configurable backtest start and stop dates AND (previous bar close > current selected moving average OR (bearish trend state AND current low <= short take-profit level) OR (bearish trend state AND current high >= short stop-loss level))