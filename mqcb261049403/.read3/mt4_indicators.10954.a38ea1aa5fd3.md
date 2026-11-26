Long: current bid > EMA(close, lookback, T1, last completed bar)
Short: current bid < EMA(close, lookback, T1, last completed bar)
Calculation: daily return = round((((current bid / close[1, T2, last completed bar]) - 1) * 100) / scale parameter, rounding precision)
Long: daily return > 0
Short: daily return <= 0
Calculation: current daily candle change = round((close[0, T2, bar still forming] - open[0, T2, bar still forming]) * 100, rounding precision)
Long: current daily candle change > 0
Short: current daily candle change <= 0