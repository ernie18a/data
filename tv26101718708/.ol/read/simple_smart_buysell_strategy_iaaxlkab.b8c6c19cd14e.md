Long: close > VWAP AND short-lookback EMA > long-lookback EMA AND low <= short-lookback EMA AND close > previous bar high
Short: close < VWAP AND short-lookback EMA < long-lookback EMA AND high >= short-lookback EMA AND close < previous bar low
Exit: Long, low <= previous bar close - previous bar ATR OR high >= previous bar close + 2 * previous bar ATR
Exit: Short, high >= previous bar close + previous bar ATR OR low <= previous bar close - 2 * previous bar ATR