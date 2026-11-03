Long: Close crosses above the shorter-period EMA of close.
Short: Close crosses below the shorter-period EMA of close.
Long: Shorter-period EMA of close > longer-period EMA of close on a higher or lower timeframe, using the last completed bar.
Short: Shorter-period EMA of close <= longer-period EMA of close on a higher or lower timeframe, using the last completed bar.
Calculation: Zone candle = OHLC of the preceding completed bar on a higher, lower, or equal timeframe, sampled onto each chart bar; the previous zone candle is the value sampled on the previous chart bar.
Long: Zone candle close > open AND previous zone candle close <= open AND absolute zone candle body / absolute previous zone candle body >= threshold AND previous zone candle close <= zone candle close AND previous zone candle open >= zone candle open.
Short: Zone candle close < open AND previous zone candle close >= open AND absolute zone candle body / absolute previous zone candle body >= threshold AND previous zone candle close >= zone candle close AND previous zone candle open <= zone candle open.