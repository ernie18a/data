Calculation: ML line = smooth the forecast-shifted blend of the rolling SMA of the source and session VWAP: SMA + sigma × (VWAP − SMA); the SMA and standard deviation use the same lookback, and smoothing may be disabled or use the selected method (including VWAP).
Calculation: Lower ML Band 1 = ML line − band 1 multiplier × rolling standard deviation of close.
Calculation: Upper ML Band 1 = ML line + band 1 multiplier × rolling standard deviation of close.
Calculation: Lower ML Band 2 = ML line − band 2 multiplier × rolling standard deviation of close.
Calculation: Upper ML Band 2 = ML line + band 2 multiplier × rolling standard deviation of close.
Long: source crosses above the selected lower ML band (Band 1 or Band 2).
Short: source crosses below the upper ML Band 1 or Band 2 selected by signal detection mode.
Exit: Long, high ≥ entry price × (1 + TP1 distance) OR high ≥ entry price × (1 + TP2 distance) OR high ≥ entry price × (1 + TP3 distance) OR low ≤ entry price × (1 − initial stop distance) OR TP1 has been reached and low ≤ highest high since entry × (1 − trailing stop distance).