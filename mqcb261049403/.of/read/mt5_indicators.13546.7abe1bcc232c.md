Calculation: DiNapoli stochastic (higher timeframe, still-forming bar) = start at 50; each bar, find the highest high and lowest low over the lookback, compute 100 × (close − lowest low) / max(highest high − lowest low, one price point), then add (that value − prior stochastic) / smoothing period to the prior stochastic.
Calculation: Signal line (higher timeframe, still-forming bar) = start at 50; each bar, add (current DiNapoli stochastic − prior signal line) / its smoothing period to the prior signal line.
Long: DiNapoli stochastic > signal line
Short: DiNapoli stochastic < signal line