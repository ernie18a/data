Calculation: Normalized volume-weighted momentum = normalize the cumulative sum of (close change × volume) using its 100-bar lowest and highest values to a range of −50 to +50.
Calculation: Imbalance score = clamp to −100…100 the decaying cumulative sum of each bar’s (close − range midpoint) / (high − low), divided by ATR and multiplied by 15; decay the prior sum each bar.
Calculation: Liquidity vacuum = volume < volume EMA − (sigma × volume standard deviation) AND high − low > ATR.
Long: ADX > trend threshold AND close > EMA(close, longer-term lookback) AND normalized volume-weighted momentum crosses above its positive threshold AND imbalance score > its positive gate AND NOT liquidity vacuum AND cooldown elapsed
Long: Imbalance score crosses above 40
Short: ADX > trend threshold AND close < EMA(close, longer-term lookback) AND normalized volume-weighted momentum crosses below its negative threshold AND imbalance score < its negative gate AND NOT liquidity vacuum AND cooldown elapsed
Short: Imbalance score crosses below −40
Exit: long, high >= entry price + ATR at entry × take-profit multiple OR low <= entry price − ATR at entry × stop-loss multiple
Exit: short, low <= entry price − ATR at entry × take-profit multiple OR high >= entry price + ATR at entry × stop-loss multiple