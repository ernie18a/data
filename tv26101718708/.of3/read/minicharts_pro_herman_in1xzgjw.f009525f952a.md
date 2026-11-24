Calculation: SwingHigh(k) = k-th most recent non-NA value of PivotHigh(T1 high, L, L)
Calculation: OtherSwingHigh(k) = other instrument high on the same T1 bar as SwingHigh(k)
Calculation: SwingLow(k) = k-th most recent non-NA value of PivotLow(T1 low, L, L)
Calculation: OtherSwingLow(k) = other instrument low on the same T1 bar as SwingLow(k)
Calculation: HighAfterSwingHigh = highest T1 high over the T1 bars newer than the bar of SwingHigh(1), including the developing bar
Calculation: OtherHighAfterSwingHigh = highest other instrument high over the same T1 bars as HighAfterSwingHigh
Calculation: LowAfterSwingLow = lowest T1 low over the T1 bars newer than the bar of SwingLow(1), including the developing bar
Calculation: OtherLowAfterSwingLow = lowest other instrument low over the same T1 bars as LowAfterSwingLow
Long: close(T1, last completed bar) > high(T1, second last completed bar) AND low(T1, last completed bar) >= low(T1, second last completed bar)
Long: low(T1, last completed bar) < low(T1, second last completed bar) AND high(T1, last completed bar) <= high(T1, second last completed bar) AND close(T1, last completed bar) >= low(T1, second last completed bar)
Short: high(T1, last completed bar) > high(T1, second last completed bar) AND low(T1, last completed bar) >= low(T1, second last completed bar) AND close(T1, last completed bar) <= high(T1, second last completed bar)
Short: low(T1, last completed bar) < low(T1, second last completed bar) AND high(T1, last completed bar) <= high(T1, second last completed bar) AND close(T1, last completed bar) < low(T1, second last completed bar)
Long: low(T1, last completed bar) > high(T1, third last completed bar) AND close(T1, developing bar) >= high(T1, third last completed bar)
Short: high(T1, last completed bar) < low(T1, third last completed bar) AND close(T1, developing bar) <= low(T1, third last completed bar)
Long: PivotLow(T1 low, L, L) at last completed bar != NA AND (SwingLow(1) < SwingLow(2)) != (OtherSwingLow(1) < OtherSwingLow(2))
Short: PivotHigh(T1 high, L, L) at last completed bar != NA AND (SwingHigh(1) > SwingHigh(2)) != (OtherSwingHigh(1) > OtherSwingHigh(2))
Long: (LowAfterSwingLow < SwingLow(1)) != (OtherLowAfterSwingLow < OtherSwingLow(1))
Short: (HighAfterSwingHigh > SwingHigh(1)) != (OtherHighAfterSwingHigh > OtherSwingHigh(1))