Calculation: Bar index i = the ith completed chart bar, where 1 is the most recently completed bar; O, H, L and C denote open, high, low and close.
Calculation: Average body A_i = the simple moving average of abs(O - C) ending at bar i, using the same lookback as the close SMA.
Calculation: Midpoint M_i = (H_i + L_i) / 2; body midpoint B_i = (O_i + C_i) / 2.
Long: C_3 - O_3 > A_1 AND C_2 - O_2 > A_1 AND C_1 - O_1 > A_1 AND M_2 > M_3 AND M_1 > M_2.
Long: C_1 - O_1 > A_1 AND O_2 - C_2 > A_1 AND C_2 > C_1 AND C_1 < O_2 AND B_2 < close SMA_2 AND O_1 < L_2.
Long: O_3 - C_3 > A_1 AND A_2 < A_1 × doji fraction AND C_2 < C_3 AND O_2 < O_3 AND O_1 > C_2 AND C_1 > C_2.
Long: O_2 > C_2 AND C_1 - O_1 > A_1 AND C_1 > O_2 AND B_2 < close SMA_2 AND O_1 < C_2.
Long: O_3 - C_3 > A_1 AND abs(C_2 - O_2) < A_1 × small-body fraction AND C_2 < C_3 AND O_2 < O_3 AND C_1 > B_3; the small-body fraction is greater than the doji fraction.
Long: M_1 < close SMA_2 AND min(O_1, C_1) > H_1 - (H_1 - L_1) × upper-body fraction AND C_1 < C_2 AND O_1 < O_2.
Long: M_1 < close SMA_2 AND min(O_1, C_1) > H_1 - (H_1 - L_1) × upper-body fraction AND C_1 < C_2 AND O_1 < O_2 AND MFI_1 < lower entry threshold.
Long: C_1 > O_1 AND O_2 - C_2 > A_1 AND C_1 < O_2 AND O_1 > C_2 AND M_2 < close SMA_2.
Long: O_2 - C_2 > A_1 AND C_1 - O_1 > A_1 AND abs(C_1 - C_2) < A_1 × close-match fraction.
Short: O_3 - C_3 > A_1 AND O_2 - C_2 > A_1 AND O_1 - C_1 > A_1 AND M_2 < M_3 AND M_1 < M_2.
Short: C_2 - O_2 > A_1 AND C_1 < C_2 AND C_1 > O_2 AND B_2 > close SMA_1 AND O_1 > H_2.
Short: C_3 - O_3 > A_1 AND A_2 < A_1 × doji fraction AND C_2 > C_3 AND O_2 > O_3 AND O_1 < C_2 AND C_1 < C_2.
Short: O_2 < C_2 AND O_1 - C_1 > A_1 AND C_1 < O_2 AND B_2 > close SMA_2 AND O_1 > C_2.
Short: C_3 - O_3 > A_1 AND abs(C_2 - O_2) < A_1 × small-body fraction AND C_2 > C_3 AND O_2 > O_3 AND C_1 < B_3.
Short: M_1 > close SMA_2 AND O_1 != 0 AND C_1 > H_1 - (H_1 - L_1) × upper-body fraction AND C_1 > C_2 AND O_1 > O_2.
Short: M_1 > close SMA_2 AND O_1 != 0 AND C_1 > H_1 - (H_1 - L_1) × upper-body fraction AND C_1 > C_2 AND O_1 > O_2 AND MFI_1 > upper entry threshold; the upper entry threshold is greater than the lower entry threshold.
Short: C_1 < O_1 AND C_2 - O_2 > A_1 AND C_1 > O_2 AND O_1 < C_2 AND M_2 > close SMA_2.
Short: C_2 - O_2 > A_1 AND O_1 - C_1 > A_1 AND abs(C_1 - C_2) < A_1 × close-match fraction.
Exit: short, (MFI_1 > lower exit threshold AND MFI_2 < lower exit threshold) OR (MFI_1 > upper exit threshold AND MFI_2 < upper exit threshold); the lower exit threshold is below the lower entry threshold and the upper exit threshold is above the upper entry threshold.
Exit: long, (MFI_1 > upper exit threshold AND MFI_2 < upper exit threshold) OR (MFI_1 < lower exit threshold AND MFI_2 > lower exit threshold).