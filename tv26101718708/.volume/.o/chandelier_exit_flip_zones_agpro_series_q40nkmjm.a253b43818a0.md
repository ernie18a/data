Calculation: Long Chandelier stop = highest high over a lookback − ATR × multiplier; carry forward the greater of this and the previous long stop if the previous close was above the previous long stop, otherwise use this value.
Calculation: Short Chandelier stop = lowest low over a lookback + ATR × multiplier; carry forward the lesser of this and the previous short stop if the previous close was below the previous short stop, otherwise use this value.
Calculation: Trail side = long if close > previous short stop; short if close < previous long stop; otherwise previous trail side.
Calculation: Active trail distance in ATR = absolute distance between close and the current trail-side stop ÷ ATR.
Long: current trail side is long AND previous trail side was short AND bar is confirmed.
Short: current trail side is short AND previous trail side was long AND bar is confirmed.
Exit: long position, trail side is long AND active trail distance in ATR ≤ exit-watch threshold.
Exit: short position, trail side is short AND active trail distance in ATR ≤ exit-watch threshold.