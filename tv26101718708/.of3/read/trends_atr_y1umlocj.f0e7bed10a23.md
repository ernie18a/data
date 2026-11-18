Calculation: ATR-stepped close and base = step close and open by ATR(lookback) × multiplier, each moving up one step when its source > its previous level + step, down one step when its source < its previous level − step, otherwise holding; base becomes the previous stepped open whenever the stepped open changes
Long: ATR-stepped close > base
Short: ATR-stepped close <= base
Long: ATR-stepped close > base AND ATR-stepped close[1] <= base[1]
Short: ATR-stepped close <= base AND ATR-stepped close[1] > base[1]