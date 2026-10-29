Calculation: Bull MA = configured simple, exponential, or double-exponential moving average of volume when close > open, and zero otherwise
Calculation: Bear MA = configured simple, exponential, or double-exponential moving average of volume when open > close, and zero otherwise
Calculation: Smoothed ROC = EMA of the percentage change in close from its value one ROC lookback earlier; EMA lookback is half the ROC lookback
Long: Bull MA > Bear MA AND (Smoothed ROC > positive threshold OR Smoothed ROC < negative threshold of equal magnitude)
Short: Bull MA < Bear MA AND (Smoothed ROC > positive threshold OR Smoothed ROC < negative threshold of equal magnitude)
Exit: Long, after the most recent long-signal bar, low <= entry price × (1 − stop-loss fraction) OR high >= entry price × (1 + take-profit fraction)
Exit: Short, after the most recent short-signal bar, high >= entry price × (1 + stop-loss fraction) OR low <= entry price × (1 − take-profit fraction)