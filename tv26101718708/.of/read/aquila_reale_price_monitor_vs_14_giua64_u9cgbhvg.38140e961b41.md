Calculation: 10Y real yield = latest available daily 10-year Treasury yield minus latest available daily 10-year breakeven inflation; use the daily bar, which is higher than an intraday chart bar and may still be forming
Calculation: 2Y intraday change = (current chart-timeframe 2-year yield close − previous chart-timeframe 2-year yield close) / previous close × 100; use the current bar, which may still be forming
Calculation: DXY intraday change = (current chart-timeframe DXY close − previous chart-timeframe DXY close) / previous close × 100; use the current bar, which may still be forming
Calculation: Gold-bias score = +1 for each of the 2Y and DXY intraday changes below −sensitivity, −1 for each above +sensitivity, and 0 otherwise
Calculation: 10Y-minus-2Y spread change = 10Y intraday change − 2Y intraday change
Long: 10Y real yield < real-yield threshold OR Gold-bias score > 0 OR (10Y-minus-2Y spread change > sensitivity AND 2Y intraday change < −sensitivity)
Short: 10Y real yield ≥ real-yield threshold OR Gold-bias score < 0 OR (10Y-minus-2Y spread change > sensitivity AND 2Y intraday change ≥ −sensitivity AND 10Y intraday change > sensitivity)
