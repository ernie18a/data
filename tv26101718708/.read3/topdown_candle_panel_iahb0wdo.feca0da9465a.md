Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Long: On chart bars using each selected higher timeframe T1...Tn's still-forming candle values, close >= open OR (high > low AND lower wick >= wick threshold × (high - low) AND lower wick > upper wick)
Short: On chart bars using each selected higher timeframe T1...Tn's still-forming candle values, close < open OR (high > low AND upper wick >= wick threshold × (high - low) AND upper wick > lower wick)