Calculation: Frame vote(T) = +1 when source on T ≥ EMA(source, common EMA lookback, T), otherwise −1; calculate on T bars, with the confirmation parameter selecting the last completed T bar or the bar still forming, and have chart bars take the selected T-bar value
Calculation: Frame age(T) = number of T bars since Frame vote(T) last changed
Calculation: Fast score = 100 × Σ over included T1–T4 [Frame vote(T) × baseWeight(T) × freshnessFactor(T)] ÷ Σ over the same frames [baseWeight(T) × freshnessFactor(T)], where freshnessFactor(T) = 1 + fresh-boost parameter × (Frame age(T) ≤ fresh-window parameter ? 1 − Frame age(T) ÷ fresh-window parameter : 0); include T1 only when its inclusion setting is enabled; the fast weighting-mode parameter selects equal weights, separate per-frame rank-weight parameters, or separate per-frame minutes-weight parameters
Calculation: Slow score = 100 × Σ over T5–T7 [Frame vote(T) × baseWeight(T) × persistenceFactor(T)] ÷ Σ over T5–T7 [baseWeight(T) × persistenceFactor(T)], where persistenceFactor(T) = min(1 + Frame age(T) ÷ persistence-divisor parameter, persistence-cap parameter); the slow weighting-mode parameter selects equal weights, separate per-frame rank-weight parameters, or separate per-frame minutes-weight parameters
Calculation: Overall score = long-term blend parameter × Slow score + (1 − long-term blend parameter) × Fast score
Calculation: Band line for each of T8 and T9 = EMA(source, common EMA lookback, that timeframe, bar selected by the confirmation parameter), optionally EMA-smoothed on chart bars using the smoothing-lookback parameter according to the band-smoothing setting
Calculation: Raw band zone on chart bars = above when close > max(band line T8, band line T9), below when close < min(band line T8, band line T9), otherwise between
Calculation: Displayed band zone starts as the Raw band zone and changes to a different Raw band zone only after that zone has remained unchanged for the fade-lookback parameter number of consecutive chart bars; otherwise retain the prior displayed zone
Long: T1 inclusion setting enabled AND Frame vote(T1) = +1
Short: T1 inclusion setting enabled AND Frame vote(T1) = −1
Long: Frame vote(T2) = +1
Short: Frame vote(T2) = −1
Long: Frame vote(T3) = +1
Short: Frame vote(T3) = −1
Long: Frame vote(T4) = +1
Short: Frame vote(T4) = −1
Long: Frame vote(T5) = +1
Short: Frame vote(T5) = −1
Long: Frame vote(T6) = +1
Short: Frame vote(T6) = −1
Long: Frame vote(T7) = +1
Short: Frame vote(T7) = −1
Long: Fast score ≥ bias threshold parameter
Short: Fast score ≤ −bias threshold parameter
Long: Slow score ≥ bias threshold parameter
Short: Slow score ≤ −bias threshold parameter
Long: Overall score ≥ bias threshold parameter
Short: Overall score ≤ −bias threshold parameter
Long: band display enabled AND Displayed band zone is above
Short: band display enabled AND Displayed band zone is below