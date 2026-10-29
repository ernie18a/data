Calculation: Signal close = selected source on the current chart-timeframe bar, or its Heikin Ashi close when Heikin Ashi is enabled
Calculation: Signal open = current chart-timeframe open, or Heikin Ashi open when Heikin Ashi is enabled
Calculation: Volume maximum = highest volume over the lookback, including the current bar
Calculation: Safety order threshold = initial entry source minus initial entry source times cumulative price deviation; cumulative deviation is deviation × safety order number when step scale = 1, otherwise deviation × (step scale^safety order number − 1) ÷ (step scale − 1), capped at the maximum safety order number
Calculation: Trailing stop = highest value so far of close × (1 − trailing deviation), starting when the high first reaches the take-profit level
Long: flat AND selected source > 0 AND current volume maximum > prior bar's volume maximum AND signal close > signal open AND time is within the configured date range
Long: position is open AND safety order number > 0 AND safety order number <= maximum safety orders AND no trailing take-profit is active AND low <= safety order threshold
Exit: long, trailing deviation = 0 AND high >= average entry price × (1 + take-profit percentage)
Exit: long, trailing deviation > 0 AND take-profit has previously been reached AND (high <= trailing stop OR close <= trailing stop)