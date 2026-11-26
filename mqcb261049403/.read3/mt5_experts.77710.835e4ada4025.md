Calculation: position notional = position volume × current position price × tick value ÷ tick size
Calculation: total managed notional = sum of position notional for managed open positions
Calculation: peak equity = highest equity recorded since tracking began
Calculation: highest daily balance = highest account balance recorded at a daily reset
Calculation: account-currency risk per price unit = position volume × tick value ÷ tick size
Exit: long, managed position AND current equity < equity at latest daily reset − initial balance × daily-loss percentage ÷ 100
Exit: short, managed position AND current equity < equity at latest daily reset − initial balance × daily-loss percentage ÷ 100
Exit: long, managed position AND current equity < selected maximum-loss reference (initial balance, peak equity, or highest daily balance) − initial balance × maximum-loss percentage ÷ 100
Exit: short, managed position AND current equity < selected maximum-loss reference (initial balance, peak equity, or highest daily balance) − initial balance × maximum-loss percentage ÷ 100
Exit: long, managed position AND daily-loss limit was breached since the latest reset
Exit: short, managed position AND daily-loss limit was breached since the latest reset
Exit: long, managed position AND position volume > per-position lot cap
Exit: short, managed position AND position volume > per-position lot cap
Exit: long, managed position AND position notional > per-position notional cap
Exit: short, managed position AND position notional > per-position notional cap
Exit: long, managed position AND total managed notional > total notional cap AND position is the newest remaining managed position
Exit: short, managed position AND total managed notional > total notional cap AND position is the newest remaining managed position
Exit: long, managed position AND no stop loss AND time since position open ≥ stop grace period
Exit: short, managed position AND no stop loss AND time since position open ≥ stop grace period
Exit: long, managed position AND stop loss < entry price AND (entry price − stop loss) × account-currency risk per price unit > per-position risk cap AND current long exit price ≤ entry price − per-position risk cap ÷ account-currency risk per price unit
Exit: short, managed position AND stop loss > entry price AND (stop loss − entry price) × account-currency risk per price unit > per-position risk cap AND current short exit price ≥ entry price + per-position risk cap ÷ account-currency risk per price unit
Exit: long, managed position AND server time is before the trading-window start or at/after its end
Exit: short, managed position AND server time is before the trading-window start or at/after its end
Exit: long, managed position AND it is Friday AND server time is at/after the Friday close time
Exit: short, managed position AND it is Friday AND server time is at/after the Friday close time
Exit: long, managed position AND a high-impact calendar release for a watched currency is within the configured before-or-after news window
Exit: short, managed position AND a high-impact calendar release for a watched currency is within the configured before-or-after news window