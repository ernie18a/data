Calculation: Volume RSI = RSI of the selected price source, where each upward change is weighted by estimated up-volume and each downward change by estimated down-volume; smooth both weighted changes with the same lookback
Calculation: Upper and lower thresholds = 50 × (1 + threshold) and 50 × (1 − threshold)
Long: Volume RSI > upper threshold OR (Volume RSI > lower threshold AND previous bar's Volume RSI trend is up)
Short: Volume RSI < lower threshold OR (Volume RSI < upper threshold AND previous bar's Volume RSI trend is down)