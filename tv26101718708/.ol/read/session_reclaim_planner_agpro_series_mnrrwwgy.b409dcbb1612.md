Calculation: ATR = average true range
Calculation: Session high/low = highest high and lowest low during the completed reference session
Calculation: Risk edge = beyond the more extreme of the rail and sweep extreme by a pocket-width and risk buffer, both measured in ATR; below for a low reclaim and above for a high reclaim
Calculation: Target price = selected opposite session rail, R-multiple target from the reclaimed rail using risk distance, or hybrid target bounded by the halfway point of the session range and the R-multiple target
Long: Intraday monitor session AND completed session rails are available AND no active plan or reclaim watch AND low rail is enabled AND (session low - low) / ATR >= minimum rail-loss threshold AND close >= session low + minimum reclaim distance in ATR
Short: Intraday monitor session AND completed session rails are available AND no active plan or reclaim watch AND high rail is enabled AND (high - session high) / ATR >= minimum rail-loss threshold AND close <= session high - minimum reclaim distance in ATR
Exit: Long, close <= risk edge OR high >= target price
Exit: Short, close >= risk edge OR low <= target price