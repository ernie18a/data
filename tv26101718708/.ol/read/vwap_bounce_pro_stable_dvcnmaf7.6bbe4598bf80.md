Calculation: Typical price = (high + low + close) / 3
Calculation: Daily VWAP = cumulative typical price × volume / cumulative volume, reset each New York calendar day
Calculation: Weekly VWAP = cumulative typical price × volume / cumulative volume, reset each New York Monday
Calculation: NY session VWAP = cumulative typical price × volume / cumulative volume during 09:30–16:00 New York time, reset at session start
Calculation: Maximum stop distance = maximum loss per trade / (contracts × point value)
Calculation: Long stop = max(signal-bar low − ATR × stop buffer, entry price − maximum stop distance)
Calculation: Long target = entry price + (entry price − long stop) × reward-to-risk ratio
Calculation: Short stop = min(signal-bar high + ATR × stop buffer, entry price + maximum stop distance)
Calculation: Short target = entry price − (short stop − entry price) × reward-to-risk ratio
Long: session filter disabled OR current bar is in the 09:30–16:00 New York session; close > weekly VWAP; before the configured New York entry cutoff; current New York weekday is enabled for longs; (prior bar low <= prior Daily VWAP AND current close > Daily VWAP OR prior bar low <= prior NY session VWAP AND current close > NY session VWAP); fewer than the configured maximum trades have occurred this New York day; bars since the last signal >= configured cooldown; no trade is active
Short: session filter disabled OR current bar is in the 09:30–16:00 New York session; close < weekly VWAP; before the configured New York entry cutoff; current New York weekday is enabled for shorts; (prior bar high >= prior Daily VWAP AND current close < Daily VWAP OR prior bar high >= prior NY session VWAP AND current close < NY session VWAP); fewer than the configured maximum trades have occurred this New York day; bars since the last signal >= configured cooldown; no trade is active; no long signal
Exit: long, low <= long stop OR high >= long target OR the NY session has just ended while the session filter is enabled
Exit: short, high >= short stop OR low <= short target OR the NY session has just ended while the session filter is enabled