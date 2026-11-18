Calculation: pivot = (T1 high + T1 low + T1 close) / 3, using the last completed T1 bar
Calculation: RANGE = T1 high - T1 low, using the last completed T1 bar
Calculation: LEVELS = {pivot, 2 * pivot - T1 low, pivot + RANGE, T1 high + 2 * (pivot - T1 low) + k * RANGE for k in {0, 1, 2}, 2 * pivot - T1 high, pivot - RANGE, T1 low - 2 * (T1 high - pivot) - k * RANGE for k in {0, 1, 2}}
Calculation: VWAP = sum((high + low + close) / 3 * volume) / sum(volume), both summed over bars since the last VWAP reset through the current bar
Long: position side is flat AND time-of-day >= session start AND time-of-day < session end AND low < VWAP AND close > VWAP AND exists L in LEVELS: low < L AND close > L
Short: position side is flat AND time-of-day >= session start AND time-of-day < session end AND high > VWAP AND close < VWAP AND exists L in LEVELS: high > L AND close < L
Exit: Long, close[1] < VWAP[1] AND close < VWAP
Exit: Short, close[1] > VWAP[1] AND close > VWAP