Calculation: Deviation = close - MA(source, MA lookback, MA type) in spread mode; 100 * (close - MA(source, MA lookback, MA type)) / MA(source, MA lookback, MA type) in percentage mode
Long: pivotlow(Deviation, pivot lookback, pivot lookback) is not na
Short: pivothigh(Deviation, pivot lookback, pivot lookback) is not na