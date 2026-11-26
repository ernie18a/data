Calculation: VWAP_T1 = VWAP(ohlc4, volume) anchored at each new T1 bar (forming bar), na before the first anchor
Calculation: VWAP_S = VWAP(ohlc4, volume) anchored at each open of S1, S2, or S3, na outside S1, S2, and S3, on chart bars
Calculation: VP_T1 = VolumeProfile(high, low, volume, row count) of bars from each new T1 bar (forming bar, shifted by time offset) through the current bar, price range = anchor-bar midpoint ± range multiple × anchor-bar range
Calculation: VP_S = VolumeProfile(high, low, volume, row count) of bars from each open of S1, S2, or S3 through the current bar, price range = anchor-bar midpoint ± range multiple × anchor-bar range, na outside S1, S2, and S3
Long: close >= VWAP_T1
Short: close < VWAP_T1
Long: close >= VWAP_S
Short: close < VWAP_S
Long: close > VAH(VP_T1, value area percent)
Short: close < VAL(VP_T1, value area percent)
Long: close > VAH(VP_S, value area percent)
Short: close < VAL(VP_S, value area percent)
Long: bar outside IB window AND close > IB high(high, most recent IB window)
Short: bar outside IB window AND close < IB low(low, most recent IB window)