Calculation: EmaVote(X) = 1 if EMA(close, shorter lookback, X) > EMA(close, longer lookback, X) AND close(X) > EMA(close, shorter lookback, X); -1 if EMA(close, shorter lookback, X) < EMA(close, longer lookback, X) AND close(X) < EMA(close, shorter lookback, X); else 0
Calculation: StructureVote(X) = 1 if the last confirmed PivotHigh(high, pivot length, pivot length) of X is above the one before it AND the last confirmed PivotLow(low, pivot length, pivot length) of X is above the one before it; -1 if the last confirmed PivotHigh of X is below the one before it AND the last confirmed PivotLow of X is below the one before it; else 0
Calculation: NormSlope(X) = (LinReg(close, momentum lookback, X) - LinReg(close, momentum lookback, X)[1]) / ATR(momentum lookback, X)
Calculation: MomentumVote(X) = 1 if NormSlope(X) > momentum threshold; -1 if NormSlope(X) < -momentum threshold; else 0
Calculation: Rows = T1, T2, T3, and T4, each evaluated on its own bars at its last completed bar, plus the chart bars when the chart timeframe is none of T1, T2, T3, or T4
Calculation: BullVotes = number of EmaVote(X), StructureVote(X), and MomentumVote(X) values equal to 1 over X in Rows
Calculation: BearVotes = number of EmaVote(X), StructureVote(X), and MomentumVote(X) values equal to -1 over X in Rows
Calculation: Agreement = 100 * max(BullVotes, BearVotes) / (3 * number of Rows)
Calculation: Bias = 1 if BullVotes > BearVotes; -1 if BullVotes < BearVotes; else 0
Calculation: Conflict = (Bias = 0) OR (Agreement < chop threshold)
Calculation: Locked = (Agreement >= strong threshold) AND NOT Conflict
Long: Locked AND NOT Locked[1] AND Bias > 0
Long: Bias > 0 AND NOT Conflict
Long: Bias > 0 AND Bias[1] != Bias
Short: Locked AND NOT Locked[1] AND Bias < 0
Short: Bias < 0 AND NOT Conflict
Short: Bias < 0 AND Bias[1] != Bias
Exit: long, Conflict AND NOT Conflict[1]
Exit: short, Conflict AND NOT Conflict[1]