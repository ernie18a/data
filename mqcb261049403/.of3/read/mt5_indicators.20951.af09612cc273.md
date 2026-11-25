Calculation: ThresholdTrend(T) = on bars of T, let H=highest(high, lookback parameter), L=min(close, lowest(low, lookback parameter)), and p=risk-base parameter minus risk parameter; set the state to +1 if close>H-(H-L)*p/100, else -1 if close<L+(H-L)*p/100, else its previous value (initially 0). Bracketed offset 0 is the still-forming bar; positive offsets are completed bars.
Long: ThresholdTrend on the current chart bar > 0
Short: ThresholdTrend on the current chart bar < 0
Long: ThresholdTrend(chart)[n] > 0 AND ThresholdTrend(chart)[n+1] <= 0
Short: ThresholdTrend(chart)[n] < 0 AND ThresholdTrend(chart)[n+1] >= 0
Long: ThresholdTrend(T1)[m] > 0
Long: ThresholdTrend(T2)[m] > 0
Long: ThresholdTrend(T3)[m] > 0
Long: ThresholdTrend(T4)[m] > 0
Long: ThresholdTrend(T5)[m] > 0
Long: ThresholdTrend(T6)[m] > 0
Long: ThresholdTrend(T7)[m] > 0
Long: ThresholdTrend(T8)[m] > 0
Long: ThresholdTrend(T9)[m] > 0
Long: ThresholdTrend(T10)[m] > 0
Short: ThresholdTrend(T1)[m] < 0
Short: ThresholdTrend(T2)[m] < 0
Short: ThresholdTrend(T3)[m] < 0
Short: ThresholdTrend(T4)[m] < 0
Short: ThresholdTrend(T5)[m] < 0
Short: ThresholdTrend(T6)[m] < 0
Short: ThresholdTrend(T7)[m] < 0
Short: ThresholdTrend(T8)[m] < 0
Short: ThresholdTrend(T9)[m] < 0
Short: ThresholdTrend(T10)[m] < 0
Long: ThresholdTrend(T1)[m] > 0 AND ThresholdTrend(T1)[m+1] <= 0
Long: ThresholdTrend(T2)[m] > 0 AND ThresholdTrend(T2)[m+1] <= 0
Long: ThresholdTrend(T3)[m] > 0 AND ThresholdTrend(T3)[m+1] <= 0
Long: ThresholdTrend(T4)[m] > 0 AND ThresholdTrend(T4)[m+1] <= 0
Long: ThresholdTrend(T5)[m] > 0 AND ThresholdTrend(T5)[m+1] <= 0
Long: ThresholdTrend(T6)[m] > 0 AND ThresholdTrend(T6)[m+1] <= 0
Long: ThresholdTrend(T7)[m] > 0 AND ThresholdTrend(T7)[m+1] <= 0
Long: ThresholdTrend(T8)[m] > 0 AND ThresholdTrend(T8)[m+1] <= 0
Long: ThresholdTrend(T9)[m] > 0 AND ThresholdTrend(T9)[m+1] <= 0
Long: ThresholdTrend(T10)[m] > 0 AND ThresholdTrend(T10)[m+1] <= 0
Short: ThresholdTrend(T1)[m] < 0 AND ThresholdTrend(T1)[m+1] >= 0
Short: ThresholdTrend(T2)[m] < 0 AND ThresholdTrend(T2)[m+1] >= 0
Short: ThresholdTrend(T3)[m] < 0 AND ThresholdTrend(T3)[m+1] >= 0
Short: ThresholdTrend(T4)[m] < 0 AND ThresholdTrend(T4)[m+1] >= 0
Short: ThresholdTrend(T5)[m] < 0 AND ThresholdTrend(T5)[m+1] >= 0
Short: ThresholdTrend(T6)[m] < 0 AND ThresholdTrend(T6)[m+1] >= 0
Short: ThresholdTrend(T7)[m] < 0 AND ThresholdTrend(T7)[m+1] >= 0
Short: ThresholdTrend(T8)[m] < 0 AND ThresholdTrend(T8)[m+1] >= 0
Short: ThresholdTrend(T9)[m] < 0 AND ThresholdTrend(T9)[m+1] >= 0
Short: ThresholdTrend(T10)[m] < 0 AND ThresholdTrend(T10)[m+1] >= 0