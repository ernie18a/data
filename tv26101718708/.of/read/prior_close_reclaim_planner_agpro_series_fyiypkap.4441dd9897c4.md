Calculation: Prior close = close of the last completed bar on a higher reference timeframe
Calculation: Reference ATR = ATR on the last completed bar of the higher reference timeframe
Calculation: Reclaim pocket = prior close ± reference ATR × pocket-width parameter; upper and lower edges bound the pocket
Calculation: Relative volume = current chart-bar volume / its moving average over the selected lookback
Calculation: Reclaim score = rounded, capped 0–100 score combining close quality, wick quality, relative volume, proximity to the prior close, volatility fit, optional wick-confirmation bonus, and excess-distance penalty
Long: On a completed chart bar, close crosses above the upper pocket edge AND reclaim score ≥ minimum ready score AND relative volume ≥ minimum AND reference age ≤ maximum
Long: On a completed chart bar, low ≤ upper pocket edge AND close > upper pocket edge AND close > open AND reclaim score ≥ minimum ready score AND relative volume ≥ minimum AND reference age ≤ maximum
Short: On a completed chart bar, close crosses below the lower pocket edge AND reclaim score ≥ minimum ready score AND relative volume ≥ minimum AND reference age ≤ maximum
Short: On a completed chart bar, high ≥ lower pocket edge AND close < lower pocket edge AND close < open AND reclaim score ≥ minimum ready score AND relative volume ≥ minimum AND reference age ≤ maximum
Exit: Long, a completed chart bar closes below the lower pocket edge after a qualified bullish reclaim
Exit: Short, a completed chart bar closes above the upper pocket edge after a qualified bearish reclaim