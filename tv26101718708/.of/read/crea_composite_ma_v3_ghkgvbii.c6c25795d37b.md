Calculation: Range-normalized value = 100 × (value − lowest value) / (highest value − lowest value) over the specified lookback; use 50 when highest equals lowest.
Calculation: EMA bias score = EMA of 50 × (1 if close is above both the short EMA and the long EMA, otherwise 0) + 50 × (1 if the short EMA is above the long EMA, otherwise 0).
Calculation: The seven component scores are EMA bias score; MFI of typical price; range-normalized (+DI − −DI); the average of EMA bias score and (100 − range-normalized ATR as a percentage of close); range-normalized (close − open); directional volume score; and range-normalized close ROC. The DI spread, ATR percentage, and ROC use the same normalization lookback; candle-body normalization uses a shorter lookback.
Calculation: Directional volume score = 50 + (clamp(100 × (volume z-score + 2) / 4, 0, 100) − 50) × (1 if close >= open, otherwise −1), where volume z-score is (volume − volume SMA) / volume standard deviation, or 0 when the standard deviation is 0.
Calculation: Composite = EMA of the weighted sum of the seven component scores divided by the sum of their weights; use 100 as the divisor when the weight sum is 0. Its smoothing length equals the EMA bias score smoothing length.
Calculation: Higher-timeframe composite = the same composite calculation evaluated on every chart bar using the last completed higher-timeframe OHLCV values, forward-filled between higher-timeframe completions. ATR and DI in this calculation use chart-timeframe high, low, and close. All other component calculations use the forward-filled higher-timeframe inputs and advance on chart bars.
Calculation: Bull agreement = count of component scores > 50; bear agreement = seven minus bull agreement.
Calculation: Signal line = EMA of the chart-timeframe composite.
Long: Composite crosses above signal line AND bull agreement >= early agreement threshold AND (higher-timeframe filter disabled OR higher-timeframe composite >= higher-timeframe bullish threshold) AND composite < bullish threshold.
Short: Composite crosses below signal line AND bear agreement >= early agreement threshold AND (higher-timeframe filter disabled OR higher-timeframe composite <= higher-timeframe bearish threshold) AND composite > bearish threshold.
Long: Composite crosses above bullish threshold AND bull agreement >= confirmed agreement threshold AND (higher-timeframe filter disabled OR higher-timeframe composite >= higher-timeframe bullish threshold).
Short: Composite crosses below bearish threshold AND bear agreement >= confirmed agreement threshold AND (higher-timeframe filter disabled OR higher-timeframe composite <= higher-timeframe bearish threshold).
Long: Composite >= signal line.
Short: Composite <= signal line.
Long: Higher-timeframe composite >= 50.
Short: Higher-timeframe composite < 50.
Long: Any component score >= component bullish display threshold.
Short: Any component score < component bearish display threshold.