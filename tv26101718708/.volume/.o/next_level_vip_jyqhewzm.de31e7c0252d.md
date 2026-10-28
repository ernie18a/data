Calculation: Rolling weighted typical price = sum(typical price × volume) divided by sum(volume), using the current bar and each bar N bars earlier recursively back to the first bar, where N is the lookback
Calculation: Trend direction = the moving average of +1 when close is above the prior bar’s highest high over the timeframe-scaled trend lookback, −1 when close is below the prior bar’s lowest low over that lookback, and 0 otherwise; its averaging lookback is scaled to the chart timeframe
Calculation: Trend confirmation = +1 when trend direction, 3-bar close change, and 2-bar EMA change are all positive; −1 when all are negative; otherwise 0
Calculation: Whale volume = volume above average volume × whale threshold × ATR divided by its 20-bar average, adjusted by chart timeframe
Calculation: Sustained whale volume = whale volume has remained true within the timeframe-scaled sustain lookback
Calculation: Upward whale activity = whale volume and sustained whale volume and close above rolling weighted typical price and close above prior close and volume above its 5-bar average × threshold
Calculation: Downward whale activity = whale volume and sustained whale volume and close below rolling weighted typical price and close below prior close and volume above its 5-bar average × threshold
Calculation: Pullback depth = (highest high − lowest low over pullback lookback) divided by ATR
Calculation: Signal score = weighted sum of trend strength, volume spike, whale volume, non-extreme RSI, trend direction agreeing with close relative to EMA, directional whale activity, and sustained whale volume
Calculation: Volatility filter = ATR below its 20-bar average × upper bound and above its 20-bar average × lower bound and 1-bar ATR change below its 20-bar average × bound
Calculation: Long target = highest high of current and prior 2 bars + ATR × target multiple
Calculation: Short target = lowest low of current and prior 2 bars − ATR × target multiple
Calculation: Trailing distance = ATR × stop multiple × max(1, ATR / 20-bar ATR average)
Long: close crosses above EMA OR upward whale activity AND close > prior-bar EMA
Long: lowest low over pullback lookback < EMA AND close > EMA AND RSI within pullback bounds AND pullback depth > pullback threshold AND close > rolling weighted typical price AND volume > average volume AND trend confirmation > 0
Long: not in a long position AND (close crosses above EMA OR upward whale activity AND close > prior-bar EMA OR pullback conditions) AND signal score ≥ timeframe-dependent threshold AND volatility filter
Short: close crosses below EMA OR downward whale activity AND close < prior-bar EMA
Short: highest high over pullback lookback > EMA AND close < EMA AND RSI within pullback bounds AND pullback depth > pullback threshold AND close < rolling weighted typical price AND volume > average volume AND trend confirmation < 0
Short: not in a short position AND (close crosses below EMA OR downward whale activity AND close < prior-bar EMA OR pullback conditions) AND signal score ≥ timeframe-dependent threshold AND volatility filter
Exit: long, close < entry price × (1 − maximum loss fraction) OR close ≥ long target OR close ≤ long trailing stop OR trend confirmation < 0
Exit: short, close > entry price × (1 + maximum loss fraction) OR close ≤ short target OR close ≥ short trailing stop OR trend confirmation > 0