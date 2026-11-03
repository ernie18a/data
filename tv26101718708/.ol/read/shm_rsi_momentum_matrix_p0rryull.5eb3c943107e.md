Calculation: OHLC4 = (open + high + low + close) / 4
Calculation: Fast and slow WMA = weighted moving averages of OHLC4, with the fast lookback shorter than the slow lookback
Calculation: Sensitivity SMA = simple moving average of OHLC4
Calculation: Locked RSI = RSI of OHLC4 on the last completed bar of a higher timeframe
Long: (close crosses above fast WMA OR close crosses above slow WMA OR high crosses above fast WMA OR high crosses above slow WMA) AND close > sensitivity SMA AND close > slow WMA AND locked RSI is between its long lower and upper thresholds, inclusive
Short: (close crosses below fast WMA OR close crosses below slow WMA OR low crosses below fast WMA OR low crosses below slow WMA) AND close < sensitivity SMA AND close < slow WMA AND locked RSI is between its short lower and upper thresholds, inclusive