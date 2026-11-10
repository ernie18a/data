Calculation: Swing levels = on each chart bar, if the high a swing lookback ago equals the highest high in the window spanning that many bars before and after it, update the latest swing high to that high; similarly update the latest swing low when the low equals the lowest low in that window. Retain each level until updated.
Calculation: Swing trend = initially neutral; after updating swing levels, set it to up if close is above the latest swing high, then set it to down if close is below the latest swing low. Otherwise retain its previous state.
Calculation: Higher-timeframe swing trend = apply the same trend update to the higher timeframe's last completed close and latest confirmed pivot high and low, using equal left and right swing lookbacks; retain each pivot until updated.
Calculation: Profit targets = at entry order submission, freeze the signal bar's close and ATR multiplied by a distance parameter; set three targets at successive integer multiples of that distance above the signal close for a long or below it for a short. Each target can trigger once per trade and closes a fixed fraction of the remaining position.
Long: Swing trend = up AND EMA of close > previous EMA of close AND ADX > threshold AND position side = flat
Short: Swing trend = down AND EMA of close < previous EMA of close AND ADX > threshold AND position side = flat
Long: EMA of close > previous EMA of close
Short: EMA of close <= previous EMA of close
Long: Swing trend = up
Short: Swing trend = down
Long: Higher-timeframe swing trend = up
Short: Higher-timeframe swing trend = down
Exit: long, close < entry price × (1 − stop-loss fraction) OR swing trend = down
Exit: short, close > entry price × (1 + stop-loss fraction) OR swing trend = up
Exit: long, high > an untriggered long profit target
Exit: short, low < an untriggered short profit target