Calculation: Internal swing high = high at the center of the longest lookback window
Calculation: Internal swing low = low at the center of the longest lookback window
Calculation: Swing high = high at the center of a longer lookback window than the internal swing high
Calculation: Swing low = low at the center of a longer lookback window than the internal swing low
Calculation: Discount midpoint = (highest high + lowest low) over the range lookback / 2
Calculation: Bullish fair value gap = current low > high two bars ago AND previous close > high two bars ago
Calculation: Bearish fair value gap = current high < low two bars ago AND previous close < low two bars ago
Calculation: Initial long stop = the greater of the lower of the latest internal swing low (if below close) or the lowest low over a shorter lookback, less an ATR buffer, and close less a maximum percentage of close; if this is at or above close, use close less 1.5 ATR
Calculation: Initial short stop = the lesser of the higher of the latest internal swing high (if above close) or the highest high over a shorter lookback, plus an ATR buffer, and close plus a maximum percentage of close; if this is at or below close, use close plus 1.5 ATR
Calculation: Long first target = entry price + (entry price − initial long stop)
Calculation: Short first target = entry price − (initial short stop − entry price)
Calculation: Long second target = qualifying latest swing high above the first target when using structural targets; otherwise entry price + 2.5 × (entry price − initial long stop)
Calculation: Short second target = qualifying latest swing low below the first target when using structural targets; otherwise entry price − 2.5 × (initial short stop − entry price)
Calculation: Long trailing stop = highest high on a bar making a higher high than the previous bar, less 3 ATR; raise the stop to this value only when it exceeds the current stop
Calculation: Short trailing stop = lowest low on a bar making a lower low than the previous bar, plus 3 ATR; lower the stop to this value only when it is below the current stop
Calculation: Bullish divergence = RSI rises while low falls from the previous bar
Calculation: Bearish divergence = RSI falls while high rises from the previous bar
Calculation: Volume momentum = volume has not fallen versus the previous bar for each bar in the volume momentum lookback
Long: flat AND close crosses above the latest internal swing high or latest swing high (according to structure mode) AND close < discount midpoint AND (current or previous bar has a bullish fair value gap) AND (when enabled, bullish divergence) AND (when enabled, close > Bollinger middle band)
Short: flat AND close crosses below the latest internal swing low or latest swing low (according to structure mode) AND close > discount midpoint AND (current or previous bar has a bearish fair value gap) AND (when enabled, bearish divergence) AND (when enabled, close < Bollinger middle band)
Exit: long, high ≥ long first target
Exit: long, high ≥ long second target
Exit: long, low ≤ current stop
Exit: short, low ≤ short first target
Exit: short, low ≤ short second target
Exit: short, high ≥ current stop