Calculation: COT net positions = selected COT long positions - selected COT short positions
Calculation: COT Index = 100 × (COT net positions - lowest(COT net positions, lookback)) / (highest(COT net positions, lookback) - lowest(COT net positions, lookback)); use the index midpoint when the denominator is zero
Calculation: COT net-position average = SMA(COT net positions, lookback)
Calculation: Smoothed SMI = SMI(high, low, close, range lookback, EMA smoothing lookback, SMA smoothing lookback)
Long: SMI crosses above its oversold threshold AND ((reversal mode AND COT filter enabled AND COT Index < lower threshold) OR (trend-following mode AND COT filter enabled AND COT Index > index midpoint) OR COT filter disabled) AND signal arrows enabled AND long entries enabled AND NOT (close-on-opposite enabled AND current position is short)
Short: Smoothed SMI crosses below its overbought threshold AND ((reversal mode AND COT filter enabled AND COT Index > upper threshold) OR (trend-following mode AND COT filter enabled AND COT Index < index midpoint) OR COT filter disabled) AND signal arrows enabled AND short entries enabled AND NOT (close-on-opposite enabled AND current position is long)
Long: COT net positions crosses above COT net-position average
Short: COT net positions crosses below COT net-position average
Long: COT Index crosses below lower threshold
Short: COT Index crosses above upper threshold
Long: COT Index < lower threshold
Short: COT Index > upper threshold
Long: trend-following mode AND COT Index display AND COT Index > index midpoint
Short: trend-following mode AND COT Index display AND COT Index < index midpoint
Long: reversal mode AND Positions display AND COT net positions > COT net-position average
Short: reversal mode AND Positions display AND COT net positions <= COT net-position average
Long: COT net positions > zero
Short: COT net positions <= zero
Exit: Long, Smoothed SMI crosses below its overbought threshold when close-on-opposite is enabled
Exit: Short, Smoothed SMI crosses above its oversold threshold when close-on-opposite is enabled
Exit: Long, high >= signal-bar close + ATR(high, low, close, lookback) × take-profit multiplier OR low <= signal-bar close - ATR(high, low, close, lookback) × stop-loss multiplier when ATR-based TP/SL is enabled
Exit: Long, high >= signal-bar close × (1 + take-profit percentage / 100) OR low <= signal-bar close × (1 - stop-loss percentage / 100) when fixed TP/SL is enabled
Exit: Short, low <= signal-bar close - ATR(high, low, close, lookback) × take-profit multiplier OR high >= signal-bar close + ATR(high, low, close, lookback) × stop-loss multiplier when ATR-based TP/SL is enabled
Exit: Short, low <= signal-bar close × (1 - take-profit percentage / 100) OR high >= signal-bar close × (1 + stop-loss percentage / 100) when fixed TP/SL is enabled