Calculation: Pivot = (high + low + close) / 3 of the last completed higher-timeframe bar.
Calculation: Weighted EMA center = EMA of the weighted average of six close EMAs with distinct, increasing periods; each EMA's weight is the greater of its absolute change over a common lookback and a positive minimum price increment.
Calculation: Center slope = weighted EMA center minus its value a lookback number of chart bars earlier.
Long: close > weighted EMA center AND center slope > 0
Short: close < weighted EMA center AND center slope < 0
Long: center slope >= 0
Short: center slope < 0
Long: close > pivot AND previous close <= previous pivot
Short: close < pivot AND previous close >= previous pivot
Long: close > weighted EMA center AND center slope > 0 AND close > pivot
Short: close < weighted EMA center AND center slope < 0 AND close <= pivot