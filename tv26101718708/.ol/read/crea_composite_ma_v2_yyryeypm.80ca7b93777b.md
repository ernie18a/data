Calculation: Composite score = EMA(3) of the weighted average of: EMA bias (EMA(3) of 50 when close is above both the shorter and longer EMAs plus 50 when the shorter EMA is above the longer EMA); MFI; normalized positive-DI minus negative-DI (100-bar range); inverse normalized ATR/close percentage (100-bar range), averaged with EMA bias; normalized close minus open (50-bar range); directional volume score (50 plus the clamped volume z-score score minus 50, multiplied by +1 when close is at least open and −1 otherwise; z-score uses a volume lookback); and normalized close ROC (100-bar range). Use each component’s configured weight and divide by the sum of weights. For each normalization, map the rolling low/high to 0–100; use 50 if they are equal. For HTF score, apply the same calculation to higher-timeframe OHLCV, using the latest completed higher-timeframe bar in historical data. EMA bias uses a shorter and a longer EMA.
Calculation: Signal line = EMA of the composite score over its configured lookback.
Long: Composite score crosses above the upper threshold (current score above it and previous score at or below it) AND (HTF filter is disabled OR higher-timeframe composite score is at least its bullish threshold)
Long: Composite score >= 55 AND (HTF filter is disabled OR higher-timeframe composite score is at least its bullish threshold)
Long: Composite score > signal line
Long: Composite score crosses above the signal line
Long: Higher-timeframe composite score >= 50
Short: Composite score crosses below the lower threshold (current score below it and previous score at or above it) AND (HTF filter is disabled OR higher-timeframe composite score is at most its bearish threshold)
Short: Composite score < 45 AND (HTF filter is disabled OR higher-timeframe composite score is at most its bearish threshold)
Short: Composite score <= signal line
Short: Composite score crosses below the signal line
Short: Higher-timeframe composite score < 50