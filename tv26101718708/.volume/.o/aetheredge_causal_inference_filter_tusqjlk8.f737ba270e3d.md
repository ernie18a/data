Calculation: Momentum driver = z-score, clipped to ±3, of (shorter-period EMA(close) − longer-period EMA(close)) / ATR; the longer EMA period is twice the shorter.
Calculation: Volatility driver = z-score, clipped to ±3, of ATR / its longer-period moving average − 1.
Calculation: Volume anomaly = z-score, clipped to ±3, of volume / its moving average − 1.
Calculation: Range expansion = z-score, clipped to ±3, of (high − low) / its moving average − 1.
Calculation: Standardized driver = (value − its moving average) / its standard deviation over the same normalization window.
Calculation: Driver causal lift = max(0, absolute rolling correlation of the lagged driver with the current one-bar return − half the absolute rolling autocorrelation of one-bar returns at that lag).
Calculation: Neural forecast = output of an online neural network with the four drivers as inputs, a tanh hidden layer, and a tanh output; it is trained by replaying past driver observations against forward returns scaled by ATR.
Calculation: Driver importance = absolute difference between the full neural forecast and the forecast with that driver set to zero.
Calculation: Causal confidence = EMA of the clipped [0,1] average of (min(1, 2 × top driver causal lift / minimum lift threshold)) and (min(1, (top driver's share of total importance − 0.25) / 0.5)); the top driver is the one with greatest importance.
Long: On a completed bar, neural forecast > 0.05 AND smoothed causal confidence ≥ its threshold AND the prior qualifying directional signal was not long.
Short: On a completed bar, neural forecast < −0.05 AND smoothed causal confidence ≥ its threshold AND the prior qualifying directional signal was not short.