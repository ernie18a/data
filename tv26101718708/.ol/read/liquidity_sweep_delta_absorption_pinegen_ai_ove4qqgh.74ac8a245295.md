Calculation: Close position = (close - low) / (high - low); use 0.5 when high = low
Calculation: Net volume delta = sum of lower-timeframe volume where close >= open minus sum where close < open; aggregate the lower-timeframe bars within the current chart bar, evaluated after the chart bar completes
Long: low < most recently confirmed swing low AND close > that swing low AND close position >= configured absorption threshold AND (volume filter disabled OR volume > its moving average * configured multiplier) AND (delta filter disabled OR net volume delta >= configured minimum)
Long: bullish absorption conditions AND (trend filter disabled OR close > configured EMA) AND (session filter disabled OR timestamp is within configured session) AND (confirmation disabled OR previous bar had bullish absorption and this bar closes > open)
Short: high > most recently confirmed swing high AND close < that swing high AND close position <= 1 - configured absorption threshold AND (volume filter disabled OR volume > its moving average * configured multiplier) AND (delta filter disabled OR net volume delta <= -configured minimum)
Short: bearish absorption conditions AND (trend filter disabled OR close < configured EMA) AND (session filter disabled OR timestamp is within configured session) AND (confirmation disabled OR previous bar had bearish absorption and this bar closes < open)
Calculation: Long stop = sweep bar low - ATR * configured stop buffer
Calculation: Long target = signal bar close + (signal bar close - long stop) * configured reward-to-risk ratio
Calculation: Short stop = sweep bar high + ATR * configured stop buffer
Calculation: Short target = signal bar close - (short stop - signal bar close) * configured reward-to-risk ratio
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target