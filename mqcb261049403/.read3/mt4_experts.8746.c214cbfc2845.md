Long: high >= buy-stop entry price
Short: low <= sell-stop entry price
Calculation: Instrument open movement in points = sum over this instrument's open positions of (close - entry price) / point for longs and (entry price - close) / point for shorts
Calculation: Combined open movement in points = sum over all strategy positions across instruments of (instrument close - entry price) / instrument point for longs and (entry price - instrument close) / instrument point for shorts
Exit: long, instrument open movement in points > per-instrument profit threshold OR combined open movement in points > combined profit threshold
Exit: short, instrument open movement in points > per-instrument profit threshold OR combined open movement in points > combined profit threshold