Long: confirmed PivotHigh(high, left lookback, right lookback) > previous confirmed PivotHigh(high, left lookback, right lookback)
Long: confirmed PivotLow(low, left lookback, right lookback) > previous confirmed PivotLow(low, left lookback, right lookback)
Short: confirmed PivotHigh(high, left lookback, right lookback) < previous confirmed PivotHigh(high, left lookback, right lookback)
Short: confirmed PivotLow(low, left lookback, right lookback) < previous confirmed PivotLow(low, left lookback, right lookback)
Long: On chart bars, high > high[1] of T1 (last completed bar) and no earlier chart bar in the current T1 period broke either boundary; reset at each T1 period
Short: On chart bars, low < low[1] of T1 (last completed bar) and high <= high[1] of T1 and no earlier chart bar in the current T1 period broke either boundary; reset at each T1 period