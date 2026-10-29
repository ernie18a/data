Calculation: Buy-side liquidity = latest confirmed pivot high, using equal left- and right-side lookbacks; remains active until raided or replaced by a newer confirmed pivot high
Calculation: Sell-side liquidity = latest confirmed pivot low, using equal left- and right-side lookbacks; remains active until raided or replaced by a newer confirmed pivot low
Calculation: Normalized trend expansion = absolute difference between the shorter-lookback and longer-lookback close EMAs, divided by ATR
Calculation: Trend-expansion percentile rank = rolling percentile rank of normalized trend expansion
Calculation: Volume percentile rank = rolling percentile rank of volume
Calculation: Lower-wick ratio = max(min(open, close) - low, 0) / max(high - low, minimum price increment)
Calculation: Upper-wick ratio = max(high - max(open, close), 0) / max(high - low, minimum price increment)
Calculation: Lower-wick percentile rank = rolling percentile rank of lower-wick ratio
Calculation: Upper-wick percentile rank = rolling percentile rank of upper-wick ratio
Calculation: Bullish reclaim = 100 × (close - low) / max(high - low, minimum price increment)
Calculation: Bearish reclaim = 100 × (high - close) / max(high - low, minimum price increment)
Calculation: Bullish sweep score = clamp(0.35 × volume percentile rank + 0.35 × lower-wick percentile rank + 0.30 × bullish reclaim, 0, 100)
Calculation: Bearish sweep score = clamp(0.35 × volume percentile rank + 0.35 × upper-wick percentile rank + 0.30 × bearish reclaim, 0, 100)
Long: sell-side liquidity is active AND low < sell-side liquidity AND close > sell-side liquidity AND trend-expansion percentile rank <= maximum threshold AND volume percentile rank >= minimum threshold AND bullish sweep score >= minimum threshold AND close > open when the directional reclaim candle filter is enabled AND all required ranks and ATR are available
Short: buy-side liquidity is active AND high > buy-side liquidity AND close < buy-side liquidity AND trend-expansion percentile rank <= maximum threshold AND volume percentile rank >= minimum threshold AND bearish sweep score >= minimum threshold AND close < open when the directional reclaim candle filter is enabled AND all required ranks and ATR are available