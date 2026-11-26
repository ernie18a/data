Calculation: Trend score = 100 * SMA(average((ohlc4 > average(open, close, T1, last completed bar) ? 1 : 0), (ohlc4 > average(open, close, T2, last completed bar) ? 1 : 0), (ohlc4 > average(open, close, T3, last completed bar) ? 1 : 0), (ohlc4 > average(open, close, T4, last completed bar) ? 1 : 0), (ohlc4 > average(open[1], close[1]) ? 1 : 0)), lookback)
Long: ohlc4 > average(open, close, T1, last completed bar)
Short: ohlc4 <= average(open, close, T1, last completed bar)
Long: ohlc4 > average(open, close, T2, last completed bar)
Short: ohlc4 <= average(open, close, T2, last completed bar)
Long: ohlc4 > average(open, close, T3, last completed bar)
Short: ohlc4 <= average(open, close, T3, last completed bar)
Long: ohlc4 > average(open, close, T4, last completed bar)
Short: ohlc4 <= average(open, close, T4, last completed bar)
Long: ohlc4 > average(open[1], close[1])
Short: ohlc4 <= average(open[1], close[1])
Long: Trend score > threshold
Short: Trend score <= threshold