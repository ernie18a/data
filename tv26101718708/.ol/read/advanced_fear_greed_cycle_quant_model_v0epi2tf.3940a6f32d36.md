Calculation: Normalized ATR = ATR over a short-term lookback, scaled to 0–100 by its position between the rolling-window minimum and maximum; use 0 if the range is zero.
Calculation: Normalized volume = volume’s position between the rolling-window minimum and maximum; use 0.5 if the range is zero.
Calculation: Sell pressure = (high − close) / (high − low); use 0.5 if high equals low.
Calculation: Normalized OBV = cumulative OBV’s position between its rolling-window minimum and maximum; OBV adds volume when close rises, subtracts volume when close falls, and is unchanged otherwise. Use 0.5 if the range is zero.
Calculation: Volatility fear = normalized ATR when close is below the short-term SMA of close, otherwise 0.
Calculation: Flow fear = weighted combination of normalized volume, sell pressure, and 1 − normalized OBV, scaled to 0–100.
Calculation: Fear index = weighted combination of volatility fear and flow fear.
Calculation: Normalized extension = the percentage distance of close above or below a long-term SMA, normalized to 0–100 by its position between the rolling-window minimum and maximum; use 50 if the range is zero. The long-term SMA lookback is longer than the short-term SMA lookback.
Calculation: Greed score = ((100 − fear index) + normalized extension) / 2.
Long: Fear index > its accumulation threshold AND normalized extension < its accumulation threshold.
Short: Greed score > the bubble threshold AND normalized extension > the bubble threshold