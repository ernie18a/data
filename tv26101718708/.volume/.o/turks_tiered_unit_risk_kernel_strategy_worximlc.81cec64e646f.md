Calculation: Ensemble weight = average of four values, one per progressively longer close SMA: clip((close − SMA) / (2 × √(lookback / longest lookback) × ATR), 0, 1); use the same ATR for all four.
Calculation: Quantized weight = round(raw weight × number of steps) / number of steps; update the held weight only when the raw weight differs from it by at least 75% of one step.
Calculation: Causal Gaussian smoother = weighted average of the current and preceding closes, with weight exp(−lag² / (2 × bandwidth²)); include lags through ceil(6 × bandwidth).
Calculation: Envelope deviation = simple moving average of the absolute difference between close and the causal Gaussian smoother.
Calculation: Effective unit weight = quantized ensemble weight, except when close is below the smoother, retain the greater of the prior effective unit weight and the quantized ensemble weight.
Calculation: Target weight = off-state floor + (1 − off-state floor) × risk scale × effective unit weight.
Long: target weight > previous target weight
Exit: long, target weight < previous target weight