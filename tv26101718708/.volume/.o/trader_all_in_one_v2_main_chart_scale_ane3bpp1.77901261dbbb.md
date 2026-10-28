Calculation: Confirmed swing high/low = a pivot high/low that is only usable after the configured number of right-hand chart bars confirms it; retain the latest confirmed high and low and whether each has been broken or swept.
Calculation: Bullish/bearish order block = the nearest opposite-color candle between the broken confirmed swing and the break bar, within the configured search lookback, whose far edge has not been invalidated by intervening closes.
Calculation: Completed session range = the high and low of chart bars whose opening times fall within each configured Asia, London, or New York session; use the most recently completed range, and do not check sweeps during that session.
Long: shorter-lookback MA > longer-lookback MA
Short: shorter-lookback MA < longer-lookback MA
Long: Supertrend direction is bullish
Short: Supertrend direction is bearish
Long: MACD > MACD signal
Short: MACD < MACD signal
Long: confirmed swing high > previous confirmed swing high OR confirmed swing low > previous confirmed swing low
Short: confirmed swing high < previous confirmed swing high OR confirmed swing low < previous confirmed swing low
Long: confirmed bar close > latest unbroken confirmed swing high
Short: confirmed bar close < latest unbroken confirmed swing low
Long: confirmed bar low < latest unbroken, unswept confirmed swing low AND confirmed bar close > that swing low
Short: confirmed bar high > latest unbroken, unswept confirmed swing high AND confirmed bar close < that swing high
Long: confirmed bar low > high two chart bars earlier AND the gap is at least the configured minimum fraction of ATR
Short: confirmed bar high < low two chart bars earlier AND the gap is at least the configured minimum fraction of ATR
Long: confirmed bar close > latest unbroken confirmed swing high AND a valid bullish order block exists
Short: confirmed bar close < latest unbroken confirmed swing low AND a valid bearish order block exists
Long: outside the session AND that session's low has not already been swept this cycle AND bar low < its last completed range low AND bar close > that range low AND bar close < that range high
Short: outside the session AND that session's high has not already been swept this cycle AND bar high > its last completed range high AND bar close < that range high AND bar close > that range low