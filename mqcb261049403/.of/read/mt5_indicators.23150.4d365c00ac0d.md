Calculation: MACD line = shorter-period moving average of a selected OHLC-derived price minus the longer-period moving average of the same price, using the same configurable moving-average method for both.
Calculation: MACD signal = simple moving average of the MACD line.
Calculation: Volume oscillator = for each of the most recent lookback-period volume changes, multiply the newer bar's volume by the preceding bar's volume; sum the products separately where volume increased (P) and decreased (N). If N > 0, return scale × (50 − 100 / (1 + P / N)); otherwise return scale × 100. Scale is a configurable price-unit factor.
Long: Volume oscillator > MACD signal.
Short: Volume oscillator < MACD signal.