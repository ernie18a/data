Calculation: Z-score = (value − SMA(value, lookback)) / standard deviation(value, lookback); use 0 when the standard deviation is 0.
Calculation: Squash(x) = 100 × (2 / (1 + exp(−0.9 × x)) − 1).
Calculation: Normalized ROC = (close − close at the ROC lookback) / ATR; use 0 when ATR is 0.
Calculation: RSI velocity = RSI − RSI at the velocity lookback.
Calculation: Normalized OBV slope = (OBV − OBV at the slope lookback) / (SMA(volume, volume lookback) × slope lookback); use 0 when average volume is 0.
Calculation: Momentum = squash of the weighted average of the Z-scores of TSI, normalized ROC, RSI velocity, normalized OBV slope, and the MACD histogram; use 0 for the weighted average when the sum of weights is 0. TSI and MACD each use shorter and longer smoothing lengths.
Calculation: Wave = squash of the MACD histogram Z-score multiplied by a positive amplitude.
Calculation: Acceleration = EMA(momentum − previous momentum).
Calculation: Direction = bullish initially; change to bullish when acceleration > positive deadzone and to bearish when acceleration < negative deadzone; otherwise retain the previous direction.
Calculation: Gate passes when the gate is disabled OR ADX ≥ minimum ADX AND relative volume ≥ minimum relative volume. Relative volume = volume / SMA(volume, volume lookback), or 1 when average volume is 0; use the same volume lookback as normalized OBV slope.
Calculation: Regime = neutral initially; change to bullish after direction is bullish and the gate passes for the confirmation lookback of consecutive bars, or to bearish after direction is bearish and the gate passes for that many consecutive bars; otherwise retain the previous regime.
Long: Direction = bullish AND gate passes.
Short: Direction = bearish AND gate passes.
Long: Regime = bullish.
Short: Regime = bearish.
Long: Wave ≥ 0.
Short: Wave < 0.
Long: Momentum crosses above 0 AND gate passes.
Short: Momentum crosses below 0 AND gate passes.
Long: A momentum pivot low is confirmed AND its momentum is greater than the previous confirmed momentum pivot low AND the price low at that pivot is less than the price low at the previous momentum pivot low. Confirm pivots after the specified number of right-side bars, using the specified number of left-side bars.
Short: A momentum pivot high is confirmed AND its momentum is less than the previous confirmed momentum pivot high AND the price high at that pivot is greater than the price high at the previous momentum pivot high. Confirm pivots after the specified number of right-side bars, using the specified number of left-side bars.
Long: Wave crosses above 0.
Short: Wave crosses below 0.
Exit: long, momentum > positive exhaustion threshold AND acceleration < 0.
Exit: short, momentum < negative exhaustion threshold AND acceleration > 0.
Exit: long, direction = bearish AND momentum > EMA(momentum, signal lookback) AND gate passes.