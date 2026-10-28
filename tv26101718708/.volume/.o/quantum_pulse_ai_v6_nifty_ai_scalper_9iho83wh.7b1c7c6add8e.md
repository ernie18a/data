Calculation: Bull confidence = percentage of the k nearest prior bars whose label is bullish; Bear confidence = percentage whose label is bearish. Neighbors use Euclidean distance across four features: (fast MA − slow MA) divided by 2 × ATR and clamped to [−1, 1]; (close − current-day VWAP) divided by 3 × ATR and clamped to [−1, 1]; (HMA − HMA two bars earlier) divided by 1.5 × ATR and clamped to [−1, 1]; and relative volume divided by 3, capped at 1. A sample’s label is bullish when its close four bars later exceeds its close eight bars later, bearish when lower, and neutral when equal. Relative volume = volume / 20-bar SMA of volume. ATR, moving averages, HMA, and VWAP use the chart bars; VWAP resets each day. k and the historical lookback are parameters.
Long: Bull confidence ≥ confidence threshold AND close > current-day VWAP AND ADX > ADX threshold, and this condition was false on the prior bar, and position side is not long
Short: Bear confidence ≥ confidence threshold AND close < current-day VWAP AND ADX > ADX threshold, and this condition was false on the prior bar, and position side is not short
Long: Fast MA > slow MA AND close > current-day VWAP AND fast MA > current-day VWAP AND HMA > its value two bars earlier AND close > HMA AND Supertrend is bullish AND ADX > ADX threshold AND relative volume > its threshold, and this condition was false on the prior bar
Short: Fast MA < slow MA AND close < current-day VWAP AND fast MA < current-day VWAP AND HMA < its value two bars earlier AND close < HMA AND Supertrend is bearish AND ADX > ADX threshold AND relative volume > its threshold, and this condition was false on the prior bar
Long: Fast MA crosses above slow MA
Short: Fast MA crosses below slow MA
Long: Fast MA crosses above current-day VWAP
Short: Fast MA crosses below current-day VWAP
Long: Fast MA > slow MA
Short: Fast MA ≤ slow MA
Long: Close > current-day VWAP AND fast MA > current-day VWAP
Short: Close ≤ current-day VWAP OR fast MA ≤ current-day VWAP
Long: HMA > its value two bars earlier AND close > HMA
Short: HMA < its value two bars earlier AND close < HMA
Long: Supertrend is bullish
Short: Supertrend is bearish
Long: ADX > ADX threshold
Short: ADX ≤ ADX threshold
Long: Relative volume > its threshold
Short: Relative volume ≤ its threshold