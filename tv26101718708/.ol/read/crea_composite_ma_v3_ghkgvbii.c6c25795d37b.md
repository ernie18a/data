Calculation: Rolling 0–100 normalization = (value − rolling minimum) / (rolling maximum − rolling minimum) × 100 over a lookback; use 50 when the range is zero.
Calculation: EMA bias score = EMA over a short smoothing lookback of 50 × (close > both a shorter-lookback EMA and a longer-lookback EMA) + 50 × (shorter-lookback EMA > longer-lookback EMA), with each condition treated as 1 when true and 0 otherwise.
Calculation: Volatility score = (100 − rolling 0–100 normalization of ATR as a percentage of close) averaged with the EMA bias score.
Calculation: Directional volume score = 50 + (clipped 0–100 volume z-score − 50) × candle direction, where the z-score uses a rolling lookback, is mapped from −2…+2 to 0…100, and candle direction is +1 when close ≥ open and −1 otherwise.
Calculation: Composite score = EMA over a short smoothing lookback of the weighted average of the EMA bias score, MFI, 0–100-normalized (+DI − −DI), volatility score, 0–100-normalized (close − open), directional volume score, and 0–100-normalized rate of change. Each component has a configurable weight.
Calculation: Higher-timeframe composite = the same composite calculated from higher-timeframe OHLCV, using the higher-timeframe bar still forming.
Calculation: Signal line = EMA of the composite score.
Long: Composite crosses above the bull threshold AND at least 5 of the 7 component scores are > 50 AND higher-timeframe composite ≥ its bull threshold.
Long: Composite crosses above the signal line AND at least 4 of the 7 component scores are > 50 AND higher-timeframe composite ≥ its bull threshold AND composite < the bull threshold.
Short: Composite crosses below the bear threshold AND at least 5 of the 7 component scores are < 50 AND higher-timeframe composite ≤ its bear threshold.
Short: Composite crosses below the signal line AND at least 4 of the 7 component scores are < 50 AND higher-timeframe composite ≤ its bear threshold AND composite > the bear threshold.