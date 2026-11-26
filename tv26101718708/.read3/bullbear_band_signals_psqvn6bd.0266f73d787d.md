Calculation: upper band boundary = max(SMA(selected chart OHLC source, SMA lookback), EMA(selected chart OHLC source, EMA lookback))
Calculation: lower band boundary = min(SMA(selected chart OHLC source, SMA lookback), EMA(selected chart OHLC source, EMA lookback))
Long: On confirmed chart bars, selected chart OHLC source > upper band boundary
Short: On confirmed chart bars, selected chart OHLC source < lower band boundary
Long: On confirmed chart bars, selected chart OHLC source crosses above upper band boundary
Short: On confirmed chart bars, selected chart OHLC source crosses below lower band boundary
Long: On confirmed chart bars, when retest events are enabled, selected chart OHLC source >= lower band boundary AND selected chart OHLC source <= upper band boundary AND previous chart bar's selected chart OHLC source > previous chart bar's upper band boundary
Short: On confirmed chart bars, when retest events are enabled, selected chart OHLC source >= lower band boundary AND selected chart OHLC source <= upper band boundary AND previous chart bar's selected chart OHLC source < previous chart bar's lower band boundary