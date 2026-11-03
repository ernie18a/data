Calculation: Trend health = weighted blend of (1) long-term SMA distance, scored by clamping a linear transform of percentage distance to 0–100; (2) long-term SMA slope, scored by clamping a linear transform of percentage slope to 0–100; and (3) price-side bias, with a higher score above the SMA than at or below it.
Calculation: Normalized ATR = short-term SMA of true range divided by close.
Calculation: ATR rank = current normalized ATR scaled between its rolling low and high over a longer lookback; use the midpoint when the high equals the low.
Calculation: Volatility health = inverse linear transform of ATR rank, clamped to a bounded score.
Calculation: Trend persistence = fraction of consecutive bar pairs over a rolling lookback whose trend states have the same sign; each trend state adds a positive component when close is above the long-term SMA and another when the SMA is rising, and a negative component otherwise.
Calculation: Regime score = clamp the short-term SMA of an adaptive weighted blend of trend health and volatility health to 0–100; increase the trend weight as trend persistence rises and decrease it as persistence falls, with the volatility weight equal to the remainder.
Long: Current Regime score > upper threshold AND previous Regime score <= upper threshold.
Short: Current Regime score < lower threshold AND previous Regime score >= lower threshold.