Calculation: Highest volume = maximum volume over the lookback window
Calculation: Safety-order threshold = initial entry price minus the cumulative price deviation, with each successive deviation scaled by the safety-order step scale
Long: position is flat AND selected price source > 0 AND Highest volume > prior bar's Highest volume AND signal close > signal open
Long: position is long AND safety orders remain AND low <= safety-order threshold
Short: Highest volume > prior bar's Highest volume AND signal close < signal open
Exit: long, high >= average entry price × (1 + target take-profit percentage) when trailing is disabled
Calculation: Trailing stop = highest stop value reached since take-profit activation, where each stop value is close × (1 − trailing deviation)
Exit: long, take-profit has activated and (high <= trailing stop OR close <= trailing stop) when trailing is enabled