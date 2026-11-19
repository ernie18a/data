Calculation: ATR trail = let previous = nz(ATR trail[1], 0), distance = sensitivity × ATR(lookback) in if close > previous AND close[1] > previous then max(previous, close − distance) else if close < previous AND close[1] < previous then min(previous, close + distance) else if close > previous then close − distance else close + distance
Long: close crosses above ATR trail
Short: close crosses below ATR trail
Long: close > ATR trail
Short: close <= ATR trail
Long: PivotHigh(high, pivot span, pivot span) is confirmed
Short: PivotLow(low, pivot span, pivot span) is confirmed
Long: configured break price (close or high, per the body-break setting) > latest unbroken confirmed pivot high
Short: configured break price (close or low, per the body-break setting) < latest unbroken confirmed pivot low