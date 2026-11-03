Calculation: MACD = shorter-lookback SMA(close) − longer-lookback SMA(close)
Calculation: EFI = (previous close − current close) × current volume / 1000
Calculation: EFI indicator = (current EFI + previous EFI) / 2
Calculation: Deviation = sqrt(((close − 2-bar SMA(close))² + (previous close − previous 2-bar SMA(close))²) / 2) / 10
Long: previous short-lookback SMA(low) < current short-lookback SMA(low) AND previous short-lookback SMA(high) < current short-lookback SMA(high) AND MACD > 0 AND close > medium-lookback SMA(close) AND EFI indicator < entry threshold AND close > longer-lookback SMA(close) AND previous MACD < current MACD
Short: previous short-lookback SMA(low) > current short-lookback SMA(low) AND previous short-lookback SMA(high) > current short-lookback SMA(high) AND MACD < 0 AND close < medium-lookback SMA(close) AND EFI indicator > entry threshold AND previous MACD > current MACD
Exit: Long, EFI indicator > exit threshold AND close < medium-lookback SMA(close)
Exit: Short, EFI indicator < exit threshold AND close > medium-lookback SMA(close) AND short-lookback SMA(close) > Deviation