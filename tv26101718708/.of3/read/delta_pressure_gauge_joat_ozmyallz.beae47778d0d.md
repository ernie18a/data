Calculation: BodyDelta = volume * (close - open) / max(high - low, tick size)
Calculation: Osc = EMA(BodyDelta, wave channel length) / max(Highest(abs(EMA(BodyDelta, wave channel length)), rolling norm window), 1)
Calculation: Sig = SMA(Osc, signal length), with signal length longer than wave channel length
Long: Osc crosses above Sig
Short: Osc crosses below Sig
Long: Osc crosses above 0
Short: Osc crosses below 0
Long: Osc > regime threshold AND Osc > Sig
Short: Osc < -regime threshold AND Osc < Sig
Long: PivotLow(Osc, pivot left bars, pivot right bars) > Osc at previous PivotLow AND low[pivot right bars] < low at previous PivotLow
Short: PivotHigh(Osc, pivot left bars, pivot right bars) < Osc at previous PivotHigh AND high[pivot right bars] > high at previous PivotHigh
Short: Osc >= overbought level 1
Short: Osc >= overbought level 2
Long: Osc <= oversold level 1
Long: Osc <= oversold level 2