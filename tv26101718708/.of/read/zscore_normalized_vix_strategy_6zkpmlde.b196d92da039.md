Calculation: Index Z-score = (higher-timeframe index close from the last completed bar − its simple moving average) / its standard deviation, using the same lookback for all selected indices
Calculation: Combined Z-score = arithmetic mean of the selected valid index Z-scores (VIX, VIX3M, VIX9D, VVIX)
Long: Combined Z-score < −threshold
Exit: long, Combined Z-score > −threshold