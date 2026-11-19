Calculation: signed flow-volatility value = π × ATR(ATR lookback)^2 × (sqrt(abs(ROC(OBV, OBV ROC lookback))) when ROC ≥ 0, otherwise −sqrt(abs(ROC(OBV, OBV ROC lookback))))
Calculation: normalized flow-volatility value = EMA(if highest(signed flow-volatility value, normalization lookback) equals lowest(signed flow-volatility value, normalization lookback), 50, otherwise 100 × (signed flow-volatility value − lowest(signed flow-volatility value, normalization lookback)) / (highest(signed flow-volatility value, normalization lookback) − lowest(signed flow-volatility value, normalization lookback)), energy smoothing lookback)
Calculation: band width = ATR(ATR lookback) × max(minimum power, normalized flow-volatility value / 50)
Calculation: squeeze condition = band width < SMA(band width, squeeze lookback) × squeeze ratio
Calculation: upper band = EMA(close, center lookback) + band width × band multiplier
Calculation: lower band = EMA(close, center lookback) − band width × band multiplier
Calculation: breakout suppression state = initially 0; set to 1 on Long, −1 on Short, or 0 when the squeeze condition is false and close is strictly between the bands; otherwise retain the prior value
Long: squeeze condition[1] AND close > upper band AND breakout suppression state before the current bar ≠ 1
Short: squeeze condition[1] AND close < lower band AND breakout suppression state before the current bar ≠ −1