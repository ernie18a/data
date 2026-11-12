Calculation: T3 = Tillson T3 moving average of close (with a volume factor)
Calculation: Osc = (T3 - lowest(T3, N)) / (highest(T3, N) - lowest(T3, N)) - 0.5, or 0 if highest equals lowest; N is the rolling normalization lookback, longer than the T3 smoothing period
Long: Osc crosses above 0 (previous bar Osc <= 0 AND current bar Osc > 0)
Short: Osc crosses below 0 (previous bar Osc >= 0 AND current bar Osc < 0)