Calculation: MVRV Z-Score = (market capitalization - realized capitalization) / sample standard deviation of market capitalization over all valid chart bars, using T1 closes (last completed bar historically; still-forming bar in real time, on chart bars)
Long: market capitalization < realized capitalization OR (MVRV Z-Score <= bottom threshold AND NOT (MVRV Z-Score[1] <= bottom threshold OR market capitalization[1] < realized capitalization[1]))
Short: MVRV Z-Score >= top threshold AND NOT (MVRV Z-Score[1] >= top threshold)
Calculation: MVRV Z-Score = (Market Capitalization(T1) - Realized Capitalization(T1)) / sample standard deviation of all available Market Capitalization(T1) values
Long: Market Capitalization(T1) < Realized Capitalization(T1)
Long: (MVRV Z-Score <= bottom upper threshold OR Market Capitalization(T1) < Realized Capitalization(T1)) AND (previous-bar MVRV Z-Score > bottom upper threshold AND previous-bar Market Capitalization(T1) >= previous-bar Realized Capitalization(T1))
Short: MVRV Z-Score >= top upper threshold AND previous-bar MVRV Z-Score < top upper threshold