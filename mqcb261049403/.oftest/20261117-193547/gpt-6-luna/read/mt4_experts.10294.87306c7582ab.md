Calculation: Bears Power = bar low minus the close-based EMA, using its own lookback parameter
Calculation: Bulls Power = bar high minus the close-based EMA, using its own lookback parameter
Long: short-lookback median-price EMA > long-lookback median-price EMA AND parabolic SAR < current bar low AND current-bar Bulls Power > 0 AND current-bar Bulls Power < previous-bar Bulls Power
Short: short-lookback median-price EMA < long-lookback median-price EMA AND parabolic SAR > current bar high AND current-bar Bears Power < 0 AND current-bar Bears Power > previous-bar Bears Power
Exit: long, bar low <= entry price minus the long stop-distance parameter OR bar high >= entry price plus the long profit-distance parameter
Exit: short, bar high >= entry price plus the short stop-distance parameter OR bar low <= entry price minus the short profit-distance parameter