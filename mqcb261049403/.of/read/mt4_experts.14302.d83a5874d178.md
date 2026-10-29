Long: no open positions AND (random integer < 8192 OR random integer > 24575)
Short: no open positions AND random integer > 8192 AND random integer < 24575
Calculation: Highest high since entry = highest high across the M1 bars from the bar after entry through the M1 bar still forming, using at least one bar
Calculation: Lowest low since entry = lowest low across the M1 bars from the bar after entry through the M1 bar still forming, using at least one bar
Exit: long, price <= entry price - stop-loss distance OR price >= entry price + take-profit distance OR open profit > 0 AND highest high since entry - trailing distance >= entry price + trailing step AND price <= highest high since entry - trailing distance
Exit: short, price >= entry price + stop-loss distance OR price <= entry price - take-profit distance OR open profit > 0 AND lowest low since entry + trailing distance <= entry price - trailing step AND price >= lowest low since entry + trailing distance