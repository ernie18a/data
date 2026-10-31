Calculation: Smoothed RSI close = smooth (RSI of close − 50) × volume using the selected smoothing method and length.
Calculation: Smoothed RSI open = smooth (RSI of open − 50) × volume using the same method and length as smoothed RSI close; if absolute open − close is at most the gap threshold, replace it with the previous bar’s smoothed RSI close.
Calculation: Smoothing method = selected SMA, EMA, SMMA, linear weighted moving average, Jurik moving average, parabolic moving average, Tillson T3, VIDYA, or Kaufman adaptive moving average; parabolic moving average is the fitted value at the newest observation of a least-squares quadratic fitted over the lookback. For the ultralinear method, apply three successive stages of 1.5 × EMA(input) − 0.5 × EMA(EMA(input)), with each EMA using alpha = 3 / (length + 2) and initialized to its first input.
Long: Smoothed RSI close >= smoothed RSI open.
Short: Smoothed RSI close < smoothed RSI open.
Long: Previous smoothed RSI close < 0 AND current smoothed RSI close >= 0.
Short: Previous smoothed RSI close > 0 AND current smoothed RSI close <= 0.
Calculation: Higher-timeframe variant = apply the same calculations and decisions to the still-forming higher-timeframe bar and its previous higher-timeframe bar, and carry the resulting higher-timeframe values across chart bars within that higher-timeframe bar.