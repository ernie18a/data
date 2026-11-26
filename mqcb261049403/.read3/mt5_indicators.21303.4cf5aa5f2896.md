Calculation: A = initialize to the selected applied price on the first calculated bar; thereafter A[1] + (selected applied price − A[1]) / smoothing parameter when (selected applied price > A[1] AND selected applied price > selected applied price[1]) OR (selected applied price < A[1] AND selected applied price < selected applied price[1]); otherwise A[1].
Calculation: B = initialize to the selected applied price on the first calculated bar; thereafter B[1] + (selected applied price − B[1]) / smoothing parameter when (selected applied price > B[1] AND selected applied price < selected applied price[1]) OR (selected applied price < B[1] AND selected applied price > selected applied price[1]); otherwise B[1].
Calculation: D = A − B.
Long: D >= 0 on chart bars.
Short: D < 0 on chart bars.
Long: D >= 0 on chart bars taking values from T1, with D calculated on T1 bars using the bar still forming.
Short: D < 0 on chart bars taking values from T1, with D calculated on T1 bars using the bar still forming.
Long: D at the selected signal-bar offset >= 0 AND D on the preceding chart bar < 0, using T1 values calculated on the bar still forming.
Short: D at the selected signal-bar offset < 0 AND D on the preceding chart bar >= 0, using T1 values calculated on the bar still forming.