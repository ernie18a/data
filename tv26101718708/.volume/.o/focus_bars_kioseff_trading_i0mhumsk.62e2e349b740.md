Calculation: Lower-timeframe direction = sign(close − previous lower-timeframe close); for tick bars, −1 if close = bid, +1 if close = ask, otherwise sign(close − previous lower-timeframe close)
Calculation: Price-row delta = sum of lower-timeframe volume × direction, divided evenly among the price rows spanned by each lower-timeframe bar’s high-low range; use lower-timeframe bars within the current chart bar
Long: Price-row delta > 0
Short: Price-row delta < 0