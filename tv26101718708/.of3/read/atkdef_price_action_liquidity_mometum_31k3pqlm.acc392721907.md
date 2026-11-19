Calculation: Body strength = if high > low then (close - open) / (high - low) else 0
Calculation: Body percentage = if high > low then abs(close - open) / (high - low) else 0
Calculation: Momentum index = RSI(close, RSI lookback) × price RSI weight + RSI(volume, RSI lookback) × volume RSI weight
Calculation: Reversal score = (1 if sign(close - close[1]) and sign(Chaikin Money Flow(lookback)) are both nonzero and differ, else 0) × min(ATR(ATR lookback) / close / volatility normalization ratio, normalization cap) × min((1 − abs(upper wick ratio − lower wick ratio)) × (1 + abs(Body strength)), normalization cap), where upper wick ratio = if high > low then (high − max(close, open)) / (high − low) else 0 and lower wick ratio = if high > low then (min(close, open) − low) / (high − low) else 0
Long: Chaikin Money Flow(lookback) > inflow threshold
Short: Chaikin Money Flow(lookback) < outflow threshold
Long: Momentum index > bullish threshold AND Momentum index ≤ overbought threshold
Short: Momentum index ≥ oversold threshold AND Momentum index ≤ bearish threshold
Long: Momentum index ≥ oversold threshold AND Momentum index ≤ overbought threshold AND Chaikin Money Flow(lookback) > 0 AND Body strength > 0
Short: Momentum index ≥ oversold threshold AND Momentum index ≤ overbought threshold AND Chaikin Money Flow(lookback) < 0 AND Body strength < 0
Long: Body percentage[n] ≥ doji threshold AND Body strength[n] > 0 for any n ∈ {0, 1, 2}
Short: Body percentage[n] ≥ doji threshold AND Body strength[n] ≤ 0 for any n ∈ {0, 1, 2}
Short: Reversal score > heavy sell threshold