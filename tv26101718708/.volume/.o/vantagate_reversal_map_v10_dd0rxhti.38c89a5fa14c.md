Calculation: Regression center = linear regression of (high + low + close) / 3
Calculation: Zone ATR = ATR over the configured zone volatility lookback
Calculation: Upper/lower inner boundary = regression center ± Zone ATR × configured zone-entry distance
Calculation: Prior liquidity high/low = highest high / lowest low over the liquidity lookback, excluding the current bar
Calculation: Close location = (close − low) / candle range
Calculation: Lower zone event = low ≤ lower inner boundary AND (low < prior liquidity low AND close > prior liquidity low OR close location ≥ configured rejection threshold AND close > open)
Calculation: Upper zone event = high ≥ upper inner boundary AND (high > prior liquidity high AND close < prior liquidity high OR close location ≤ 1 − configured rejection threshold AND close < open)
Calculation: Zone ready = the corresponding zone event occurred within the configured zone-permission memory, including the current bar
Calculation: Vanta field = EMA of a weighted sum of normalized price stretch from an EMA equilibrium, normalized five-bar price velocity, velocity recoil from its EMA, and rejection bias scaled by volume surge; rejection bias is upper-wick fraction minus lower-wick fraction, and volume surge is volume relative to its EMA, clamped to the configured range
Calculation: Vanta natural = a bounded transform of Vanta field centered at the neutral level
Calculation: Vanta spring = Vanta natural displaced from neutral by a release factor that decreases as consecutive bars at an upper or lower extreme accumulate
Calculation: Vanta gravity = adaptive-alpha smoothing of Vanta spring, with alpha decreasing as Vanta spring moves farther from neutral
Long: bar closes AND lower zone event OR (Vanta spring crosses above Vanta gravity AND Vanta spring reached the lower extreme within its recent lookback AND Vanta spring is below neutral AND Vanta field is rising AND lower zone is ready)
Short: bar closes AND upper zone event OR (Vanta spring crosses below Vanta gravity AND Vanta spring reached the upper extreme within its recent lookback AND Vanta spring is above neutral AND Vanta field is falling AND upper zone is ready)