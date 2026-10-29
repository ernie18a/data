Calculation: Average move = mean of the absolute percentage change from each recent session’s first-bar open to the close at the same intraday bar offset, including the current session when available
Calculation: Upper bound = max(current session’s first-bar open, previous bar’s close) × (1 + average move)
Calculation: Lower bound = min(current session’s first-bar open, previous bar’s close) × (1 − average move)
Long: close > upper bound AND (current bar is not the first bar of the session OR end-of-session exit is disabled)
Short: close < lower bound AND (current bar is not the first bar of the session OR end-of-session exit is disabled)
Exit: long, close < max(VWAP, upper bound)
Exit: short, close > min(VWAP, lower bound)
Exit: long, current bar is the last bar of the session AND end-of-session exit is enabled
Exit: short, current bar is the last bar of the session AND end-of-session exit is enabled