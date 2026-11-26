Calculation: log return(x) = ln(x / x[1])
Calculation: correlation = Correlation(log return(close), log return(silver close), beta length)
Calculation: beta = Beta(log return(silver close), log return(close), beta length)
Calculation: correlation valid = correlation >= correlation enter threshold OR (correlation valid[1] AND correlation >= correlation exit threshold)
Calculation: relationship valid = correlation valid AND beta >= minimum beta AND beta <= maximum beta
Calculation: z-score(x, n) = (x - SMA(x, n)) / StDev(x, n)
Calculation: pair score = (1 - ratio weight) * z-score(ln(silver close / silver close[move length]) - beta * ln(close / close[move length]), z lookback) - ratio weight * z-score(ln(close / silver close), ratio lookback)
Calculation: long turn count = IF(relationship valid AND pair score >= entry z AND pair score < pair score[1], long turn count[1] + 1, 0)
Calculation: short turn count = IF(relationship valid AND pair score <= -entry z AND pair score > pair score[1], short turn count[1] + 1, 0)
Long: long turn count >= turn bars AND position side is flat AND bars since last exit >= cooldown bars
Short: short turn count >= turn bars AND position side is flat AND bars since last exit >= cooldown bars
Exit: long, pair score <= exit z
Exit: long, pair score >= entry score + adverse z stop
Exit: long, leverage * ((entry beta * (low / entry price - 1) - (silver high / entry silver price - 1)) / (entry beta + 1)) <= -1
Exit: short, pair score >= -exit z
Exit: short, pair score <= entry score - adverse z stop
Exit: short, leverage * ((silver low / entry silver price - 1 - entry beta * (high / entry price - 1)) / (entry beta + 1)) <= -1
Exit: long or short, relationship valid is false OR bars since entry >= max hold bars