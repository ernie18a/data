Long: within configured UTC active session AND MACD histogram crosses above zero AND close > the EMA of the configured long lookback on the last completed hourly bar AND volume > its configured moving average
Short: within configured UTC active session AND MACD histogram crosses below zero AND close < the EMA of the configured long lookback on the last completed hourly bar AND volume > its configured moving average
Calculation: Long stop = entry price less configured stop distance; when close > entry price + configured ATR trigger, raise the stop to the greater of its prior value and entry price + configured ATR offset
Calculation: Long target = entry price + three times the configured stop distance
Calculation: Short stop = entry price plus configured stop distance; when close < entry price - configured ATR trigger, lower the stop to the lesser of its prior value and entry price - configured ATR offset
Calculation: Short target = entry price - three times the configured stop distance
Exit: Long, low <= long stop OR high >= long target
Exit: Short, high >= short stop OR low <= short target