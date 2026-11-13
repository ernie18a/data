Calculation: pct_change(T) = (current price - close of the last completed bar of timeframe T) / that close * 100, where current price is the close of the chart's still-forming bar and T is higher than the chart timeframe. T1 < T2 < T3 (T2 is longer than T1, T3 is longer than T2).
Long: pct_change(T1) > 0
Long: pct_change(T2) > 0
Long: pct_change(T3) > 0
Short: pct_change(T1) < 0
Short: pct_change(T2) < 0
Short: pct_change(T3) < 0