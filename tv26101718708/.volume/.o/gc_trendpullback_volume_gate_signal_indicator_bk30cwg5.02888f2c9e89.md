Calculation: Long stop = entry price − chart-timeframe ATR at entry × stop multiplier
Calculation: Long target = entry price + (entry price − long stop) × reward-to-risk multiple
Calculation: Short stop = entry price + chart-timeframe ATR at entry × stop multiplier
Calculation: Short target = entry price − (short stop − entry price) × reward-to-risk multiple
Long: Flat after applying exits AND shorter-lookback EMA > longer-lookback EMA on the last completed higher-timeframe bar AND RSI crosses above its lower re-entry threshold AND volume >= its moving average
Short: Flat after applying exits AND shorter-lookback EMA < longer-lookback EMA on the last completed higher-timeframe bar AND RSI crosses below its higher re-entry threshold AND volume >= its moving average
Exit: Long, close <= long stop OR close >= long target OR shorter-lookback EMA < longer-lookback EMA on the last completed higher-timeframe bar AND RSI crosses below its higher re-entry threshold AND volume >= its moving average
Exit: Short, close >= short stop OR close <= short target OR shorter-lookback EMA > longer-lookback EMA on the last completed higher-timeframe bar AND RSI crosses above its lower re-entry threshold AND volume >= its moving average