Calculation: VolWeight(i) = volume weighting enabled ? max(volume-weight floor, (volume[i] / max(Highest(volume, volume normalization window) at the current bar, 1))^volume-weight power) : 1
Calculation: VWNW(n) = sum over i from n to n+lookback window-1 of K(i-n)*VolWeight(i)*close[i], divided by the sum over the same i of K(i-n)*VolWeight(i), where K is the selected kernel: Gaussian(d, bandwidth), RationalQuadratic(d, bandwidth, alpha), or Epanechnikov(d, bandwidth)
Calculation: HalfWidth = band multiplier*ATR(ATR length) if band method is ATR; band multiplier*StDev(close[non-repaint offset], lookback window) if band method is Stdev; percent offset/100*VWNW(non-repaint offset) if band method is Percent
Calculation: UpperBand = VWNW(non-repaint offset) + HalfWidth
Calculation: LowerBand = VWNW(non-repaint offset) - HalfWidth
Calculation: RegressionRising = VWNW(non-repaint offset) > VWNW(non-repaint offset + 1)
Long: close < LowerBand
Long: RegressionRising
Long: band-crossover signals enabled AND NOT extension-close mode AND close crosses above LowerBand AND (NOT slope-change filter OR RegressionRising) AND no Long or Short in the previous (minimum bars between signals - 1) bars AND no Long after the last bar with LowerBand < close < UpperBand
Long: band-crossover signals enabled AND extension-close mode AND close < LowerBand AND no Long or Short in the previous (minimum bars between signals - 1) bars AND no Long after the last bar with LowerBand < close < UpperBand
Short: close > UpperBand
Short: NOT RegressionRising
Short: band-crossover signals enabled AND NOT extension-close mode AND close crosses below UpperBand AND (NOT slope-change filter OR NOT RegressionRising) AND no Long or Short in the previous (minimum bars between signals - 1) bars AND no Short after the last bar with LowerBand < close < UpperBand
Short: band-crossover signals enabled AND extension-close mode AND close > UpperBand AND no Long or Short in the previous (minimum bars between signals - 1) bars AND no Short after the last bar with LowerBand < close < UpperBand
Exit: long, close >= VWNW(non-repaint offset)
Exit: short, close <= VWNW(non-repaint offset)
Exit: long, low < low of the long-entry bar
Exit: short, high > high of the short-entry bar