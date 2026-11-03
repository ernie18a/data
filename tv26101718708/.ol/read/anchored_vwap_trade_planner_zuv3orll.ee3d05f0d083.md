Calculation: Anchored VWAP = cumulative typical price × volume divided by cumulative volume, reset at the selected session, week, manual timestamp, or most recent pivot high/low anchor; typical price = (high + low + close) / 3
Calculation: Z-score = (close − Anchored VWAP) / rolling standard deviation of (close − Anchored VWAP)
Calculation: Long stop = signal-bar Anchored VWAP + (entry price − Anchored VWAP) × stop fraction − signal-bar ATR × buffer multiplier
Calculation: Short stop = signal-bar Anchored VWAP + (entry price − Anchored VWAP) × stop fraction + signal-bar ATR × buffer multiplier
Calculation: Profit target n = signal-bar Anchored VWAP + (entry price − Anchored VWAP) × target n multiplier; target multipliers increase from target 1 to target 2 to target 3
Calculation: Long trailing stop = highest high since trailing starts − ATR × trail multiplier; ratchet upward only
Calculation: Short trailing stop = lowest low since trailing starts + ATR × trail multiplier; ratchet downward only
Long: close > Anchored VWAP AND Z-score >= positive threshold AND bars since previous signal >= cooldown
Short: close < Anchored VWAP AND Z-score <= negative threshold AND bars since previous signal >= cooldown
Exit: long, high >= profit target 1 OR low <= long stop
Exit: long, high >= profit target 2 OR low <= long stop
Exit: long, high >= profit target 3 OR (profit target 2 has been reached AND low <= long trailing stop) OR low <= long stop
Exit: short, low <= profit target 1 OR high >= short stop
Exit: short, low <= profit target 2 OR high >= short stop
Exit: short, low <= profit target 3 OR (profit target 2 has been reached AND high >= short trailing stop) OR high >= short stop