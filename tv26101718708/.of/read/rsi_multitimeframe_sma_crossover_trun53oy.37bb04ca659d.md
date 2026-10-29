Calculation: Multi-timeframe RSI average = the equally weighted mean of eight values, each a volume-weighted moving average of RSI(close) on its configured timeframe; use the latest available bar from each timeframe (the still-forming bar when available).
Calculation: Shorter-lookback smoothed average = EMA of the multi-timeframe RSI average, using a shorter lookback than the longer-lookback smoothed average.
Calculation: Longer-lookback smoothed average = EMA of the multi-timeframe RSI average, using a longer lookback than the shorter-lookback smoothed average.
Long: Shorter-lookback smoothed average crosses above longer-lookback smoothed average AND datetime is within the configured backtest window AND long entries are enabled
Short: Shorter-lookback smoothed average crosses below longer-lookback smoothed average AND datetime is within the configured backtest window AND short entries are enabled
Exit: long, Shorter-lookback smoothed average crosses below longer-lookback smoothed average OR low <= entry price × (1 − configured long stop-loss fraction)
Exit: short, high >= entry price × (1 + configured short stop-loss fraction)