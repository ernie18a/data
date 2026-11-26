Calculation: O = OsMA(close, shorter lookback, longer lookback, signal lookback) calculated on T1 bars; O[0] is the selected signal bar (last completed or still forming), and O[n] is n T1 bars earlier
Long: O[0] > O[1] AND O[0] < 0 AND O[1] < O[2] AND O[1] < 0
Short: O[0] < O[1] AND O[0] > 0 AND O[1] > O[2] AND O[1] > 0