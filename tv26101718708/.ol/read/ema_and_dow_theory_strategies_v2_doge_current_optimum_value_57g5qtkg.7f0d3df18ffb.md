Calculation: EMA = exponential moving average of close
Calculation: RSI = relative strength index of close
Calculation: ATR = average true range
Calculation: Swing trend = retain the latest confirmed swing high and low, where a swing high/low is the high/low at the center of a lookback window that is the highest/lowest across that window; set trend up when close > latest swing high and down when close < latest swing low, otherwise retain trend
Calculation: Long PnL (%) = (close - entry price) / entry price × 100
Calculation: Short PnL (%) = (entry price - close) / entry price × 100
Long: (symbol fast EMA > symbol slow EMA OR (symbol fast EMA = symbol slow EMA AND index fast EMA < index slow EMA)) AND swing trend is up AND RSI < overbought level AND long lockout is inactive
Short: symbol fast EMA < symbol slow EMA AND swing trend is down AND RSI > oversold level AND short lockout is inactive
Exit: Long, swing trend is down
Exit: Short, swing trend is up
Exit: Long, Long PnL (%) < stop-loss threshold AND NOT (symbol fast EMA < symbol slow EMA)
Exit: Short, Short PnL (%) < stop-loss threshold AND NOT (symbol fast EMA > symbol slow EMA OR (symbol fast EMA = symbol slow EMA AND index fast EMA < index slow EMA))
Exit: Long, previous bar had symbol fast EMA >= symbol slow EMA and index fast EMA >= index slow EMA AND current bar does not AND Long PnL (%) > 0.1 AND NOT (symbol fast EMA < symbol slow EMA) AND no prior weakening-trend scale-out in this position
Exit: Short, previous bar had symbol fast EMA < symbol slow EMA and index fast EMA < index slow EMA AND current bar does not AND Short PnL (%) > 0.1 AND NOT (symbol fast EMA > symbol slow EMA OR (symbol fast EMA = symbol slow EMA AND index fast EMA < index slow EMA)) AND no prior weakening-trend scale-out in this position
Exit: Long, take-profit is enabled AND high > entry price + ATR(50) × take-profit factor
Exit: Long, take-profit is enabled AND high > entry price + 2 × ATR(50) × take-profit factor
Exit: Long, take-profit is enabled AND high > entry price + 3 × ATR(50) × take-profit factor
Exit: Short, take-profit is enabled AND low < entry price - ATR(50) × take-profit factor
Exit: Short, take-profit is enabled AND low < entry price - 2 × ATR(50) × take-profit factor
Exit: Short, take-profit is enabled AND low < entry price - 3 × ATR(50) × take-profit factor