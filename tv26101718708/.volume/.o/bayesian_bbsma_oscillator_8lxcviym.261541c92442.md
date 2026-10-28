Calculation: Bollinger basis = SMA(close, Bollinger lookback)
Calculation: Bollinger upper band = Bollinger basis + standard-deviation multiplier × standard deviation(close, Bollinger lookback)
Calculation: Trend SMA = SMA(close, its lookback)
Calculation: For each level X (Bollinger upper band, Bollinger basis, Trend SMA), U_X = count(close > X over Bayesian lookback) / [count(close > X) + count(close < X) over Bayesian lookback]; D_X = count(close < X over Bayesian lookback) / [count(close > X) + count(close < X) over Bayesian lookback]
Calculation: Sigma down = (((U_upper × U_basis × U_SMA) / U_upper) × U_basis × U_SMA) + ((1 − U_upper) × (1 − U_basis) × (1 − U_SMA))
Calculation: Sigma up = (((D_upper × D_basis × D_SMA) / D_upper) × D_basis × D_SMA) + ((1 − D_upper) × (1 − D_basis) × (1 − D_SMA))
Calculation: Prime probability = (((Sigma down × Sigma up) / Sigma down) × Sigma up) + ((1 − Sigma down) × (1 − Sigma up))
Calculation: AO = SMA(hl2, fast lookback) − SMA(hl2, slow lookback), where fast is shorter than slow
Calculation: AC = [SMA(hl2, fast lookback) − SMA(hl2, slow lookback)] − SMA([SMA(hl2, fast lookback) − SMA(hl2, slow lookback)], fast lookback), where fast is shorter than slow
Long: (Prime probability > lower threshold AND previous bar's Prime probability = 0 OR Sigma up < 1 AND previous bar's Sigma up = 1) AND (Bill Williams confirmation disabled OR (AC > previous bar's AC AND AO > previous bar's AO AND open > jaw AND close > jaw))
Short: (Prime probability = 0 AND previous bar's Prime probability > lower threshold OR Sigma down < 1 AND previous bar's Sigma down = 1) AND (Bill Williams confirmation disabled OR (AC ≤ previous bar's AC AND open < jaw AND close < jaw))