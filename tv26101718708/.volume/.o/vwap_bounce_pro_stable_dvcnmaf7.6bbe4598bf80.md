Calculation: Typical price = (high + low + close) / 3
Calculation: Daily VWAP = cumulative (typical price × volume) / cumulative volume, reset at each New York calendar day; current bar value and previous completed bar value
Calculation: Weekly VWAP = cumulative (typical price × volume) / cumulative volume, reset each New York Monday; current bar value
Calculation: NY-session VWAP = cumulative (typical price × volume) / cumulative volume during 09:30–16:00 New York time, reset at session start; current bar value and previous completed bar value, valid only during the session
Calculation: Maximum stop distance = maximum loss per trade / (contracts × point value)
Calculation: Long stop = max(low − ATR × stop buffer, entry price − maximum stop distance)
Calculation: Long target = entry price + (entry price − long stop) × reward-to-risk ratio
Calculation: Short stop = min(high + ATR × stop buffer, entry price + maximum stop distance)
Calculation: Short target = entry price − (short stop − entry price) × reward-to-risk ratio
Long: (NY session if the NY-session filter is enabled) AND current close > weekly VWAP AND ((previous low ≤ previous daily VWAP AND current close > current daily VWAP) OR (previous low ≤ previous NY-session VWAP AND current close > current NY-session VWAP)) AND current weekday's long trading is enabled AND New York time < entry cutoff AND no active trade AND bars since most recent signal ≥ cooldown AND trades opened today < daily trade limit
Short: (NY session if the NY-session filter is enabled) AND current close < weekly VWAP AND ((previous high ≥ previous daily VWAP AND current close < current daily VWAP) OR (previous high ≥ previous NY-session VWAP AND current close < current NY-session VWAP)) AND current weekday's short trading is enabled AND New York time < entry cutoff AND no active trade AND bars since most recent signal ≥ cooldown AND trades opened today < daily trade limit
Exit: long, low ≤ long stop OR high ≥ long target OR (NY-session filter enabled AND current bar outside NY session AND previous bar inside NY session)
Exit: short, high ≥ short stop OR low ≤ short target OR (NY-session filter enabled AND current bar outside NY session AND previous bar inside NY session)