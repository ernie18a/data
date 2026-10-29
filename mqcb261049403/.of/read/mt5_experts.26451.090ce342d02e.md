Calculation: Range high and range low = highest high and lowest low over the same lookback of completed chart bars, excluding the current bar.
Long: position side = flat AND range high - range low <= maximum range width AND current bar high > range high.
Short: position side = flat AND range high - range low <= maximum range width AND current bar low < range low.
Exit: long, current bar low <= entry price - stop-loss distance OR current bar high >= entry price + take-profit distance.
Exit: short, current bar high >= entry price + stop-loss distance OR current bar low <= entry price - take-profit distance.