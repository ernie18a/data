Calculation: Relative volume = volume / SMA(volume, core lookback)
Calculation: Flow = clamp(EMA(((close - prior close) / ATR) × min(relative volume, 3), flow smoothing), -1, 1)
Calculation: Displacement = clamp(((close - open) / ATR) × min(relative volume, 3) / 2.2, -1, 1)
Calculation: Structure = clamp(2 × (close - rolling low) / (rolling high - rolling low) - 1, -1, 1), where rolling high and low use the core lookback including the current bar
Calculation: Strix Score = EMA(50 + 50 × (0.444 × Flow + 0.328 × Displacement + 0.228 × Structure), flow smoothing)
Long: chart bar is confirmed AND Strix Score ≥ signal threshold AND prior bar's Strix Score < signal threshold AND no setup is active or the prior setup closed at TP3 or stop loss
Short: chart bar is confirmed AND Strix Score ≤ 100 - signal threshold AND prior bar's Strix Score > 100 - signal threshold AND no setup is active or the prior setup closed at TP3 or stop loss
Exit: Long, after the entry bar, low ≤ entry price - ATR at entry × stop-loss multiplier OR high ≥ entry price + ATR at entry × third-target multiplier
Exit: Short, after the entry bar, high ≥ entry price + ATR at entry × stop-loss multiplier OR low ≤ entry price - ATR at entry × third-target multiplier