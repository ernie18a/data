Long: close(T1, last completed bar) > EMA(high, lookback, T1, last completed bar) AND close(T1, last completed bar)[1] < EMA(high, lookback, T1, last completed bar)[1] AND close(T1, last completed bar)[2] < EMA(high, lookback, T1, last completed bar)[2] AND close(T1, last completed bar)[3] < EMA(high, lookback, T1, last completed bar)[3]
Long: close(T1, last completed bar) > HIGHEST(high, price lookback, T1, last completed bar, chart bars)[1] AND volume(T1, last completed bar) > HIGHEST(volume, volume lookback, T1, last completed bar, chart bars)[1] AND close(T1, last completed bar) > SMA(close, trend lookback, T1, last completed bar, chart bars)
Short: close(T1, last completed bar) < LOWEST(low, price lookback, T1, last completed bar, chart bars)[1] AND volume(T1, last completed bar) > HIGHEST(volume, volume lookback, T1, last completed bar, chart bars)[1] AND close(T1, last completed bar) < SMA(close, trend lookback, T1, last completed bar, chart bars)
Long: on T2 last completed bar, close[1] < open[1] AND open > open[1]
Long: on T2 last completed bar, open < low[1] AND close > low[1]
Long: on T2 last completed bar, open = low
Long: on T2 last completed bar, high <= high[1] AND low >= low[1]
Long: on T2 last completed bar, high[1] < high[3] AND close > high[1] AND close > high[2] AND close > high[3]
Short: on T2 last completed bar, open > high[1] AND close <= high[1]
Short: on T2 last completed bar, open = high
Short: on T2 last completed bar, high > high[1] AND low < low[1]
Short: on T2 last completed bar, low[1] > low[3] AND close < low[1] AND close < low[2] AND close < low[3]