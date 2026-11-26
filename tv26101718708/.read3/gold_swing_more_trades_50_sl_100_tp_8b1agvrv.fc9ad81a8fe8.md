Calculation: short EMA = EMA(close, shorter lookback)
Calculation: long EMA = EMA(close, longer lookback)
Calculation: RSI = RSI(close, lookback)
Calculation: VWAP = VWAP(hlc3)
Long: long entries enabled AND (session filter disabled OR datetime is within configured session) AND (no prior entry OR bars since prior entry > cooldown period) AND position side is flat or short AND close > VWAP AND short EMA > long EMA AND short EMA > short EMA[2] AND low <= short EMA AND close > short EMA AND close > open AND RSI >= long-entry threshold
Short: short entries enabled AND (session filter disabled OR datetime is within configured session) AND (no prior entry OR bars since prior entry > cooldown period) AND position side is flat or long AND close < VWAP AND short EMA < long EMA AND short EMA < short EMA[2] AND high >= short EMA AND close < short EMA AND close < open AND RSI <= short-entry threshold
Exit: long, low <= entry price - (stop-distance parameter × pip-size parameter) OR high >= entry price + (take-profit-distance parameter × pip-size parameter)
Exit: short, high >= entry price + (stop-distance parameter × pip-size parameter) OR low <= entry price - (take-profit-distance parameter × pip-size parameter)