Calculation: Regression channel = fit a linear regression of the selected price source over the lookback. At the current bar, the upper bound is the fitted value plus either a multiple of the root mean square regression residual or the maximum high above the fitted line over the lookback; the lower bound is the fitted value minus either a multiple of the same residual measure or the maximum fitted-line value above the low over the lookback.
Calculation: Buy volume ratio = sum of volume from bars with close >= open divided by total volume over the regression lookback, excluding bars with high = low; use one-half if total volume is zero.
Long: Linear regression slope > 0
Short: Linear regression slope <= 0
Long: Close > upper regression channel bound
Short: Close <= upper regression channel bound AND close < lower regression channel bound
Long: Buy volume ratio > one-half
Short: Buy volume ratio <= one-half