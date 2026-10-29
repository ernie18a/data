Calculation: Smoothed range = EMA(EMA(absolute change in close, longer lookback), lookback equal to twice the longer lookback minus one) multiplied by a range multiplier
Calculation: Range filter = recursively constrain close to within the smoothed range of the prior filter value; when close is above the prior filter, use the greater of the prior filter and close minus smoothed range, otherwise use the lesser of the prior filter and close plus smoothed range
Calculation: VVIX and VIX = close of each series on a higher timeframe, using the bar still forming
Calculation: VVIX rising = VVIX > its EMA AND VVIX > its prior value
Calculation: VVIX falling = VVIX < its EMA AND VVIX < its prior value
Calculation: VIX rising = VIX > its EMA AND VIX > its prior value
Calculation: Panic risk = VVIX at or above the panic threshold OR (VVIX rising AND VIX rising)
Long: close > EMA(close) AND close > range filter AND range filter > its prior value AND VVIX below the caution threshold AND NOT VIX rising AND VVIX falling
Exit: long, Panic risk OR (VVIX at or above the danger threshold AND VVIX rising) OR (close < EMA(close) AND close < range filter AND range filter < its prior value)