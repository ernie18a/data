Calculation: Rolling lookback = clamp(floor(lookback duration / chart-bar duration), minimum lookback, maximum lookback) when chart-bar duration is positive; otherwise clamp(initial lookback, minimum lookback, maximum lookback)
Calculation: Normalized range(x, lookback, fallback) = (x - lowest(x, lookback)) / (highest(x, lookback) - lowest(x, lookback)) when highest(x, lookback) > lowest(x, lookback), else fallback
Calculation: Volatility fear = percentage scale × normalized range(ATR(short lookback), rolling lookback, zero fallback) when close < SMA(close, short lookback), else zero
Calculation: Flow fear = percentage scale × (volume weight × normalized range(volume, rolling lookback, midpoint fallback) + sell-pressure weight × (high - close) / (high - low) when high > low, else midpoint fallback + OBV weight × complement of normalized range(OBV(close, volume), rolling lookback, midpoint fallback))
Calculation: Market fear = volatility-fear weight × volatility fear + flow-fear weight × flow fear
Calculation: Long-term mean = SMA(close, shorter T1-chart lookback) on chart bars when the chart timeframe is T1, otherwise SMA(close, longer non-T1-chart lookback) on chart bars; both lookbacks are longer than the short lookback
Calculation: Price extension = percentage scale × (close - long-term mean) / long-term mean when long-term mean > zero, else zero
Calculation: Normalized extension = percentage scale × normalized range(price extension, rolling lookback, midpoint fallback)
Calculation: Euphoria score = equal-weight mean(percentage complement of market fear, normalized extension)
Long: Market fear > institutional fear threshold AND normalized extension < institutional extension threshold
Short: Euphoria score > bubble threshold AND normalized extension > bubble threshold