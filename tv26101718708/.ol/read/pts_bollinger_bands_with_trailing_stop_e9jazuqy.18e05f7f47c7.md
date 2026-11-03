Long: position is flat AND close > upper Bollinger Band AND datetime is within the configured active date range
Exit: long, close < lower Bollinger Band OR low <= ATR trailing stop AND datetime is within the configured active date range
Calculation: ATR trailing stop = highest high since entry minus the ATR-based trailing offset set at entry