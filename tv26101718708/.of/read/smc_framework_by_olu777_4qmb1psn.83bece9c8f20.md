Calculation: ATR = Wilder's moving average of true range.
Calculation: Fixed-window pivot = a high or low confirmed after an equal number of bars on each side, using the standard pivot-high or pivot-low test. If both occur on the same bar, the low is the new pivot.
Calculation: Major pivot = either a fixed-window pivot or an adaptive pivot. For the adaptive method, track the highest high and lowest low and their bars, updating on ties. Confirm a high when the previous confirmed pivot was not a high and the tracked high minus the current low is at least ATR times a threshold; then reset the tracked low to the current low. Otherwise confirm a low when the previous pivot was not a low and the current high minus the tracked low is at least ATR times the threshold; then reset the tracked high to the current high. Initialize both extremes from the first bar and the previous pivot direction as neutral.
Calculation: Minor pivot = fixed-window pivot with a shorter window than the fixed-window major pivot. Retain the most recent limited history of minor pivots, including both pivots when a high and low are confirmed together, with the low recorded last.
Calculation: Pending high or low = the price of the latest new pivot of that kind, separately for major and minor pivots; replace it when a newer pivot of that kind appears and clear it after its corresponding structure break. Update pivots before testing breaks.
Calculation: Bullish structure break = close > pending high AND previous close <= that same pending high. Bearish structure break = close < pending low AND previous close >= that same pending low.
Calculation: Minor bias = direction of the latest minor structure break, initially neutral; if both breaks occur on one bar, bearish takes precedence.
Calculation: Sweep reference = the newest confirmed minor pivot of the required kind among a limited number of the most recent minor pivots, whose pivot bar is older than a minimum age.
Long: A new major pivot is a low.
Short: A new major pivot is a high.
Long: Bullish major structure break OR minor bias = bullish.
Short: Bearish major structure break OR minor bias = bearish.
Long: Low < minor pivot low sweep reference AND close > that reference AND lower wick >= ATR times a threshold AND lower wick / max(high - low, a small positive constant) >= a threshold AND bars since the previous bullish sweep > a cooldown; initialize the previous sweep bar index to zero.
Short: High > minor pivot high sweep reference AND close < that reference AND upper wick >= ATR times a threshold AND upper wick / max(high - low, a small positive constant) >= a threshold AND bars since the previous bearish sweep > a cooldown; initialize the previous sweep bar index to zero.
Long: Low > high two bars ago AND previous close > high two bars ago AND low - high two bars ago >= ATR times a threshold.
Short: High < low two bars ago AND previous close < low two bars ago AND low two bars ago - high >= ATR times a threshold.