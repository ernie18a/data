Calculation: Real yield = selected 10-year real yield, 30-year real yield, or 10-year real yield × blend weight + 30-year real yield × (1 − blend weight)
Calculation: Regime score = EMA(orientation sign × [(Z-score(gold implied-volatility close, longer normalization lookback) − Z-score(VIX close, longer normalization lookback)) × gap weight + Z-score(dollar-index close, longer normalization lookback) × dollar weight + (real-yield filter enabled ? Z-score(real yield, longer normalization lookback) × real-yield weight : 0)], regime smoothing length); uses external T1 closes sampled on chart bars with no lookahead (T1 bar may be forming in real time)
Calculation: Tactical score = the Regime score formula using the shorter normalization lookback and the separate tactical smoothing length; uses the same T1 external closes on chart bars
Calculation: Momentum histogram = Tactical score − Regime score
Calculation: Histogram growing = abs(Momentum histogram) > abs(Momentum histogram[1])
Long: crosses above(Momentum histogram, 0)
Short: crosses below(Momentum histogram, 0)
Long: Momentum histogram > 0 AND Histogram growing AND NOT Histogram growing[1]
Short: Momentum histogram < 0 AND Histogram growing AND NOT Histogram growing[1]
Long: (orientation inverted AND crosses above(Regime score, upper threshold)) OR (orientation not inverted AND crosses below(Regime score, lower threshold))
Short: (orientation inverted AND crosses below(Regime score, lower threshold)) OR (orientation not inverted AND crosses above(Regime score, upper threshold))
Long: (orientation inverted AND crosses above(Regime score, 0)) OR (orientation not inverted AND crosses below(Regime score, 0))
Short: (orientation inverted AND crosses below(Regime score, 0)) OR (orientation not inverted AND crosses above(Regime score, 0))