Calculation: Quotient with zero fallback(x, y) = 0 when y = 0; otherwise x / y
Calculation: Volume pulse ratio = Quotient with zero fallback(volume, EMA(volume, pressure lookback))
Calculation: Composite buying-pressure score = pressure-ratio weight * Quotient with zero fallback(EMA((((close - low) - (high - close)) / max(high - low, minimum tick)) * volume, pressure lookback), EMA(volume, pressure lookback)) + body-pressure weight * EMA(((close - open) / max(high - low, minimum tick)) * min(volume pulse ratio, volume-pulse cap), pressure lookback)
Calculation: Normalized order-pressure strength = clamp(strength gain * composite buying-pressure score / (nonlinearity offset + abs(composite buying-pressure score)), -strength limit, strength limit)
Calculation: Blended price basis = ALMA(price source, basis lookback, ALMA offset, ALMA sigma) * ALMA share + EMA(price source, basis lookback) * (1 - ALMA share)
Calculation: Adaptive width factor = width base + abs(normalized order-pressure strength) / strength normalization * strength width factor + clamp(volume pulse ratio - volume baseline, volume lower bound, volume upper bound) * volume width factor
Calculation: Cloud half-width = ATR(ATR lookback) * cloud multiplier * adaptive width factor
Calculation: Upper inner boundary = blended price basis + cloud half-width * inner-cloud fraction
Calculation: Lower inner boundary = blended price basis - cloud half-width * inner-cloud fraction
Long: On chart-bar close, (normalized order-pressure strength crosses above signal threshold AND close > blended price basis) OR (normalized order-pressure strength > signal threshold AND low <= upper inner boundary AND close > blended price basis)
Short: On chart-bar close, (normalized order-pressure strength crosses below negative signal threshold AND close < blended price basis) OR (normalized order-pressure strength < negative signal threshold AND high >= lower inner boundary AND close < blended price basis)