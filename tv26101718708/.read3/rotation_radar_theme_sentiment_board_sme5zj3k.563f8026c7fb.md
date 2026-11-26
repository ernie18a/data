Calculation: calendar-year return = close / (close at the first T1 bar of the calendar year, or current close if no such boundary exists in the available history) - 1, calculated on T1 bars and sampled on chart bars; use the current T1 bar while it is forming and the last completed T1 bar historically
Calculation: positive-return count = count of values above P0 among the four T1 close returns and calendar-year return; missing values count as 0
Long: close / close[shortest lookback] - 1 >= P0 on T1 bars, sampled on chart bars; use the current T1 bar while forming and the last completed T1 bar historically
Short: close / close[shortest lookback] - 1 < P0 on T1 bars, sampled on chart bars; use the current T1 bar while forming and the last completed T1 bar historically
Long: close / close[next longer lookback] - 1 >= P0 on T1 bars, sampled on chart bars; use the current T1 bar while forming and the last completed T1 bar historically
Short: close / close[next longer lookback] - 1 < P0 on T1 bars, sampled on chart bars; use the current T1 bar while forming and the last completed T1 bar historically
Long: close / close[second-longest lookback] - 1 >= P0 on T1 bars, sampled on chart bars; use the current T1 bar while forming and the last completed T1 bar historically
Short: close / close[second-longest lookback] - 1 < P0 on T1 bars, sampled on chart bars; use the current T1 bar while forming and the last completed T1 bar historically
Long: close / close[longest lookback] - 1 >= P0 on T1 bars, sampled on chart bars; use the current T1 bar while forming and the last completed T1 bar historically
Short: close / close[longest lookback] - 1 < P0 on T1 bars, sampled on chart bars; use the current T1 bar while forming and the last completed T1 bar historically
Long: calendar-year return >= P0
Short: calendar-year return < P0
Long: positive-return count >= Pbull
Short: positive-return count <= Pbear