Calculation: Pre-London range high/low = highest high / lowest low during the pre-London session, locked at London open
Calculation: Confirmed pivot high/low = a bar high/low greater than / less than the highs/lows of an equal number of bars on both sides; use the latest confirmed pivot
Calculation: Higher-timeframe EMA = EMA of close on a higher timeframe, using the last completed higher-timeframe bar
Calculation: Long stop = the lower of the latest pivot low minus a buffer and entry price minus ATR times a multiplier
Calculation: Short stop = the higher of the latest pivot high plus a buffer and entry price plus ATR times a multiplier
Calculation: Long target = entry price plus (entry price minus long stop) times the reward-to-risk ratio
Calculation: Short target = entry price minus (short stop minus entry price) times the reward-to-risk ratio
Long: bar time is within the London session AND session trade count is below its limit AND position is flat AND pre-London range size meets its minimum AND (close > pre-London range high AND previous close <= pre-London range high OR close > latest confirmed pivot high AND previous close <= latest confirmed pivot high) AND RSI >= long threshold AND volume > its moving average times a multiplier AND close > higher-timeframe EMA
Short: bar time is within the London session AND session trade count is below its limit AND position is flat AND pre-London range size meets its minimum AND (close < pre-London range low AND previous close >= pre-London range low OR close < latest confirmed pivot low AND previous close >= latest confirmed pivot low) AND RSI <= short threshold AND volume > its moving average times a multiplier AND close < higher-timeframe EMA
Exit: long, low <= long stop OR high >= long target OR the London session has ended
Exit: short, high >= short stop OR low <= short target OR the London session has ended