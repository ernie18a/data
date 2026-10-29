Calculation: Channel basis = EMA(close, long lookback)
Calculation: Channel step = smoothed ATR multiplied by a band-spacing parameter
Calculation: MACD histogram = MACD line − MACD signal line, using a faster and a slower EMA plus a signal EMA
Calculation: Bull trend = close > channel basis AND channel basis > its value at a prior lookback
Calculation: Bear trend = close < channel basis AND channel basis < its value at a prior lookback
Calculation: Trend extension = (close − channel basis) / channel step
Calculation: Long histogram dip depth = (recent histogram peak − recent histogram low) / recent histogram peak, when the peak is positive
Calculation: Short histogram dip depth = (recent histogram high − recent histogram trough) / absolute value of the trough, when the trough is negative
Calculation: Long reversal tag = a recent low reached or fell below the lower reversal band
Calculation: Short reversal tag = a recent high reached or exceeded the upper reversal band
Calculation: Long histogram turn = histogram > prior histogram AND prior histogram ≤ the histogram before it
Calculation: Short histogram turn = histogram < prior histogram AND prior histogram ≥ the histogram before it
Calculation: Higher-timeframe MACD histogram = MACD histogram computed on a higher timeframe, using its last completed bar
Long: Allowed long direction AND entry cooldown elapsed AND (MACD crosses below its signal line AND bear trend AND higher-timeframe MACD histogram < 0 AND ADX ≥ minimum AND DI− > DI+ AND trend extension > −maximum extension AND (pullback-only-cross disabled OR MACD line < 0) OR bull trend AND higher-timeframe MACD histogram > 0 AND ADX ≥ minimum AND DI+ > DI− AND trend extension < maximum extension AND MACD histogram > 0 AND MACD histogram > prior histogram AND prior histogram ≤ the histogram before it AND long histogram dip depth ≥ minimum dip depth AND close > open OR long reversal tag AND long histogram turn AND close > open AND close > prior close)
Short: Allowed short direction AND entry cooldown elapsed AND no long signal on this bar AND (MACD crosses below its signal line AND bear trend AND higher-timeframe MACD histogram < 0 AND ADX ≥ minimum AND DI− > DI+ AND trend extension > −maximum extension AND (pullback-only-cross disabled OR MACD line > 0) OR bear trend AND higher-timeframe MACD histogram < 0 AND ADX ≥ minimum AND DI− > DI+ AND trend extension > −maximum extension AND MACD histogram < 0 AND MACD histogram < prior histogram AND prior histogram ≥ the histogram before it AND short histogram dip depth ≥ minimum dip depth AND close < open OR short reversal tag AND short histogram turn AND close < open AND close < prior close)
Exit: Long, low ≤ active stop OR high ≥ profit target OR (minimum hold elapsed AND MACD crosses below its signal line) OR (time-stop setting enabled AND maximum hold elapsed)
Exit: Short, high ≥ active stop OR low ≤ profit target OR (minimum hold elapsed AND MACD crosses above its signal line) OR (time-stop setting enabled AND maximum hold elapsed)
Calculation: Initial long stop = entry price − stop distance; initial short stop = entry price + stop distance; stop distance = ATR multiplied by a stop parameter
Calculation: Profit target = entry price + initial risk distance multiplied by target multiple for long positions; entry price − initial risk distance multiplied by target multiple for short positions
Calculation: Break-even/trail trigger = entry price + initial risk distance multiplied by trigger multiple for long positions; entry price − initial risk distance multiplied by trigger multiple for short positions
Calculation: Long trailing stop = highest high over a short lookback − ATR multiplied by trail parameter
Calculation: Short trailing stop = lowest low over a short lookback + ATR multiplied by trail parameter
Calculation: After the break-even/trail trigger is reached, long active stop = maximum of prior active stop, entry price, and (when trailing is enabled) long trailing stop; short active stop = minimum of prior active stop, entry price, and (when trailing is enabled) short trailing stop