Calculation: Confirmed swing high or low = a high or low at a bar that is a pivot using equal numbers of preceding and following chart bars; it becomes available after the following bars complete. Retain the latest confirmed high and low separately. A close crossing above the retained high clears that high; a close crossing below the retained low clears that low. Retain each pivot's bar index after its price is cleared. Evaluate crosses using the current and previous bar's retained level.
Calculation: Active order blocks = on a close crossing above the retained swing high, create a bullish block from the high and low of the latest confirmed swing-low bar; inspect that bar and successive bars up to a configurable search limit and select the first bearish candle whose low is below the initial block low multiplied by a configurable factor above one, if found. On a close crossing below the retained swing low, create a bearish block from the high and low of the latest confirmed swing-high bar; similarly select the first bullish candle whose high is above the initial block high multiplied by a configurable factor below one, if found. Create a block only if its pivot bar exists and its age is within a configurable limit. Keep at most a configurable number of blocks across both directions, removing the oldest on overflow. After creation and pruning, remove bullish blocks when close is below their bottom and bearish blocks when close is above their top; evaluate rejection on the remaining blocks.
Calculation: Bias score = the count of true conditions among close > open, shorter EMA of close > longer EMA of close, close > session VWAP, and close > a third EMA of close whose lookback is longer than both other EMAs.
Calculation: Signal cooldown = bars elapsed since the most recent buy or sell signal, initialized as though a signal occurred at bar index zero. Evaluate both signals against the same prior cooldown, then reset it if either occurs.
Long: close >= open
Short: close < open
Long: shorter EMA of close >= longer EMA of close
Short: shorter EMA of close < longer EMA of close
Long: close > session VWAP
Short: close <= session VWAP
Long: RSI <= oversold threshold
Short: RSI >= overbought threshold
Long: bias score >= 3
Short: bias score <= 1
Long: close crosses above the retained confirmed swing high
Short: close crosses below the retained confirmed swing low
Long: low > high two chart bars earlier
Short: high < low two chart bars earlier
Long: signal cooldown > configurable cooldown length AND ((RSI crosses above oversold threshold AND (shorter EMA of close > longer EMA of close OR bias score >= 2)) OR (low <= top of any active bullish order block AND close >= its bottom AND close > open AND shorter EMA of close > longer EMA of close))
Short: signal cooldown > configurable cooldown length AND ((RSI crosses below overbought threshold AND (shorter EMA of close <= longer EMA of close OR bias score <= 2)) OR (high >= bottom of any active bearish order block AND close <= its top AND close < open AND shorter EMA of close <= longer EMA of close))