Calculation: trend average = selected moving average(selected source, moving-average lookback, MA type, LSMA offset, ALMA offset, ALMA sigma)
Calculation: average true range = ATR(ATR lookback, ATR smoothing type)
Long: close > trend average
Short: close <= trend average
Long: close crosses above trend average AND abs(close - trend average) <= average true range
Short: close crosses below trend average AND abs(close - trend average) <= average true range
Exit: long, close crosses below trend average OR low <= entry-signal-bar close - ATR at entry signal * stop-distance multiplier OR high >= entry-signal-bar close + ATR at entry signal * target-distance multiplier
Exit: short, close crosses above trend average OR high >= entry-signal-bar close + ATR at entry signal * stop-distance multiplier OR low <= entry-signal-bar close - ATR at entry signal * target-distance multiplier