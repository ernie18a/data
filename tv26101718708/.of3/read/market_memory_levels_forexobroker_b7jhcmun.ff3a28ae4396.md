Calculation: T1 levels = high, low, and close of the last completed T1 bar, taken on chart bars; T1 is shorter than T2
Calculation: T2 levels = high and low of the last completed T2 bar, taken on chart bars
Calculation: Within proximity(level) = abs(close - level) < ATR(ATR lookback) * proximity multiplier
Calculation: Round-number level = floor(close / round-number spacing) * round-number spacing + offset * round-number spacing, where offset ranges from negative round-level count through positive round-level count
Calculation: Support bounce = ((previous-day levels enabled AND Within proximity(T1 low)) OR (previous-week levels enabled AND Within proximity(T2 low)) OR (previous-day levels enabled AND close > T1 close AND Within proximity(T1 close)) OR (round-number levels enabled AND a round-number level at or below close is within proximity)) AND close > open AND close - open > (high - low) * minimum body fraction
Calculation: Resistance rejection = ((previous-day levels enabled AND Within proximity(T1 high)) OR (previous-week levels enabled AND Within proximity(T2 high)) OR (previous-day levels enabled AND close < T1 close AND Within proximity(T1 close)) OR (round-number levels enabled AND a round-number level at or above close is within proximity)) AND NOT (close > open AND close - open > (high - low) * minimum body fraction) AND open - close > (high - low) * minimum body fraction
Long: close > T1 close
Short: close < T1 close
Long: Support bounce
Short: Resistance rejection
Long: Support bounce AND volume > SMA(volume, volume lookback) * volume multiplier AND signal cooldown bars have elapsed since the last long or short signal AND chart bar is confirmed
Short: Resistance rejection AND volume > SMA(volume, volume lookback) * volume multiplier AND signal cooldown bars have elapsed since the last long or short signal AND chart bar is confirmed