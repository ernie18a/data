Calculation: One-week average volume = average volume of approximately one trading week's prior chart bars, excluding the current bar
Calculation: Surge hit count = number of bars in the rolling window where volume is at least the selected tier multiple of the one-week average volume
Calculation: Up surge count = number of surge-hit bars in the rolling window where close > open; down surge count = number where close < open
Calculation: Bias score = price vote + surge vote, where price vote is 1 if current close > close at the start of the rolling window, -1 if lower, otherwise 0; surge vote is 1 if up surge count > down surge count, -1 if lower, otherwise 0
Long: Surge hit count >= minimum required hits AND bias score > 0
Short: Surge hit count >= minimum required hits AND bias score < 0