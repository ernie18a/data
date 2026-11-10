Calculation: Doji = high > low AND abs(close - open) / (high - low) <= body-to-range threshold.
Calculation: Latest Doji = the most recent Doji, including the current bar; its high and low persist across day changes until replaced.
Calculation: ATR distance = (close - EMA of close) / ATR when ATR > 0, otherwise 0.
Calculation: Long and short signal counts = counts since the latest Doji or start of the current day, whichever is later; reset both counts at either event and increment the corresponding count on each signal.
Calculation: Position state = on a long signal, set side to long, entry price to the latest Doji high, and entry bar to the current bar; on a short signal, set side to short, entry price to the latest Doji low, and entry bar to the current bar. Process long before short if both occur. Signals replace any existing position.
Calculation: Long exit condition = close < entry price OR low < previous close - exit offset OR low <= entry price - hard-stop distance.
Calculation: Short exit condition = close > entry price OR high > previous close + exit offset OR high >= entry price + hard-stop distance.
Calculation: Long and short pending flags = initially false; on each bar after the entry bar, update only the current position side's flag to that side's exit condition, after checking for an exit. An exit clears its side's flag and the position. New entries and opposite-side positions do not reset either flag.
Long: latest Doji exists AND current bar index > latest Doji bar index + 1 AND long signal count = 0 AND high > latest Doji high AND close > previous close AND ATR distance < long distance limit.
Short: latest Doji exists AND current bar index > latest Doji bar index + 1 AND short signal count = 0 AND low < latest Doji low AND close < previous close AND ATR distance > short distance limit.
Exit: long, current bar index > entry bar index AND long pending flag = true AND long exit condition = true.
Exit: short, current bar index > entry bar index AND short pending flag = true AND short exit condition = true.