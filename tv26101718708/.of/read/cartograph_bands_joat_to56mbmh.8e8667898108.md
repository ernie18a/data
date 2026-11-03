Calculation: Momentum score = clamp(EMA(0.32 × clamp((RSI(close) − 50) / 50, −1, 1) + 0.24 × clamp(CMO(close) / 100, −1, 1) + 0.24 × clamp(ROC z-score / 2.5, −1, 1) + 0.20 × slope component, momentum smoothing length), −1, 1). ROC z-score = (ROC(close) − SMA(ROC(close))) / standard deviation of ROC(close), using the same lookback for the SMA and standard deviation; division by zero returns zero. Slope component = clamp(linear regression slope of close / max(0.35 × ATR, minimum price increment × 10), −1, 1), with division by zero returning zero.
Calculation: Regime score = clamp(EMA(0.65 × momentum score + 0.35 × EMA(slope component, momentum smoothing length), longer regime smoothing length), −1, 1).
Long: Momentum score > 0.
Short: Momentum score < 0.
Long: Regime score > 0.
Short: Regime score < 0.
Long: Regime score > bullish threshold.
Short: Regime score < bearish threshold.
Long: Regime score on the last completed bar of any of three higher timeframes > bullish threshold.
Short: Regime score on the last completed bar of any of three higher timeframes < bearish threshold.