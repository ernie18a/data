Calculation: O = Oracle line(applied price, lookback, smoothing depth, T1, selected signal-bar offset), sampled on T1 updates for a completed bar or on chart bars while the selected bar is forming
Calculation: S = Oracle signal line(applied price, lookback, smoothing depth, T1, selected signal-bar offset), sampled on T1 updates for a completed bar or on chart bars while the selected bar is forming
Long: (S > 0 AND S[1] <= 0) OR (S[1] < S AND S[2] >= S[1]) OR (S < O AND S[1] >= O[1])
Short: (S < 0 AND S[1] >= 0) OR (S[1] > S AND S[2] <= S[1]) OR (S > O AND S[1] <= O[1])
Exit: long, (S < 0 AND S[1] < 0) OR (S[1] > S AND S[2] > S[1]) OR (S > O AND S[1] > O[1])
Exit: short, (S > 0 AND S[1] > 0) OR (S[1] < S AND S[2] < S[1]) OR (S < O AND S[1] < O[1])