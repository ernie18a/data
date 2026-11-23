Calculation: constituent oscillator = SMA(mean of ROC(constituent close, lookback) across constituents, smoothing length)
Calculation: index oscillator = SMA(ROC(equal-weight index close, lookback), smoothing length)
Calculation: relative oscillator = constituent oscillator - index oscillator
Calculation: breadth = percentage of constituents with ROC(constituent close, lookback) > 0
Long: constituent oscillator > bullish threshold
Long: index oscillator > bullish threshold
Long: relative oscillator > bullish threshold
Long: constituent oscillator crosses above bullish threshold
Long: index oscillator crosses above bullish threshold
Long: relative oscillator crosses above divergence threshold
Long: constituent oscillator crosses above zero
Long: index oscillator crosses above zero
Long: relative oscillator crosses above zero
Long: constituent oscillator > zero
Long: index oscillator > zero
Long: breadth > upper breadth threshold
Short: constituent oscillator < bearish threshold
Short: index oscillator < bearish threshold
Short: relative oscillator < bearish threshold
Short: constituent oscillator crosses below bearish threshold
Short: index oscillator crosses below bearish threshold
Short: relative oscillator crosses below -divergence threshold
Short: constituent oscillator crosses below zero
Short: index oscillator crosses below zero
Short: relative oscillator crosses below zero
Short: constituent oscillator <= zero
Short: index oscillator <= zero
Short: breadth < lower breadth threshold