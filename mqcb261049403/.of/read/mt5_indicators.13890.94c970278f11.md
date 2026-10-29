Calculation: JJRSX = Jurik-smoothed ratio of JurX-smoothed price change to JurX-smoothed absolute price change, clipped to [-1, 1]; use progressively longer lookbacks for the five component values.
Calculation: FastTrend = weighted sum of the five JJRSX values, using the corresponding weights; the third and second values use the same weight.
Calculation: SlowTrend = FastTrend / smoothing lookback + previous SlowTrend × (1 − 1 / smoothing lookback).
Long: FastTrend > SlowTrend on the chart timeframe or, for each configured higher timeframe, on its bar still forming.
Short: FastTrend < SlowTrend on the chart timeframe or, for each configured higher timeframe, on its bar still forming.