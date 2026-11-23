Calculation: Intrabar delta = On each chart bar, sum volume × sign(close − close[1]) over its available T1 bars, including a still-forming T1 bar when available; if none are available, use chart-bar volume × sign(close − close[1]).
Calculation: Delta share = Intrabar delta divided by the sum of volume over the same T1 bars, or chart-bar volume if none are available; use 0 when that volume is 0.
Calculation: Flow-cost percentile = On chart bars, PercentRank(EMA(abs(Intrabar delta) / max(tick-travel floor, abs(close − close[1]) / minimum tick), cost-smoothing lookback), percentile lookback).
Long: Flow-cost percentile ≥ upper cost threshold AND Delta share ≤ −one-sided delta threshold
Short: Flow-cost percentile ≥ upper cost threshold AND Delta share ≥ one-sided delta threshold