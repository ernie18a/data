Calculation: Volume spike = volume > SMA(volume, volume-spike lookback) × volume-spike multiplier
Calculation: Bull score = count of true conditions: EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback); close > close[1]; sector close > sector EMA(sector close, sector EMA lookback) on chart bars using the current, still-forming chart-timeframe bar; RSI(close, RSI lookback) < bull-score RSI cutoff; volume spike
Calculation: Bear score = count of true conditions: EMA(close, fast EMA lookback) <= EMA(close, slow EMA lookback); close <= close[1]; sector close <= sector EMA(sector close, sector EMA lookback) on chart bars using the current, still-forming chart-timeframe bar; RSI(close, RSI lookback) > bear-score RSI cutoff; volume spike
Long: EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback)
Short: EMA(close, fast EMA lookback) <= EMA(close, slow EMA lookback)
Long: EMA(close, fast EMA lookback) crosses above EMA(close, slow EMA lookback)
Short: EMA(close, fast EMA lookback) crosses below EMA(close, slow EMA lookback)
Long: close > close[1]
Short: close <= close[1]
Long: sector close > sector EMA(sector close, sector EMA lookback) on chart bars using the current, still-forming chart-timeframe bar
Short: sector close <= sector EMA(sector close, sector EMA lookback) on chart bars using the current, still-forming chart-timeframe bar
Long: (close / close[relative-strength lookback] - 1) > (sector close / sector close[relative-strength lookback] - 1), using sector values on chart bars and the current, still-forming chart-timeframe bar
Short: (close / close[relative-strength lookback] - 1) <= (sector close / sector close[relative-strength lookback] - 1), using sector values on chart bars and the current, still-forming chart-timeframe bar
Long: RSI(close, RSI lookback) < bull-score RSI cutoff
Short: RSI(close, RSI lookback) > bear-score RSI cutoff
Long: MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) > 0
Short: MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) <= 0
Long: Bull score >= active-score threshold AND EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback)
Short: Bear score >= active-score threshold AND EMA(close, fast EMA lookback) <= EMA(close, slow EMA lookback)
Long: Bull score >= high-score threshold AND EMA(close, fast EMA lookback) crosses above EMA(close, slow EMA lookback)
Short: Bear score >= high-score threshold AND EMA(close, fast EMA lookback) crosses below EMA(close, slow EMA lookback)
Long: volume spike AND EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback)
Short: Bull score >= active-score threshold AND Bull score < high-score threshold AND EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback)
Short: Bear score >= active-score threshold AND Bear score < high-score threshold AND EMA(close, fast EMA lookback) <= EMA(close, slow EMA lookback)
Long: Bull score >= high-score threshold AND EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback)
Short: Bear score >= high-score threshold AND EMA(close, fast EMA lookback) <= EMA(close, slow EMA lookback)