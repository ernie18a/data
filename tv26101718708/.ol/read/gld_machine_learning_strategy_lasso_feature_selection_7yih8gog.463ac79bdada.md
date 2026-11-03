Calculation: Feature set = simple moving averages of volume, open minus close, and (high minus close) × (low minus close), plus products of simple moving averages of open minus close or low minus close with a simple moving average of volume; use shorter and longer lookbacks as applicable
Calculation: Score = linear weighted sum of the normalized features
Long: Score ≥ threshold
Exit: Long, Score < threshold