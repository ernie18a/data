Calculation: Normalized ATR = SMA(True range(high, low, close), volatility length) / close
Calculation: Volatility rank = (Normalized ATR - lowest(Normalized ATR, volatility rank length)) / (highest(Normalized ATR, volatility rank length) - lowest(Normalized ATR, volatility rank length)), or 0.5 if the denominator is 0
Calculation: Volatility health = clamp(100 - volatility health scale * Volatility rank, volatility health floor, 100)
Calculation: MA slope = (SMA(close, trend length) / SMA(close, trend length)[1] - 1) * 100
Calculation: Trend health = distance weight * clamp(50 + distance scale * (close / SMA(close, trend length) - 1) * 100, 0, 100) + slope weight * clamp(50 + slope scale * MA slope, 0, 100) + bias weight * (above-MA bias if close > SMA(close, trend length), else below-MA bias)
Calculation: Trend state = (+1 if close > SMA(close, trend length), else -1) + (+1 if SMA(close, trend length) > SMA(close, trend length)[1], else -1)
Calculation: Trend persistence = (count of n from 1 to persistence window where Trend state[n] * Trend state[n-1] > 0) / (count of n from 1 to persistence window where both states are defined), or 0.5 if that count is 0
Calculation: Trend weight = clamp(trend base weight + persistence sensitivity * (Trend persistence - 0.5), trend min weight, trend max weight)
Calculation: Regime score = clamp(SMA(Trend weight * Trend health + (1 - Trend weight) * Volatility health, smoothing length), 0, 100)
Calculation: Slope feature = clamp(MA slope / slope normalization scale + 0.5, 0, 1)
Calculation: Outlook confidence = clamp(0.5 + KNN scale * mean of forward return[i] over the neighbors, 0, 1), where forward return[i] = close[i - horizon] / close[i] - 1; the neighbors are the candidates i with the smallest Euclidean distance between (Trend health[i] / 100, Volatility rank[i], Slope feature[i]) and the same values at the current bar (neighbor count = neighbors); candidates range over i from horizon to history lookback + horizon bars ago, within available history, with defined values; undefined if there are fewer candidates than neighbors
Long: Regime score of any tracked instrument crosses above strong threshold
Short: Regime score of any tracked instrument crosses below weak threshold
Long: Outlook confidence >= up threshold
Short: Outlook confidence < down threshold