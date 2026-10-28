Calculation: Z-score = if (close − SMA(close, lookback)) / standard_deviation(close, lookback) ≠ 0, then standard_deviation(close, lookback); otherwise 1
Calculation: RSI MA = configured moving average of RSI(Z-score), using its configured smoothing lookback
Calculation: Exit range = overbought level − oversold level
Calculation: Long exit level = oversold level + exit range × selected fraction (¼, ½, ¾, or 1 for full crossover)
Calculation: Short exit level = overbought level − exit range × selected fraction (¼, ½, ¾, or 1 for full crossover)
Long: RSI MA crosses above 50 OR RSI(Z-score) crosses above RSI MA OR RSI(Z-score) crosses below oversold level OR RSI MA crosses below oversold level
Short: RSI MA crosses below 50 OR RSI(Z-score) crosses below RSI MA OR RSI(Z-score) crosses above overbought level OR RSI MA crosses above overbought level
Exit: Long, RSI MA crosses below 50 OR RSI(Z-score) crosses below RSI MA OR RSI(Z-score) crosses above long exit level OR RSI MA crosses above long exit level OR open profit percentage exceeds configured threshold
Exit: Short, RSI MA crosses above 50 OR RSI(Z-score) crosses above RSI MA OR RSI(Z-score) crosses below short exit level OR RSI MA crosses below short exit level OR open profit percentage exceeds configured threshold