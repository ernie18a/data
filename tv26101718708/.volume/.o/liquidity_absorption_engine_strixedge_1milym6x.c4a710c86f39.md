Calculation: Relative volume = volume divided by its lookback simple moving average; use 1 if the average is zero.
Calculation: Absorption = clamp(((lower wick − upper wick) / (high − low)) × min(relative volume, 2.5) / 1.4, −1, 1), where upper wick = high − max(open, close) and lower wick = min(open, close) − low.
Calculation: Sweep rejection = +1 if the current low is below the lowest low of the preceding lookback bars and close is above that low; otherwise −1 if the current high is above the highest high of the preceding lookback bars and close is below that high; otherwise 0.
Calculation: Flow = clamp(EMA(((close − previous close) / ATR) × min(relative volume, 3), flow smoothing), −1, 1).
Calculation: Score = EMA(50 + 50 × clamp(0.72 × clamp(0.45 × absorption + 0.30 × sweep rejection + 0.25 × flow, −1, 1) + 0.28 × ((0.22 × absorption + 0.20 × sweep rejection + 0.18 × flow) / 0.60), −1, 1), flow smoothing).
Long: current score ≥ signal threshold AND previous score < signal threshold AND chart bar is confirmed AND no setup is active (or the prior setup ended at TP3 or stop loss).
Short: current score ≤ 100 − signal threshold AND previous score > 100 − signal threshold AND chart bar is confirmed AND no setup is active (or the prior setup ended at TP3 or stop loss).
Exit: long, after the entry bar, low ≤ entry price − entry-bar ATR × stop multiplier OR high ≥ entry price + entry-bar ATR × third-target multiplier.
Exit: short, after the entry bar, high ≥ entry price + entry-bar ATR × stop multiplier OR low ≤ entry price − entry-bar ATR × third-target multiplier.