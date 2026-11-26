Long: On chart bars using the still-forming T1 bar, flat AND close > open(T1) AND high(T1) - open(T1) > open(T1) - low(T1)
Short: On chart bars using the still-forming T1 bar, flat AND close < open(T1) AND high(T1) - open(T1) < open(T1) - low(T1)
Exit: long, close - entry price >= first profit threshold AND first profit threshold > 0
Exit: long, close - entry price >= second profit threshold AND second profit threshold > 0 AND first profit exit has occurred
Exit: long, close - entry price >= third profit threshold AND third profit threshold > 0 AND second profit exit has occurred
Exit: short, entry price - close >= first profit threshold AND first profit threshold > 0
Exit: short, entry price - close >= second profit threshold AND second profit threshold > 0 AND first profit exit has occurred
Exit: short, entry price - close >= third profit threshold AND third profit threshold > 0 AND second profit exit has occurred
Exit: long, hour(datetime) >= closing-hour parameter
Exit: short, hour(datetime) >= closing-hour parameter