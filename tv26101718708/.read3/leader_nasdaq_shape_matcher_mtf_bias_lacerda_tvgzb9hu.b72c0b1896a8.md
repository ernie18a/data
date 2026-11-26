Long: On chart bars using T1 values, the close of the last completed T1 bar > the high of the T1 bar immediately preceding it
Short: On chart bars using T1 values, the close of the last completed T1 bar < the low of the T1 bar immediately preceding it
Long: On chart bars using T2 values, the close of the last completed T2 bar > its open
Short: On chart bars using T2 values, the close of the last completed T2 bar < its open
Calculation: Cumulative session error = sum through the current chart bar of abs(chart close / chart session-start close - candidate close / candidate session-start close)
Long: During an active configured session, a candidate with available closes and a nonzero session-start close ranks within the lowest cumulative session errors up to the leader-count parameter, and its close > its session-start close
Short: During an active configured session, a candidate with available closes and a nonzero session-start close ranks within the lowest cumulative session errors up to the leader-count parameter, and its close < its session-start close