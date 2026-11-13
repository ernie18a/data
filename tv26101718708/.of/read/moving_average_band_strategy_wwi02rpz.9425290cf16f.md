Calculation: UpperBand = moving average of high over a lookback, times (1 + offset fraction)
Calculation: LowerBand = moving average of low over the same lookback and same moving-average type as UpperBand, times (1 - offset fraction)
Calculation: Entry price = close of the signal bar; StopLevel is frozen at entry and is not updated while the position is open: long StopLevel = LowerBand at the entry bar, short StopLevel = UpperBand at the entry bar; Risk = abs(Entry price - StopLevel); long TargetLevel = Entry price + Risk * reward-to-risk multiple, short TargetLevel = Entry price - Risk * reward-to-risk multiple
Long: close crosses above UpperBand (previous close <= previous UpperBand AND current close > current UpperBand) AND current position is not long (flat or short)
Short: close crosses below LowerBand (previous close >= previous LowerBand AND current close < current LowerBand) AND current position is not short (flat or long)
Exit: long, low <= StopLevel
Exit: long, (risk-reward target mode enabled) AND high >= TargetLevel
Exit: long, (risk-reward target mode disabled) AND close crosses below LowerBand (previous close >= previous LowerBand AND current close < current LowerBand)
Exit: short, high >= StopLevel
Exit: short, (risk-reward target mode enabled) AND low <= TargetLevel
Exit: short, (risk-reward target mode disabled) AND close crosses above UpperBand (previous close <= previous UpperBand AND current close > current UpperBand)