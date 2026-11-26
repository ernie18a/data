Long: On chart bars, current T1 close (still forming in real time) > Highest(high, lookback, T1, last completed bar), with T1 values taken on chart bars using lookahead off.
Short: On chart bars, current T1 close (still forming in real time) < Lowest(low, lookback, T1, last completed bar), with T1 values taken on chart bars using lookahead off.
Long: scanned-symbol close > highest(scanned-symbol high, P1)[1] on T1
Short: scanned-symbol close < lowest(scanned-symbol low, P1)[1] on T1