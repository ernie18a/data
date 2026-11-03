Calculation: OTHERS-to-USDT-dominance ratio = OTHERS dominance divided by USDT dominance, using daily close bars aggregated from the backtest data; use the last completed daily bar when daily is higher than the chart timeframe.
Calculation: Log-ratio Z-Score = (natural logarithm of the ratio minus its rolling mean) divided by its rolling standard deviation.
Calculation: EMA of the Z-Score = exponential moving average of the Z-Score.
Long: (Visualization mode is Extremes AND Log-ratio Z-Score < lower inner threshold) OR (Visualization mode is Trend AND Log-ratio Z-Score > its EMA)
Short: (Visualization mode is Extremes AND Log-ratio Z-Score > upper inner threshold) OR (Visualization mode is Trend AND Log-ratio Z-Score <= its EMA)