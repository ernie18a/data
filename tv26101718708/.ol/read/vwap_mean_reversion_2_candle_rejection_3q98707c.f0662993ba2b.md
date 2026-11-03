Calculation: Upper band = session VWAP + ATR × band multiplier
Calculation: Lower band = session VWAP − ATR × band multiplier
Calculation: Long stop = session VWAP − ATR × stop multiplier
Calculation: Short stop = session VWAP + ATR × stop multiplier
Calculation: EMA flatness = absolute difference between the current EMA and that same EMA at an earlier bar < ATR × flatness multiplier
Long: (low of the previous completed chart bar < its lower band OR current low < current lower band) AND current close > current lower band AND (session VWAP − current close) ≥ (current close − long stop) × reward-risk threshold AND New York hour of current bar’s datetime is ≥ 18 OR ≤ 2 AND EMA flatness
Short: (high of the previous completed chart bar > its upper band OR current high > current upper band) AND current close < current upper band AND (current close − session VWAP) ≥ (short stop − current close) × reward-risk threshold AND New York hour of current bar’s datetime is ≥ 18 OR ≤ 2 AND EMA flatness
Exit: long, current low ≤ long stop OR current high ≥ session VWAP
Exit: short, current high ≥ short stop OR current low ≤ session VWAP