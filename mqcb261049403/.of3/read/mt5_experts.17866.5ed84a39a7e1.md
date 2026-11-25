Calculation: T3 tick-volume ratio = integer quotient(tick volume of the current forming T3 bar sampled on chart ticks, tick volume of the last completed T3 bar)
Calculation: T4 range = high of the current forming T4 bar sampled on chart ticks − low of the same bar
Long: current ask > high of the current forming T4 bar AND T3 tick-volume ratio > volume-ratio parameter AND T4 range > range parameter × pip size
Short: current bid − (current ask − current bid) < low of the current forming T4 bar AND T3 tick-volume ratio > volume-ratio parameter AND T4 range > range parameter × pip size
Exit: long, Parabolic SAR(high, low, SAR step parameter, SAR maximum parameter, T1, current forming bar sampled on chart ticks) > close of the last completed T2 bar, where T2 is the chart timeframe
Exit: short, Parabolic SAR(high, low, SAR step parameter, SAR maximum parameter, T1, current forming bar sampled on chart ticks) < close of the last completed T2 bar, where T2 is the chart timeframe