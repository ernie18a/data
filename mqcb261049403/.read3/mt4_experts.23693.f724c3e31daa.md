Long: matching strategy position count = 0 on a new chart bar
Short: matching strategy position count = 0 on a new chart bar
Long: a long position is open AND close <= lowest long entry price - spread - step distance AND NOT (long position count = maximum position count AND close-at-limit is enabled)
Short: a short position is open AND close >= highest short entry price + step distance AND NOT (short position count = maximum position count AND close-at-limit is enabled)
Exit: long, close >= lowest long entry price + take-profit distance
Exit: short, close + spread <= highest short entry price - take-profit distance
Exit: long, close <= highest high since entry - per-position trailing distance AND highest high since entry > entry price + per-position trailing distance
Exit: short, close + spread >= lowest ask since entry + per-position trailing distance AND entry price - lowest ask since entry > per-position trailing distance
Calculation: weighted average entry price = sum(entry price × position size) / sum(position size)
Exit: long, basket trailing is enabled AND close <= highest close since weighted-average long profit first reached basket trailing start - basket trailing distance
Exit: short, basket trailing is enabled AND close + spread >= lowest ask since (weighted average entry price + close + spread) / pip size, rounded to zero decimal places, first reached basket trailing start + basket trailing distance
Calculation: basket profit = sum(open-position profit + swap + commission)
Exit: long, strategy position count > maximum position count AND close-at-limit is enabled
Exit: short, strategy position count > maximum position count AND close-at-limit is enabled
Exit: long, long position count = maximum position count AND close-at-limit is enabled
Exit: short, short position count = maximum position count AND close-at-limit is enabled
Exit: long, basket profit <= -(account balance × hard-stop percentage / 100)
Exit: short, basket profit <= -(account balance × hard-stop percentage / 100)
Exit: long, basket profit <= -(account balance × maximum-loss percentage / 100) AND strategy position count >= minimum basket size
Exit: short, basket profit <= -(account balance × maximum-loss percentage / 100) AND strategy position count >= minimum basket size