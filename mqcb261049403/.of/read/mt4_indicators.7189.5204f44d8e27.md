Calculation: RSI = RSI of chart-bar closes. Its upper exit threshold is above its upper add threshold, which is above its midpoint; its lower exit threshold is below its lower add threshold, which is below its midpoint.
Calculation: Last upper-add RSI = RSI at the most recent upper-add long decision, reset to the minimum possible RSI at initialization and at every upward midpoint crossing.
Calculation: Last lower-add RSI = RSI at the most recent lower-add short decision, initialized to the minimum possible RSI and reset to current RSI at every downward midpoint crossing.
Long: Current RSI > midpoint AND previous RSI < midpoint.
Long: Current RSI >= upper add threshold AND previous RSI < upper add threshold AND last upper-add RSI <= upper add threshold.
Short: Current RSI < midpoint AND previous RSI > midpoint.
Short: Current RSI < lower add threshold AND previous RSI > lower add threshold AND last lower-add RSI >= lower add threshold.
Exit: long, current RSI >= midpoint AND current RSI < upper exit threshold AND previous RSI >= upper exit threshold AND no prior upper-exit decision since initialization or the most recent upward midpoint crossing.
Exit: short, current RSI < midpoint AND current RSI > lower exit threshold AND previous RSI < lower exit threshold AND no prior lower-exit decision since initialization or the most recent downward midpoint crossing.
Exit: long, a short decision occurs.
Exit: short, a long decision occurs.