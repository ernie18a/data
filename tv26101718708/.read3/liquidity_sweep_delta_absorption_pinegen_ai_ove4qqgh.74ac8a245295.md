Calculation: close position = (close - low) / (high - low), or 0.5 when high equals low
Calculation: net volume delta = on each confirmed chart bar, sum volume of completed T1 bars within that chart bar where close >= open minus sum volume of those bars where close < open
Long: bar is confirmed AND low < the most recent confirmed Pivot Low(low, left swing lookback, right swing lookback) AND close > that pivot low AND close position >= absorption threshold AND (volume filter disabled OR volume > SMA(volume, volume lookback) * volume multiplier) AND (delta filter disabled OR net volume delta >= minimum absolute delta)
Short: bar is confirmed AND high > the most recent confirmed Pivot High(high, left swing lookback, right swing lookback) AND close < that pivot high AND close position <= 1 - absorption threshold AND (volume filter disabled OR volume > SMA(volume, volume lookback) * volume multiplier) AND (delta filter disabled OR net volume delta <= -minimum absolute delta)
Long: bullish absorption conditions AND (trend filter disabled OR close > EMA(close, trend lookback)) AND (session filter disabled OR chart bar is within the configured session and time zone) AND long entries enabled
Short: bearish absorption conditions AND (trend filter disabled OR close < EMA(close, trend lookback)) AND (session filter disabled OR chart bar is within the configured session and time zone) AND short entries enabled
Calculation: long stop = low of the latest long signal bar - ATR(lookback) on the entry signal bar * stop buffer
Calculation: long risk distance = entry signal bar close - long stop
Calculation: long target = entry signal bar close + long risk distance * reward:risk
Calculation: short stop = high of the latest short signal bar + ATR(lookback) on the entry signal bar * stop buffer
Calculation: short risk distance = short stop - entry signal bar close
Calculation: short target = entry signal bar close - short risk distance * reward:risk
Long: bar is confirmed AND position is flat AND (trade limit disabled OR entries since the start of the current T2 bar < trade limit) AND long risk distance > 0 AND ((confirmation wait disabled AND current bar satisfies the long signal conditions) OR (confirmation wait enabled AND previous chart bar satisfies the long signal conditions AND close > open))
Short: bar is confirmed AND position is flat AND (trade limit disabled OR entries since the start of the current T2 bar < trade limit) AND short risk distance > 0 AND ((confirmation wait disabled AND current bar satisfies the short signal conditions) OR (confirmation wait enabled AND previous chart bar satisfies the short signal conditions AND close < open))
Exit: Long, low <= long stop OR high >= long target
Exit: Short, high >= short stop OR low <= short target