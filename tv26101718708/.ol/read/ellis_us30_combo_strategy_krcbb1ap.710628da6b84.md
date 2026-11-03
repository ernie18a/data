Calculation: Stochastic RSI K and D = RSI normalized between its rolling low and high, then smoothed twice; K uses the shorter smoothing and D the longer smoothing
Calculation: Bullish RSI divergence = the latest confirmed paired price low is lower than the preceding paired price low, its RSI low is higher, and the latest pivot is within the scan lookback
Calculation: Bearish RSI divergence = the latest confirmed paired price high is higher than the preceding paired price high, its RSI high is lower, and the latest pivot is within the scan lookback
Long: short-term SMA > intermediate-term SMA AND Stochastic RSI K crosses above D AND min(K, D) <= oversold threshold
Long: short-term SMA > intermediate-term SMA AND short-term SMA > long-term SMA AND intermediate-term SMA > long-term SMA AND MACD line crosses above signal line AND MACD line < 0 AND MACD signal line < 0 AND RSI > divergence midpoint AND bullish RSI divergence
Short: short-term SMA < intermediate-term SMA AND Stochastic RSI K crosses below D AND max(K, D) >= overbought threshold
Short: short-term SMA < intermediate-term SMA AND short-term SMA < long-term SMA AND intermediate-term SMA < long-term SMA AND MACD line crosses below signal line AND MACD line > 0 AND MACD signal line > 0 AND RSI < divergence midpoint AND bearish RSI divergence
Exit: long, low <= entry price - stop distance OR high >= entry price + target distance
Exit: short, high >= entry price + stop distance OR low <= entry price - target distance