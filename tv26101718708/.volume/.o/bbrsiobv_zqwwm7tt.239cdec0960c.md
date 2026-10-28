Calculation: Bollinger middle band = simple moving average of close; upper and lower bands = middle band ± a multiplier × standard deviation of close, using the same lookback
Calculation: On-balance volume = cumulative sum of sign(close − prior-bar close) × volume
Long: close > Bollinger middle band AND RSI(close) > 50 AND on-balance volume > prior-bar on-balance volume
Short: close < Bollinger middle band AND RSI(close) < 50 AND on-balance volume < prior-bar on-balance volume
Exit: long, close < Bollinger lower band
Exit: short, close > Bollinger upper band