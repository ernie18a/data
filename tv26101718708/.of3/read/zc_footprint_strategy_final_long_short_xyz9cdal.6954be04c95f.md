Calculation: delta = sum of volume allocated to price bins when the bin profile is populated; otherwise, volume if close > open and −volume otherwise
Long: delta > delta threshold AND datetime >= start date AND position is flat
Short: delta < −delta threshold AND datetime >= start date AND position is flat
Exit: long, high >= entry price + take-profit ticks × tick size OR low <= entry price − stop-loss ticks × tick size
Exit: short, low <= entry price − take-profit ticks × tick size OR high >= entry price + stop-loss ticks × tick size