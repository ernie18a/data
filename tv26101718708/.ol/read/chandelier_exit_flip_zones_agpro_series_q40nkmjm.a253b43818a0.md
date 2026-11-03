Calculation: Chandelier long stop = highest high over the structure lookback minus ATR times the ATR multiple; if the previous close is above the previous long stop, use the greater of this value and the previous long stop, otherwise use this value
Calculation: Chandelier short stop = lowest low over the structure lookback plus ATR times the ATR multiple; if the previous close is below the previous short stop, use the lesser of this value and the previous short stop, otherwise use this value
Calculation: Chandelier trail side = long if close is above the previous Chandelier short stop; short if close is below the previous Chandelier long stop; otherwise retain the previous trail side
Calculation: Active Chandelier trail = Chandelier long stop when trail side is long; Chandelier short stop when trail side is short
Calculation: Distance from active trail in ATR = absolute value of (close minus active Chandelier trail) divided by ATR
Long: current Chandelier trail side is long AND previous Chandelier trail side was short
Short: current Chandelier trail side is short AND previous Chandelier trail side was long
Exit: long, distance from active trail in ATR <= exit-watch threshold
Exit: short, distance from active trail in ATR <= exit-watch threshold