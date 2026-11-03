Calculation: Estimated volume delta = EMA(volume × (2 × (close − low) / (high − low) − 1)); when high = low, use zero
Calculation: Cumulative delta = running sum of estimated volume delta, reset at the start of each day
Calculation: Smoothed buy share = EMA(100 × estimated buy volume / volume), where estimated buy volume = volume × (close − low) / (high − low); when high = low, estimated buy volume = volume / 2
Calculation: Relative volume = volume / average volume over a lookback
Long: Estimated volume delta > 0 OR Cumulative delta > 0 OR Smoothed buy share ≥ imbalance threshold OR Relative volume ≥ block multiplier AND close ≥ open OR close > daily VWAP OR Cumulative delta > 0 AND Smoothed buy share > 50
Short: Estimated volume delta ≤ 0 OR Cumulative delta ≤ 0 OR Smoothed buy share ≤ 100 − imbalance threshold OR Relative volume ≥ block multiplier AND close < open OR close ≤ daily VWAP OR Cumulative delta < 0 AND Smoothed buy share < 50