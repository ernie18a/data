Calculation: JCCX = JurX(price − JMA(price)) / JurX(abs(price − JMA(price))), capped to [−1, 1]; JMA and both JurX smoothers use the selected applied price on the higher-timeframe bar still forming.
Calculation: Fast trend = weighted sum of five JCCX values on that same higher-timeframe bar; their lookbacks are ordered shortest to longest.
Calculation: Slow trend = Fast trend / smoothing length + previous Slow trend × (1 − 1 / smoothing length), using the same higher-timeframe series.
Long: Fast trend > Slow trend
Short: Fast trend < Slow trend