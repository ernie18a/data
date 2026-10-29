Calculation: Lookback high = highest high of the last N completed chart-timeframe bars, excluding the forming bar
Calculation: Lookback low = lowest low of the last N completed chart-timeframe bars, excluding the forming bar
Long: current bid >= lookback high AND lookback high - lookback low <= maximum range width AND there are no open long or short positions
Short: current bid < lookback low AND lookback high - lookback low <= maximum range width AND there are no open long or short positions
Exit: long, bar low <= entry price - stop-loss distance OR bar high >= entry price + take-profit distance
Exit: short, bar high >= entry price + stop-loss distance OR bar low <= entry price - take-profit distance