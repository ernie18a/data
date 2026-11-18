Calculation: Most recent long-event time = current chart-bar time when the still-forming T1 close crosses above the still-forming T1 open on chart bars, otherwise its prior value, initially 0
Calculation: Most recent short-event time = current chart-bar time when the still-forming T1 close crosses below the still-forming T1 open on chart bars, otherwise its prior value, initially 0
Long: crossover(most recent long-event time, most recent short-event time)
Short: crossover(most recent short-event time, most recent long-event time)
Long: cross(close, SMA(close, channel lookback)) == 1 AND rising(close, close-trend lookback)
Short: cross(close, SMA(close, channel lookback)) == 1 AND falling(close, close-trend lookback)
Long: rising(EMA(close, EMA 1 lookback), EMA direction lookback)
Short: falling(EMA(close, EMA 1 lookback), EMA direction lookback)
Long: rising(EMA(close, EMA 2 lookback), EMA direction lookback)
Short: falling(EMA(close, EMA 2 lookback), EMA direction lookback)