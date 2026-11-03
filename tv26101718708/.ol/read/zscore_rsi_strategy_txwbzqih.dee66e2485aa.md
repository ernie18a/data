Calculation: Rolling mean = simple moving average of close over the Z-score lookback
Calculation: Rolling standard deviation = standard deviation of close over the Z-score lookback
Calculation: Z-score = rolling standard deviation if (close - rolling mean) / rolling standard deviation != 0; otherwise 1
Calculation: Z-score RSI = RSI of the Z-score
Calculation: RSI moving average = selected moving average type applied to Z-score RSI; its lookback is the smoothing length
Calculation: Long exit level = oversold level + (overbought level - oversold level) × selected fraction (1/4, 1/2, 3/4, or 1)
Calculation: Short exit level = overbought level - (overbought level - oversold level) × selected fraction (1/4, 1/2, 3/4, or 1)
Long: position size <= 0 AND (RSI moving average crosses above 50 OR Z-score RSI crosses above RSI moving average OR Z-score RSI crosses below oversold level OR RSI moving average crosses below oversold level)
Short: position size >= 0 AND (RSI moving average crosses below 50 OR Z-score RSI crosses below RSI moving average OR Z-score RSI crosses above overbought level OR RSI moving average crosses above overbought level)
Exit: long, open profit percentage > risk threshold OR RSI moving average crosses below 50 OR Z-score RSI crosses below RSI moving average OR Z-score RSI crosses above long exit level OR RSI moving average crosses above long exit level
Exit: short, open profit percentage > risk threshold OR RSI moving average crosses above 50 OR Z-score RSI crosses above RSI moving average OR Z-score RSI crosses below short exit level OR RSI moving average crosses below short exit level