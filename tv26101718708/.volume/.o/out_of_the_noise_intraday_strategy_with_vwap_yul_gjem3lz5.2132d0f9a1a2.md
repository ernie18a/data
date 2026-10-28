Calculation: Average intraday move = mean of the absolute percentage change from each of the last n sessions’ first-bar open to its close at the current session’s matching intraday bar index; include the current session’s still-forming bar when available.
Calculation: Upper bound = max(current session’s first-bar open, previous bar’s close) × (1 + average intraday move).
Calculation: Lower bound = min(current session’s first-bar open, previous bar’s close) × (1 − average intraday move).
Long: close > upper bound AND position is flat or short AND (current bar is not the first session bar OR end-of-session exit is disabled).
Short: close < lower bound AND position is flat or long AND (current bar is not the first session bar OR end-of-session exit is disabled).
Exit: short, close > min(VWAP, lower bound).
Exit: long, close < max(VWAP, upper bound).
Exit: long or short, current bar is the last session bar AND end-of-session exit is enabled.