Calculation: Donchian range = highest high minus lowest low over a lookback
Calculation: Lower COG boundary = lowest low over the lookback + 0.382 × Donchian range
Calculation: Upper COG boundary = lowest low over the lookback + 0.618 × Donchian range
Calculation: COG width = upper COG boundary − lower COG boundary
Calculation: Channel width = distance between outer channel boundaries, which are offset from the COG boundaries by an ATR-based width; update the boundaries only when the lower COG boundary changes
Long: close > upper COG boundary AND (COG width > its previous-bar value OR channel width > its previous-bar value)
Short: close < lower COG boundary AND (COG width > its previous-bar value OR channel width > its previous-bar value)