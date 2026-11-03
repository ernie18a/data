Calculation: ATR = average true range over the configured ATR lookback.
Calculation: Relative volume = volume divided by its simple moving average over the core lookback; use 1 when that average is zero.
Calculation: Wick absorption pressure = clamp(((lower wick − upper wick) / (high − low)) × min(relative volume, 2.5) / 1.4, −1, 1), where upper wick = high − max(open, close) and lower wick = min(open, close) − low.
Calculation: Liquidity sweep rejection = 1 if low is below the lowest low of the prior core-lookback bars and close is above that low; −1 if high is above the highest high of the prior core-lookback bars and close is below that high; otherwise 0.
Calculation: Normalized flow = clamp(EMA(((close − prior close) / ATR) × min(relative volume, 3), flow smoothing length), −1, 1).
Calculation: Score = EMA(50 + 50 × clamp(0.72 × (0.45 × wick absorption pressure + 0.30 × liquidity sweep rejection + 0.25 × normalized flow) + 0.28 × ((22 × wick absorption pressure + 20 × liquidity sweep rejection + 18 × normalized flow) / 60), −1, 1), flow smoothing length).
Calculation: Long stop = entry price − ATR at entry × stop multiplier; long TP3 = entry price + ATR at entry × TP3 multiplier. Short stop = entry price + ATR at entry × stop multiplier; short TP3 = entry price − ATR at entry × TP3 multiplier.
Long: score ≥ signal threshold AND prior score < signal threshold AND chart bar is confirmed AND no active setup or prior setup closed.
Short: score ≤ 100 − signal threshold AND prior score > 100 − signal threshold AND chart bar is confirmed AND no active setup or prior setup closed.
Exit: long, after the entry bar AND (low ≤ long stop OR (high ≥ long TP3 AND low > long stop))
Exit: short, after the entry bar AND (high ≥ short stop OR (low ≤ short TP3 AND high < short stop))