Calculation: Confirmed swing high/low = a pivot high/low with equal left- and right-side lookbacks; available only after the right-side bars complete
Calculation: Upper resistance line = line through the two latest descending confirmed swing highs, extended each bar; retain only if intervening lows stay at or below it
Calculation: Lower support line = line through the two latest rising confirmed swing lows, extended each bar; retain only if intervening highs stay at or above it
Calculation: Entry price = close of the signal bar
Calculation: Long stop = lower of the selected stop reference and entry price minus one minimum tick; stop reference is either the lowest low over a lookback excluding the signal bar, or the upper resistance line at its break minus an ATR-based buffer, then subtract a tick buffer
Calculation: Short stop = higher of the selected stop reference and entry price plus one minimum tick; stop reference is either the highest high over a lookback excluding the signal bar, or the lower support line at its break plus an ATR-based buffer, then add a tick buffer
Calculation: Long target = entry price + (entry price − long stop) × selected reward multiple
Calculation: Short target = entry price − (short stop − entry price) × selected reward multiple
Long: low > active upper resistance line OR (an upper resistance line broke within the wait period AND close > latest confirmed swing high)
Short: high < active lower support line OR (a lower support line broke within the wait period AND close < latest confirmed swing low)
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target