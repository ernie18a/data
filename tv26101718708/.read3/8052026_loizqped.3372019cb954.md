Calculation: FVG threshold = automatic mode ? cumulative sum((high - low) / low) / bar_index : threshold percentage / 100
Calculation: Supply zone = [confirmed PivotHigh(high, swing lookback, swing lookback) - ATR(ATR lookback) * zone-width parameter / width-divisor parameter, confirmed PivotHigh(high, swing lookback, swing lookback)]; accept only if its midpoint is farther than ATR(ATR lookback) * overlap-multiplier parameter from every retained supply-zone midpoint; retain up to the zone-history parameter and remove when close >= zone top
Calculation: Demand zone = [confirmed PivotLow(low, swing lookback, swing lookback), confirmed PivotLow(low, swing lookback, swing lookback) + ATR(ATR lookback) * zone-width parameter / width-divisor parameter]; accept only if its midpoint is farther than ATR(ATR lookback) * overlap-multiplier parameter from every retained demand-zone midpoint; retain up to the zone-history parameter and remove when close <= zone bottom
Long: SMA(close, SMA lookback) > SMA(close, SMA lookback)[1]
Short: SMA(close, SMA lookback) < SMA(close, SMA lookback)[1]
Long: close crosses above SMA(close, SMA lookback) on a chart bar close
Short: close crosses below SMA(close, SMA lookback) on a chart bar close
Long: close > EMA(close, EMA lookback)
Short: close < EMA(close, EMA lookback)
Long: (high + low + close) / 3 >= EMA(close, separate EMA lookback)
Short: (high + low + close) / 3 < EMA(close, separate EMA lookback)
Long: MACD histogram(source, fast lookback, slow lookback, signal lookback) >= 0
Short: MACD histogram(source, fast lookback, slow lookback, signal lookback) < 0
Long: on chart bars at bar close, bull FVG detection computed on T1 bars using request.security values (last completed T1 bar historically; still-forming T1 bar in real time): low > high[2] AND close[1] > high[2] AND (low - high[2]) / high[2] > FVG threshold
Short: on chart bars at bar close, bear FVG detection computed on T1 bars using request.security values (last completed T1 bar historically; still-forming T1 bar in real time): high < low[2] AND close[1] < low[2] AND (low[2] - high) / high > FVG threshold
Long: current confirmed PivotLow(low, divergence lookback, divergence lookback) is lower than its preceding paired confirmed pivot low AND current confirmed PivotLow(MACD histogram(source, fast lookback, slow lookback, signal lookback), divergence lookback, divergence lookback) is higher than its preceding paired confirmed pivot low; both current pivots and both preceding pivots are simultaneous pairs
Short: current confirmed PivotHigh(high, divergence lookback, divergence lookback) is higher than its preceding paired confirmed pivot high AND current confirmed PivotHigh(MACD histogram(source, fast lookback, slow lookback, signal lookback), divergence lookback, divergence lookback) is lower than its preceding paired confirmed pivot high; both current pivots and both preceding pivots are simultaneous pairs
Long: price-action labels enabled AND (confirmed PivotHigh(high, swing lookback, swing lookback) >= preceding confirmed pivot high, initially zero OR confirmed PivotLow(low, swing lookback, swing lookback) >= preceding confirmed pivot low, initially zero)
Short: price-action labels enabled AND (confirmed PivotHigh(high, swing lookback, swing lookback) < preceding confirmed pivot high, initially zero OR confirmed PivotLow(low, swing lookback, swing lookback) < preceding confirmed pivot low, initially zero)
Long: confirmed PivotLow(low, swing lookback, swing lookback) forms an accepted demand zone AND no confirmed PivotHigh(high, swing lookback, swing lookback) occurs on the same bar
Short: confirmed PivotHigh(high, swing lookback, swing lookback) forms an accepted supply zone
Long: close >= top of any retained supply zone
Short: close <= bottom of any retained demand zone