Calculation: RSI = RSI of close; RSI signal = EMA of RSI.
Calculation: Paired low pivot = a bar where both low and RSI are confirmed pivot lows using the same number of bars on each side; paired high pivot = the corresponding confirmed pivot highs. Compare the latest two paired pivots of each kind, retaining them until a new paired pivot of that kind is confirmed.
Calculation: Bullish divergence = latest paired low pivot is separated from the previous one by at least the minimum and at most the maximum pivot spacing AND its low is lower AND its RSI is higher AND its RSI is below the overbought level minus a configured offset. Bearish divergence = latest paired high pivot is separated from the previous one by at least the minimum and at most the maximum pivot spacing AND its high is higher AND its RSI is lower AND its RSI is above the oversold level plus a configured offset. Reevaluate these conditions on every bar.
Calculation: Setup state = on every bar, bullish divergence sets the state to long and resets its age to zero; then bearish divergence sets it to short and resets its age to zero, taking precedence if both occur. Clear the state when its age exceeds the configured maximum or when a filtered entry fires. The filtered long entry requires a long setup, RSI crossing above its signal, the optional time filter passing, close above session VWAP of typical price if the VWAP filter is enabled, and volume at least its SMA multiplied by a configured factor if the volume filter is enabled. The filtered short entry uses a short setup, RSI crossing below its signal, the same time and volume filters, and close below VWAP if enabled. The time filter passes when disabled or when the bar's Asia/Kolkata time is at or after the configured cutoff. Evaluate entries before clearing the setup; evaluate setup markings after clearing it.
Long: Bullish divergence = true
Short: Bearish divergence = true
Long: Setup state = long
Short: Setup state = short
Long: Filtered long entry = true
Short: Filtered short entry = true
Long: Setup state = long AND RSI crosses above RSI signal
Short: Setup state = short AND RSI crosses below RSI signal
Long: RSI < oversold level
Short: RSI > overbought level
Long: RSI > RSI signal
Short: RSI <= RSI signal
Long: Close > session VWAP of typical price
Short: Close <= session VWAP of typical price