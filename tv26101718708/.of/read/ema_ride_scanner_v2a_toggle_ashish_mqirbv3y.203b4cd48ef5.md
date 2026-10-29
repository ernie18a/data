Calculation: Distance from EMA9 (%) = (close − EMA9) / EMA9 × 100
Calculation: ATR% = ATR / close × 100
Calculation: EMA21 ride count = number of consecutive bars ending at the current bar where close > EMA21
Calculation: Volume ratio = volume / moving average of volume
Calculation: Relative outperformance = stock percentage return over the lookback − benchmark percentage return over the same lookback
Long: (standard mode AND EMA9 > EMA21 AND EMA21 > EMA50 AND distance from EMA9 is between 0% and 5% inclusive AND volume ratio ≤ its threshold) OR (grinder mode AND EMA9 > EMA21 AND EMA21 > EMA50 AND ATR% ≤ its maximum AND EMA21 ride count ≥ its minimum AND relative outperformance ≥ its minimum AND (close is between EMA9 and EMA21 inclusive OR distance from EMA9 is within 1% of zero))