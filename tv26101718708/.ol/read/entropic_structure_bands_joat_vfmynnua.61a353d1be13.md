Calculation: Adaptive regression = On each bar, calculate ordinary least squares on closing prices from each of the most recent confirmed pivot-high or pivot-low anchors to the current bar; keep candidates whose R² meets a minimum quality threshold and select the candidate with the highest R² × ln(number of bars). Recompute each bar.
Calculation: Entropy-adjusted deviation = Regression standard error × (1 + 0.8 × clamp((smoothed Shannon entropy − 1) / 3, 0, 1)); Shannon entropy is calculated from binned log returns over a lookback and smoothed with an EMA.
Calculation: Regression bands = Regression midline ± entropy-adjusted deviation × a band multiplier; inner and outer bands use separate multipliers, with the outer multiplier larger.
Calculation: Regression-channel Z-score = (close − regression midline) / entropy-adjusted deviation.
Calculation: Higher-timeframe regression slope = Adaptive regression slope calculated on a higher timeframe, using the last completed higher-timeframe bar.
Long: Regression slope > 0 AND close > regression midline AND close > prior close AND close > close two bars earlier AND (low one, two, or three bars earlier ≤ the corresponding bar's lower inner band) AND smoothed Shannon entropy < its threshold AND higher-timeframe regression slope > 0 AND ADX > its threshold AND RSI > 40 AND RSI < its overbought threshold
Long: Regression slope > 0
Long: Regression-channel Z-score < −1.5
Long: Regression slope > 0 AND prior regression slope ≤ 0
Short: Regression slope < 0 AND close < regression midline AND close < prior close AND close < close two bars earlier AND (high one, two, or three bars earlier ≥ the corresponding bar's upper inner band) AND smoothed Shannon entropy < its threshold AND higher-timeframe regression slope < 0 AND ADX > its threshold AND RSI < 60 AND RSI > (100 − its overbought threshold)
Short: Regression slope < 0
Short: Regression-channel Z-score > 1.5
Short: Regression slope < 0 AND prior regression slope ≥ 0