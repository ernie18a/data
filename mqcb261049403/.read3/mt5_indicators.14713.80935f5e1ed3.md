Calculation: BearsGap = Smooth(high - Smooth(open, method M1, lookback L1, phase P1), method M2, lookback L2, phase P2) - Smooth(high - Smooth(close, method M1, lookback L1, phase P1), method M2, lookback L2, phase P2)[1]
Long: BearsGap > 0
Short: BearsGap < 0
Long: BearsGap from the still-forming T1 bar, sampled on chart bars at shift N+1 = 0 AND BearsGap from the still-forming T1 bar, sampled on chart bars at shift N > 0
Short: BearsGap from the still-forming T1 bar, sampled on chart bars at shift N+1 > 0 AND BearsGap from the still-forming T1 bar, sampled on chart bars at shift N = 0