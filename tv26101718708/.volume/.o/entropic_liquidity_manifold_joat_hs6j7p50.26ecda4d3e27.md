Calculation: Close location = ((close − low) − (high − close)) / max(high − low, minimum price increment)
Calculation: Volume density = volume / max(high − low, minimum price increment)
Calculation: Density z-score = (volume density − its moving average over density memory) / its standard deviation over density memory; use 0 when standard deviation is 0
Calculation: Volume z-score = (volume − its moving average over density memory) / its standard deviation over density memory; use 0 when standard deviation is 0
Calculation: Entropy = clamp(EMA(1 − abs(close location), entropy memory), 0, 1)
Calculation: Directed auction = EMA(close location × volume, short lookback) / max(EMA(volume, same short lookback), 1)
Calculation: Participation = clamp(14 × density z-score + 8 × volume z-score + 50, 0, 100)
Calculation: Adaptive manifold = initialize to (high + low + close) / 3; thereafter manifold + clamp(0.035 + 0.018 × max(density z-score, 0) + 0.030 × entropy, 0.025, 0.22) × ((high + low + close) / 3 − manifold)
Calculation: Displacement = (close − adaptive manifold) / max(ATR, minimum price increment)
Calculation: Shelf width = ATR × (0.65 + clamp(participation / 100, 0, 1.5) × 0.65 + entropy × 0.30)
Calculation: Upper shelf = adaptive manifold + shelf width
Calculation: Lower shelf = adaptive manifold − shelf width
Calculation: Release score = clamp((1 − entropy) × 35 + participation × 0.30 + abs(displacement) × 18 + abs(directed auction) × 25, 0, 100)
Calculation: Absorption event = confirmed bar AND absorption score ≥ absorption gate AND abs(displacement) < 0.85 AND participation > 54 AND high − low < its moving average over density memory AND abs(displacement) < 0.85 AND (previous bar was not an absorption condition OR cooldown has elapsed since the last absorption, upside release, or downside release event)
Long: confirmed bar AND release score ≥ release gate AND close > upper shelf AND directed auction > 0 AND (previous bar was not an upside release condition OR cooldown has elapsed since the last absorption, upside release, or downside release event)
Short: confirmed bar AND release score ≥ release gate AND close < lower shelf AND directed auction < 0 AND (previous bar was not a downside release condition OR cooldown has elapsed since the last absorption, upside release, or downside release event)