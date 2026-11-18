Calculation: MVRV Z-Score = (Market Capitalization(T1) - Realized Capitalization(T1)) / sample standard deviation of all available Market Capitalization(T1) values
Long: Market Capitalization(T1) < Realized Capitalization(T1)
Long: (MVRV Z-Score <= bottom upper threshold OR Market Capitalization(T1) < Realized Capitalization(T1)) AND (previous-bar MVRV Z-Score > bottom upper threshold AND previous-bar Market Capitalization(T1) >= previous-bar Realized Capitalization(T1))
Short: MVRV Z-Score >= top upper threshold AND previous-bar MVRV Z-Score < top upper threshold