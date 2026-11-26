Calculation: Selected MA(x) = chosen ALMA, HMA, SMA, SWMA, VWMA, WMA, ZLEMA, or EMA; use MA lookback except for fixed-length SWMA, ALMA also uses ALMA offset and ALMA sigma, and ZLEMA = EMA(2*x - x[floor((MA lookback - 1)/2)], MA lookback).
Calculation: Smoothed HA body = Selected MA(Heikin-Ashi close) - Selected MA(Heikin-Ashi open), on chart bars.
Calculation: Trend = 100 * Smoothed HA body / (Selected MA(Heikin-Ashi high) - Selected MA(Heikin-Ashi low)), on chart bars.
Calculation: Raw slope(n) = (Smoothed HA body - Smoothed HA body[n]) / n for Momentum; linreg(Smoothed HA body, n, 0) - linreg(Smoothed HA body, n, 1) for Linear Regression; otherwise SMA(Smoothed HA body - Smoothed HA body[1], n). Use separate fast and slow lookbacks, with fast shorter than slow.
Calculation: Blended slope = Kaufman Efficiency Ratio(close, ER lookback) * Raw slope(fast lookback) + (1 - Kaufman Efficiency Ratio(close, ER lookback)) * Raw slope(slow lookback); the ratio is 0 when its path sum is 0.
Calculation: Normalized slope = 100 * Blended slope / highest(abs(Blended slope), slope normalization lookback), or 0 when that highest value is 0.
Calculation: Trend slope = Normalized slope * slope scale / 100.
Calculation: Positive peak = Trend slope[1] > Trend slope AND Trend slope[1] >= Trend slope[2] AND Trend slope[1] > 0.
Calculation: Negative peak = Trend slope[1] < Trend slope AND Trend slope[1] <= Trend slope[2] AND Trend slope[1] < 0.
Calculation: Strong positive peak = Positive peak AND Normalized slope[1] > momentum threshold.
Calculation: Strong negative peak = Negative peak AND Normalized slope[1] < -momentum threshold.
Calculation: Bullish anchor = stored (Trend slope[1], close[1]) from a strong positive peak; initially inactive, it activates at a strong positive peak, expires before processing any bar with Trend <= 0, initializes on a strong positive peak while inactive, and updates after comparison on each strong positive peak while active.
Calculation: Bearish anchor = stored (Trend slope[1], close[1]) from a strong negative peak; initially inactive, it activates at a strong negative peak, expires before processing any bar with Trend >= 0, initializes on a strong negative peak while inactive, and updates after comparison on each strong negative peak while active.
Long: Trend slope > slope deadband AND Trend slope[1] <= slope deadband OR Positive peak AND previously active bullish anchor AND Trend > 0 AND Trend[1] > 0 AND Trend slope[1] < bullish anchor slope AND close[1] > bullish anchor close.
Short: Trend slope < -slope deadband AND Trend slope[1] >= -slope deadband OR Negative peak AND previously active bearish anchor AND Trend < 0 AND Trend[1] < 0 AND Trend slope[1] > bearish anchor slope AND close[1] < bearish anchor close.