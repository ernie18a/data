Calculation: Fast simple moving average = simple moving average of close over a shorter lookback.
Calculation: Slow volume-weighted moving average = volume-weighted moving average of high over a longer lookback.
Long: datetime is within the configured date window AND fast simple moving average crosses above slow volume-weighted moving average.
Short: datetime is within the configured date window AND slow volume-weighted moving average crosses above fast simple moving average.
Calculation: Smoothed RSI = exponential moving average of RSI of close, using separate RSI lookback and smoothing parameters.
Long: datetime is within the configured date window AND smoothed RSI crosses above the configured oversold level.
Short: datetime is within the configured date window AND smoothed RSI crosses above the configured overbought level.