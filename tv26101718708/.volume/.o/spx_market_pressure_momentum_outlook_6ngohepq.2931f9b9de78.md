Calculation: Liquidity pressure edge = clamp((0.55 × close location within range + 0.30 × candle body divided by range + 0.15 × clamp((close − previous close) / ATR, −1, 1)) × clamp(volume / its moving average, 0, volume cap), −1, 1); use 1 for the volume factor when unavailable or disabled
Calculation: Sigma edge = weighted average of SPY and QQQ liquidity pressure edges
Long: SPY, QQQ, or Sigma edge ≥ 0.2 on any of the three configured timeframes
Short: SPY, QQQ, or Sigma edge ≤ −0.2 on any of the three configured timeframes