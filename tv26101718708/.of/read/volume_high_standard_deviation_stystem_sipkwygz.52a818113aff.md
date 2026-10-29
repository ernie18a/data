Calculation: Trend average = simple moving average of close with half the lookback of the volume calculations
Calculation: Adjusted volume = volume when nonzero; otherwise the previous adjusted volume
Calculation: Volume upper limit = simple moving average of adjusted volume + 2 × factor × standard deviation of adjusted volume, using the same lookback
Long: trend average > its previous value AND volume < volume upper limit AND position side is not long
Short: trend average < its previous value AND volume < volume upper limit AND position side is not short
Exit: long, trend average < its previous value OR (close > its previous value AND volume > volume upper limit)
Exit: short, trend average > its previous value OR (close < its previous value AND volume > volume upper limit)