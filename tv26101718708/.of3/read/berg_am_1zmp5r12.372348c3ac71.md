Calculation: SelectedMA(src, p) = selected SMA or EMA of src over p bars, on chart bars when chart MAs are selected or on T1 with lookahead off and sampled on chart bars (developing T1 bar in real time; last completed T1 bar historically); P1 < P2 < P3 < P4 < P5 < P6 < P7
Calculation: PremarketGap(x) = 100 * (x - previous completed T1 close) / previous completed T1 close, where x is the premarket open, latest premarket close, high, or low aggregated from chart bars
Long: close > SelectedMA(close, P1)
Short: close < SelectedMA(close, P1)
Long: close > SelectedMA(close, P2)
Short: close < SelectedMA(close, P2)
Long: close > SelectedMA(close, P3)
Short: close < SelectedMA(close, P3)
Long: close > SelectedMA(close, P4)
Short: close < SelectedMA(close, P4)
Long: close > SelectedMA(close, P5)
Short: close < SelectedMA(close, P5)
Long: close > SelectedMA(close, P6)
Short: close < SelectedMA(close, P6)
Long: close > SelectedMA(close, P7)
Short: close < SelectedMA(close, P7)
Long: SelectedMA(close, P1) > SelectedMA(close, P2)
Short: SelectedMA(close, P1) <= SelectedMA(close, P2)
Long: SelectedMA(close, P2) > SelectedMA(close, P3)
Short: SelectedMA(close, P2) <= SelectedMA(close, P3)
Long: SelectedMA(close, P3) > SelectedMA(close, P6)
Short: SelectedMA(close, P3) <= SelectedMA(close, P6)
Long: selected single-gap calculation is PremarketGap(premarket open or latest premarket close) >= 0 OR selected high-low calculation has PremarketGap(premarket high) >= 0 AND PremarketGap(premarket low) >= 0
Short: selected single-gap calculation is PremarketGap(premarket open or latest premarket close) < 0 OR selected high-low calculation has PremarketGap(premarket high) < 0 AND PremarketGap(premarket low) < 0