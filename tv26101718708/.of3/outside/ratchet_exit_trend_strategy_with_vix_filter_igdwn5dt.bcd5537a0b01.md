Calculation: Three-bar breakout(closing price, average) = closing price > average AND prior closing price > prior average AND second-prior closing price > second-prior average AND third-prior closing price < third-prior average
Long: SMA(closing price, P1) crosses above SMA(closing price, P2) AND (VIX filter is off OR VIX close on T1 < P5)
Long: Three-bar breakout(closing price, SMA(closing price, P2)) AND (VIX filter is off OR VIX close on T1 < P5)
Long: Three-bar breakout(closing price, SMA(closing price, P3)) AND (VIX filter is off OR VIX close on T1 < P5)
Long: Three-bar breakout(closing price, SMA(closing price, P4)) AND (VIX filter is off OR VIX close on T1 < P5)
Exit: long, VIX filter is on AND VIX close on T1 > P5