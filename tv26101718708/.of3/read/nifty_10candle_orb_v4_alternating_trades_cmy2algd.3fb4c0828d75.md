Calculation: opening-range high = maximum high of the first N chart bars of each day
Calculation: opening-range low = minimum low of the first N chart bars of each day
Long: opening range complete AND flat AND current bar time is before the last-entry hour AND before the exit time AND (no prior trade today OR the most recent trade today was short) AND close crosses above opening-range high
Short: opening range complete AND flat AND current bar time is before the last-entry hour AND before the exit time AND (no prior trade today OR the most recent trade today was long) AND close crosses below opening-range low
Exit: long, high >= entry price * (1 + profit-target percent / 100) OR low <= entry price * (1 - stop-loss percent / 100) OR current bar time >= exit time
Exit: short, low <= entry price * (1 - profit-target percent / 100) OR high >= entry price * (1 + stop-loss percent / 100) OR current bar time >= exit time