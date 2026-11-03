Long: close > EMA AND previous close > previous EMA AND MACD < 0 AND MACD crosses above its signal line AND flat AND datetime is within the configured trading window
Short: close < EMA AND previous close < previous EMA AND MACD > 0 AND MACD crosses below its signal line AND flat AND datetime is within the configured trading window
Calculation: Long stop = lowest low over the long stop lookback, measured through the bar before entry, minus stop buffer; hold this level fixed for the position
Calculation: Long target = entry price + (entry price − lowest low over the long stop lookback through the bar before entry) × long profit factor + stop buffer
Calculation: Short stop = highest high over the short stop lookback, measured through the bar before entry, plus stop buffer; hold this level fixed for the position
Calculation: Short target = entry price − (highest high over the short stop lookback through the bar before entry − entry price) × short profit factor − stop buffer
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target