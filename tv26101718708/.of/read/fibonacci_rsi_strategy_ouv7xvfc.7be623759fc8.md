Calculation: lower 1 band = VWMA(typical price, lookback) − multiplier × standard deviation(typical price, same lookback)
Calculation: upper 1 band = VWMA(typical price, lookback) + multiplier × standard deviation(typical price, same lookback)
Calculation: lower 0.764 band = VWMA(typical price, lookback) − 0.764 × multiplier × standard deviation(typical price, same lookback)
Calculation: upper 0.764 band = VWMA(typical price, lookback) + 0.764 × multiplier × standard deviation(typical price, same lookback)
Long: year ≥ 2000 AND low < lower 1 band AND RSI one bar ago > oversold threshold AND RSI two bars ago ≤ oversold threshold AND high < lower 0.764 band
Short: year ≥ 2000 AND high > upper 1 band AND RSI one bar ago < overbought threshold AND RSI two bars ago ≥ overbought threshold AND low > upper 0.764 band
Exit: Long, high > lower 0.764 band captured when the position size first increases
Exit: Short, low < upper 0.764 band captured when the position size first decreases