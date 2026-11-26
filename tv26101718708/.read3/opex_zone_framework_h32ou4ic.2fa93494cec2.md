Long: on chart bars, close(T1, bar still forming) >= gamma-flip parameter AND close(T1, bar still forming) < pin parameter
Long: on chart bars, close(T1, bar still forming) >= pin parameter
Long: on chart bars, close(T1, last completed bar) crosses above gamma-flip parameter
Long: on chart bars, close(T1, last completed bar) crosses above pin parameter
Short: on chart bars, close(T1, bar still forming) < put-floor parameter
Short: on chart bars, close(T1, last completed bar) crosses below put-floor parameter
Long: current time <= expiration date AND T1 close >= gamma flip level
Long: T1 close crosses above gamma flip level
Long: T1 close crosses above pin strike
Short: current time <= expiration date AND T1 close < put floor
Short: T1 close crosses below put floor
Exit: long, T1 close < gamma flip level