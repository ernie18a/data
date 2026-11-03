Calculation: ATR = average true range over its lookback, using the last completed chart-timeframe bar
Calculation: Initial long target and stop = entry price + ATR × target factor and entry price − ATR × stop factor, respectively; initial short target and stop = entry price − ATR × target factor and entry price + ATR × stop factor, respectively; clamp each distance to the minimum allowed stop distance
Calculation: Trailing stop = after favorable movement from entry exceeds the start threshold, set the long stop to current price − step threshold or the short stop to current price + step threshold, only when this tightens the existing stop and respects the minimum allowed stop distance
Long: close > open on the last completed chart-timeframe bar AND position side = flat
Short: close < open on the last completed chart-timeframe bar AND position side = flat
Exit: long, current price <= stop-loss OR current price >= take-profit
Exit: short, current price >= stop-loss OR current price <= take-profit