Calculation: LastHigh(P) = high of the last completed bar of timeframe P, taken on chart bars; for a session window P, the highest high of chart bars within the most recently completed session P
Calculation: HighReclaim(P) = this bar is the first bar that closes below LastHigh(P) at or after the first bar since the most recent completion of period P whose high exceeds LastHigh(P)
Calculation: LastLow(P) = low of the last completed bar of timeframe P, taken on chart bars; for a session window P, the lowest low of chart bars within the most recently completed session P
Calculation: LowReclaim(P) = this bar is the first bar that closes above LastLow(P) at or after the first bar since the most recent completion of period P whose low is below LastLow(P)
Short: HighReclaim(T1) AND chart timeframe < T1
Short: HighReclaim(T2) AND chart timeframe < T2
Short: HighReclaim(T3) AND chart timeframe < T3
Short: HighReclaim(S1) AND chart timeframe < T4
Short: HighReclaim(S2) AND chart timeframe < T4
Short: HighReclaim(S3) AND chart timeframe < T4
Long: LowReclaim(T1) AND chart timeframe < T1
Long: LowReclaim(T2) AND chart timeframe < T2
Long: LowReclaim(T3) AND chart timeframe < T3
Long: LowReclaim(S1) AND chart timeframe < T4
Long: LowReclaim(S2) AND chart timeframe < T4
Long: LowReclaim(S3) AND chart timeframe < T4