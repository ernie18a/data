Calculation: HTF resistance = highest high over the range lookback of HTF bars, including the current still-forming HTF bar
Calculation: HTF support = lowest low over the range lookback of HTF bars, including the current still-forming HTF bar
Calculation: Long stop = HTF support × (1 − stop buffer)
Calculation: Short stop = HTF resistance × (1 + stop buffer)
Calculation: Long target = Bollinger basis if target mode is mid-band; otherwise max(Bollinger basis, HTF resistance)
Calculation: Short target = Bollinger basis if target mode is mid-band; otherwise min(Bollinger basis, HTF support)
Long: (close ≤ lower Bollinger Band AND RSI ≤ long threshold AND HTF support ≤ close ≤ HTF resistance AND (VWAP filter disabled OR abs(close − VWAP) / VWAP ≤ VWAP proximity threshold)) AND (position is flat OR short)
Short: (close ≥ upper Bollinger Band AND RSI ≥ short threshold AND HTF support ≤ close ≤ HTF resistance AND (VWAP filter disabled OR abs(close − VWAP) / VWAP ≤ VWAP proximity threshold)) AND (position is flat OR long)
Exit: long, low ≤ Long stop OR high ≥ Long target
Exit: short, high ≥ Short stop OR low ≤ Short target