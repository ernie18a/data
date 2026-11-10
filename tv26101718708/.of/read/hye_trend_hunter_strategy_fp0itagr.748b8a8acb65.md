Calculation: Rolling VWAP(n) = sum(((high + low + close) / 3) * volume, n) / sum(volume, n).
Calculation: VWAP midpoint(n) = (highest rolling VWAP(n) over n bars + lowest rolling VWAP(n) over n bars) / 2.
Calculation: Leading line = average of VWAP midpoint using a shorter lookback and VWAP midpoint using a longer lookback. The fast leading line uses shorter lookbacks than the corresponding slow leading line.
Calculation: Upper band = SMA of the average of the fast and slow leading lines plus a multiplier times the standard deviation of that average, both over the same lookback.
Calculation: Time segmented volume = rolling sum of volume * (close - previous close).
Calculation: VIDYA = source * alpha * absolute CMO + previous VIDYA * (1 - alpha * absolute CMO), where alpha = 2 / (lookback + 1), CMO = (sum of positive source changes - sum of absolute negative source changes) / (sum of positive source changes + sum of absolute negative source changes), and missing previous VIDYA is zero.
Long: Fast leading line > previous fast leading line AND slow leading line > previous slow leading line AND close > upper band AND time segmented volume > 0 AND time segmented volume > its EMA AND (VIDYA filter disabled OR close > VIDYA) AND datetime >= start date AND datetime < end date.
Exit: long, fast leading line < previous fast leading line AND slow leading line < previous slow leading line.