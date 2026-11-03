Calculation: Gaussian filter = multi-pole Gaussian low-pass filter of close, with optional lag reduction and fast-response averaging with a one-pole filter
Calculation: Money Flow Index = RSI of rolling sums of HLC3 × volume on rising HLC3 bars and falling HLC3 bars, using the same lookback
Calculation: Smoothed ROC = EMA of close’s percentage change over a longer lookback, with an EMA length half as long
Calculation: ROC is moving = Smoothed ROC > half the positive threshold OR Smoothed ROC < half the negative threshold
Long: Gaussian filter > its prior-bar value AND ROC is moving AND Money Flow Index > its prior-bar value
Short: Gaussian filter < its prior-bar value AND ROC is moving AND Money Flow Index < its prior-bar value
Exit: long, low ≤ entry price × (1 − stop-loss percentage) OR high ≥ entry price × (1 + take-profit percentage)
Exit: short, high ≥ entry price × (1 + stop-loss percentage) OR low ≤ entry price × (1 − take-profit percentage)