Long: EMA(close, shorter lookback) crosses above EMA(close, longer lookback)
Short: EMA(close, shorter lookback) crosses below EMA(close, longer lookback)
Long: close crosses above session VWAP(close)
Short: close crosses below session VWAP(close)
Long: EMA(close, shorter lookback) > EMA(close, longer lookback) AND close > session VWAP(close)
Short: EMA(close, shorter lookback) < EMA(close, longer lookback) AND close < session VWAP(close)
Long: EMA(close, shorter lookback) > EMA(close, longer lookback) AND close > session VWAP(close) AND close >= highest(high, lookback)[1] - buffer AND close < highest(high, lookback)[1]
Short: EMA(close, shorter lookback) < EMA(close, longer lookback) AND close < session VWAP(close) AND close <= lowest(low, lookback)[1] + buffer AND close > lowest(low, lookback)[1]
Long: high crosses above highest(high, lookback)[1]
Short: low crosses below lowest(low, lookback)[1]