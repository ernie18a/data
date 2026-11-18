Calculation: last pivot-high confirmation close = last close when PivotHigh(close, left lookback, right lookback) confirms
Calculation: last pivot-low confirmation close = last close when PivotLow(close, left lookback, right lookback) confirms
Calculation: pivot-high plot = close when PivotHigh(close, left lookback, right lookback) confirms on the current bar, otherwise undefined
Calculation: pivot-low plot = close when PivotLow(close, left lookback, right lookback) confirms on the current bar, otherwise undefined
Long: close > last pivot-high confirmation close
Short: close < last pivot-low confirmation close
Exit: long, close >= entry price AND pivot-high plot < pivot-low plot
Exit: short, close <= entry price AND pivot-low plot > pivot-high plot
Exit: long, NOT (close > last pivot-high confirmation close) AND (low <= entry price * (1 - stop-loss percent / 100) OR high >= entry price * (1 + take-profit percent / 100))
Exit: short, NOT (close < last pivot-low confirmation close) AND (high >= entry price * (1 + stop-loss percent / 100) OR low <= entry price * (1 - take-profit percent / 100))