Calculation: Source close = close of the last completed bar from a timeframe lower than the chart timeframe
Calculation: True Strength Index = 100 × EMA(EMA(change in source close, longer lookback), shorter lookback) ÷ EMA(EMA(abs(change in source close), longer lookback), shorter lookback)
Calculation: Signal = EMA(True Strength Index, lookback shorter than both True Strength Index smoothing lookbacks)
Long: True Strength Index crosses above Signal AND datetime is within the configured backtest window
Short: True Strength Index crosses below Signal AND datetime is within the configured backtest window
Exit: Long, True Strength Index crosses below Signal AND datetime is within the configured backtest window
Exit: Short, True Strength Index crosses above Signal AND datetime is within the configured backtest window