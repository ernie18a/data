Calculation: Volatility = standard deviation of close-to-close log returns over the volatility lookback
Calculation: Velocity = EMA of close-to-close log return divided by volatility, using the velocity smoothing lookback
Calculation: Acceleration = EMA of the change in velocity, using half the velocity smoothing lookback (minimum 2 bars)
Calculation: Jerk = EMA of the change in acceleration, using 3 bars
Calculation: Equilibrium = 5-bar EMA of 62% linear regression of close and 38% VWAP of hlc3, using the equilibrium lookback for the regression
Calculation: Displacement = (close − equilibrium) / ATR(14)
Calculation: Normalized energy = clamp(14 × z-score of kinetic energy over the volatility lookback + 50, 0, 100), where kinetic energy = 0.5 × velocity² / (volatility × √252)
Calculation: Inertia score = clamp(50 + 12 × velocity + 22 × acceleration + 16 × jerk + sign(displacement) × min(7 × abs(displacement), 18), 0, 100)
Calculation: Energy rail width = ATR(14) × (0.75 + 0.75 × clamp(normalized energy / 100, 0, 1.25) + 0.18 × min(abs(displacement), 2.5)); upper rail = equilibrium + width; lower rail = equilibrium − width
Long: On a completed bar, at least the cooldown interval has passed since the previous signal AND ((inertia score > inertia gate AND velocity > 0 AND acceleration > 0 AND normalized energy ≥ energy gate AND close > prior bar's upper energy rail) OR (displacement < −1.5 AND acceleration > 0 AND close > lower energy rail))
Short: On a completed bar, at least the cooldown interval has passed since the previous signal AND ((inertia score < 100 − inertia gate AND velocity < 0 AND acceleration < 0 AND normalized energy ≥ energy gate AND close < prior bar's lower energy rail) OR (displacement > 1.5 AND acceleration < 0 AND close < upper energy rail))