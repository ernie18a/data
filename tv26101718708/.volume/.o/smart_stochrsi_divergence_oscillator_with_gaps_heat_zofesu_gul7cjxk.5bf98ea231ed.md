Calculation: StochRSI K = SMA of RSI’s stochastic position within its lookback range
Calculation: D = SMA of K; use a shorter smoothing lookback than K’s smoothing lookback
Calculation: Volume rank = percentile rank of current volume within its lookback
Calculation: Average range = SMA(high − low, 14 bars)
Long: Bull watch active AND K is between the lower extreme and midpoint, inclusive, AND K crosses above D AND close < stored reference close AND (volume filter disabled OR volume rank ≥ selected percentile) OR K ≤ lower extreme AND close ≤ previous stored heat reference close × (1 − heat distance %) OR a tracked bullish gap exists AND low ≤ its boundary
Short: Bear watch active AND K is between the midpoint and upper extreme, inclusive, AND K crosses below D AND close > stored reference close AND (volume filter disabled OR volume rank ≥ selected percentile) OR K ≥ upper extreme AND close ≥ previous stored heat reference close × (1 + heat distance %) OR a tracked bearish gap exists AND high ≥ its boundary
Exit: Long, no exit decision specified
Exit: Short, no exit decision specified