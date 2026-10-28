Long: close > VWAP AND shorter-lookback EMA(close) > longer-lookback EMA(close) AND low <= shorter-lookback EMA(close) AND close > previous bar high
Short: close < VWAP AND shorter-lookback EMA(close) < longer-lookback EMA(close) AND high >= shorter-lookback EMA(close) AND close < previous bar low
Exit: long, low <= close - ATR OR high >= close + 2 × ATR
Exit: short, high >= close + ATR OR low <= close - 2 × ATR