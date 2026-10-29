Calculation: Weighted EMA center = EMA-smoothed average of six EMAs with successively longer lookbacks, weighted by each EMA’s absolute change over a common lookback.
Calculation: Center slope = weighted EMA center minus its value three chart bars ago.
Calculation: Daily pivot = average of high, low, and close of the last completed higher-timeframe daily bar.
Long: (close > weighted EMA center AND center slope > 0) OR (confirmed chart bar closes above the daily pivot after the previous close was at or below its prior value)
Short: (close < weighted EMA center AND center slope < 0) OR (confirmed chart bar closes below the daily pivot after the previous close was at or above its prior value)