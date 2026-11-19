Long: on a confirmed chart bar, if the chart timeframe is intraday or T2, this is the first bar in the current T1 period with high > high(T1, last completed bar)
Short: on a confirmed chart bar, if the chart timeframe is intraday or T2, this is the first bar in the current T1 period with low < low(T1, last completed bar)
Long: at a confirmed chart-bar close, close > high(T1, last completed bar) AND close[1] <= high(T1, last completed bar)
Short: at a confirmed chart-bar close, close < low(T1, last completed bar) AND close[1] >= low(T1, last completed bar)