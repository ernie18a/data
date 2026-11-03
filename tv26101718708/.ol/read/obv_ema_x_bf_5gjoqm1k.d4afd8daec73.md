Calculation: ATR-weighted OBV = previous ATR-weighted OBV + sign(close − previous close) × volume² / ATR, where ATR is average true range
Long: short-term EMA of ATR-weighted OBV > long-term EMA of ATR-weighted OBV AND previous short-term EMA <= previous long-term EMA
Short: short-term EMA of ATR-weighted OBV < long-term EMA of ATR-weighted OBV AND previous short-term EMA >= previous long-term EMA
Exit: long, low <= entry price × (1 − stop-loss percentage), after the entry bar while the latest crossover state is long
Exit: short, high >= entry price × (1 + stop-loss percentage), after the entry bar while the latest crossover state is short