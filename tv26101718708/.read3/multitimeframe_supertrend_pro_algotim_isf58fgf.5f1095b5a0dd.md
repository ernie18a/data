Calculation: PrimaryDirection = Supertrend direction(hl2, primary ATR length, primary factor) on chart bars
Calculation: ConfirmationDirection = PrimaryDirection if confirmation timeframe is blank, else Supertrend direction(hl2, confirmation ATR length, confirmation factor) on T1 bars, last completed bar
Calculation: HigherDirection = Supertrend direction(hl2, higher ATR length, higher factor) on T2 bars, last completed bar
Calculation: BullishVotes = count of PrimaryDirection, ConfirmationDirection, HigherDirection equal to bullish
Calculation: BearishVotes = count of PrimaryDirection, ConfirmationDirection, HigherDirection equal to bearish
Calculation: Consensus = bullish if BullishVotes >= consensus threshold, else bearish if BearishVotes >= consensus threshold, else neutral
Long: Consensus = bullish AND Consensus[1] != bullish
Long: Consensus = bullish
Long: BullishVotes = 3 AND BullishVotes[1] < 3
Long: PrimaryDirection = bullish AND PrimaryDirection[1] = bearish
Long: PrimaryDirection = bullish
Long: ConfirmationDirection = bullish
Long: HigherDirection = bullish
Short: Consensus = bearish AND Consensus[1] != bearish
Short: Consensus = bearish
Short: BearishVotes = 3 AND BearishVotes[1] < 3
Short: PrimaryDirection = bearish AND PrimaryDirection[1] = bullish
Short: PrimaryDirection = bearish
Short: ConfirmationDirection = bearish
Short: HigherDirection = bearish