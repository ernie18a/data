Calculation: shelf ledger = on each chart bar, register any confirmed pivot high then pivot low (using the pivot lookback on both sides) at its confirmation-bar price; merge each into the last existing shelf within cluster-tolerance parameter * ATR(ATR lookback), incrementing its touch count and setting its price to the mean of its old price and the pivot price; otherwise append a shelf with one touch; remove the oldest shelf when the count exceeds the maximum-shelves parameter
Calculation: nearest strong shelf = the shelf with at least the minimum-touches parameter that is closest to close by absolute distance; choose the first shelf on ties; undefined if none qualifies
Calculation: upward shelf rejection = a nearest strong shelf exists AND low <= shelf price + reject-buffer parameter * ATR(ATR lookback) AND high >= shelf price - reject-buffer parameter * ATR(ATR lookback) AND close > shelf price + reject-buffer parameter * ATR(ATR lookback) AND close > open
Calculation: downward shelf rejection = a nearest strong shelf exists AND low <= shelf price + reject-buffer parameter * ATR(ATR lookback) AND high >= shelf price - reject-buffer parameter * ATR(ATR lookback) AND close < shelf price - reject-buffer parameter * ATR(ATR lookback) AND close < open
Calculation: rejection bias = bullish after an upward shelf rejection until a downward shelf rejection; bearish after a downward shelf rejection until an upward shelf rejection; initially neutral
Long: upward shelf rejection
Short: downward shelf rejection
Long: rejection bias is bullish
Short: rejection bias is bearish
Long: position side is long
Short: position side is short
Long: ((rejection-only mode AND upward shelf rejection) OR (NOT rejection-only mode AND rejection bias is bullish AND close crosses above EMA(close, reclaim EMA lookback))) AND session filter passes AND position side is not long AND cooldown bars have elapsed since the previous signal (initial reference is the chart's first bar) AND chart bar is confirmed
Short: ((rejection-only mode AND downward shelf rejection) OR (NOT rejection-only mode AND rejection bias is bearish AND close crosses below EMA(close, reclaim EMA lookback))) AND session filter passes AND position side is not short AND cooldown bars have elapsed since the previous signal (initial reference is the chart's first bar) AND chart bar is confirmed