Calculation: Selected moving average = configured moving-average type applied to close over its configured lookback
Long: close > selected moving average AND previous close < current selected moving average AND weekday is Monday
Short: close < selected moving average AND previous close > current selected moving average AND weekday is Monday
Exit: Long, weekday is Sunday OR high >= entry price × (1 + take-profit percentage) OR low <= entry price × (1 − stop-loss percentage)
Exit: Short, weekday is Sunday OR low <= entry price × (1 − take-profit percentage) OR high >= entry price × (1 + stop-loss percentage)