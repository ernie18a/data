Calculation: Calendar spread = selected front-month futures price - selected back-month futures price
Calculation: Z-Score = (calendar spread - SMA(calendar spread, lookback length)) / standard deviation(calendar spread, lookback length)
Long: Z-Score crosses above negative entry threshold
Short: Z-Score crosses below entry threshold
Exit: Long, (take-profit-at-mean enabled AND Z-Score crosses below zero) OR (stop-loss enabled AND Z-Score is below negative stop threshold)
Exit: Short, (take-profit-at-mean enabled AND Z-Score crosses above zero) OR (stop-loss enabled AND Z-Score is above stop threshold)