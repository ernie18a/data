Long: EMA(close, fast lookback)[1] > EMA(close, slow lookback)[1] AND close[1] > EMA(close, filter lookback)[1]
Short: EMA(close, fast lookback)[1] < EMA(close, slow lookback)[1] AND close[1] < EMA(close, filter lookback)[1]
Long: EMA(close, fast lookback)[1] > EMA(close, fast lookback)[2]
Short: EMA(close, fast lookback)[1] < EMA(close, fast lookback)[2]
Long: EMA(close, fast lookback, T1 bars, last completed bar) > EMA(close, slow lookback, T1 bars, last completed bar) AND close(T1 bars, last completed bar) > EMA(close, fast lookback, T1 bars, last completed bar)
Short: EMA(close, fast lookback, T1 bars, last completed bar) < EMA(close, slow lookback, T1 bars, last completed bar) AND close(T1 bars, last completed bar) < EMA(close, fast lookback, T1 bars, last completed bar)
Long: close[1] > Highest(high, breakout lookback)[2]
Short: close[1] < Lowest(low, breakout lookback)[2]