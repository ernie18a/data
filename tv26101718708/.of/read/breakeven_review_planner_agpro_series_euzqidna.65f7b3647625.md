Calculation: Prior structure high/low = highest high / lowest low over the lookback, excluding the current bar
Calculation: Candle body ratio = absolute(close − open) / (high − low)
Calculation: Bullish / bearish close location = (close − low) / (high − low) / (high − close) / (high − low)
Calculation: Long / short invalidation shelf = latest confirmed swing low minus / swing high plus an ATR buffer; if unavailable, lowest low / highest high over the structure lookback minus / plus the buffer
Calculation: Risk distance = entry close minus long invalidation shelf / short invalidation shelf minus entry close
Long: no active context or prior context invalidated, stale, at its invalidation shelf, or opposed by a bearish activation; close > prior structure high + ATR × minimum impulse × sensitivity factor; close > open; candle body ratio ≥ sensitivity-dependent minimum; bullish close location ≥ sensitivity-dependent minimum; sensitivity-dependent bullish trend filter holds; risk distance > max(ATR × minimum risk, 10 minimum price increments)
Short: no active context or prior context invalidated, stale, at its invalidation shelf, or opposed by a bullish activation; close < prior structure low − ATR × minimum impulse × sensitivity factor; close < open; candle body ratio ≥ sensitivity-dependent minimum; bearish close location ≥ sensitivity-dependent minimum; sensitivity-dependent bearish trend filter holds; risk distance > max(ATR × minimum risk, 10 minimum price increments)
Exit: Long, low ≤ long invalidation shelf
Exit: Short, high ≥ short invalidation shelf