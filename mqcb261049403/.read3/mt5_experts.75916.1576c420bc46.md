Calculation: ATR = ATR(ATR period, T1, last completed bar, sampled on each management update)
Calculation: initial risk = min(max(d, minimum ATR distance), maximum ATR distance), where minimum ATR distance = minimum ATR multiple × ATR, maximum ATR distance = maximum ATR multiple × ATR, and d is (entry − lowest low of the swing lookback last completed T1 bars) + ATR buffer × ATR for long positions or (highest high of those bars − entry) + ATR buffer × ATR for short positions when the swing is available and d > 0; otherwise d = minimum ATR distance
Calculation: current R distance = abs(entry − active stop); if zero, use minimum ATR distance
Exit: long, low <= entry − initial risk when the initial stop is set
Exit: short, high >= entry + initial risk when the initial stop is set
Exit: long, after favorable movement reaches breakeven trigger R × current R distance, low <= max(active stop, entry + breakeven lock R × current R distance)
Exit: short, after favorable movement reaches breakeven trigger R × current R distance, high >= min(active stop, entry − breakeven lock R × current R distance)
Exit: long, after favorable movement reaches the applicable trailing profile start R × current R distance, low <= max(active stop, highest high since trailing activation − applicable trailing ATR multiple × ATR)
Exit: short, after favorable movement reaches the applicable trailing profile start R × current R distance, high >= min(active stop, lowest low since trailing activation + applicable trailing ATR multiple × ATR)
Exit: long, when fixed take profit is enabled, high >= entry + fixed take-profit R × initial risk
Exit: short, when fixed take profit is enabled, low <= entry − fixed take-profit R × initial risk