Calculation: OpeningRangeHigh = maximum high of the first opening-range length bars of each day
Calculation: OpeningRangeLow = minimum low of the first opening-range length bars of each day
Long: opening range complete AND position flat AND current time before the last-entry hour AND before the exit time AND close crosses above OpeningRangeHigh AND (no trade yet today OR the most recent trade today was short)
Short: opening range complete AND position flat AND current time before the last-entry hour AND before the exit time AND close crosses below OpeningRangeLow AND (no trade yet today OR the most recent trade today was long)
Exit: long, high >= entry price × (1 + profit-target percentage / 100) OR low <= entry price × (1 - stop-loss percentage / 100) OR current time >= exit time
Exit: short, low <= entry price × (1 - profit-target percentage / 100) OR high >= entry price × (1 + stop-loss percentage / 100) OR current time >= exit time