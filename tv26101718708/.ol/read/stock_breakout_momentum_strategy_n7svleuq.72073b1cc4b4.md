Calculation: Breakout high = highest high over the breakout lookback, excluding the current bar
Calculation: Breakout low = lowest low over the breakout lookback, excluding the current bar
Calculation: Trend average = simple moving average of close over a longer lookback than the volume average lookback
Calculation: Volume average = simple moving average of volume over a shorter lookback than the trend average lookback
Calculation: Long stop = signal bar open − ATR × stop multiplier; while long, update to the greater of the previous stop and current close − current ATR × stop multiplier
Calculation: Short stop = signal bar open + ATR × stop multiplier; while short, update to the lesser of the previous stop and current close + current ATR × stop multiplier
Calculation: Long target = signal bar open + signal bar ATR × target multiplier
Calculation: Short target = signal bar open − signal bar ATR × target multiplier
Long: position is flat AND completed bar close > breakout high AND completed bar close > trend average AND completed bar volume > volume average × volume multiplier
Short: short entries are enabled AND position is flat AND completed bar close < breakout low AND completed bar close < trend average AND completed bar volume > volume average × volume multiplier
Exit: long, bar low <= long stop OR bar high >= long target OR bars since signal bar >= time exit length
Exit: short, bar high >= short stop OR bar low <= short target OR bars since signal bar >= time exit length