Calculation: K = 33 − configurable risk parameter
Calculation: Williams %R = standard Williams %R on signal-timeframe bars
Calculation: BykovTrend state = carry the prior state forward unless Williams %R < −100 + K (set bearish) or Williams %R > −K (set bullish)
Calculation: X2MA = apply a configurable smoothing to close, then apply a second configurable smoothing to the result; the two lookbacks are independent
Calculation: X2MA direction = rising when X2MA > its prior value, falling when X2MA < its prior value, otherwise flat
Calculation: Signal timeframe = configurable; it may be higher or lower than the chart timeframe. Evaluate signals on completed bars.
Long: BykovTrend state changes from not bullish to bullish OR X2MA direction changes from not rising to rising
Short: BykovTrend state changes from not bearish to bearish OR X2MA direction changes from not falling to falling
Exit: long, BykovTrend state is bearish OR X2MA direction is falling OR low ≤ entry price − stop distance OR high ≥ entry price + target distance
Exit: short, BykovTrend state is bullish OR X2MA direction is rising OR high ≥ entry price + stop distance OR low ≤ entry price − target distance