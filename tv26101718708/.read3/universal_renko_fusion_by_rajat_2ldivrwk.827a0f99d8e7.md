Calculation: RB = Renko(close, box size)
Calculation: PT = trend of PPST(RB high, RB low, RB close, PPST pivot period, PPST ATR period, PPST ATR factor) at last completed RB
Calculation: ST = trend of SuperTrend(RB high, RB low, RB close, ST factor, ST ATR length) at last completed RB
Calculation: OSC = SMA(x, OSC smoothing), where x = (RB close - lowest(RB low, OSC period)) / (highest(RB high, OSC period) - lowest(RB low, OSC period)) - 0.5, or x = 0 if highest(RB high, OSC period) == lowest(RB low, OSC period), at last completed RB
Calculation: CHOP = Choppiness(RB high, RB low, RB close, chop length) at last completed RB
Calculation: MA = SMA(RB close, MA length) at last completed RB
Long: PT == up AND PT[1] == down
Long: PT == up
Long: ST == up AND ST[1] == down AND (OSC filter disabled OR OSC > 0) AND (CHOP filter disabled OR CHOP < chop threshold)
Long: ST == up AND (OSC filter disabled OR OSC > 0) AND (CHOP filter disabled OR CHOP < chop threshold)
Long: close > MA
Short: PT == down AND PT[1] == up
Short: PT == down
Short: ST == down AND ST[1] == up AND (OSC filter disabled OR OSC < 0) AND (CHOP filter disabled OR CHOP < chop threshold)
Short: ST == down AND (OSC filter disabled OR OSC < 0) AND (CHOP filter disabled OR CHOP < chop threshold)
Short: close <= MA