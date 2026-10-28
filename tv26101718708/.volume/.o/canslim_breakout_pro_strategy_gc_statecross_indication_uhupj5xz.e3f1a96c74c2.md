Calculation: Pivot = highest high over the preceding base lookback bars, excluding the current bar
Calculation: Highest close since entry = maximum close from the entry bar through the current bar
Long: (market gate disabled OR market data unavailable OR market fast SMA > market slow SMA) AND (sector gate disabled OR sector data unavailable OR sector fast SMA > sector slow SMA) AND close > Pivot AND close <= Pivot × (1 + buy-range fraction) AND volume >= volume SMA × volume multiplier
Long: market fast SMA crosses above market slow SMA
Long: sector gate enabled AND sector fast SMA crosses above sector slow SMA
Exit: long, close <= entry price × (1 − hard stop fraction)
Exit: long, close >= entry price × (1 + target fraction)
Exit: long, close >= entry price × (1 + trail activation fraction) AND close <= Highest close since entry × (1 − trailing stop fraction)