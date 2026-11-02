Calculation: O_i, H_i, L_i, C_i = open, high, low, close of the i-th completed chart bar, where i=1 is the latest completed bar.
Calculation: A_i = mean absolute candle body size |O_j − C_j| over the body lookback beginning at bar i and extending into older bars; use the same lookback for every A_i and for the close SMA.
Calculation: P_i = (H_i + L_i) / 2; B_i = (O_i + C_i) / 2; S_i = close SMA at bar i.
Long: C_3 − O_3 > A_1 AND C_2 − O_2 > A_1 AND C_1 − O_1 > A_1 AND P_2 > P_3 AND P_1 > P_2.
Short: O_3 − C_3 > A_1 AND O_2 − C_2 > A_1 AND O_1 − C_1 > A_1 AND P_2 < P_3 AND P_1 < P_2.
Long: C_1 − O_1 > A_1 AND O_2 − C_2 > A_1 AND C_2 > C_1 AND C_1 < O_2 AND B_2 < S_2 AND O_1 < L_2.
Short: C_2 − O_2 > A_1 AND C_1 < C_2 AND C_1 > O_2 AND B_2 > S_1 AND O_1 > H_2.
Long: O_3 − C_3 > A_1 AND A_2 < A_1 × small-body factor AND C_2 < C_3 AND O_2 < O_3 AND O_1 > C_2 AND C_1 > C_2.
Short: C_3 − O_3 > A_1 AND A_2 < A_1 × small-body factor AND C_2 > C_3 AND O_2 > O_3 AND O_1 < C_2 AND C_1 < C_2.
Long: O_2 > C_2 AND C_1 − O_1 > A_1 AND C_1 > O_2 AND B_2 < S_2 AND O_1 < C_2.
Short: O_2 < C_2 AND O_1 − C_1 > A_1 AND C_1 < O_2 AND B_2 > S_2 AND O_1 > C_2.
Long: O_3 − C_3 > A_1 AND |C_2 − O_2| < A_1 × star-body factor AND C_2 < C_3 AND O_2 < O_3 AND C_1 > B_3.
Short: C_3 − O_3 > A_1 AND |C_2 − O_2| < A_1 × star-body factor AND C_2 > C_3 AND O_2 > O_3 AND C_1 < B_3.
Long: P_1 < S_2 AND min(O_1, C_1) > H_1 − (H_1 − L_1) × upper-range fraction AND C_1 < C_2 AND O_1 < O_2.
Short: P_1 > S_2 AND min(O_1, numeric value of (C_1 > H_1 − (H_1 − L_1) × upper-range fraction AND C_1 > C_2 AND O_1 > O_2)) != 0, where true=1 and false=0.
Long: C_1 > O_1 AND O_2 − C_2 > A_1 AND C_1 < O_2 AND O_1 > C_2 AND P_2 < S_2.
Short: C_1 < O_1 AND C_2 − O_2 > A_1 AND C_1 > O_2 AND O_1 < C_2 AND P_2 > S_2.
Long: O_2 − C_2 > A_1 AND C_1 − O_1 > A_1 AND |C_1 − C_2| < small-body factor × A_1.
Short: C_2 − O_2 > A_1 AND O_1 − C_1 > A_1 AND |C_1 − C_2| < small-body factor × A_1.
Long: O_2 − C_2 > A_1 AND C_1 − O_1 > A_1 AND |C_1 − C_2| < small-body factor × A_1 AND MFI_1 < lower entry threshold.
Short: C_2 − O_2 > A_1 AND O_1 − C_1 > A_1 AND |C_1 − C_2| < small-body factor × A_1 AND MFI_1 > upper entry threshold.
Exit: short, (MFI_2 < lower exit threshold AND MFI_1 > lower exit threshold) OR (MFI_2 < upper exit threshold AND MFI_1 > upper exit threshold).
Exit: long, (MFI_2 < upper exit threshold AND MFI_1 > upper exit threshold) OR (MFI_2 > lower exit threshold AND MFI_1 < lower exit threshold).