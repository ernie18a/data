Calculation: rvol = volume / simple moving average of volume over the core lookback (1 if the average is unavailable or not positive)
Calculation: components, each tanh(sensitivity * raw), with every denominator floored at a tiny positive value: impulse = (close - close one core lookback ago) / (short-period ATR * sqrt(core lookback)); slope = (short EMA of close - long EMA of close) / short-period ATR; momentum = short-period ROC of close / stdev of that ROC over the core lookback; range = clamp((close - midpoint of core-lookback highest high and lowest low) / (half of that high-low span), -1, 1); body = (close - open) / (high - low)
Calculation: pressureScore = 100 * tanh(c * blend), where blend = positive-weighted sum of the five components (weights decreasing in the order impulse > slope > momentum = range > body) + small positive coefficient * (clamp((rvol - a) / b, 0, 1) - 0.5)
Calculation: signalLine = EMA of pressureScore, length shorter than the core lookback
Calculation: consensus = clamp(1 - (|impulse - slope| + |slope - momentum| + |momentum - range| + |range - body|) / 8, 0, 1), using the tanh-normalized components
Long: on a completed bar, pressureScore crosses above signalLine (previous bar pressureScore <= signalLine, current bar pressureScore > signalLine) AND pressureScore > entry threshold (positive) AND consensus >= min conviction AND rvol >= min relative volume
Short: on a completed bar, pressureScore crosses below signalLine (previous bar pressureScore >= signalLine, current bar pressureScore < signalLine) AND pressureScore < -entry threshold AND consensus >= min conviction AND rvol >= min relative volume
Long: pressureScore > signalLine AND pressureScore > 0
Short: pressureScore < signalLine AND pressureScore < 0
Long: pressureScore > bias threshold (positive, smaller than the entry threshold)
Short: pressureScore < -bias threshold