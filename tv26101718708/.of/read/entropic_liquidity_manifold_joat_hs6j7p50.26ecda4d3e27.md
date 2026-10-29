Calculation: Bar range = max(high - low, positive minimum-price-increment floor)
Calculation: Close location = ((close - low) - (high - close)) / bar range
Calculation: Volume density = volume / bar range
Calculation: Density z-score = z-score of volume density over the density-memory lookback
Calculation: Volume z-score = z-score of volume over the same density-memory lookback
Calculation: Auction entropy = clamp(EMA(1 - abs(close location), entropy-memory lookback), 0, 1)
Calculation: Directional auction = EMA(close location × volume, short lookback) / max(EMA(volume, same short lookback), 1)
Calculation: Participation = clamp(14 × density z-score + 8 × volume z-score + 50, 0, 100)
Calculation: Adaptive liquidity mean = initialize to HLC3; thereafter add adaptive alpha × (HLC3 - prior mean), where adaptive alpha = clamp(0.035 + 0.018 × max(density z-score, 0) + 0.030 × auction entropy, 0.025, 0.22)
Calculation: Displacement = (close - adaptive liquidity mean) / max(ATR, positive minimum-price-increment floor)
Calculation: Liquidity shelf width = ATR × (0.65 + 0.65 × clamp(participation / 100, 0, 1.5) + 0.30 × auction entropy)
Calculation: Upper liquidity shelf = adaptive liquidity mean + liquidity shelf width
Calculation: Lower liquidity shelf = adaptive liquidity mean - liquidity shelf width
Calculation: Release score = clamp(35 × (1 - auction entropy) + 0.30 × participation + 18 × abs(displacement) + 25 × abs(directional auction), 0, 100)
Calculation: Absorption score = clamp(45 × auction entropy + 0.35 × participation - 9 × abs(displacement) + 12 when bar range is below its SMA over the density-memory lookback, otherwise 0, 0, 100)
Long: bar is confirmed AND release score >= release threshold AND close > upper liquidity shelf AND directional auction > 0 AND no long-release event on the prior bar AND cooldown has elapsed since the most recent absorption, long-release, or short-release event
Short: bar is confirmed AND release score >= release threshold AND close < lower liquidity shelf AND directional auction < 0 AND no short-release event on the prior bar AND cooldown has elapsed since the most recent absorption, long-release, or short-release event