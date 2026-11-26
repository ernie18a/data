Calculation: double-smoothed price = JMA(JMA(applied price, lookback 1, phase 1), lookback 2, phase 2)
Calculation: slope = double-smoothed price - double-smoothed price[1]
Long: slope > 0
Long: slope > smaller coefficient × StandardDeviation(slope, lookback) AND slope <= larger coefficient × StandardDeviation(slope, lookback)
Long: slope > larger coefficient × StandardDeviation(slope, lookback)
Short: slope < 0
Short: slope < -smaller coefficient × StandardDeviation(slope, lookback) AND slope >= -larger coefficient × StandardDeviation(slope, lookback)
Short: slope < -larger coefficient × StandardDeviation(slope, lookback)
Long: slope(T1, still-forming bar) > 0, using the T1 value on chart bars
Long: slope(T1, still-forming bar) > smaller coefficient × StandardDeviation(slope(T1, still-forming bar), lookback) AND slope(T1, still-forming bar) <= larger coefficient × StandardDeviation(slope(T1, still-forming bar), lookback), using the T1 value on chart bars
Long: slope(T1, still-forming bar) > larger coefficient × StandardDeviation(slope(T1, still-forming bar), lookback), using the T1 value on chart bars
Short: slope(T1, still-forming bar) < 0, using the T1 value on chart bars
Short: slope(T1, still-forming bar) < -smaller coefficient × StandardDeviation(slope(T1, still-forming bar), lookback) AND slope(T1, still-forming bar) >= -larger coefficient × StandardDeviation(slope(T1, still-forming bar), lookback), using the T1 value on chart bars
Short: slope(T1, still-forming bar) < -larger coefficient × StandardDeviation(slope(T1, still-forming bar), lookback), using the T1 value on chart bars