Calculation: opening-range high = highest chart-bar high during the configured opening-range window, reset when the bar date changes and fixed after the window ends
Calculation: opening-range low = lowest chart-bar low during the configured opening-range window, reset when the bar date changes and fixed after the window ends
Calculation: opening-range width = opening-range high - opening-range low
Calculation: initial stop = opening-range low for breakout longs, opening-range high for breakout shorts, entry price - opening-range width for mean-reversion longs, or entry price + opening-range width for mean-reversion shorts
Calculation: VWAP deviation = sqrt(sum since bar-date change of volume * (HLC3 - VWAP(HLC3))^2 / sum since bar-date change of volume), including the current chart bar
Long: flat AND opening range complete AND within the configured trading session in its configured time zone AND trades since bar-date change < maximum-trades-per-date parameter AND close > SMA(close, mid lookback) AND ((breakout logic selected AND close crosses above opening-range high AND EMA(close, shorter lookback) > EMA(close, longer lookback)) OR (mean-reversion logic selected AND close < VWAP(HLC3) - deviation multiplier * VWAP deviation AND close crosses above the previous chart bar's low))
Short: flat AND opening range complete AND within the configured trading session in its configured time zone AND trades since bar-date change < maximum-trades-per-date parameter AND close < SMA(close, mid lookback) AND ((breakout logic selected AND close crosses below opening-range low AND EMA(close, shorter lookback) < EMA(close, longer lookback)) OR (mean-reversion logic selected AND close > VWAP(HLC3) + deviation multiplier * VWAP deviation AND close crosses below the previous chart bar's high))
Exit: long, while both targets are active, high >= entry price + ATR(lookback) at entry * target 1 ATR multiplier
Exit: long, while both targets are active, low <= initial stop
Exit: long, after target 1 is reached and while the position remains open, high >= entry price + ATR(lookback) at entry * target 2 ATR multiplier
Exit: long, after target 1 is reached and while the position remains open, low <= entry price
Exit: short, while both targets are active, low <= entry price - ATR(lookback) at entry * target 1 ATR multiplier
Exit: short, while both targets are active, high >= initial stop
Exit: short, after target 1 is reached and while the position remains open, low <= entry price - ATR(lookback) at entry * target 2 ATR multiplier
Exit: short, after target 1 is reached and while the position remains open, high >= entry price
Exit: long, the chart-bar date changes
Exit: short, the chart-bar date changes