Calculation: JCCX = JurX-smoothed (applied price − JMA-smoothed applied price) divided by JurX-smoothed absolute(applied price − JMA-smoothed applied price), clipped to [−1, 1]; the JMA and both JurX smoothers use the same smoothing parameters.
Calculation: Fast trend = weighted sum of five JCCX values with progressively longer lookbacks; the third and second values use the same weight parameter.
Calculation: Slow trend = current fast trend divided by its smoothing lookback + previous slow trend × (1 − 1 / that lookback).
Long: On any configured timeframe higher or lower than the chart timeframe, using its last completed bar, fast trend > slow trend.
Short: On any configured timeframe higher or lower than the chart timeframe, using its last completed bar, fast trend < slow trend.