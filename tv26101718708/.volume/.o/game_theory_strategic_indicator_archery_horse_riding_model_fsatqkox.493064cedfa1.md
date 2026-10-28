Calculation: Mixed-strategy probability = clamp((current volume / its simple moving average − 1) × 0.5 + 0.5, 0, 1); use the same lookback as RSI and ATR.
Calculation: Buyer utility = p × (RSI − 50) / volatility + (1 − p) × (50 − RSI) / volatility, where p is the mixed-strategy probability and volatility = ATR / close × 100; RSI and ATR use the same lookback.
Calculation: Seller utility = 0.
Calculation: Nash score = 1 − |buyer utility − seller utility| / max(|buyer utility|, |seller utility|); if the maximum is zero, the score is 0. Nash state = Nash score > the equilibrium threshold.
Calculation: Replicator value = bullish frequency × (bull fitness − average fitness), where bullish frequency is the exponential moving average of 1 when close > prior close and 0 otherwise; bull fitness = RSI / 100; bear fitness = 1 − bull fitness; average fitness = bullish frequency × bull fitness + (1 − bullish frequency) × bear fitness. Use the RSI lookback for the moving average.
Calculation: Minimax value = sum of positive returns / sum of absolute nonpositive returns over the lookback, where each return = (prior close − earlier close) / earlier close; if the denominator is zero, use a positive fallback value.
Calculation: Best response = 1 when buyer utility > seller utility, −1 when seller utility > buyer utility, otherwise 0; confidence = |buyer utility − seller utility|.
Calculation: Composite score = 0.4 × best response × confidence + 0.3 × replicator value + 0.3 × (minimax value − 1).
Long: composite score > 0.5 AND Nash score ≤ the equilibrium threshold AND best response > 0.
Short: composite score < −0.5 AND Nash score ≤ the equilibrium threshold AND best response < 0.